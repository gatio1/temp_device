----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/03/2024 04:38:20 PM
-- Design Name: 
-- Module Name: seconds_clk - Behavioral
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

entity seconds_clk is
  Port ( signal clk_in:in std_logic;
          signal clk_sec_out:out std_logic;
          signal clk_msec_out:out std_logic
          --signal mode:in std_logic_vector 
          );
end seconds_clk;

architecture Behavioral of seconds_clk is
    signal clk_internal_ms: std_logic := '1';
    signal clk_internal_s:  std_logic := '1';
--    signal clock_dev: natural range 0 to 1000 := 434;
begin
process (clk_in) is
variable clock_dev: natural range 0 to 1000000 := 50000;
variable msecs: natural range 0 to 1000 := 0;
begin
    if(clk_in = '1' and clk_in'event)
        then
            clock_dev := clock_dev - 1;
            if clock_dev = 0
            then
                clk_internal_ms <= not clk_internal_ms;
                clock_dev := 50000;
                msecs := msecs + 1;
            end if;
            if(msecs = 500)
            then
                clk_internal_s <= not clk_internal_s;
                msecs := 0;
             end if;
                
        end if;
end process;

clk_msec_out <= clk_internal_ms;
clk_sec_out <= clk_internal_s;
    
end Behavioral;
