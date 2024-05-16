----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/01/2024 10:02:22 PM
-- Design Name: 
-- Module Name: receive_uart_symbol - Behavioral
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

entity receive_uart_symbol is
  Port (
    signal baud_clock: in std_logic;
    signal rx: in std_logic;
    signal byte: out std_logic_vector(0 to 7) := "11111111";
    signal valid: out std_logic := '0';
    signal new_val: out std_logic := '0');
end receive_uart_symbol;

architecture Behavioral of receive_uart_symbol is
component register_11b
port(
    signal D: in std_logic_vector(0 to 10);
    signal enable_set: in std_logic;
    signal clk: in std_logic;
    signal shiftR: in std_logic;
    signal Q: out std_logic_vector(0 to 10));
end component register_11b;
    
    signal D: std_logic_vector(0 to 10) := "10000000000";
    signal enable_set: std_logic := '1';
    signal clk: std_logic := '0';
    signal shiftR: std_logic := '1';
    signal Q: std_logic_vector(0 to 10);
    
    signal counter: natural range 0 to 10 := 0;
    signal started: std_logic := '0'; 
    signal read_byte: std_logic_vector(0 to 7) := "111111111";  
    signal in_data: std_logic_vector(0 to 10) := "111111111111";
begin
reg_11: register_11b port map(
    D => D,
    enable_set => enable_set,
    clk => clk,
    shiftR => shiftR,
    Q => Q   
);

receive_byte:
process (baud_clock) is
variable internal_valid: std_logic := '1'; 
begin
    if(baud_clock'event and baud_clock = '1')
    then
        if(counter = 0)
        then   
            if(rx = '0')
            then         
                counter <= counter + 1;
            else
                new_val <= '0';
            end if;
        end if;
        
        
        if(counter < 9 and counter /= 0)
        then 
            read_byte(counter-1) <= rx;
        end  if;
        
        if(counter = 9)
        then
            if rx = (read_byte(0) xor read_byte(1) xor read_byte(2) 
                xor read_byte(3)xor read_byte(4)
                xor read_byte(5) xor read_byte(6) xor read_byte(7))
            then
                internal_valid := '1';
            else
                internal_valid := '0'; 
            end if;
            
            if(counter = 9)
            then
                if rx = '1'
                then
                    internal_valid := internal_valid and '1';
                else
                    internal_valid := '0';
                end if;
                counter <= 0;
                byte <= read_byte;
                valid <= internal_valid;
                new_val <= '1';
            end if;
        end if;
    end if;
end process receive_byte;

end Behavioral;
