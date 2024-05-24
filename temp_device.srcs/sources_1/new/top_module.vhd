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
    signal select_switches: in std_logic_vector(0 to 2);
    signal time_set_btn: in std_logic_vector(0 to 4);
    signal clk: in std_logic;
    signal uart_tx: out std_logic
     );
end top_module;

architecture Behavioral of top_module is

signal data: send_data_struct;
signal new_data: std_logic;
begin

map_serialize_uart:
serialize_uart_data port map(
    new_data => new_data,
    send_data => data,
    clk => clk,
    tx_uart => uart_tx
);

map_generate_data:
generate_send_data port map(
    vauxn6 => vauxn6,
    vauxp6 => vauxp6,
    send_data => data,
    seven_seg => seven_seg,
    seven_seg_select => seven_seg_select,
    select_switches => select_switches,
    time_set_btn => time_set_btn,
    new_data => new_data,
    clk_100M => clk
);

end Behavioral;
