----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/23/2024 09:36:50 PM
-- Design Name: 
-- Module Name: axi_spi_if - Behavioral
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
use work.modules_pack.all;
use work.spi_module_pack.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity axi_spi_if is
Port (
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
end axi_spi_if;

architecture Behavioral of axi_spi_if is

    signal io0_tt : STD_LOGIC := '0';
    signal io1_tt : STD_LOGIC := '0';
    signal io2_tt : STD_LOGIC := '0';
    signal io3_tt : STD_LOGIC := '0';

    signal ss_tt : std_logic := '0';

    signal ext_spi_clk : STD_LOGIC := '0';
    signal s_axi4_aclk : STD_LOGIC := '0';
    signal s_axi4_aresetn : STD_LOGIC := '0';
    signal s_axi4_awid : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    signal s_axi4_awaddr : STD_LOGIC_VECTOR(23 DOWNTO 0);
    signal s_axi4_awlen : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal s_axi4_awsize : STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal s_axi4_awburst : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal s_axi4_awlock : STD_LOGIC := '0';
    signal s_axi4_awcache : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0011";
    signal s_axi4_awprot : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    signal s_axi4_awvalid : STD_LOGIC := '0';
    signal s_axi4_awready : STD_LOGIC;
    signal s_axi4_wdata : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal s_axi4_wstrb : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal s_axi4_wlast : STD_LOGIC;
    signal s_axi4_wvalid : STD_LOGIC;
    signal s_axi4_wready : STD_LOGIC;
    signal s_axi4_bid : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal s_axi4_bresp : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal s_axi4_bvalid : STD_LOGIC;
    signal s_axi4_bready : STD_LOGIC;
    signal s_axi4_arid : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    signal s_axi4_araddr : STD_LOGIC_VECTOR(23 DOWNTO 0);
    signal s_axi4_arlen : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal s_axi4_arsize : STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal s_axi4_arburst : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal s_axi4_arlock : STD_LOGIC := '0';
    signal s_axi4_arcache : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0011";
    signal s_axi4_arprot : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
    signal s_axi4_arvalid : STD_LOGIC;
    signal s_axi4_arready : STD_LOGIC;
    signal s_axi4_rid : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    signal s_axi4_rdata : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal s_axi4_rresp : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal s_axi4_rlast : STD_LOGIC;
    signal s_axi4_rvalid : STD_LOGIC;
    signal s_axi4_rready : STD_LOGIC;
    
    signal new_data_internal : std_logic := new_data;
    signal new_data_read_internal : std_logic_vector(0 to 63);
    signal bit_progress_write : natural := 0;
    signal bit_progress_read : natural := 0;
    signal addr_saved : std_logic := '1';
    signal exp_slave_resp: std_logic := '0';
    signal init_flash: std_logic := '1';
    signal read_addr: std_logic_vector(23 downto 0) := std_logic_vector(DATA_START_ADDR);
    signal write_addr: std_logic_vector(23 downto 0) := std_logic_vector(DATA_START_ADDR);
    signal write_length: natural := 0;
    signal read_ready_internal: std_logic := '0';
    signal read_busy: std_logic := '0';
    signal curr_axi_raction: axi_action := NO_AXI_ACTION;
    signal curr_axi_waction: axi_action := NO_AXI_ACTION;
    signal save_current_flash_state_delay : natural := 0;
    signal save_current_flash_state_internal : std_logic := save_current_flash_state;
    signal axi_exp_bresp : std_logic := '0';

COMPONENT axi_quad_spi_0
  PORT (
    ext_spi_clk : IN STD_LOGIC;
    -- write address bus
    s_axi4_aclk : IN STD_LOGIC;
    s_axi4_aresetn : IN STD_LOGIC;
    s_axi4_awid : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi4_awaddr : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    s_axi4_awlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s_axi4_awsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s_axi4_awburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi4_awlock : IN STD_LOGIC;
    s_axi4_awcache : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi4_awprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s_axi4_awvalid : IN STD_LOGIC;
    s_axi4_awready : OUT STD_LOGIC;
    
    -- write dat bus
    s_axi4_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi4_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi4_wlast : IN STD_LOGIC;
    s_axi4_wvalid : IN STD_LOGIC;
    s_axi4_wready : OUT STD_LOGIC;
    -- feedback bus
    s_axi4_bid : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi4_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi4_bvalid : OUT STD_LOGIC;
    s_axi4_bready : IN STD_LOGIC;
    -- read address
    s_axi4_arid : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi4_araddr : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
    s_axi4_arlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s_axi4_arsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s_axi4_arburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi4_arlock : IN STD_LOGIC;
    s_axi4_arcache : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi4_arprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s_axi4_arvalid : IN STD_LOGIC;
    s_axi4_arready : OUT STD_LOGIC;
    -- read data
    s_axi4_rid : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi4_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi4_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi4_rlast : OUT STD_LOGIC;
    s_axi4_rvalid : OUT STD_LOGIC;
    s_axi4_rready : IN STD_LOGIC;
    
    -- IN/OUT to FLASH
    io0_i : IN STD_LOGIC;
    io0_o : OUT STD_LOGIC;
    io0_t : OUT STD_LOGIC; -- Indicates if tristate mode is enabled.
    io1_i : IN STD_LOGIC;
    io1_o : OUT STD_LOGIC;
    io1_t : OUT STD_LOGIC; -- Indicates if tristate mode is enabled.
    io2_i : IN STD_LOGIC;
    io2_o : OUT STD_LOGIC;
    io2_t : OUT STD_LOGIC; -- Indicates if tristate mode is enabled.
    io3_i : IN STD_LOGIC;
    io3_o : OUT STD_LOGIC;
    io3_t : OUT STD_LOGIC; -- Indicates if tristate mode is enabled.
    ss_i : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    ss_o : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    ss_t : OUT STD_LOGIC;
    cfgclk : OUT STD_LOGIC;
    cfgmclk : OUT STD_LOGIC;
    eos : OUT STD_LOGIC;
    preq : OUT STD_LOGIC;
    ip2intc_irpt : OUT STD_LOGIC 
  );
END COMPONENT;
begin

AXI_SPI: axi_quad_spi_0
    port map(
    ext_spi_clk => ext_spi_clk,
    s_axi4_aclk => s_axi4_aclk,
    s_axi4_aresetn => s_axi4_aresetn,
    s_axi4_awid => s_axi4_awid,
    s_axi4_awaddr => s_axi4_awaddr,
    s_axi4_awlen => s_axi4_awlen,
    s_axi4_awsize => s_axi4_awsize,
    s_axi4_awburst => s_axi4_awburst,
    s_axi4_awlock => s_axi4_awlock,
    s_axi4_awcache => s_axi4_awcache,
    s_axi4_awprot => s_axi4_awprot,
    s_axi4_awvalid => s_axi4_awvalid,
    s_axi4_awready => s_axi4_awready,
    s_axi4_wdata => s_axi4_wdata,
    s_axi4_wstrb => s_axi4_wstrb,
    s_axi4_wlast => s_axi4_wlast,
    s_axi4_wvalid => s_axi4_wvalid,
    s_axi4_wready => s_axi4_wready,
    s_axi4_bid => s_axi4_bid,
    s_axi4_bresp => s_axi4_bresp,
    s_axi4_bvalid => s_axi4_bvalid,
    s_axi4_bready => s_axi4_bready,
    s_axi4_arid => s_axi4_arid,
    s_axi4_araddr => s_axi4_araddr,
    s_axi4_arlen => s_axi4_arlen,
    s_axi4_arsize => s_axi4_arsize,
    s_axi4_arburst => s_axi4_arburst,
    s_axi4_arlock => s_axi4_arlock,
    s_axi4_arcache => s_axi4_arcache,
    s_axi4_arprot => s_axi4_arprot,
    s_axi4_arvalid => s_axi4_arvalid,
    s_axi4_arready => s_axi4_arready,
    s_axi4_rid => s_axi4_rid,
    s_axi4_rdata => s_axi4_rdata,
    s_axi4_rresp => s_axi4_rresp,
    s_axi4_rlast => s_axi4_rlast,
    s_axi4_rvalid => s_axi4_rvalid,
    s_axi4_rready => s_axi4_rready,
    io0_i => io0,
    io0_o => io0,
    io0_t => io0_tt,
    io1_i => io1,
    io1_o => io1,
    io1_t => io1_tt,
    io2_i => io2,
    io2_o => io2,
    io2_t => io2_tt,
    io3_i => io3,
    io3_o => io3,
    io3_t => io3_tt,
    ss_i(0) => ss(0),
    ss_o(0) => ss(0),
    ss_t => ss_tt,
    cfgclk => cfgclk,
    cfgmclk => cfgmclk,
    eos => eos,
    preq => preq,
    ip2intc_irpt => ip2intc_irpt
    );
    
    process(clk)
    begin
      -- NOTE:
      -- Add Sector/block erase command directly to FLASH.
      
      if(clk'event and clk = '1')
      then
	-- Write a data entry to flash. NOTE: Make it use burst.
        if(new_data /= new_data_internal)
        then
            new_data_internal <= new_data;
            if(bit_progress_write >= 64) -- Check if write address is lower than read address.
            then
		curr_axi_waction <= AXI_WRITE_DATA;
                new_data_read_internal <= std_logic_vector(new_data_struct.timestamp) & std_logic_vector(new_data_struct.temp_data);
                bit_progress_write <= 0;
                write_length <= new_data_read_internal'length;
		s_axi4_awburst <= "01";
		s_axi4_awlen <= "00000010";
		s_axi4_awsize <= "011";
                s_axi4_awaddr <= write_addr;
                --s_axi4_wdata <= new_data_read_internal(bit_progress_write + 32 downto bit_progress_write);
                --bit_progress_write <= bit_progress_write + 32;
                --s_axi4_wvalid <= '1';
                s_axi4_awvalid <= '1';
                
            end if;
        end if;

	if(curr_axi_waction = AXI_WRITE_DATA)
	then
		if(s_axi4_wready = '1') -- Make sure that read address is before write address.
		then
			s_axi4_wdata <= new_data_read_internal(bit_progress_write + 31 downto bit_progress_write);
			bit_progress_write <= bit_progress_write + 32;
			s_axi4_wstrb <= "1111";
			if(bit_progress_write >= write_length - 32)
			then
				s_axi4_wlast <= '1';
				s_axi4_bready <= '1';
				axi_exp_bresp <= '1';
			end if;
			s_axi4_wvalid <= '1';
		else
			s_axi4_wvalid <= '0';
		end if;
		if(axi_exp_bresp = '1' and s_axi4_bvalid = '1')
		then
			axi_exp_bresp <= '0';
			if(s_axi4_bresp = "00") -- Code for success non exclusive access
			then
				write_addr <= std_logic_vector(to_unsigned((to_integer(unsigned(write_addr)) + write_length), write_addr'length));
			end if;
			curr_axi_waction <= NO_AXI_ACTION;
		end if;

	end if;

	-- Continue write
        if(bit_progress_write < write_length)
        then
            s_axi4_wdata <= new_data_read_internal(bit_progress_write downto bit_progress_write - 31);
            s_axi4_awaddr <= std_logic_vector(to_unsigned((TO_INTEGER(unsigned(write_addr)) + bit_progress_write), s_axi4_awaddr'length));
            
        else
            s_axi4_awvalid <= '0';
            s_axi4_wvalid <= '0';
            -- check b register for success.
        end if;
        

	-- Initiate burst read of one entry
        if(read_request = '1' and read_busy = '0')
        then
            read_busy <= '1';
	    bit_progress_read <= 0;
	    s_axi4_araddr <= read_addr;
	    curr_axi_raction <= AXI_READ_DATA;
	    s_axi4_arburst <= "01";
	    s_axi4_arlen <= "00000010";
	    s_axi4_arsize <= "011";
	    -- Set two bytes burst read
	    s_axi4_arvalid <= '1'; -- Keep high until arready = '1';

        end if;
        
        if(read_ready_internal = '1')
        then
            read_ready <= '0';
            read_ready_internal <= '0';
            read_busy <= '0';
        end if;



	if(save_current_flash_state_delay /= 0)
	then
		if(save_current_flash_state_delay < 100000)
		then
			save_current_flash_state_delay <= save_current_flash_state_delay + 1;
		else
			save_current_flash_state_delay <= 0;
		end if;
	end if; 
	-- Write current flash start and end addresses in flash
	if(save_current_flash_state_internal = '1' and save_current_flash_state_delay = 0)
	then
		s_axi4_awburst <= "01";	
		s_axi4_awsize <= "011";
		s_axi4_awlen <= "00000010";
		s_axi4_awaddr <= std_logic_vector(CONFIG_START_ADDR);
		s_axi4_awvalid <= '1';

		write_length <= 64; --This line crashes simulation.
		bit_progress_write <= 0;
		curr_axi_waction <= AXI_WRITE_ADDR;
	end if;
	if(s_axi4_awready = '1')
	then
		s_axi4_awvalid <= '0';
	end if;
	

	-- Write address info
	if(curr_axi_waction = AXI_WRITE_ADDR)
	then
		if(s_axi4_wready = '1')
		then
			if(bit_progress_write = 0)
			then
				s_axi4_wdata(23 downto 0) <= read_addr;
				s_axi4_wvalid <= '1';
			else 	
				if(bit_progress_write >= 32)
				then
					s_axi4_wdata(23 downto 0) <= write_addr;
					s_axi4_wvalid <= '1';
					s_axi4_wlast <= '1';
					exp_slave_resp <= '1';
					s_axi4_bready <= '1';
				end if;
			end if;
			bit_progress_write <= bit_progress_write + 32;
		end if;	
		--if(bit_progress_write >= write_length)
		--then 
			--curr_axi_action <= NO_AXI_ACTION;
		--end if;
		if(s_axi4_wlast = '1')
		then
			s_axi4_wlast <= '0';
		end if;
	end if;

	if(exp_slave_resp = '1')
	then
		if(s_axi4_bvalid = '1')
		then
			if(s_axi4_bresp = "00")
			then
			end if;	
			s_axi4_bready <= '0';
			exp_slave_resp <= '0';
			curr_axi_waction <= NO_AXI_ACTION;
			-- s_axi4_awready <= '0';
			-- s_axi4_wready <= '0';
			
			write_addr <= std_logic_vector(to_unsigned((to_integer(unsigned(write_addr)) + bit_progress_write), write_addr'length));
		end if;	
	end if;
	-- Initiate flash locations Make this happen only when a switch is selected.
        if(init_flash = '1') -- Read memory with info about write and read address.
        then
	    if(reset_flash_on_init = '1') -- Should write flash state as start addresses.
	    then
		   save_current_flash_state_internal <= '1';
		   save_current_flash_state_delay <= save_current_flash_state_delay + 1;
	    else -- Initiate reading of flash address.
		    -- if(read_addr <= write_addr)
		    -- then
		    read_busy <= '1';
		    bit_progress_read <= 0;
		    s_axi4_araddr <= std_logic_vector(CONFIG_START_ADDR);
		    curr_axi_raction <= AXI_READ_ADDR;
		    s_axi4_arburst <= "01";
		    s_axi4_arlen <= "00000010";
		    s_axi4_arsize <= "011";
		    -- Set two bytes burst read
		    s_axi4_arvalid <= '1'; -- Keep high until arready = '1';
	    end if;
	    -- incremental burst(arburst = '0b01', 00 - fixed, 10 - wrap)
	    -- size per transfer = 4(arsize = 4);
            -- end if;
            -- read config address and write start addr to register
            -- add option to delete previous info
            init_flash <= '0';
        end if;    
	if(save_current_flash_state_internal = '1')
	then
		save_current_flash_state_internal <= '0';
        end if;
        
	-- Read next word form burst
        if(s_axi4_rvalid = '1') 
        then
            case s_axi4_rresp is
            when "00" => s_axi4_rready <= '1'; -- OKAY
--            when "01" =>; -- EXOK case
--            when "10" => s_axi4_rready <= '1'; -- slave error case
--            when "11" =>; -- decode error
	    when others => s_axi4_rready <= '0';
            end case;

            bit_progress_read <= bit_progress_read + 32;
	    -- When reading data
	    if(curr_axi_raction = AXI_READ_ADDR)
	    then
		   -- read address first, write address second.
		    if(bit_progress_read < 64)
		    then
			    case bit_progress_read
			    is
				    when 0 to 31 => read_addr(23 downto 0) <= s_axi4_rdata(23 downto 0);
				    when others => write_addr(23 downto 0) <= s_axi4_rdata(23 downto 0);
			    end case;
			    if(bit_progress_read = 0)
			    then
			    end if;	
			    bit_progress_read <= bit_progress_read + 32;
		    else
		    end if;

	    end if;
	    -- When reading spi for begin and end locations of data.
            if(curr_axi_raction = AXI_READ_DATA)
            then 
		    if(bit_progress_read < 64)
		    then
			    case bit_progress_read
			    is
				    when 0 to 31 => new_data_read.timestamp <= s_axi4_rdata;
				    when others => new_data_read.temp_data <= signed(s_axi4_rdata);
			    end case;
			    if(bit_progress_read = 0)
			    then
			    end if;	
			    bit_progress_read <= bit_progress_read + 32;
		    else
		    end if;
           		 
	    end if;
	    -- When last word from read is received.
	    if(s_axi4_rlast = '1')
	    then
		if(curr_axi_raction = AXI_READ_DATA)
		then
			read_ready <= '1';
		end if;
		curr_axi_raction <= NO_AXI_ACTION;
		read_busy <= '0';
	    else
		read_ready <= '0';
	    end if;

        else
            s_axi4_rready <= '0';
        end if;
        
        
        -- rdata handle:
        -- Read data are kept on port until rready goes high.
        -- rready needs to go high for each word read from flash
        -- Last data is receiverd on rlast.
        -- Need to get success on rresp.
	-- Add write address functionality.
        
      end if;  
    end process;


end Behavioral;

