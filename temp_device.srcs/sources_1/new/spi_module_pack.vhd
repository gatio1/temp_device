----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/15/2024 11:57:29 PM
-- Design Name: 
-- Module Name: spi_module_pack - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use work.modules_pack.send_data_struct;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
package spi_module_pack is


constant PP_COMMAND: std_logic_vector(0 to 7) := x"02"; -- Program page(set 0)
constant BE_COMMAND: std_logic_vector(0 to 7) := x"D8"; -- Block erase
constant WREN_COMMAND: std_logic_vector(0 to 7) := x"06"; -- Enable writting
constant WRDI_COMMAND: std_logic_vector(0 to 7) := x"04"; -- WRITE disable
constant RDSR_COMMAND: std_logic_vector(0 to 7) := x"05"; -- Read status reg
constant FAST_RD_COMMAND:std_logic_vector(0 to 7) := x"0B"; -- Fast read (can be done at 100MHz)
constant CONFIG_START_ADDR:unsigned(0 to 23) := x"380000"; -- Address of configuration
constant DATA_START_ADDR:unsigned(0 to 23) := x"381000"; -- Address where data starts. -- Move to another file
 
type command is
(NOP, PP, BE, WREN, WRDI, RDSR, FAST_RD); -- uart operations

type action is
(WRITE_ENTRY, READ_ENTRY, DELETE_ALL, GET_ADDR, NO_ACTION); -- Only internal to wrapper. Used for a state machine. Internally this state machine contains state machine with the commands for each operation.

component spi_mem_if
port(
    clk:in std_logic;
    wr_rd_flag:in std_logic;
    init_flash_sw: in std_logic; -- Switch that will reset flash on init
    exp: out std_logic; -- If command is finished but input from spi is expected.
    finish: std_logic; -- When operation is finished (no read)
    -- SPI ports
    CS: out std_logic := '1';
    -- SCLK: out std_logic:= '1';
    SI: out std_logic:='0'
);
end component spi_mem_if;

component spi_read_if
port(
    finish : in std_logic;
    exp : in std_logic; -- always expect 4 bytes
    --num_exp : in natural;
    SO: in std_logic;
    clk: in std_logic; -- 100MHz clock
    
    read_out: out send_data_struct; -- When reading data
    progress: out natural := 0;
    read_ready: out std_logic
    );
end component spi_read_if;
    

end package spi_module_pack;