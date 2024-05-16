----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/03/2024 12:28:42 AM
-- Design Name: 
-- Module Name: adc_get_reading - Behavioral
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

entity adc_get_reading is
  Port (
    signal clk : in std_logic;
    signal request : in std_logic; 
    signal out_val : out std_logic_vector(0 to 15);
    signal vauxp5 : in STD_LOGIC;
    signal vauxn5 : in STD_LOGIC;
    signal new_val : out std_logic := '0'); 
end adc_get_reading;

architecture Behavioral of adc_get_reading is
COMPONENT xadc_wiz_0
  PORT (
    di_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    daddr_in : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
    den_in : IN STD_LOGIC;
    dwe_in : IN STD_LOGIC;
    drdy_out : OUT STD_LOGIC;
    do_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    dclk_in : IN STD_LOGIC;
    vp_in : IN STD_LOGIC;
    vn_in : IN STD_LOGIC;
    vauxp5 : IN STD_LOGIC;
    vauxn5 : IN STD_LOGIC;
    channel_out : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
    eoc_out : OUT STD_LOGIC;
    alarm_out : OUT STD_LOGIC;
    eos_out : OUT STD_LOGIC;
    busy_out : OUT STD_LOGIC 
  );
END COMPONENT;
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

    signal di_in : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal daddr_in : STD_LOGIC_VECTOR(6 DOWNTO 0);
    signal den_in : STD_LOGIC := '0';
    signal dwe_in : STD_LOGIC;
    signal drdy_out : STD_LOGIC := '0';
    signal do_out : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal vp_in : STD_LOGIC;
    signal vn_in : STD_LOGIC;
    signal channel_out : STD_LOGIC_VECTOR(4 DOWNTO 0);
    signal eoc_out : STD_LOGIC;
    signal alarm_out : STD_LOGIC;
    signal eos_out : STD_LOGIC;
    signal busy_out : STD_LOGIC; 
    
    signal request_sent: std_logic := '0';


begin
    
ADC : xadc_wiz_0
  PORT MAP (
    di_in => x"0000",
    daddr_in => daddr_in,
    den_in => den_in,
    dwe_in => dwe_in,
    drdy_out => drdy_out,
    do_out => do_out,
    dclk_in => clk,
    vp_in => vp_in,
    vn_in => vn_in,
    vauxp5 => vauxp5,
    vauxn5 => vauxn5,
    channel_out => channel_out,
    eoc_out => eoc_out,
    alarm_out => alarm_out,
    eos_out => eos_out,
    busy_out => busy_out
  );
  
request_drive:
    process(clk)
    begin
        if(clk'event and clk = '1')
        then
            if(request = '1')
            then
                daddr_in <= "0000000";
                den_in <= '1';
            else 
                den_in <= '0';
            end if;
            
            if(drdy_out = '1')
            then
                 out_val <= std_logic_vector(shift_right(unsigned(do_out), 4));
                 new_val <= '1';
            else
                new_val <= '0';
            end if;
        end if;  
    end process request_drive;
  
--request_reading:
--  process(request) is
--  begin
--    if(request'event and request = '1')
--    then
--        daddr_in <= "0000000";
--        den_in <= '1';
--        request_sent <= '1';
--    end if;
--  end process request_reading;
  
--receive_reading:
--    process(drdy_out) is
--    begin
--        if(drdy_out'event and drdy_out = '1')
--        then
--            if request = '1'
--            then
--                if(request_sent = '1')
--                then
--                    out_val <= std_logic_vector(shift_right(unsigned(do_out), 4));
--                    request_sent <= '0';
--                    new_val <= '1';
--                else
--                    new_val <= '0';
--                end if;
--            end if;
--        end if;
--    end process receive_reading;
 
end Behavioral;
