----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/30/2024 12:06:29 AM
-- Design Name: 
-- Module Name: test_generate_baud - Behavioral
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

entity test_generate_baud is
--  Port ( );
end test_generate_baud;

architecture Behavioral of test_generate_baud is
component generate_baud
port(
    signal clk_in: in std_logic;
    signal clk_out: out std_logic
    );
end component generate_baud;

    signal clk_in: std_logic := '1';
    signal clk_out: std_logic;
begin

gen_baud:
    generate_baud port map(
        clk_in => clk_in,
        clk_out => clk_out
    );
    
    process is
    begin
        clk_in <= '1';
        wait for 5ns;
        clk_in <= '0';
        wait for 5ns;
    end process;
end Behavioral;
