----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/04/2024 04:04:49 PM
-- Design Name: 
-- Module Name: set_time_from_input - Behavioral
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

entity set_time_from_input is
    Port (
    signal ms_clock: in std_logic;
    signal sec_clock: in std_logic;
    signal select_switches: in std_logic_vector(0 to 2);
    signal time_set_btn: in std_logic_vector(0 to 4);
    signal current_time: out unsigned(0 to 31); -- time in seconds since epoch
    signal last_reading: in integer;
    signal seven_seg: out std_logic_vector(0 to 7);
    signal seven_seg_select: out std_logic_vector(0 to 3));
end set_time_from_input;

architecture Behavioral of set_time_from_input is
    signal time_set_btn_prev: std_logic_vector(0 to 4) := "00000"; 
    signal current_time_internal: unsigned(0 to 31) := to_unsigned(0, 32);
    signal seven_seg_select_internal: std_logic_vector(0 to 3) := "1110";
    signal digit: natural range 0 to 9 := 0;
    signal side: std_logic := '0';
    signal lights_on: std_logic := '1';
    signal digits_of_time_global: natural range 0 to 9999 :=0;

        
    function f_digit_to_7seg(
        in_digit: in natural range 0 to 9)
        return std_logic_vector is
        variable v_out: std_logic_vector(0 to 7);
    begin
        case in_digit is
            when 0 =>
                v_out := "00000011"; 
            when 1 =>
                v_out := "10011111";
            when 2 =>
                v_out := "00100101";
            when 3 =>
                v_out := "00001101";
            when 4 =>
                v_out := "10011001";
            when 5 =>
                v_out := "01001001";
            when 6 =>
                v_out := "01000001";
            when 7 =>
                v_out := "00011111";
            when 8 =>
                v_out := "00000001";
            when 9 =>
                v_out := "00001001"; 
            end case;
            return v_out;
    end;

begin

