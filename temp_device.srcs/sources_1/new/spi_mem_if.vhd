----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/26/2024 11:50:49 AM
-- Design Name: 
-- Module Name: spi_mem_if - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Used to send commands to SPI interface. Has interface to module for spi input and sets a flag for what is expected.
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
use work.spi_module_pack.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spi_mem_if is
  Port (
  -- Add a way to pass PP bytes.
  -- Add in signal for read address.
  addr_in: in std_logic_vector(24 downto 0);
  cur_comm: in command;
  new_command: in std_logic;
  clk:in std_logic;
  wr_rd_flag:in std_logic;
  init_flash_sw: in std_logic; -- Switch that will reset flash on init
  exp: out std_logic; -- If command is finished but input from spi is expected.
  finish: out std_logic := '1'; -- When operation is finished
  -- SPI ports
  CS: out std_logic := '1';
  -- SCLK: out std_logic:= '1';
  SI: out std_logic:='0');
end spi_mem_if;
architecture Behavioral of spi_mem_if is

signal current_p_write: unsigned(0 to 23):= DATA_START_ADDR;
signal current_p_read: unsigned(0 to 23):= DATA_START_ADDR;
signal in_data_latch:  std_logic_vector(0 to 64):= x"00000000";
signal init: std_logic := '1';
signal spi_tx_command:std_logic_vector(0 to 40):= x"0000000000";
signal bits_transmit: natural range 0 to 63 := 0;
signal bytes_receive: natural range 0 to 63 := 0;
signal rx_tx: std_logic := '1'; -- 0 if recieving, 1 if transmitting to flash
signal initing: std_logic := '0';
signal state_flags: std_logic_vector(0 to 7) := x"0000";

signal cur_comm_internal: command;
signal bit_comm: natural := 0;
signal byte_comm: natural := 0;
signal addr: std_logic_vector(24 downto 0);

signal current_byte :std_logic_vector(7 downto 0);

signal reading_bytes :natural := 0; -- Number of bytes left to receive.

signal new_comm: std_logic := '0';
signal new_comm_prev: std_logic := '0';

signal finish_internal: std_logic := '1';



begin
read_write:
process(clk)
variable count_ops: natural:= 0;
begin
    if(clk'event and clk='1')
    then
        if(new_command = '1' and finish_internal = '1')
        then
            cur_comm_internal <= cur_comm;
            finish <= '0';
        end if;
        if(init = '1')
        then
            init <= '0';
            if(init_flash_sw = '1')
            then
                -- Start write enable
                bits_transmit <= 8;
                CS <= '0';
            end if;
        else
        end if;
        if bit_comm /= 0
        then
            bit_comm <= bit_comm - 1;
            SI <= current_byte(bit_comm);
        end if;
        case cur_comm_internal is
            when PP => -- 23:16, 15:8, 7:0(addr)
                if byte_comm = 0 and new_comm /= new_comm_prev
                then 
                    bit_comm <= 7;
                    byte_comm <= 2;
                    current_byte <= PP_COMMAND;
                else
                    if(bit_comm = 0)
                    then
                        byte_comm <= byte_comm - 1;
                        bit_comm <= 7;
                        current_byte <= addr(byte_comm*7-1 downto (byte_comm-1)*7);
                    end if;
                 end if;
            when BE => -- 23:16, 15:8, 7:0(addr)
                if byte_comm = 0 and new_comm /= new_comm_prev
                then 
                    bit_comm <= 7;
                    byte_comm <= 2;
                    current_byte <= BE_COMMAND;
                else
                    if(bit_comm = 0)
                    then
                        byte_comm <= byte_comm - 1;
                        bit_comm <= 7;
                        current_byte <= addr(byte_comm*7-1 downto (byte_comm-1)*7);
                    end if;
                    -- set current_byte
                 end if;
            when WREN => -- No args.
                if byte_comm = 0 and new_comm /= new_comm_prev
                then 
                    bit_comm <= 7;
                    byte_comm <= 0;
                    current_byte <= WREN_COMMAND;
                end if;
            when WRDI => -- No args., 
                if byte_comm = 0 and new_comm /= new_comm_prev
                then 
                    bit_comm <= 7;
                    byte_comm <= 0;
                    current_byte <= WRDI_COMMAND;
                end if;
            when RDSR => -- No args., Read after 1 B
                if byte_comm = 0 and new_comm /= new_comm_prev
                then 
                    bit_comm <= 7;
                    byte_comm <= 0;
                    current_byte <= WRDI_COMMAND;
                    reading_bytes <= 1;
                end if;
            when FAST_RD => -- 23:16, 15:8, 7:0(addr), Dummy(8), READ N bytes until CS(high). 
                if byte_comm = 0 and new_comm /= new_comm_prev
                then 
                    bit_comm <= 7;
                    byte_comm <= 2;
                    current_byte <= BE_COMMAND;
                else
                    if(bit_comm = 0)
                    then
                        byte_comm <= byte_comm - 1;
                        bit_comm <= 7;
                        current_byte <= addr(byte_comm*7-1 downto (byte_comm-1)*7);
                        reading_bytes <= 0; -- Bytes should be passed as argument
                    end if;
                    -- set current_byte
                 end if;
            when NOP =>
                finish <='1';
            when others =>
                finish <= '1';
        end case;
        new_comm_prev <= new_comm;
    end if;
end process;
finish <= finish_internal;
end Behavioral;
