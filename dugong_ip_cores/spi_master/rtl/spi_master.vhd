----------------------------------------------------------------------------------
-- Company: University of Cape Town
-- Engineer: Matthew Bridges 
-- 
-- Create Date:    11:43:28 06/19/2012 
-- Design Name: 
-- Module Name:    spi_master - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use IEEE.NUMERIC_STD.ALL;

library unisim;
use unisim.vcomponents.all;

entity spi_master is
	generic(
		DATA_WIDTH     : natural := 8;
		ADDR_WIDTH     : natural := 5;
		SPI_INST_WIDTH : natural := 8;
		SPI_DATA_WIDTH : natural := 8
	);
	port(
		--System Control Inputs
		CLK_I    : in  STD_LOGIC;
		RST_I    : in  STD_LOGIC;
		--Wishbone Slave Lines
		DAT_I    : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DAT_O    : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		ADR_I    : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		STB_I    : in  STD_LOGIC;
		WE_I     : in  STD_LOGIC;
		--		CYC_I : in   STD_LOGIC;
		ACK_O    : out STD_LOGIC;
		--Serial Peripheral Interface
		SCLK_O   : out  STD_LOGIC;
		SPI_CLK  : out STD_LOGIC;
		SPI_MOSI : out STD_LOGIC;
		SPI_MISO : in  STD_LOGIC;
		SPI_N_SS : out STD_LOGIC
	);
end spi_master;

