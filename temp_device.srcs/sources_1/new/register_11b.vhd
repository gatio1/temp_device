----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/23/2024 12:11:12 AM
-- Design Name: 
-- Module Name: register_11b - Behavioral
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity register_11b is
port(
    signal D: in std_logic_vector(0 to 10);
    signal enable_set: in std_logic;
    signal clk: in std_logic;
    signal shiftR: in std_logic;
    signal Q: out std_logic_vector(0 to 10));
end register_11b;

architecture Behavioral of register_11b is
signal Q_internal: std_logic_vector(0 to 10) := "11111111111";
begin
set_state_of_reg:
    process(clk, enable_set, D)
    begin
    if(enable_set = '1') then
        Q_internal <= D;
    end if;
        if (clk'event and clk = '1') then
            if (enable_set = '0') then
                if(shiftR = '1')
                then
                    Q_internal(0) <= Q_internal(10);
                    Q_internal(1 to 10) <= Q_internal(0 to 9);
                end if;
            end if;
        end if;

    end process set_state_of_reg;
    Q <= Q_internal;
end Behavioral;
