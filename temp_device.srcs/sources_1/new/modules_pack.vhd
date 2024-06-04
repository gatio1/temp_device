----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/12/2024 01:33:10 PM
-- Design Name: 
-- Module Name:  - 
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

package modules_pack is
component send_uart_symbol
port(
    signal baud_clock:in std_logic;
    signal byte:in std_logic_vector (0 to 7);
    signal is_set: in std_logic;
    signal tx: out std_logic;
    signal is_busy: out std_logic);
end component send_uart_symbol;

component seconds_clk
port(
    signal clk_in:in std_logic;
    signal clk_sec_out:out std_logic;
    signal clk_msec_out:out std_logic
);
end component seconds_clk;

component generate_baud
port(
    signal clk_in:in std_logic;
    signal clk_out:out std_logic
    --signal mode:in std_logic_vector
);
end component generate_baud;

type send_data_struct is record
    timestamp : std_logic_vector(0 to 31);
    temp_data : signed(0 to 31);
 end record send_data_struct;
 
component generate_send_data
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
end component generate_send_data;

component serialize_uart_data
port(
    signal new_data : in std_logic;
    signal send_data: in send_data_struct;
    signal clk: in std_logic;
    signal tx_uart: out std_logic
    );
end component serialize_uart_data;

end package modules_pack;
