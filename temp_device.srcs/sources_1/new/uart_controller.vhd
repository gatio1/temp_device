----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/12/2024 10:38:32 PM
-- Design Name: 
-- Module Name: uart_controller - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.modules_pack.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_controller is
Port (
	signal new_data :in std_logic; 
	signal new_data_request :out std_logic := '0';
	signal tx_send_data: in send_data_struct;
	signal clk :in std_logic;
	signal tx :out std_logic;
	signal rx :in std_logic
	);
end uart_controller;

architecture Behavioral of uart_controller is
    
    type command is
    (C_NO, C_OK, C_NEXT, C_REP, C_DATA); -- What kind of command is received?

    type exp_rcv is
    (A_CONFIRM, A_COMMAND, A_STRING);

    type read_state_t is
    (S_BEGIN, S_SIZE, S_STR); -- State of fifo read

	signal ALMOSTEMPTY: std_logic := '0';
	signal ALMOSTFULL: std_logic := '0';
	signal DO: std_logic_vector(8 downto 0) := "000000000";
	signal EMPTY: std_logic := '0';
	signal FULL: std_logic := '0';
	signal RDCOUNT: std_logic_vector(10 downto 0) := "00000000000";
	signal RDERR: std_logic := '0';
	signal WRCOUNT: std_logic_vector(10 downto 0) := "00000000000";
	signal WRERR: std_logic := '0';
	signal DI: std_logic_vector(8 downto 0) := "000000000";
	signal RDCLK: std_logic := '0';
	signal RDEN: std_logic := '0';
	signal RST: std_logic := '0';
	signal WRCLK: std_logic := '0';
	signal WREN: std_logic := '0';

	signal baud_clk : std_logic := '0';

    	signal new_data_request_internal :std_logic := '0';
	signal new_data_internal :std_logic;
	signal send_data : send_data_struct;
    	signal tx_send_data_internal : send_data_struct;
	
	signal rx_byte: std_logic_vector(0 to 7) := "11111111";
	signal new_val: std_logic := '0';
	signal valid: std_logic := '0';


	signal last_fifo_state: std_logic := '0';

	signal b_to_read: natural := 0; -- Number of bytes left in current responce.
	signal processed: std_logic := '0'; -- 1 if last data fetched from fifo is processed.
	signal exp_size: std_logic := '0'; -- Indicates that size of string is expected.
	signal fifo_read_b: std_logic_vector(0 to 7) := "00000000";
	signal read_state: read_state_t := S_BEGIN;
    	signal action: exp_rcv := A_COMMAND;

	signal last_command: command := C_NO;
	signal size_byte : natural range 0 to 4 := 0;

	signal read_new: std_logic := '0'; -- Make this signal to read from flash.
	signal repeat: std_logic := '0';
    
    function decode_command(
        in_char: in std_logic_vector(0 to 7))
        return command is
        variable new_command: command;
    begin
        case in_char is
        when "01010010" => -- 'R'
            new_command := C_REP;
        when "01010011" => -- 'S'
            new_command := C_DATA;
        when "01001011" => -- 'K'
            new_command := C_OK;
        when "01001110" => -- 'N'
            new_command := C_NEXT;
        when others => -- Unrecognised
            new_command := C_NO;
        end case;
        return new_command;
    end;
    

 -- Create instance of fifo. Pass read data to controller and save read data from receive_uart_symbol.
 -- Add reading of fifo that takes command and additional data text.
 -- Add reading of data and sending of reading only after command.
begin
map_fifo:
fifo_init port map(
   ALMOSTEMPTY => ALMOSTEMPTY,
   ALMOSTFULL => ALMOSTFULL,
   DO => DO,
   EMPTY => EMPTY,
   FULL => FULL,
   RDCOUNT => RDCOUNT,
   RDERR => RDERR,
   WRCOUNT => WRCOUNT,
   WRERR => WRERR,
   DI => DI,
   RDCLK => RDCLK,
   RDEN => RDEN,
   RST => RST,
   WRCLK => WRCLK,
   WREN => WREN
   );
   
map_baud_gen:
generate_baud port map(
	clk_in => clk,
	clk_out => baud_clk
);

map_serialize_uart:
serialize_uart_data port map(
    new_data => new_data_internal,
    send_data => send_data,
    clk => clk,
    repeat => repeat,
    tx_uart => tx
    );
    
map_receive_uart_symbol:
receive_uart_symbol port map(
    baud_clock => baud_clk,
    rx => rx,
    byte => rx_byte,
    valid => valid,
    new_val => new_val);
    

rx_to_fifo:
process(clk)
is
variable fifo_read_byte: std_logic_vector(7 downto 0);
variable last_command: command;

begin
    if(clk'event and clk = '1')
    then
	if(valid = '1') -- Assume valid means new value has been received via uart.
        then
		--if(action = A_COMMAND)
		--then
			case (decode_command(rx_byte)) is
				when C_NEXT => -- request next entry from flash
					new_data_request_internal <= '1';			
					action <= A_COMMAND;
				when C_REP => -- Repeat last entry sent
					new_data_internal <= not new_data_internal; -- signal that last sent data is valid.
					action <= A_CONFIRM;
				when C_DATA => -- Expect first 4 bytes to br data size.
					action <= A_STRING;
					if(FULL = '0') -- Add byte to fifo when command is not C_DATA.
					then
						if(WREN = '1')
						then
							WREN <= '0';
						else
							DI(7 downto 0) <= rx_byte;
							DI(8) <= '0';
							WREN <= '1';	
						end if;
					end if;
				when C_NO =>
					new_data_request_internal <= '0';
				when C_OK => 
					action <= A_COMMAND;
					new_data_request_internal <= '0';
				when others =>
					new_data_request_internal <= '0';
			end case;
		--end if;
	else
		new_data_request_internal <= '0';
        end if;

	if(new_data = '1')
	then
		send_data <= tx_send_data;
		tx_send_data_internal <= tx_send_data;
		new_data_internal <= '1';		
	end if;
        
        if(processed = '1')
        then
            if(EMPTY = '0')
            then
                RDEN <= '1';                
            end if;
            if(RDEN = '1' and read_state = S_BEGIN) -- Make it when -- case
            then
                -- RDEN <= '0';
                fifo_read_byte := DO(7 downto 0); -- might need to convert.
                
                last_command := decode_command(fifo_read_byte);
                
                case last_command is
                    when C_NO =>
                        read_state <= S_BEGIN;
                    when C_OK => -- Do nothing 
                        READ_STATE <= S_BEGIN;
		    when C_NEXT => -- request next byte to be read from flash Shouldn't be written in fifo. process in real time.
                        read_new <= '1';
                        READ_STATE <= S_BEGIN;
                    when C_REP => -- Resend last sent item
                        repeat <= '1'; -- Repeat signal to serialize uart.
                        READ_STATE <= S_BEGIN;
		    when C_DATA => -- Expect size of data in bytes and then data as long as the 32 bit size.
                        READ_STATE <= S_SIZE;
                    when others =>
                        READ_STATE <= S_BEGIN;
                end case;
                
                -- process args.
            end if;
        end if;
    end if;
end process rx_to_fifo;
new_data_request <= new_data_request_internal;
end Behavioral;
