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
    signal select_switches: in std_logic_vector(0 to 3);
    signal time_set_btn: in std_logic_vector(0 to 4);
    signal current_time: out unsigned(0 to 31); -- time in seconds since epoch
    signal last_reading: in integer;
    signal seven_seg: out std_logic_vector(0 to 7);
    signal seven_seg_select: out std_logic_vector(0 to 3));
end set_time_from_input;

architecture Behavioral of set_time_from_input is
    -- months constants(seconds from beginning of year to end of month):
    constant days_jan: integer := 31;
    constant days_feb_l: integer := 60;
    constant days_feb: integer := 59;
    constant days_mar: integer := 90;
    constant days_apr: integer := 120;
    constant days_may: integer := 151;
    constant days_jun: integer := 181;
    constant days_jul: integer := 212;
    constant days_aug: integer := 243;
    constant days_sep: integer := 273;
    constant days_oct: integer := 304;
    constant days_nov: integer := 334;
    
     
    -- Time constants
    constant sec_in_minute: integer := 60;
    constant sec_in_hour: integer := 3600;
    constant sec_in_day: integer := 86400;
    constant sec_normal_year: integer := 31536000;
    constant sec_four_years: integer := 126230400; --three normal plus one leap year

    signal time_set_btn_prev: std_logic_vector(0 to 4) := "00000"; 
    signal current_time_internal: unsigned(0 to 31) := to_unsigned(43200, 32); -- start at 12pm on 01.01.1970
    signal seven_seg_select_internal: std_logic_vector(0 to 3) := "1110";
    signal digit: natural range 0 to 9 := 0;
    signal side: std_logic := '0';
    signal lights_on: std_logic := '1';
    signal digits_of_time_global: natural range 0 to 9999 :=0;
    signal utc_time_offset: unsigned(0 to 31) := to_unsigned(0, 32);

        
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
                    if(select_switches = "1000" or select_switches = "0100")
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
            if(select_switches = "0010" or select_switches = "0100" or select_switches = "1000" or select_switches = "0001") then
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
    variable tmp_32b: unsigned(0 to 31) := to_unsigned(0, 32);
