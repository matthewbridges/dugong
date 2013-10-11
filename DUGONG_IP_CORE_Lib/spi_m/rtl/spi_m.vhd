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
-- Last Modified:	11-OCT-2013
-- Modified By:		MATTHEW BRIDGES
---------------------------------------------------------------------------------------------------------------
--	ADDR	| NAME		| Type		--
--	0	| SPI_OUT(n)	| WB_FIFO	--
-- 	1	| SPI_IN(n-1)	| WB_LATCH	--
-- 	2	| SPI_OUT(n-1)	| WB_LATCH	--
-- 	3	| XFER_COUNT	| WB_LATCH	--
--------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

entity spi_m is
	generic(
		SPI_DATA_WIDTH : natural   := 32;
		SPI_CPHA       : std_logic := '0';
		SPI_BIG_ENDIAN : std_logic := '1'
	);
	port(
		--System Control Inputs
		RST_I           : in  STD_LOGIC;
		--Bus Logic Interface
		TX_DATA_I       : in  STD_LOGIC_VECTOR(SPI_DATA_WIDTH - 1 downto 0);
		RX_DATA_O       : out STD_LOGIC_VECTOR(SPI_DATA_WIDTH - 1 downto 0);
		TX_FEEDBACK_O   : out STD_LOGIC_VECTOR(SPI_DATA_WIDTH - 1 downto 0);
		XFER_COUNT_O    : out STD_LOGIC_VECTOR(SPI_DATA_WIDTH - 1 downto 0);
		TX_DATA_VALID_I : in  STD_LOGIC;
		--SPI Interface
		SPI_CLK_I       : in  STD_LOGIC;
		SPI_BUSY        : out STD_LOGIC;
		SPI_MOSI        : out STD_LOGIC;
		SPI_MISO        : in  STD_LOGIC;
		SPI_N_SS        : out STD_LOGIC
	);
end spi_m;

architecture Behavioral of spi_m is
	--SPI Specific Signals	
	signal busy               : std_logic;
	signal mosi_busy          : std_logic;
	signal miso_busy          : std_logic;
	signal miso_busy_advanced : std_logic;
	signal write_data         : std_logic_vector(SPI_DATA_WIDTH - 1 downto 0);
	signal read_data          : std_logic_vector(SPI_DATA_WIDTH - 1 downto 0);
	signal transfer_bit       : unsigned(min_num_of_bits(SPI_DATA_WIDTH - 1) - 1 downto 0);
	signal transfer_complete  : std_logic;

	signal count : unsigned(SPI_DATA_WIDTH - 1 downto 0);

begin
	----------------------------------
	----------{ USER LOGIC }----------
	----------------------------------

	--SPI Instruction generation process
	process(SPI_CLK_I)
	begin
		if (rising_edge(SPI_CLK_I)) then
			-- RESET STATE
			if (RST_I = '1') then
				write_data <= (others => '0');
				busy       <= '0';
				count      <= (others => '0');
			else
				-- IDLE STATE
				if (busy = '0') then
					if (TX_DATA_VALID_I = '1') then
						write_data <= TX_DATA_I;
						busy       <= '1';
					end if;
				--SHIFTING STATE
				else
					if (transfer_complete = '1') then
						if ((mosi_busy and miso_busy and miso_busy_advanced) = '0') then
							RX_DATA_O     <= read_data;
							TX_FEEDBACK_O <= write_data;
							count         <= count + 1;
							busy          <= '0';
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;

	SPI_BUSY <= busy;

	--SPI Shifter Process
	process(SPI_CLK_I, RST_I)
	begin
		-- RESET STATE
		if (RST_I = '1') then
			mosi_busy          <= '0';
			miso_busy          <= '0';
			miso_busy_advanced <= '0';
			read_data          <= (others => '0');
			SPI_MOSI           <= '0';
		else
			--Perform Clock Rising Edge operations
			if (SPI_CLK_I'event and SPI_CLK_I = (SPI_CPHA)) then
				if (busy = '0') then
				else
					if (transfer_complete = '1') then
						mosi_busy <= '0';
						SPI_MOSI  <= '0';
					else
						mosi_busy <= '1';
						SPI_MOSI  <= write_data(to_integer(transfer_bit));
					end if;
				end if;
			end if;

			--Perform Clock Falling Edge operations
			if (SPI_CLK_I'event and SPI_CLK_I = (not SPI_CPHA)) then
				if (busy = '0') then
					read_data <= (others => '0');
				else
					if (transfer_complete = '1') then
						miso_busy          <= '0';
						miso_busy_advanced <= '0';
					else
						miso_busy          <= mosi_busy;
						miso_busy_advanced <= not mosi_busy;
						if (mosi_busy = '1') then
							read_data(to_integer(transfer_bit)) <= SPI_MISO;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;

	--Generate Downward Counter
	Bit_counter_DOWN : if (SPI_BIG_ENDIAN = '1') generate
	begin
		--Downward Counter Process
		process(SPI_CLK_I, RST_I)
		begin
			-- RESET STATE
			if (RST_I = '1') then
				transfer_bit      <= (others => '0');
				transfer_complete <= '0';
			else
				--Perform Clock Falling Edge operations
				if (SPI_CLK_I'event and SPI_CLK_I = (not SPI_CPHA)) then
					if (busy = '0') then
						transfer_bit      <= to_unsigned(SPI_DATA_WIDTH - 1, min_num_of_bits(SPI_DATA_WIDTH - 1));
						transfer_complete <= '0';
					else
						if (transfer_bit = 0) then
							transfer_complete <= '1';
						elsif (mosi_busy = '1') then
							transfer_bit <= transfer_bit - 1; --Decrement Transfer bit;
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
		process(SPI_CLK_I, RST_I)
		begin
			-- RESET STATE
			if (RST_I = '1') then
				transfer_bit      <= (others => '0');
				transfer_complete <= '0';
			else
				--Perform Clock Falling Edge operations
				if (SPI_CLK_I'event and SPI_CLK_I = (not SPI_CPHA)) then
					if (busy = '0') then
						transfer_bit      <= (others => '0');
						transfer_complete <= '0';
					else
						if (transfer_bit = SPI_DATA_WIDTH - 1) then
							transfer_complete <= '1';
						elsif (mosi_busy = '1') then
							transfer_bit <= transfer_bit + 1; --Decrement Transfer bit;
						end if;
					end if;
				end if;
			end if;
		end process;
	end generate Bit_Counter_UP;

	CPHA_0_N_SS : if (SPI_CPHA = '0') generate
	begin
		SPI_N_SS <= not (mosi_busy);    -- or miso_busy);
	end generate CPHA_0_N_SS;

	CPHA_1_N_SS : if (SPI_CPHA = '1') generate
	begin
		SPI_N_SS <= not (mosi_busy or miso_busy_advanced);
	end generate CPHA_1_N_SS;

	XFER_COUNT_O <= std_logic_vector(count);

end Behavioral;