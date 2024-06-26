----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/19/2024 06:37:47 PM
-- Design Name: 
-- Module Name: generate_baud - Behavioral
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity generate_baud is
  Port ( signal clk_in:in std_logic;
          signal clk_out:out std_logic
          --signal mode:in std_logic_vector 
          );
end generate_baud;

architecture Behavioral of generate_baud is
signal clk_internal: std_logic := '1';
--signal clock_dev: natural range 0 to 1000 := 434; -- The Division needed for 115200 baud
begin
count_baud:    
    process(clk_in) is
    variable clock_dev: natural range 0 to 1000 := 434; -- invert signal every 434 clocks to get 115200Hz
    begin
        if(clk_in = '1' and clk_in'event)
        then
            clock_dev := clock_dev - 1;
            if clock_dev = 0
            then
                clk_internal <= not clk_internal; --invert clk signal
                clock_dev := 434;
            end if;
        end if;
    end process count_baud;

    clk_out <= clk_internal;
end Behavioral;