--    variable disp_select: std_logic_vector;
    variable digits_of_time: natural range 0 to 9999 :=0;

    begin
        if(sec_clock'event and sec_clock = '1')
        then
            digits_of_time := 0;
            current_year := 1970;
--            num_leap_years := to_unsigned(1, num_leap_years'length);
            days_of_year := 1;
            is_leap := '0';
            tmp_32b := to_unsigned(0, 32);
            
--            if((current_time_internal/(3600*24*365))/4 <
            if (current_time_internal/sec_normal_year > 4) then
                tmp_32b := 1 + (current_time_internal - (sec_four_years-sec_normal_year))/sec_four_years;--  Accurate number of leap years
            else if (current_time_internal > (sec_four_years - sec_normal_year)) then
                    tmp_32b := to_unsigned(1, 32);
                end if;
            end if;
            num_leap_years := tmp_32b(24 to 31);-- Can't be more than 8 bit in the used range.
--            if(num_leap_years /= (current_time_internal/(3600*24*365) + 3600*24*num_leap_years)/4) then
--                num_leap_years := num_leap_years + 1;            
--            end if;
                current_year := current_year + to_integer((current_time_internal/(sec_in_day) - num_leap_years)/365); -- valid  until 2100
                case select_switches is
                when "1000" =>
                    digits_of_time := digits_of_time + to_integer((current_time_internal/60) mod 60);
                    digits_of_time := digits_of_time + to_integer((current_time_internal/3600) mod 24)*100;
                when "0100" =>
                    if(current_year mod 4 = 0) then
                        is_leap := '1'; 
                    else
                        is_leap := '0';
                    end if;
                    days_of_year := to_integer(current_time_internal)/sec_in_day+1; -- total days since 1970
                    days_of_year := days_of_year - 365*(current_year-1970) - to_integer(num_leap_years);
                    if(days_of_year <= days_jan)then --january
                        digits_of_time := digits_of_time + days_of_year+100;
                        else if is_leap = '1' then --february
                            if days_of_year <= days_feb_l then
                                digits_of_time := digits_of_time + days_of_year+200 - days_jan;
                            else --year is leap
                                if(days_of_year <= days_mar + 1)then --march
                                digits_of_time := digits_of_time + days_of_year + 300 - days_feb_l;
                                else if days_of_year <= days_apr + 1 then --april
                                digits_of_time := digits_of_time + days_of_year + 400 - days_mar - 1;
                                else if days_of_year <= days_may + 1 then --may
                                digits_of_time := digits_of_time + days_of_year + 500 - days_apr - 1;
                                else if days_of_year <= days_jun + 1 then --june
                                digits_of_time := digits_of_time + days_of_year + 600 - days_may - 1;
                                else if days_of_year <= days_jul + 1 then --july
                                digits_of_time := digits_of_time + days_of_year + 700 - days_jun - 1;
                                else if days_of_year <= days_aug+1 then --august
                                digits_of_time := digits_of_time + days_of_year + 800 - days_jul - 1;
                                else if days_of_year <= days_sep + 1 then --september
                                digits_of_time := digits_of_time + days_of_year + 900 - days_aug - 1;
                                else if days_of_year <= days_oct + 1 then --october
                                digits_of_time := digits_of_time + days_of_year + 1000 - days_sep - 1;
                                else if days_of_year <= days_nov + 1 then --november
                                digits_of_time := digits_of_time + days_of_year + 1100 - days_oct - 1;
                                else --december
                                digits_of_time := digits_of_time + days_of_year + 1200 - days_nov - 1;
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
                        else  
                            if days_of_year <= days_feb then
                                digits_of_time := digits_of_time + days_of_year+200 - days_jan;
                            else --year is normal
                                if(days_of_year <= days_mar)then --march
                                digits_of_time := digits_of_time + days_of_year + 300 - days_feb;
                                else if days_of_year <= days_apr then --april
                                digits_of_time := digits_of_time + days_of_year + 400 - days_mar;
                                else if days_of_year <= days_may then --may
                                digits_of_time := digits_of_time + days_of_year + 500 - days_apr;
                                else if days_of_year <= days_jun then --june
                                digits_of_time := digits_of_time + days_of_year + 600 - days_may;
                                else if days_of_year <= days_jul then --july
                                digits_of_time := digits_of_time + days_of_year + 700 - days_jun;
                                else if days_of_year <= days_aug then --august
                                digits_of_time := digits_of_time + days_of_year + 800 - days_jul;
                                else if days_of_year <= days_sep then --september
                                digits_of_time := digits_of_time + days_of_year + 900 - days_aug;
                                else if days_of_year <= days_oct then --october
                                digits_of_time := digits_of_time + days_of_year + 1000 - days_sep;
                                else if days_of_year <= days_nov then --november
                                digits_of_time := digits_of_time + days_of_year + 1100 - days_oct;
                                else --december
                                digits_of_time := digits_of_time + days_of_year + 1200 - days_nov;
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
                    end if;
                when "0010" =>
                    digits_of_time := current_year;
                when "0001" =>
                    digits_of_time := to_integer(utc_time_offset);
                when others =>
                    digits_of_time := (last_reading/10) mod 10000;
                    digits_of_time_global <= digits_of_time;
             end case;
             digits_of_time_global <= digits_of_time;

        end if;
    end process display_time;
    
    
state_machine:
    process(sec_clock) --adds or subtracts from timestamp
    variable two_digits: natural range 0 to 99 := 0;
    begin
        if(sec_clock = '1' and sec_clock'event)
        then
            case select_switches is
                when "1000" => --assign minutes/hr
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
                    
                when "0100" => --assign date/month
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
                    
                when "0010" =>--assign year
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
                    
		 when "0001" => --assign utc offset
			 if(time_set_btn_prev = time_set_btn)
			 then
				 if(time_set_btn = "00100") then
					 if(utc_time_offset = to_unsigned(24, 32)) then
						utc_time_offset <= to_unsigned(0, 32);
					 else
						 utc_time_offset <= utc_time_offset + to_unsigned(1, 32);
					 end if;
				  else if (time_set_btn = "00010") then
					  if(utc_time_offset = to_unsigned(0, 32)) then
						utc_time_offset <= to_unsigned(24, 32);
					  else
						 utc_time_offset <= utc_time_offset - to_unsigned(1, 32);
					  end if;
				  end if;
				  end if;
			  end if;
                    

                 when "0000" =>
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
    current_time <= current_time_internal-to_unsigned(to_integer(utc_time_offset)*3600, 32) when (utc_time_offset <= to_unsigned(12, 32))
    else current_time_internal+to_unsigned(((24 - to_integer(utc_time_offset))*3600), 32);

end Behavioral;
