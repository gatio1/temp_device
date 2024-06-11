----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/14/2024 11:07:53 PM
-- Design Name: 
-- Module Name: send_uart_symbol - Behavioral
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

-- Uart frames format:
    -- S -Start bit
    -- D -data bit
    -- P -parity check bit
    -- s -stop bit
    -- format: SDDDDDDDDPs
    --         01234567890
    

entity send_uart_symbol is
    Port (
    signal baud_clock:in std_logic;
    signal byte:in std_logic_vector (0 to 7);
    signal is_set: in std_logic; -- Changes state when new byte is sent
    signal tx: out std_logic := '1';
    signal is_busy: out std_logic := '1');
end send_uart_symbol;

architecture Behavioral of send_uart_symbol is
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
    
    signal send_symbol: std_logic_vector(0 to 10) := "11111111111";
    signal is_set_prev: std_logic := '0';
begin
reg_11: register_11b port map(
    D => D,
    enable_set => enable_set,
    clk => clk,
    shiftR => shiftR,
    Q => Q   
);

send_bit:
    process(baud_clock) is
    variable masked_data: std_logic_vector(0 to 10) := "11111111111";
    variable or_res: std_logic := '1';
    variable send_data: std_logic_vector(0 to 7) := "00000000";
    begin

        if (baud_clock'event and baud_clock='1')
        then  
            if enable_set = '1' then
                    
                    enable_set <= '0';
                    is_set_prev <= is_set;
            
            else            
                for i in 0 to 10 loop
                    masked_data(i) := send_symbol(i) and Q(i);
                end loop;    
                or_res := masked_data(0) or masked_data(1) or masked_data(2) or masked_data(3) or masked_data(4) or 
                masked_data(5) or masked_data(6) or masked_data(7) or masked_data(8) or 
                masked_data(9) or masked_data(10);
                tx <= or_res;
                
                if (Q(9) = '1') then
                    is_busy <= '0';
                end if; 
                
                if (Q(10) = '1') then
                    if (is_set = not is_set_prev)
                    then
                        send_data := byte;
                                -- construct symbol:
                        send_symbol(0) <= '0';
                        send_symbol(1 to 8) <= send_data;
                        
                        -- parity bit is 1 on odd number of 1s in data
                        send_symbol(9) <= send_data(0) xor send_data(1) xor send_data(2) xor
                         send_data(3) xor send_data(4) xor send_data(5) xor
                          send_data(6) xor send_data(7);
                          
                          send_symbol(10) <= '1';
                          is_busy <= '1';
                          is_set_prev <= is_set;
                    else
                        send_symbol <= "11111111111";
                    end if;
                 end if;            
            end if;
        end if;
    end process send_bit;
    
    D <= "10000000000";
          
          shiftR <= '1'; 
          clk <= baud_clock;
end architecture Behavioral;