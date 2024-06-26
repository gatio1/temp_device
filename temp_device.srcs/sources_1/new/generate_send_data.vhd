----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/11/2024 11:44:41 PM
-- Design Name: 
-- Module Name: generate_send_data - Behavioral
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
use work.modules_pack.send_data_struct;
use work.modules_pack.seconds_clk;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity generate_send_data is
port(
    signal vauxn6 : in std_logic;
    signal vauxp6 : in std_logic;
    signal send_data : out send_data_struct;
    signal seven_seg: out std_logic_vector(0 to 7);
    signal seven_seg_select: out std_logic_vector(0 to 3);
    signal select_switches: in std_logic_vector(0 to 3);
    signal time_set_btn: in std_logic_vector(0 to 4);
    signal new_data: out std_logic := '1';
    signal clk_100M: in std_logic
    );
end generate_send_data;

architecture Behavioral of generate_send_data is
component set_time_from_input is
port(
    signal ms_clock: in std_logic;
    signal sec_clock: in std_logic;
    signal select_switches: in std_logic_vector(0 to 3);
    signal time_set_btn: in std_logic_vector(0 to 4);
    signal current_time: out unsigned(0 to 31); -- time in seconds since epoch
    signal last_reading: in integer;
    signal seven_seg: out std_logic_vector(0 to 7);
    signal seven_seg_select: out std_logic_vector(0 to 3));
end component set_time_from_input;

component adc_get_reading is
port(
    signal clk : in std_logic;
    signal request : in std_logic; 
    signal out_val : out std_logic_vector(0 to 15);
    signal vauxp6 : in STD_LOGIC;
    signal vauxn6 : in STD_LOGIC;
    signal new_val : out std_logic := '0');
end component adc_get_reading;

    function f_adc_reading_lmt70_conversion(
        in_reading: in unsigned(0 to 15))
        return integer is
        variable temp_reading: integer;
        variable tmp_int1: integer;
        variable tmp_int2: integer; 
--        variale to_mv: integer;
    begin
        temp_reading := to_integer(in_reading);
        tmp_int1 := 1047*4 + (96*1047*4)/4000; --10 degrees
        tmp_int2 := 995*4 + (96*995*4)/4000; --20 degrees
        if(temp_reading >= tmp_int2) then -- result is one digit after dp.
            temp_reading := 20000 - (10000/(tmp_int1-tmp_int2))*(temp_reading - tmp_int2); -- four adc intervals make one mV
        else
        tmp_int1 := 995*4 + (96*995*4)/4000; --20 degrees
        tmp_int2 := 943*4 + (96*943*4)/4000; --30 degrees
        if(temp_reading >= tmp_int2) then -- result is one digit after dp.
            temp_reading := 30000 - (10000/(tmp_int1-tmp_int2))*(temp_reading - tmp_int2); -- four adc intervals make one mV
        else
        tmp_int1 := 943*4 + (96*943*4)/4000; --30 degrees
        tmp_int2 := 891*4 + (96*891*4)/4000; --40 degrees
        if(temp_reading >= tmp_int2) then -- result is one digit after dp.
            temp_reading := 40000 - (10000/(tmp_int1-tmp_int2))*(temp_reading - tmp_int2);
        else
        tmp_int1 := 891*4 + (96*891*4)/4000; --40 degrees
        tmp_int2 := 838*4 + (96*838*4)/4000; --50 degrees
        if(temp_reading >= tmp_int2) then -- result is one digit after dp.
            temp_reading := 50000 - (10000/(tmp_int1-tmp_int2))*(temp_reading - tmp_int2);
        else
            tmp_int1 := 838*4 + (96*838*4)/4000;
            tmp_int2 := 303*4 + (96*303*4)/4000;
            temp_reading := 150000 - (100000/(tmp_int1-tmp_int2))*(temp_reading - tmp_int2);
        end if;
        end if; 
        end if;
        end if;
        return temp_reading;
    end;

signal request:std_logic := '0';
signal adc_reading: std_logic_vector(0 to 15);
signal value_fetched: std_logic := '0';
signal new_data_internal: std_logic := '1'; 

signal new_data_yes: std_logic := '0';
signal request_yes: std_logic := '0';
signal adc_request: std_logic;
signal adc_ready_flag: std_logic;
signal adc_ready_flag_internal: std_logic := '0';
signal last_reading_internal : integer := 0;

signal sec_internal: std_logic;
signal sec_internal_prev: std_logic;
signal ms_internal: std_logic;

signal current_time_internal: unsigned(0 to 31);

begin

map_clock:
seconds_clk port map(
    clk_in => clk_100M,
    clk_sec_out => sec_internal,
    clk_msec_out => ms_internal
);

map_reading:
adc_get_reading port map(
    clk => clk_100M,
    request => adc_request, 
    out_val => adc_reading,
    vauxp6 => vauxp6,
    vauxn6 => vauxn6,
    new_val => adc_ready_flag
);

map_input_time:
set_time_from_input port map(
    ms_clock => ms_internal,
    sec_clock => sec_internal,
    select_switches => select_switches,
    time_set_btn => time_set_btn,
    current_time => current_time_internal,-- time in seconds since epoch
    seven_seg => seven_seg,
    seven_seg_select => seven_seg_select,
    last_reading => last_reading_internal
);

send_request:
process (clk_100M)
variable req_yes_prev: std_logic;
variable new_data_yes_prev :std_logic;

variable reading_tmp : integer := 0; 

variable tmp_int1: integer; 
variable tmp_int2: integer; 
variable num_sec: natural range 0 to 60 := 0;
begin
    if(clk_100M'event and clk_100M = '1')
    then
        if(adc_request = '1') 
        then
            adc_request <= '0';
        end if;
        sec_internal_prev <= sec_internal;
        if((adc_ready_flag = not adc_ready_flag_internal) and adc_ready_flag = '1')
        then
            send_data.timestamp <= std_logic_vector(current_time_internal);
            -- The transfer function of the temperature sensor is 0.123 for every lsb in the adc reading.
            -- We will represent the temperature in 1housandths of the degree.
            reading_tmp := f_adc_reading_lmt70_conversion(unsigned(adc_reading));
--            reading_tmp := to_integer(unsigned(adc_reading)); -- Read chip temperature
--            reading_tmp := reading_tmp*123 -273150;
            last_reading_internal <= reading_tmp;
            send_data.temp_data <= to_signed(reading_tmp, send_data.temp_data'length);
            new_data <= not new_data_internal;
            new_data_internal <= not new_data_internal;
            else
            adc_ready_flag_internal <= adc_ready_flag;
        end if;
        if( sec_internal = not sec_internal_prev and sec_internal = '1')
        then
            if(num_sec = 0)
            then
                adc_request <= '1';
                num_sec := 0;
            else
                num_sec := num_sec + 1;
            end if;
        end if;
    end if;
end process send_request;

end Behavioral;
