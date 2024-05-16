----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/12/2024 11:49:28 PM
-- Design Name: 
-- Module Name: serialize_uart_data - Behavioral
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
use work.modules_pack.send_uart_symbol;
use work.modules_pack.send_data_struct;
use work.modules_pack.generate_baud;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity serialize_uart_data is
port(
    signal new_data : in std_logic; -- initial value should be 1.
    signal send_data: in send_data_struct;
    signal clk: in std_logic;
    signal tx_uart: out std_logic
    );
end serialize_uart_data;

architecture Behavioral of serialize_uart_data is
signal baud_clk: std_logic := '0';
signal new_byte: std_logic := '0';
signal byte_pointer: natural range 0 to 64 := 0;
signal uart_busy: std_logic;
signal new_data_prev: std_logic := '1';
signal current_data_done: std_logic := '1';
signal uart_state_prev: std_logic := '1';
signal send_data_internal : send_data_struct;

signal send_byte: std_logic_vector(0 to 7) := x"ff";

    function backwards_array(
        in_bits: in std_logic_vector(0 to 7))
        return std_logic_vector is
        variable v_out: std_logic_vector(0 to 7);
    begin
        v_out(7) := in_bits(0);
        v_out(6) := in_bits(1);
        v_out(5) := in_bits(2);
        v_out(4) := in_bits(3);
        v_out(3) := in_bits(4);
        v_out(2) := in_bits(5);
        v_out(1) := in_bits(6);
        v_out(0) := in_bits(7);
        return v_out;
    end;
begin
baud_map:
generate_baud port map(
    clk_in => clk,
    clk_out => baud_clk
);

send_uart_map:
send_uart_symbol port map(
    baud_clock => baud_clk,
    byte => send_byte,
    tx => tx_uart,
    is_set => new_byte,
    is_busy => uart_busy
);

new_uart_byte:
process (clk) is
begin
    if(clk'event and clk = '1')
    then
        if(uart_busy = '0' and uart_state_prev = '1')
        then
            if(byte_pointer < 63)
            then
                if(byte_pointer < 32)
                then
                    send_byte <= backwards_array(std_logic_vector(send_data_internal.timestamp(byte_pointer to byte_pointer + 7 )));
                else
                    send_byte <= backwards_array(std_logic_vector(send_data_internal.temp_data(byte_pointer - 32 to byte_pointer+7-32)));
                end if;
                byte_pointer <= byte_pointer + 8;

                if(current_data_done = '0')
                then
                    new_byte <= not new_byte;
                end if;
            else
                current_data_done <= '1';
            end if;
        end if;
        
        if(new_data = not new_data_prev)
        then
--            if(byte_pointer >= 63) -- assign new byte only if old one is fully transmitted.
--            then
                byte_pointer <= 8;
                send_byte <= backwards_array(send_data.timestamp(0 to 7));
                new_byte <= not new_byte;
                send_data_internal <= send_data;
--            end if;  
            current_data_done <= '0';
        end if;      
        uart_state_prev <= uart_busy;
        new_data_prev <= new_data;
--        new_data_prev <= new_data;
    end if;
end process new_uart_byte;

end Behavioral;
