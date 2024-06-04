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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spi_mem_if is
  Port (
  clk:in std_logic;
  wr_rd_flag:in std_logic;
  cs_pin:in std_logic;
  read_request: in std_logic:= '1';
  write_request: in std_logic:= '1';
  write_data: in send_data_struct;
  read_out: in send_data_struct;
  init_flash_sw: in std_logic; -- Switch that will reset flash on init
  CS: out std_logic := '1';
  SCLK: out std_logic:= '1';
  SI: out std_logic:='0';
  SO: in std_logic);
end spi_mem_if;
architecture Behavioral of spi_mem_if is
constant PP_COMMAND: std_logic_vector(0 to 7) := x"02";
constant BE_COMMAND: std_logic_vector(0 to 7) := x"D8";
constant WREN_COMMAND: std_logic_vector(0 to 7) := x"06";
constant WRDI_COMMAND: std_logic_vector(0 to 7) := x"04";
constant RDSR_COMMAND: std_logic_vector(0 to 7) := x"05";
constant FAST_RD_COMMAND:std_logic_vector(0 to 7) := x"0B";
constant CONFIG_START_ADDR:unsigned(0 to 23) := x"380000";
constant DATA_START_ADDR:unsigned(0 to 23) := x"381000";

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



begin
read_write:
process(clk)
variable count_ops: natural:= 0;
begin
    if(clk'event and clk='1')
    then
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
    end if;
end process;

end Behavioral;
