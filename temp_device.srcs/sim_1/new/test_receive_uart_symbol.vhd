----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/07/2024 10:25:07 PM
-- Design Name: 
-- Module Name: test_receive_uart_symbol - Behavioral
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
use work.modules_pack.generate_baud;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_receive_uart_symbol is
--  Port ( );
end test_receive_uart_symbol;

architecture Behavioral of test_receive_uart_symbol is
	signal byteR: std_logic_vector(0 to 7) := "11111111";
	signal byteS: std_logic_vector(0 to 7) := "00110111";
	signal rx: std_logic := '1';
	signal new_val: std_logic := '1';
	signal valid: std_logic := '0';
	signal baud_clock: std_logic := '1';
	
	signal is_set: std_logic := '0';
    signal tx: std_logic := '1';
    signal is_busy: std_logic := '0';

	
	component send_uart_symbol
    port(
    signal baud_clock:in std_logic;
    signal byte:in std_logic_vector (0 to 7);
    signal is_set: in std_logic;
    signal tx: out std_logic;
    signal is_busy: out std_logic);
    end component send_uart_symbol;

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
		byte => byteR,
		valid => valid,
		new_val => new_val);
		
send_symbol: send_uart_symbol port map(
    baud_clock => baud_clock,
    byte => byteS,
    is_set => is_set,
    tx => tx,
    is_busy => is_busy
);

--process(is_busy)
--begin
--    if(is_busy = '1')
--    then
--        is_set <= not is_set;
--    end if;
--end process;
process is
    variable count: integer := 0;
begin
    baud_clock <= '1';
    wait for 4340ns;
    baud_clock <= '0';
    wait for 4340ns;
    if(count < 100)
    then
        count := count+1;
    else
        count := 0;
        is_set<=not is_set;
    end if;
end process;

rx <= tx;
end Behavioral;
