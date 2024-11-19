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

component receive_uart_symbol is
port(
    signal baud_clock: in std_logic;
    signal rx: in std_logic;
    signal byte: out std_logic_vector(0 to 7);
    signal valid: out std_logic := '0';
    signal new_val: out std_logic := '0');
end component receive_uart_symbol;

component fifo_init
port(
    signal ALMOSTEMPTY: out std_logic;
    signal ALMOSTFULL: out std_logic;
    signal DO: out std_logic_vector(8 downto 0);
    signal EMPTY: out std_logic;
    signal FULL: out std_logic;
    signal RDCOUNT: out std_logic_vector(10 downto 0);
    signal RDERR: out std_logic;
    signal WRCOUNT: out std_logic_vector(10 downto 0);
    signal WRERR: out std_logic;
    signal DI: in std_logic_vector(8 downto 0);
    signal RDCLK: in std_logic;
    signal RDEN: in std_logic;
    signal RST: in std_logic;
    signal WRCLK: in std_logic;
    signal WREN: in std_logic);
end component fifo_init;

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
    signal repeat: in std_logic := '0';
    signal tx_uart: out std_logic
    );
end component serialize_uart_data;

component uart_controller
port(
	new_data: in std_logic;
	new_data_request: out std_logic;
	tx_send_data: in send_data_struct;
	clk: in std_logic;
	tx: out std_logic;
	rx: in std_logic
);
end component uart_controller;

component axi_spi_if
port(
    io0 : INOUT STD_LOGIC;
    io1 : INOUT STD_LOGIC;
    io2 : INOUT STD_LOGIC;
    io3 : INOUT STD_LOGIC;

    ss : INOUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    cfgclk : OUT STD_LOGIC;
    cfgmclk : OUT STD_LOGIC;
    eos : OUT STD_LOGIC;
    preq : OUT STD_LOGIC;
    ip2intc_irpt : OUT STD_LOGIC ;
    clk: in std_logic;
    
    new_data: in std_logic;
    new_data_struct: in send_data_struct;
    
    reset_flash_on_init: in std_logic;
    save_current_flash_state: in std_logic;    

    read_request: in std_logic;
    read_ready: out std_logic := '0';
    new_data_read: out send_data_struct

);
end component axi_spi_if;


end package modules_pack;
