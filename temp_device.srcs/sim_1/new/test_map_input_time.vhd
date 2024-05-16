----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/16/2024 08:12:48 PM
-- Design Name: 
-- Module Name: test_map_input_time - Behavioral
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

entity test_map_input_time is
--  Port ( );
end test_map_input_time;

architecture Behavioral of test_map_input_time is
signal clk_100M : std_logic;
signal sec_internal : std_logic;
signal ms_internal : std_logic;
signal select_switches : std_logic_vector(0 to 2) := "000";
signal time_set_btn : std_logic_vector(0 to 4) := "00000";
signal current_time_internal : unsigned(0 to 31) := to_unsigned(0, 32);
signal last_reading_internal : integer := 0;
signal seven_seg: std_logic_vector(0 to 7) := "11111111";
signal seven_seg_select : std_logic_vector(0 to 3) := "1111";


component set_time_from_input is
port(
    signal ms_clock: in std_logic;
    signal sec_clock: in std_logic;
    signal select_switches: in std_logic_vector(0 to 2);
    signal time_set_btn: in std_logic_vector(0 to 4);
    signal current_time: out unsigned(0 to 31); -- time in seconds since epoch
    signal last_reading: in integer := 0;
    signal seven_seg: out std_logic_vector(0 to 7);
    signal seven_seg_select: out std_logic_vector(0 to 3));
end component set_time_from_input;
begin
map_clock:
seconds_clk port map(
    clk_in => clk_100M,
    clk_sec_out => sec_internal,
    clk_msec_out => ms_internal
);
map_input_time:
set_time_from_input port map(
    ms_clock => ms_internal,
    sec_clock => sec_internal,
    select_switches => select_switches,
    time_set_btn => time_set_btn,
    current_time => current_time_internal,-- time in seconds since epoch
    seven_seg => seven_seg,
    seven_seg_select => seven_seg_select,
    last_reading => last_reading_internal
);

process is
begin
    clk_100M <= '1';
    wait for 5ns;
    clk_100M <= '0';
    wait for 5ns;
end process;
    
end Behavioral;
