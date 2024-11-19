----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/11/2024 11:35:40 PM
-- Design Name: 
-- Module Name: spi_wrapper - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Controls data flow and sets the current command for spi_mem_if. Instantiates internally spi_mem_if and spi_in_if.
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
use work.spi_module_pack.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spi_wrapper is
port(
  SO: in std_logic;
  clk: in std_logic; -- 100MHz clock 
  read_request: in std_logic:= '0';
  write_request: in std_logic:= '0';
  write_data: in send_data_struct;
  read_out: out send_data_struct;
  SI: out std_logic;
  CS: out std_logic);
--  Port ( );
end spi_wrapper;

architecture Behavioral of spi_wrapper is
    
    signal write_data_internal: send_data_struct;
    signal read_data_waiting: std_logic := '0';

    signal finish : std_logic;
    signal exp : std_logic; -- always expect 4 bytes
    --num_exp : in natural;
    
    signal read_out_internal: send_data_struct; -- When reading data
    signal progress: natural := 0;
    signal read_ready: std_logic; 


    signal wr_rd_flag: std_logic;
    signal init_flash_sw: std_logic; -- Switch that will reset flash on init
      -- SPI ports 
    signal SCLK: std_logic:= '1';
    --num_exp : in natural;
    
    signal to_do: action := NO_ACTION;
    
    signal read_addr: std_logic_vector(23 downto 0);
    signal write_addr: std_logic_vector(23 downto 0);
    
    signal cur_comm: command := NOP;
    signal new_command: std_logic := '0';
    signal spi_rd_wr_comm :std_logic := '0'; -- Used to indicate from mem_if that read is expected.
    
    -- signal read_out: send_data_struct; -- When reading data
    -- signal progress: natural := 0;
    -- signal read_ready: std_logic
    
begin

map_spi_read_if:
spi_read_if port map(
    finish => finish,
    exp => exp,
    SO => SO,
    clk => clk,
    read_out => read_out_internal,
    progress => progress,
    read_ready => read_ready
);

map_spi_mem_if:
spi_mem_if port map(
    addr_in => write_addr,
    cur_comm => cur_comm,
    new_command => new_command,
    clk => clk,
    wr_rd_flag => wr_rd_flag,
    init_flash_sw => init_flash_sw,
    exp => exp,
    finish => finish,
    CS => CS,
    -- SCLK => clk,
    SI => SI
);

process (clk)
begin
    if(clk'event and clk = '1')
    then
    
    
        -- set CS pin to low when starting an operation.
        -- CS is set to low again by higher modules.
        if(write_request = '1' and to_do = NO_ACTION)
        then
            to_do <= WRITE_ENTRY;
            -- write_request <= '0';
            
            -- start checking status
            -- send write request
        end if;
        
        if(read_request = '1' and to_do = NO_ACTION)
        then
            to_do <= READ_ENTRY;
            -- read_request <= '0';
            -- send read request
        end if;
        
        if(read_ready = '1')
        then
            to_do <= NO_ACTION;
        end if;

        if(wr_rd_flag = '1')
        then
        end if;
        
        
        
        
       -- Add erase functionality and address location.
        case to_do is
        when WRITE_ENTRY => --Add actions.
            if(finish = '1')
            then
                case cur_comm is
                when NOP =>
                    new_command <= '1';
                    cur_comm <= WREN;
                when WREN =>
                    new_command <= '1';
                    -- pass address to program.
                    -- If address reaches end of page should issue a new PP comm.
                    
                    cur_comm <= PP; -- Check address of writing. Page is 256 bytes.
                    -- Set data to write.
                when PP =>
                    new_command <= '1';
                    cur_comm <= WRDI;
                when others => 
                    new_command <= '0';
                    cur_comm <= NOP;
                end case;
                
            end if;
            -- enable writing
            -- send write request
            -- stop CS
            -- disable writing
        when READ_ENTRY =>
            if(finish = '1')
            then
                case cur_comm is

                when NOP => 
                    new_command <= '1';
                    -- pass address to read.
                    cur_comm <= FAST_RD;
                when FAST_RD =>
                    exp <= '1';
                    if(finish = '1')
                    then
                        exp <= '0';
                        -- Set CS to high.
                    end if;
                
                end case;
            end if;
        when NO_ACTION =>
        when others =>
        end case;   
    end if;
    if(new_command = '1')
    then 
        new_command <= '0'; -- Set new_comm to 1 only for one clk cycle
    end if;
    
end process;

read_out <= read_out_internal;

end Behavioral;
