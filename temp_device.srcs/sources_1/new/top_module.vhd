----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/11/2024 11:51:27 PM
-- Design Name: 
-- Module Name: top_module - Behavioral
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

entity top_module is
  Port ( 
    signal vauxn6: in std_logic;
    signal vauxp6: in std_logic;
    signal seven_seg: out std_logic_vector(0 to 7);
    signal seven_seg_select: out std_logic_vector(0 to 3);
    signal select_switches: in std_logic_vector(0 to 3);
    signal time_set_btn: in std_logic_vector(0 to 4);
    signal clk: in std_logic;
    signal uart_tx: out std_logic;
    signal uart_rx: in std_logic;
    signal reset_flash_on_init: in std_logic;
    signal save_current_flash_state: in std_logic;

    signal io0 : INOUT STD_LOGIC;
    signal io1 : INOUT STD_LOGIC;
    signal io2 : INOUT STD_LOGIC;
    signal io3 : INOUT STD_LOGIC;

    signal flash_cs: INOUT STD_LOGIC_VECTOR(0 downto 0)
     );
end top_module;

architecture Behavioral of top_module is
signal data_to_save: send_data_struct;
signal new_data_prod: std_logic;

signal read_ready: std_logic;
signal data_read: send_data_struct;
signal read_request: std_logic;

signal cfgclk : STD_LOGIC;
signal cfgmclk : STD_LOGIC;
signal eos : STD_LOGIC;
signal preq : STD_LOGIC;
signal ip2intc_irpt : STD_LOGIC;

begin

-- map_serialize_uart:
-- serialize_uart_data port map(
 -- 	new_data => read_ready,
 -- 	new_data_request => read_request,
 -- 	send_data => data_read,
 -- 	clk => clk,
 -- 	tx_uart => uart_tx
-- );

map_uart_controller:
uart_controller port map(
	new_data => read_ready,
	new_data_request => read_request,
	tx_send_data => data_read,
	clk => clk,
	tx => uart_tx,
	rx => uart_rx
);

map_axi_spi_if:
axi_spi_if port map(
	io0 => io0,
	io1 => io1,
	io2 => io2,
	io3 => io3,

	ss => flash_cs,
	cfgclk => cfgclk,
	cfgmclk => cfgmclk,
	eos => eos,
	preq => eos,
	ip2intc_irpt => ip2intc_irpt,
	clk => clk,

	new_data => new_data_prod,
	new_data_struct => data_to_save,

	reset_flash_on_init => reset_flash_on_init,
	save_current_flash_state => save_current_flash_state,

	read_request => read_request,
	read_ready => read_ready, -- Add signal in serialize_uart_data
	new_data_read => data_read
    
);

map_generate_data:
generate_send_data port map(
	vauxn6 => vauxn6,
	vauxp6 => vauxp6,
	send_data => data_to_save,
	seven_seg => seven_seg,
	seven_seg_select => seven_seg_select,
	select_switches => select_switches,
	time_set_btn => time_set_btn,
	new_data => new_data_prod,
	clk_100M => clk
);

end Behavioral;
