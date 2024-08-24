----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/11/2024 11:50:51 PM
-- Design Name: 
-- Module Name: spi_read_if - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Reads form spi interface data depending on the command given and buffers the data.
-- Reads will be stored in fifo.
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
use work.modules_pack.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spi_read_if is
port(
    finish : in std_logic;
    exp : in std_logic; -- always expect 4 bytes
    --num_exp : in natural;
    SO: in std_logic;
    clk: in std_logic; -- 100MHz clock
    
    read_out: out send_data_struct; -- When reading data
    progress: out natural := 0;
    read_ready: out std_logic
    
    );
--  Port ( );
end spi_read_if;

architecture Behavioral of spi_read_if is  

signal num_exp_internal : natural := 0;
signal read_out_internal: send_data_struct;

begin
process_input:
process(clk)
begin
    if(num_exp_internal = 0 and exp = '1')
    then
        num_exp_internal <= 64;
    end if;
    
    if(clk'event and clk = '1')
    then
        if(exp = '1' and num_exp_internal /= 0)
        then
            if(num_exp_internal > 31)
            then
                read_out_internal.temp_data(64 - num_exp_internal) <= SO;
            else
                read_out_internal.timestamp(num_exp_internal - 1) <= SO;
            end if;
            num_exp_internal <= num_exp_internal - 1;
            progress <= num_exp_internal;
        end if;
    end if;

end process;
read_out <= read_out_internal when(num_exp_internal = 0); -- Define a 0 structure.

end Behavioral;
