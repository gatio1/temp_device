----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/30/2024 01:21:15 PM
-- Design Name: 
-- Module Name: test_send_uart_symbol - Behavioral
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

entity test_send_uart_symbol is
--  Port ( );
end test_send_uart_symbol;

architecture Behavioral of test_send_uart_symbol is
component send_uart_symbol
port(
    signal baud_clock:in std_logic;
    signal byte:in std_logic_vector (0 to 7);
    signal is_set: in std_logic;
    signal tx: out std_logic;
    signal is_busy: out std_logic);
end component send_uart_symbol;

signal baud_clock: std_logic := '1';
signal byte: std_logic_vector (0 to 7) := "01100111";
signal is_set: std_logic := '0';
signal tx: std_logic;
signal is_busy: std_logic;

begin

send_symbol:
send_uart_symbol port map(
    baud_clock => baud_clock,
    byte => byte,
    is_set => is_set,
    tx => tx,
    is_busy => is_busy
);

process(is_busy)
begin
    if(is_busy = '0')
    then
        is_set <= not is_set;
    end if;
end process;
process is
begin
    baud_clock <= '1';
    wait for 4340ns;
    baud_clock <= '0';
    wait for 4340ns;
end process;

end Behavioral;
