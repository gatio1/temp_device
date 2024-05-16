----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/14/2024 11:43:12 PM
-- Design Name: 
-- Module Name: test_map_serialize_uart - Behavioral
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
use work.modules_pack.serialize_uart_data;
use work.modules_pack.send_data_struct;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_map_serialize_uart is
--  Port ( );
end test_map_serialize_uart;

architecture Behavioral of test_map_serialize_uart is
--    type send_data_struct is record
--    timestamp : std_logic_vector(0 to 31);
--    temp_data : signed(0 to 31);
--    end record send_data_struct;
    
--    component serialize_uart_data
--    port(
--        signal new_data : in std_logic;
--        signal send_data: in send_data_struct;
--        signal clk: in std_logic;
--        signal tx_uart: out std_logic
--        );
--    end component serialize_uart_data;
    
    signal uart_tx: std_logic:= '1';
    signal data: send_data_struct;
    signal new_data: std_logic := '1';
    signal clk: std_logic;


begin
map_serialize_uart:
    serialize_uart_data port map(
        new_data => new_data,
        send_data => data,
        clk => clk,
        tx_uart => uart_tx
    );
    process is
    begin
        clk <= '1';
        wait for 5ns;
        clk <= '0';
        wait for 5ns;
    end process;
    
    process is
    begin
        wait for 1000000ns;
        new_data <= not new_data;
    end process;
    data.timestamp <= x"01234567";
    data.temp_data <= x"89ABCDEF";
    end Behavioral;
