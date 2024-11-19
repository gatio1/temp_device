----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/13/2024 08:12:40 PM
-- Design Name: 
-- Module Name: test_axi_spi_if - Behavioral
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
use work.spi_module_pack.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_axi_spi_if is
--  Port ( );
end test_axi_spi_if;

architecture Behavioral of test_axi_spi_if is

component axi_spi_if
	port(
    io0 : INOUT STD_LOGIC;
    io1 : INOUT STD_LOGIC;
    io2 : INOUT STD_LOGIC;
    io3 : INOUT STD_LOGIC;

    ss : INOUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    cfgclk : OUT STD_LOGIC;
    cfgmclk : OUT STD_LOGIC;
    eos : OUT STD_LOGIC;
    preq : OUT STD_LOGIC;
    ip2intc_irpt : OUT STD_LOGIC ;
    clk: in std_logic;
    
    new_data: in std_logic;
    new_data_struct: in send_data_struct;
    
    reset_flash_on_init: in std_logic;
    save_current_flash_state: in std_logic;    

    read_request: in std_logic;
    read_ready: out std_logic := '0';
    new_data_read: out send_data_struct
    );
end component axi_spi_if;

    signal io0_t :STD_LOGIC;
    signal io1_t : STD_LOGIC;
    signal io2_t : STD_LOGIC;
    signal io3_t : STD_LOGIC;

    signal ss_t : STD_LOGIC_VECTOR(0 DOWNTO 0);
    signal cfgclk_t : STD_LOGIC;
    signal cfgmclk_t : STD_LOGIC;
    signal eos_t : STD_LOGIC;
    signal preq_t : STD_LOGIC;
    signal ip2intc_irpt_t : STD_LOGIC ;
    signal clk_t: std_logic;
    
    signal new_data_t: std_logic;
    signal new_data_struct_t: send_data_struct;
    
    signal reset_flash_on_init_t: std_logic;
    signal save_current_flash_state_t: std_logic;    

    signal read_request_t: std_logic;
    signal read_ready_t: std_logic := '0';
    signal new_data_read_t: send_data_struct;

    signal clk_period: time := 100ns;

begin

	axi_spi: axi_spi_if port map
	(
	    io0 => io0_t,
	    io1 => io1_t,
	    io2 => io2_t,
	    io3 => io3_t,

	    ss => ss_t,
	    cfgclk => cfgclk_t,
	    cfgmclk => cfgmclk_t,
	    eos => eos_t,
	    preq => preq_t,
	    ip2intc_irpt => ip2intc_irpt_t,
	    clk => clk_t,
	    
	    new_data => new_data_t,
	    new_data_struct => new_data_struct_t,
	    
	    reset_flash_on_init => reset_flash_on_init_t,
	    save_current_flash_state => save_current_flash_state_t,

	    read_request => read_request_t,
	    read_ready => read_ready_t,
	    new_data_read => new_data_read_t
	);

test_proc: process is
begin
	clk_t <= '0';
	wait for clk_period/2;
	clk_t <= '1';
	wait for clk_period/2;
end process;

save_current_flash_state_t <= '0';
reset_flash_on_init_t <= '1';
read_request_t <= '0';
new_data_t <= '0';

end Behavioral;