architecture Behavioral of spi_master is
	type ram_type is array (0 to (2 ** ADDR_WIDTH) - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal user_mem   : ram_type;
	signal data_valid : std_logic_vector(0 to (2 ** ADDR_WIDTH) - 1) := (others => '0');
	signal mem_adr    : integer;
	--	constant MSB : natural := SPI_INST_WIDTH + SPI_DATA_WIDTH - 1;

	-- Input clock buffering / unused connectors
	--	signal spi_clk_b       : std_ulogic;
	-- Output clock buffering
	signal spi_clk_pb      : std_ulogic;
	signal spi_clk2_pb      : std_ulogic;
	signal clkout0         : std_ulogic;
	signal clkout0_b       : std_ulogic;
	signal clkout1         : std_ulogic;
	signal clkout1_b       : std_ulogic;
	signal clkfbout        : std_ulogic;
	signal locked_internal : std_logic;

	signal c0 : std_logic;
	signal c1 : std_logic;

	signal idle    : boolean;
	signal reading : boolean;

	signal mem_stb : boolean;
	signal mem_ack : boolean;

	signal adr           : unsigned(ADDR_WIDTH - 1 downto 0);
	signal transfer_data : std_logic_vector(SPI_DATA_WIDTH - 1 downto 0);
	signal transfer_inst : std_logic_vector(SPI_INST_WIDTH - 1 downto 0);
	signal transfer_bit  : integer;

begin

	-- PLL_BASE: Phase Locked Loop (PLL) Clock Management Component
	--           Spartan-6
	-- Xilinx HDL Libraries Guide, version 14.1

	SYS_CLK_PLL_BASE : PLL_BASE
		generic map(
			BANDWIDTH             => "OPTIMIZED", -- "HIGH", "LOW" or "OPTIMIZED"
			CLKFBOUT_MULT         => 4, -- Multiply value for all CLKOUT clock outputs (1-64)
			CLKFBOUT_PHASE        => 0.0, -- Phase offset in degrees of the clock feedback output (0.0-360.0).
			CLKIN_PERIOD          => 10.0, -- Input clock period in ns to ps resolution (i.e. 33.333 is 30MHz).
			-- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for CLKOUT# clock output (1-128)
			CLKOUT0_DIVIDE        => 64,
			CLKOUT1_DIVIDE        => 64,
			CLKOUT2_DIVIDE        => 1,
			CLKOUT3_DIVIDE        => 1,
			CLKOUT4_DIVIDE        => 1,
			CLKOUT5_DIVIDE        => 1,
			-- CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for CLKOUT# clock output (0.01-0.99).
			CLKOUT0_DUTY_CYCLE    => 0.5,
			CLKOUT1_DUTY_CYCLE    => 0.5,
			CLKOUT2_DUTY_CYCLE    => 0.5,
			CLKOUT3_DUTY_CYCLE    => 0.5,
			CLKOUT4_DUTY_CYCLE    => 0.5,
			CLKOUT5_DUTY_CYCLE    => 0.5,
			-- CLKOUT0_PHASE - CLKOUT5_PHASE: Output phase relationship for CLKOUT# clock output (-360.0-360.0).
			CLKOUT0_PHASE         => 0.0,
			CLKOUT1_PHASE         => 180.0,
			CLKOUT2_PHASE         => 0.0,
			CLKOUT3_PHASE         => 0.0,
			CLKOUT4_PHASE         => 0.0,
			CLKOUT5_PHASE         => 0.0,
			CLK_FEEDBACK          => "CLKFBOUT", -- Clock source to drive CLKFBIN ("CLKFBOUT" or "CLKOUT0")
			COMPENSATION          => "SYSTEM_SYNCHRONOUS", -- "SYSTEM_SYNCHRONOUS", "SOURCE_SYNCHRONOUS", "EXTERNAL"
			DIVCLK_DIVIDE         => 1, -- Division value for all output clocks (1-52)
			REF_JITTER            => 0.100, -- Reference Clock Jitter in UI (0.000-0.999).
			RESET_ON_LOSS_OF_LOCK => FALSE -- Must be set to FALSE
		)
		port map(
			CLKFBOUT => clkfbout,       -- 1-bit output: PLL_BASE feedback output
			-- CLKOUT0 - CLKOUT5: 1-bit (each) output: Clock outputs
			CLKOUT0  => clkout0,
			CLKOUT1  => clkout1,
			CLKOUT2  => open,
			CLKOUT3  => open,
			CLKOUT4  => open,
			CLKOUT5  => open,
			LOCKED   => locked_internal, -- 1-bit output: PLL_BASE lock status output
			CLKFBIN  => clkfbout,       -- 1-bit input: Feedback clock input
			CLKIN    => CLK_I,          -- 1-bit input: Clock input
			RST      => RST_I           -- 1-bit input: Reset input
		);

	-- End of PLL_BASE_inst instantiation

	clkout0_buf : BUFG
		port map(
			O => clkout0_b,
			I => clkout0
		);

	c0 <= clkout0;

	clkout1_buf : BUFG
		port map(
			O => clkout1_b,
			I => clkout1
		);

	c1 <= clkout1;

	process(CLK_I)
	begin

		--Perform Clock Rising Edge operations
		if (rising_edge(CLK_I)) then

			--Check for reset
			if (RST_I = '1') then
				DAT_O          <= (others => '0');
				user_mem(0)    <= "10101010";
				data_valid(0)  <= '1';
				user_mem(23)   <= "00000100";
				data_valid(23) <= '1';
			--Check for strobe
			elsif (STB_I = '1') then
				DAT_O <= user_mem(mem_adr);
				--Check for write
				if (WE_I = '1') then
					user_mem(mem_adr)   <= DAT_I;
					data_valid(mem_adr) <= '1';
				end if;
			elsif (mem_stb) then
				if (reading) then
					user_mem(mem_adr) <= transfer_data;
				else
					data_valid(mem_adr) <= '0';
				end if;
				mem_ack <= true;
			else
				mem_ack <= false;
			end if;
			ACK_O <= STB_I;
		end if;
	end process;

	mem_adr <= to_integer(unsigned(ADR_I)) when (STB_I = '1') else to_integer(adr);

	--SPI Shifter Process
	process(c0)
	begin
		--Perform Rising Edge operations
		if (rising_edge(c0)) then
			if (RST_I = '1') then
				adr      <= (others => '0');
				idle     <= true;
				SPI_MOSI <= '0';
				SPI_N_SS <= '1';
			----			elsif (STB_I = '0') then
			----				--Check if there is Data Pending then start new SPI Transfer
			elsif (idle) then
				transfer_inst(ADDR_WIDTH - 1 downto 0) <= std_logic_vector(adr);
				transfer_inst(SPI_INST_WIDTH - 2)      <= '0';
				transfer_inst(SPI_INST_WIDTH - 3)      <= '0';

				if (data_valid(to_integer(adr)) = '1') then
					transfer_inst(SPI_INST_WIDTH - 1) <= '0';
					reading                           <= false;
					transfer_data                     <= user_mem(to_integer(adr));
				else
					transfer_inst(SPI_INST_WIDTH - 1) <= '1';
					reading                           <= true;
				end if;

				transfer_bit <= SPI_INST_WIDTH + SPI_DATA_WIDTH - 1;
				idle         <= false;

			--Check if SPI transfer has completed
			elsif (mem_stb and mem_ack) then
				mem_stb <= false;
				idle    <= true;
				adr     <= adr + 1;
			else
				if (transfer_bit < 0) then
					mem_stb  <= true;
					SPI_MOSI <= '0';
					SPI_N_SS <= '1';
				elsif (transfer_bit < 8) then
					if (reading) then
						SPI_MOSI                    <= '0';
						transfer_data(transfer_bit) <= SPI_MISO;
					else
						SPI_MOSI <= transfer_data(transfer_bit);
					end if;
				else
					SPI_MOSI <= transfer_inst(transfer_bit - 8);
					SPI_N_SS <= '0';
				end if;
				--Decrement Transfer bit;
				transfer_bit <= transfer_bit - 1;
			end if;
		end if;
	end process;

	--ODDR for Clock Forwarding
	SPI_CLK_ODDR2 : ODDR2
		generic map(
			DDR_ALIGNMENT => "NONE",    -- Sets output alignment to "NONE", "C0", "C1"
			INIT          => '0',       -- Sets initial state of the Q output to '0' or '1'
			SRTYPE        => "SYNC")    -- Specifies "SYNC" or "ASYNC" set/reset
		port map(
			Q  => spi_clk_pb,           -- 1-bit output data
			C0 => clkout0_b,            -- 1-bit clock input
			C1 => clkout1_b,            -- 1-bit clock input
			CE => locked_internal,      -- 1-bit clock enable input
			D0 => '0',                  -- 1-bit data input (associated with C0)
			D1 => '1',                  -- 1-bit data input (associated with C1)
			R  => '0',                  -- 1-bit reset input
			S  => '0'                   -- 1-bit set input
		);

	-- Output buffering
	SPI_CLK_OBUF : OBUF
		port map(
			O => SPI_CLK,
			I => spi_clk_pb
		);
		
		--ODDR for Clock Forwarding
	SPI_CLK2_ODDR2 : ODDR2
		generic map(
			DDR_ALIGNMENT => "NONE",    -- Sets output alignment to "NONE", "C0", "C1"
			INIT          => '0',       -- Sets initial state of the Q output to '0' or '1'
			SRTYPE        => "SYNC")    -- Specifies "SYNC" or "ASYNC" set/reset
		port map(
			Q  => spi_clk2_pb,           -- 1-bit output data
			C0 => clkout0_b,            -- 1-bit clock input
			C1 => clkout1_b,            -- 1-bit clock input
			CE => locked_internal,      -- 1-bit clock enable input
			D0 => '0',                  -- 1-bit data input (associated with C0)
			D1 => '1',                  -- 1-bit data input (associated with C1)
			R  => '0',                  -- 1-bit reset input
			S  => '0'                   -- 1-bit set input
		);
		
	-- Output buffering
	SPI_CLK2_OBUF : OBUF
		port map(
			O => SCLK_O,
			I => spi_clk2_pb
		);

end Behavioral;

