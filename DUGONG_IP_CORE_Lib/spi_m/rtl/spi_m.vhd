--
-- _______/\\\\\\\\\_______/\\\________/\\\____/\\\\\\\\\\\____/\\\\\_____/\\\_________/\\\\\________
-- \ ____/\\\///////\\\____\/\\\_______\/\\\___\/////\\\///____\/\\\\\\___\/\\\_______/\\\///\\\_____\
--  \ ___\/\\\_____\/\\\____\/\\\_______\/\\\_______\/\\\_______\/\\\/\\\__\/\\\_____/\\\/__\///\\\___\
--   \ ___\/\\\\\\\\\\\/_____\/\\\\\\\\\\\\\\\_______\/\\\_______\/\\\//\\\_\/\\\____/\\\______\//\\\__\
--    \ ___\/\\\//////\\\_____\/\\\/////////\\\_______\/\\\_______\/\\\\//\\\\/\\\___\/\\\_______\/\\\__\
--     \ ___\/\\\____\//\\\____\/\\\_______\/\\\_______\/\\\_______\/\\\_\//\\\/\\\___\//\\\______/\\\___\
--      \ ___\/\\\_____\//\\\___\/\\\_______\/\\\_______\/\\\_______\/\\\__\//\\\\\\____\///\\\__/\\\_____\
--       \ ___\/\\\______\//\\\__\/\\\_______\/\\\____/\\\\\\\\\\\___\/\\\___\//\\\\\______\///\\\\\/______\
--        \ ___\///________\///___\///________\///____\///////////____\///_____\/////_________\/////________\
--         \ __________________________________________\          \__________________________________________\
--          |:------------------------------------------|: DUGONG :|-----------------------------------------:|
--         / ==========================================/          /========================================= /
--        / =============================================================================================== /
--       / ================  Reconfigurable Hardware Interface for computatioN and radiO  ================ /
--      / ===============================  http://www.rhinoplatform.org  ================================ /
--     / =============================================================================================== /
--
---------------------------------------------------------------------------------------------------------------
-- Company:		UNIVERSITY OF CAPE TOWN
-- Engineer: 		MATTHEW BRIDGES
--
-- Name:		SPI_M (003)
-- Type:		USER_LOGIC (5)
-- Description: 	Logic which forwards SPI data out to OFF-CHIP SPI slaves. Has a generic CORE_DATA_WIDTH
--			which corresponds to the length of the SPI data transfer. No assumptions are made as to
--			the content of the data. The input has a FIFO, however, it is up to the user to ensure 
--			that the data rate does not exceed the SPI's capacity. Excess data is just ignored.
--
-- Compliance:		DUGONG V0.5
-- ID:			x 0-5-3-003
--
-- Last Modified:	31-OCT-2013
-- Modified By:		MATTHEW BRIDGES
---------------------------------------------------------------------------------------------------------------
--	PORT	| NAME		| DIRECTION	--
--	0	| TX_DATA	| IN		--
-- 	1	| RX_DATA	| OUT		--
-- 	2	| TX_FEEDBACK	| OUT		--
-- 	3	| XFER_COUNT	| OUT		--
--------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

library unisim;
use unisim.vcomponents.all;

entity spi_m is
	generic(
		SPI_DATA_WIDTH  : natural   := 32;
		SPI_CPHA        : std_logic := '0';
		SPI_CPOL        : std_logic := '0';
		SPI_SCLK_OUT_EN : std_logic := '1';
		SPI_BIG_ENDIAN  : std_logic := '1'
	);
	port(
		--System Control Inputs
		RST_I         : in  STD_LOGIC;
		--Bus Logic Interface
		TX_DATA_I     : in  STD_LOGIC_VECTOR(SPI_DATA_WIDTH - 1 downto 0);
		RX_DATA_O     : out STD_LOGIC_VECTOR(SPI_DATA_WIDTH - 1 downto 0);
		TX_FEEDBACK_O : out STD_LOGIC_VECTOR(SPI_DATA_WIDTH - 1 downto 0);
		XFER_COUNT_O  : out STD_LOGIC_VECTOR(SPI_DATA_WIDTH - 1 downto 0);
		--SPI Control Signals
		SPI_CLK_P_I   : in  STD_LOGIC;
		SPI_CLK_N_I   : in  STD_LOGIC;
		SPI_ENABLE_I  : in  STD_LOGIC;
		SPI_BUSY_O    : out STD_LOGIC;
		SPI_CPOL_O    : out STD_LOGIC;
		--SPI Interface
		SPI_SCLK      : out STD_LOGIC;
		SPI_MOSI      : out STD_LOGIC;
		SPI_MISO      : in  STD_LOGIC;
		SPI_nSS       : out STD_LOGIC
	);
