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
    signal uart_tx: out std_logic
     );
end top_module;

architecture Behavioral of top_module is

	signal data: send_data_struct;
	signal new_data: std_logic;

	signal byte: std_logic_vector(0 to 7);
	signal rx: std_logic;
	signal new_val: std_logic;
	signal valid: std_logic;
	signal baud_clock: std_logic;

	component receive_uart_symbol
	port(
	signal baud_clock: in std_logic;
	signal rx: in std_logic;
	signal byte: out std_logic_vector(0 to 7);
	signal valid: out std_logic;
	signal new_val: out std_logic);
	end component receive_uart_symbol;

begin
rcv:	receive_uart_symbol port map(
		baud_clock => baud_clock,
		rx => rx,
		byte => byte,
		valid => valid,
		new_val => new_val);
	
	

end Behavioral;