display_driver:
    process (ms_clock)
    variable count_clocks: natural := 0;
    variable seven_seg_code: std_logic_vector(0 to 7) := X"FF";
    begin
        if(ms_clock = '1' and ms_clock'event)
        then
            case seven_seg_select_internal is
            when "0111" =>
                if(side = '0' and count_clocks < 250) then
                    seven_seg_code := X"FF";
                else
                    seven_seg_code := f_digit_to_7seg(digits_of_time_global mod 10);
                end if;
                seven_seg_select_internal <= "1011";
            when "1011" =>
                if(side = '0' and count_clocks < 250) then
                    seven_seg_code := X"FF";
                else
                    seven_seg_code := f_digit_to_7seg((digits_of_time_global/10) mod 10);
                end if;
                seven_seg_select_internal <= "1101";
   
            when "1101" =>
                if(side = '1' and count_clocks < 250) then
                    seven_seg_code := X"FF";
                else
                    seven_seg_code :=  f_digit_to_7seg((digits_of_time_global/100) mod 10);
                    if(select_switches = "100" or select_switches = "010")
                    then
                        seven_seg_code(7) := '0';
                    end if;
                end if;
                seven_seg_select_internal <= "1110";

            when "1110" =>
                if(side = '1' and count_clocks < 250) then
                    seven_seg_code := X"FF";
                else
                    seven_seg_code := f_digit_to_7seg(digits_of_time_global/1000);
                end if;
                seven_seg_select_internal <= "0111";
            when others =>
                seven_seg_code := X"FF";
                seven_seg_select_internal <= "0111";
                count_clocks := 251;
            end case;
            if(select_switches = "001" or select_switches = "010" or select_switches = "100") then
                count_clocks := count_clocks+1;
            else
                count_clocks := 251;
            end if;
            if(count_clocks = 500) then 
                count_clocks := 0;
            end if;
            
            seven_seg <= seven_seg_code;
            seven_seg_select <= seven_seg_select_internal; 
        end if;
    end process display_driver;
    
    
display_time:
    process(sec_clock)
    variable current_year: natural range 0 to 9999 := 1970;
    variable days_of_year: natural := 1;
    variable num_leap_years: unsigned(0 to 7);
    variable is_leap: bit := '0';
    variable days_in_months_so_far: natural := 0;
    variable months_done: bit := '0';
    variable tmp_32b: unsigned(0 to 31) := to_unsigned(0, 32);
--    variable disp_select: std_logic_vector;
    variable digits_of_time: natural range 0 to 9999 :=0;

    begin
        if(sec_clock'event and sec_clock = '1')
        then
            digits_of_time := 0;
            current_year := 1970;
--            num_leap_years := to_unsigned(0, num_leap_years'length);
            days_of_year := 1;
            days_in_months_so_far := 0;
            months_done := '0';
            is_leap := '0';
--            if((current_time_internal/(3600*24*365))/4 <
            tmp_32b := ((current_time_internal/(3600*24*365))/4);
            num_leap_years := tmp_32b(24 to 31);-- Can't be more than 8 bit in the used range.
            if(num_leap_years /= (current_time_internal/(3600*24*365) + 3600*24*num_leap_years)/4) then
                num_leap_years := num_leap_years + 1;            
            end if;
            current_year := current_year + to_integer((current_time_internal-(num_leap_years*24*3600))/(365*24*3600));-- valid  until 2100
                case select_switches is
                when "100" =>
                    digits_of_time := digits_of_time + to_integer((current_time_internal/60) mod 60);
                    digits_of_time := digits_of_time + to_integer((current_time_internal/3600) mod 24)*100;
                when "010" =>
                    if(current_year mod 4 = 0) then
                        is_leap := '1';
                    else
                        is_leap := '0';
                    end if;
                    days_of_year := to_integer(current_time_internal)/(24*3600)+1; -- total days since 1970
                    days_of_year := days_of_year - 365*(current_year-1970) - to_integer(num_leap_years);
                    if(days_of_year < 32)then --january
                        digits_of_time := digits_of_time + days_of_year+100;
                        months_done := '1';
                    else days_in_months_so_far := days_in_months_so_far + 31; 
                        if is_leap = '1' then --february
                            if days_of_year - days_in_months_so_far < 30 then
                                digits_of_time := digits_of_time + days_of_year+200 - days_in_months_so_far;
                                months_done := '1';
                            else
                                days_in_months_so_far := days_in_months_so_far + 29;
                            end if;
                        else  
                            if days_of_year - days_in_months_so_far < 29 then
                                digits_of_time := digits_of_time + days_of_year+200 - days_in_months_so_far;
                                months_done := '1';
                            else
                                days_in_months_so_far := days_in_months_so_far + 28;
                            end if;
                        end if;
                    end if;
                    if(months_done = '0')
                    then
                        if(days_of_year - days_in_months_so_far < 32)then --march
                        digits_of_time := digits_of_time + days_of_year + 300 - days_in_months_so_far;
                        else days_in_months_so_far := days_in_months_so_far + 31; 
                        if days_of_year - days_in_months_so_far < 31 then --april
                        digits_of_time := digits_of_time + days_of_year + 400 - days_in_months_so_far;
                        else days_in_months_so_far := days_in_months_so_far + 30;
                        if days_of_year - days_in_months_so_far < 32 then --may
                        digits_of_time := digits_of_time + days_of_year + 500 - days_in_months_so_far;
                        else days_in_months_so_far := days_in_months_so_far + 31;
                        if days_of_year - days_in_months_so_far < 31 then --june
                        digits_of_time := digits_of_time + days_of_year + 600 - days_in_months_so_far;
                        else days_in_months_so_far := days_in_months_so_far + 30;
                        if days_of_year - days_in_months_so_far < 32 then --july
                        digits_of_time := digits_of_time + days_of_year + 700 - days_in_months_so_far;
                        else days_in_months_so_far := days_in_months_so_far + 31;
                        if days_of_year - days_in_months_so_far < 32 then --august
                        digits_of_time := digits_of_time + days_of_year + 800 - days_in_months_so_far;
                        else days_in_months_so_far := days_in_months_so_far + 31;
                        if days_of_year - days_in_months_so_far < 31 then --september
                        digits_of_time := digits_of_time + days_of_year + 900 - days_in_months_so_far;
                        else days_in_months_so_far := days_in_months_so_far + 30;
                        if days_of_year - days_in_months_so_far < 32 then --october
                        digits_of_time := digits_of_time + days_of_year + 1000 - days_in_months_so_far;
                        else days_in_months_so_far := days_in_months_so_far + 31;
                        if days_of_year - days_in_months_so_far < 31 then --november
                        digits_of_time := digits_of_time + days_of_year + 1100 - days_in_months_so_far;
                        else days_in_months_so_far := days_in_months_so_far + 30;
                        if days_of_year - days_in_months_so_far < 32 then --december
                        digits_of_time := digits_of_time + days_of_year + 1200 - days_in_months_so_far;
                        else days_in_months_so_far := days_in_months_so_far + 31;
                        end if;
                        end if;
                        end if;
                        end if;
                        end if;
                        end if;
                        end if;
                        end if;
                        end if;
                        end if;
                    end if;
                when "001" =>
                    digits_of_time := current_year;
                when others =>
                    digits_of_time := (last_reading/10) mod 10000;
                    digits_of_time_global <= digits_of_time;
             end case;
             digits_of_time_global <= digits_of_time;
--                for i in 0 to 3 loop
                    
--                end loop;
        end if;
    end process display_time;
    
    
state_machine:
    process(sec_clock) --adds or subtracts from timestamp
    variable two_digits: natural range 0 to 99 := 0;
    begin
        if(sec_clock = '1' and sec_clock'event)
        then
            case select_switches is
                when "100" =>
                    if(time_set_btn_prev = time_set_btn)
                    then
                        case(time_set_btn) is
                        when "10000" =>
                            side <= not side;
                        when "01000" =>
                            side <= not side;
                        when "00100" =>
                            if side = '1'
                            then
                                current_time_internal <= current_time_internal + 1*3600;
                            else if side = '0'
                                then
                                    current_time_internal <= current_time_internal + 60;
                                 end if;
                            end if;
                        when "00010" =>
                            if side = '1'
                            then
                                current_time_internal <= current_time_internal - 1*3600;
                            else if side = '0'
                                then
                                    current_time_internal <= current_time_internal - 60;
                                 end if;
                            end if; 
                         when "00101" =>
                            if side = '1'
                            then
                                current_time_internal <= current_time_internal + 1*36000;
                            else if side = '0'
                                then
                                    current_time_internal <= current_time_internal + 600;
                                 end if;
                            end if;   
                         when "00011" =>
                            if side = '1'
                            then
                                current_time_internal <= current_time_internal - 1*36000;
                            else if side = '0'
                                then
                                    current_time_internal <= current_time_internal - 600;
                                 end if;
                            end if;  
                         when others =>
                            current_time_internal <= current_time_internal;
                        end case;
                    end if;
                    --assign minutes/hr
                when "010" =>
                    if(time_set_btn_prev = time_set_btn)
                    then
                        case(time_set_btn) is
                        when "10000" =>
                            side <= not side;
                        when "01000" =>
                            side <= not side;
                        when "00100" =>
                            if side = '1'
                            then
                                current_time_internal <= current_time_internal + 1*3600*24*30;
                            else if side = '0'
                                then
                                    current_time_internal <= current_time_internal + 3600*24;
                                 end if;
                            end if;
                        when "00010" =>
                            if side = '1'
                            then
                                current_time_internal <= current_time_internal - 1*3600*24*30;
                            else if side = '0'
                                then
                                    current_time_internal <= current_time_internal - 3600*24;
                                 end if;
                            end if; 
                         when "00101" =>
                            if side = '1'
                            then
                                current_time_internal <= current_time_internal + 1*3600*24*30*10;
                            else if side = '0'
                                then
                                    current_time_internal <= current_time_internal + 3600*24*10;
                                 end if;
                            end if;   
                         when "00011" =>
                            if side = '1'
                            then
                                current_time_internal <= current_time_internal - 1*3600*24*30*10;
                            else if side = '0'
                                then
                                    current_time_internal <= current_time_internal - 3600*24*10;
                                 end if;
                            end if; 
                         when others =>
                            current_time_internal <= current_time_internal; 
                        end case;
                    end if;
                    --assign date/month
                when "001" =>
                    if(time_set_btn_prev = time_set_btn)
                    then
                        case(time_set_btn) is
                        when "00100" =>
                                current_time_internal <= current_time_internal + 1*3600*24*365;
                        when "00010" =>
                                current_time_internal <= current_time_internal - 1*3600*24*365;
                        when "00101" =>
                                current_time_internal <= current_time_internal + 1*3600*24*365*10; 
                        when "00011" =>
                                current_time_internal <= current_time_internal - 1*3600*24*365*10;
                        when others =>
                            current_time_internal <= current_time_internal;
                        end case;
                    end if;
                    --assign year
                 when "000" =>
                    current_time_internal <= current_time_internal + 1;
                 when others =>
                    current_time_internal <= current_time_internal;
            end case;
            if(current_time_internal(0) = '1' and current_time_internal(1 to 31) >= to_unsigned(1954961152, 31))-- return current time to 0 when year 2100 is reached.
            then
                current_time_internal <= to_unsigned(0, current_time_internal'length);
                
            end if;
            time_set_btn_prev <= time_set_btn;
        end if;
    end process state_machine;
    current_time <= current_time_internal;
end Behavioral;