end spi_m;

architecture Behavioral of spi_m is
	--SPI Specific Signals	
	signal busy       : std_logic;
	signal write_data : std_logic_vector(SPI_DATA_WIDTH - 1 downto 0);
	signal read_data  : std_logic_vector(SPI_DATA_WIDTH - 1 downto 0);

	signal clock_active : std_logic;

	signal transfer_active   : std_logic;
	signal transfer_bit      : unsigned(min_num_of_bits(SPI_DATA_WIDTH - 1) - 1 downto 0);
	signal transfer_bit_buf  : unsigned(min_num_of_bits(SPI_DATA_WIDTH - 1) - 1 downto 0);
	signal transfer_complete : std_logic;
	signal shifting          : std_logic;

	signal nSS_P : std_logic;
	signal nSS_N : std_logic;

	signal count : unsigned(SPI_DATA_WIDTH - 1 downto 0);

begin
	----------------------------------
	----------{ USER LOGIC }----------
	----------------------------------

	SPI_CPOL_O <= SPI_CPOL;

	--SPI Instruction generation process
	process(SPI_CLK_N_I)
	begin
		if (rising_edge(SPI_CLK_N_I)) then
			-- RESET STATE
			if (RST_I = '1') then
				write_data    <= (others => '0');
				busy          <= '0';
				RX_DATA_O     <= (others => '0');
				TX_FEEDBACK_O <= (others => '0');
				count         <= (others => '0');
			else
				-- IDLE STATE
				if (busy = '0') then
					if (SPI_ENABLE_I = '1') then
						write_data <= TX_DATA_I;
						busy       <= '1';
					end if;
				--SHIFTING STATE
				else
					if (transfer_active = '0') then
						busy          <= '0';
						RX_DATA_O     <= read_data;
						TX_FEEDBACK_O <= write_data;
						count         <= count + 1;
					end if;
				end if;
			end if;
		end if;
	end process;

	SPI_BUSY_O <= busy;

	XFER_COUNT_O <= std_logic_vector(count);

	--Generate Downward Counter
	Bit_counter_DOWN : if (SPI_BIG_ENDIAN = '1') generate
	begin
		--Downward Counter Process
		process(SPI_CLK_P_I)
		begin
			if (rising_edge(SPI_CLK_P_I)) then
				-- RESET STATE
				if (RST_I = '1') then
					transfer_bit      <= (others => '0');
					transfer_active   <= '0';
					transfer_complete <= '1';
					clock_active      <= SPI_CPOL;
				else
					if (transfer_active = '1') then
						if (transfer_complete = '1') then
							transfer_active <= '0';
						elsif (transfer_bit = 0) then
							transfer_complete <= '1';
							clock_active      <= SPI_CPOL;
						else
							transfer_bit <= transfer_bit - 1; --Decrement Transfer bit;						
						end if;
					else
						if (busy = '1') then
							transfer_bit      <= to_unsigned(SPI_DATA_WIDTH - 1, min_num_of_bits(SPI_DATA_WIDTH - 1));
							transfer_active   <= '1';
							transfer_complete <= '0';
							clock_active      <= not SPI_CPOL;
						end if;
					end if;
				end if;
			end if;
		end process;
	end generate Bit_counter_DOWN;

	--Generate Upward Counter
	Bit_counter_UP : if (SPI_BIG_ENDIAN = '0') generate
	begin
		--Upward Counter Process
		process(SPI_CLK_P_I)
		begin
			if (rising_edge(SPI_CLK_P_I)) then
				-- RESET STATE
				if (RST_I = '1') then
					transfer_bit      <= (others => '0');
					transfer_active   <= '0';
					transfer_complete <= '1';
					clock_active      <= SPI_CPOL;
				else
					if (transfer_active = '1') then
						if (transfer_complete = '1') then
							transfer_active <= '0';
						elsif (transfer_bit = SPI_DATA_WIDTH - 1) then
							transfer_complete <= '1';
							clock_active      <= SPI_CPOL;
						else
							transfer_bit <= transfer_bit + 1; --Increment Transfer bit;						
						end if;
					elsif (busy = '1') then
						transfer_bit      <= (others => '0');
						transfer_active   <= '1';
						transfer_complete <= '0';
						clock_active      <= not SPI_CPOL;
					end if;
				end if;
			end if;
		end process;
	end generate Bit_Counter_UP;

	--SPI Shifter Process
	process(SPI_CLK_P_I)
	begin
		--Perform Clock Rising Edge operations
		if (SPI_CLK_P_I'event and SPI_CLK_P_I = (SPI_CPHA)) then
			-- RESET STATE
			if (RST_I = '1') then
				SPI_MOSI         <= 'Z';
				transfer_bit_buf <= (others => '0');
			else
				if (transfer_complete = '0') then
					SPI_MOSI         <= write_data(to_integer(transfer_bit));
					transfer_bit_buf <= transfer_bit;
					shifting         <= '1';
				else
					SPI_MOSI <= 'Z';
					shifting <= '0';
				end if;
			end if;
		end if;
		--Perform Clock Falling Edge operations
		if (SPI_CLK_P_I'event and SPI_CLK_P_I = (not SPI_CPHA)) then
			-- RESET STATE
			if (RST_I = '1') then
				read_data <= (others => '0');
			else
				if (shifting = '1') then
					read_data(to_integer(transfer_bit_buf)) <= SPI_MISO;
				end if;
			end if;
		end if;
	end process;

	process(SPI_CLK_N_I)
	begin
		if (rising_edge(SPI_CLK_N_I)) then
			nSS_N <= transfer_complete;
		end if;
	end process;

	--Create 180 degree phase shifted slave select signal
	process(SPI_CLK_P_I)
	begin
		if (rising_edge(SPI_CLK_P_I)) then
			nSS_P <= nSS_N;
		end if;
	end process;

	SPI_nSS <= (nSS_P and nSS_N);

	--Generate SPI_SCLK Output Buffer
	SCLK_Output_Buffer : if (SPI_SCLK_OUT_EN = '1') generate
	begin
		--ODDR for Clock Forwarding
		SPI_SCLK_ODDR2 : ODDR2
			generic map(
				DDR_ALIGNMENT => "C0",  -- Sets output alignment to "NONE", "C0", "C1"
				INIT          => '0', -- Sets initial state of the Q output to '0' or '1'
				SRTYPE        => "ASYNC" -- Specifies "SYNC" or "ASYNC" set/reset
			)
			port map(
				Q  => SPI_SCLK,         -- 1-bit output data
				C0 => SPI_CLK_P_I,      -- 1-bit clock input
				C1 => SPI_CLK_N_I,      -- 1-bit clock input
				CE => '1',              -- 1-bit clock enable input
				D0 => clock_active,     -- 1-bit data input (associated with C0)
				D1 => SPI_CPOL,         -- 1-bit data input (associated with C1)
				R  => RST_I,            -- 1-bit reset input
				S  => '0'               -- 1-bit set input
			);
	end generate SCLK_Output_Buffer;

	--Generate SPI_SCLK Output Status Signal
	SCLK_Output_Status : if (SPI_SCLK_OUT_EN = '0') generate
	begin
		SPI_SCLK <= clock_active;
	end generate SCLK_Output_Status;

end Behavioral;