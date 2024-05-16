----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/24/2024 12:27:49 AM
-- Design Name: 
-- Module Name: test_register_11b - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_register_11b is
--  Port ( );
end test_register_11b;

architecture Behavioral of test_register_11b is
component register_11b
port(
    signal D: in std_logic_vector(0 to 10);
    signal enable_set: in std_logic;
    signal clk: in std_logic;
    signal shiftR: in std_logic;
    signal Q: out std_logic_vector(0 to 10));
end component register_11b;
    
    signal D: std_logic_vector(0 to 10) := "00000000000";
    signal enable_set: std_logic := '1';
    signal clk: std_logic := '0';
    signal shiftR: std_logic := '0';
    signal Q: std_logic_vector(0 to 10);
    
    signal clk_period: time:=100ns;
begin
reg_11: register_11b port map(
    D => D,
    enable_set => enable_set,
    clk => clk,
    shiftR => shiftR,
    Q => Q   
);

clk_proc : process is
begin
    clk <='0';
    wait for clk_period/2;
    clk <='1';
    wait for clk_period/2;
end process clk_proc;

enable_set_proc: process
begin
    enable_set <= '0';
    enable_set <= '1';
    D <= "10000000000";
    wait for 100ns;
    enable_set <= '0';
    wait;
end process enable_set_proc;

shiftR_proc: process
begin
    shiftR <= '0';
    wait for 200 ns;
    shiftR <= '1';
    wait;
end process shiftR_proc;

D <= "10000000000";


end Behavioral;
