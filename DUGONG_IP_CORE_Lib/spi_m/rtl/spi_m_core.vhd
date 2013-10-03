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
-- Name:		SPI_M_CORE (003)
-- Type:		CORE (3)
-- Description: 	A core which forwards SPI data out to OFF-CHIP SPI slaves. Has a generic CORE_DATA_WIDTH
--			which corresponds to the length of the SPI data transfer. No assumptions are made as to
--			the content of the data. The input has a FIFO, however, it is up to the user to ensure 
--			that the data rate does not exceed the SPI's capacity. Excess data is just ignored.
--
-- Compliance:		DUGONG V0.3
-- ID:			x 0-3-3-003
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

entity spi_m_core is
	generic(
		CORE_DATA_WIDTH : natural   := 32;
		CORE_ADDR_WIDTH : natural   := 3;
		SPI_CPHA        : std_logic := '0';
		SPI_BIG_ENDIAN  : std_logic := '1'
	);
	port(
		--System Control Inputs
		CLK_I       : in  STD_LOGIC;
		RST_I       : in  STD_LOGIC;
		--Wishbone Slave Lines
		ADR_I       : in  STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0);
		DAT_I       : in  STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
		DAT_O       : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
		WE_I        : in  STD_LOGIC;
		STB_I       : in  STD_LOGIC;
		ACK_O       : out STD_LOGIC;
		CYC_I       : in  STD_LOGIC;
		--SPI Interface
		SPI_CLK_I   : in  STD_LOGIC;
		SPI_CE      : in  STD_LOGIC;
		SPI_BUS_REQ : out STD_LOGIC;
		SPI_MOSI    : out STD_LOGIC;
		SPI_MISO    : in  STD_LOGIC;
		SPI_N_SS    : out STD_LOGIC
	);
end spi_m_core;

architecture Behavioral of spi_m_core is
	---------------------------------
	----------{ BUS LOGIC }----------
	---------------------------------

	subtype small_int is integer range 0 to 2 ** CORE_ADDR_WIDTH - 5;
	type t is array (0 to (2 ** CORE_ADDR_WIDTH) - 5) of small_int;

	---------------------------------
	--DEFINE MEMORY STRUCTURE HERE --
	---------------------------------
	constant NUMBER_OF_REGISTERS : natural := 0;
	constant NUMBER_OF_FIFOS     : natural := 1;
	constant user_addr           : t       := (0, 1, 2, 3); --Addresses of registers followed by Addresses of FIFOs followed by Addresses of Latches
	--------------------------------------------------
	--	ADDR	| NAME		| Type		--
	--	0	| SPI_OUT(n)	| WB_FIFO	--
	-- 	1	| SPI_IN(n-1)	| WB_LATCH	--
	-- 	2	| SPI_OUT(n-1)	| WB_LATCH	--
	-- 	3	| XFER_COUNT	| WB_LATCH	--
	--------------------------------------------------

	----------------------------------------
	--END OF MEMEORY STRUCTURE DEFINITION --
	----------------------------------------

	--User memory architecture
	type ram_type is array (0 to (2 ** CORE_ADDR_WIDTH) - 5) of std_logic_vector(CORE_DATA_WIDTH - 1 downto 0);
	signal user_D   : ram_type                                                := (others => (others => '0'));
	signal user_Q   : ram_type                                                := (others => (others => '0'));
	signal user_stb : std_logic_vector(((2 ** CORE_ADDR_WIDTH) - 5) downto 0) := (others => '0');
	signal user_ack : std_logic_vector(((2 ** CORE_ADDR_WIDTH) - 5) downto 0) := (others => '0');

	signal wb_addr : small_int;

	signal fifo_stb   : std_logic;
	signal fifo_ack   : std_logic;
	signal fifo_empty : std_logic;

	----------------------------------
	----------{ USER LOGIC }----------
	----------------------------------

	component spi_m is
		generic(
			SPI_DATA_WIDTH : natural   := 32;
			SPI_CPHA       : std_logic := '0';
			SPI_BIG_ENDIAN : std_logic := '1'
		);
		port(
			--System Control Inputs
			RST_I         : in  STD_LOGIC;
			--Bus Logic Interface
			TX_DATA_I     : in  STD_LOGIC_VECTOR(SPI_DATA_WIDTH - 1 downto 0);
			RX_DATA_O     : out STD_LOGIC_VECTOR(SPI_DATA_WIDTH - 1 downto 0);
			TX_FEEDBACK_O : out STD_LOGIC_VECTOR(SPI_DATA_WIDTH - 1 downto 0);
			XFER_COUNT_O  : out STD_LOGIC_VECTOR(SPI_DATA_WIDTH - 1 downto 0);
			FIFO_STB      : out STD_LOGIC;
			FIFO_ACK      : in  STD_LOGIC;
			FIFO_EMPTY    : in  STD_LOGIC;
			--SPI Interface
			SPI_CLK_I     : in  STD_LOGIC;
			SPI_CE        : in  STD_LOGIC;
			SPI_BUS_REQ   : out STD_LOGIC;
			SPI_MOSI      : out STD_LOGIC;
			SPI_MISO      : in  STD_LOGIC;
			SPI_N_SS      : out STD_LOGIC
		);
	end component spi_m;

begin
	---------------------------------
	----------{ BUS LOGIC }----------
	---------------------------------

	wb_addr <= to_integer(unsigned(ADR_I));

	--Generate WB registers
	user_registers : if (NUMBER_OF_REGISTERS > 0) generate
	begin
		user_registers : for i in 0 to (NUMBER_OF_REGISTERS - 1) generate
		begin
			--WISHBONE Register
			reg : wb_register
				generic map(
					DATA_WIDTH   => CORE_DATA_WIDTH,
					DEFAULT_DATA => x"00000000"
				)
				port map(
					CLK_I => CLK_I,
					RST_I => RST_I,
					DAT_I => user_D(user_addr(i)),
					DAT_O => user_Q(user_addr(i)),
					WE_I  => WE_I,
					STB_I => user_stb(user_addr(i)),
					ACK_O => user_ack(user_addr(i))
				);

			user_D(user_addr(i)) <= DAT_I;
		end generate user_registers;
	end generate user_registers;

	--Generate WB FIFOs
	user_fifos : if (NUMBER_OF_FIFOs > 0) generate
	begin
		user_fifos : for i in NUMBER_OF_REGISTERS to (NUMBER_OF_REGISTERS + NUMBER_OF_FIFOS - 1) generate
		begin
			--WISHBONE FIFOs
			fifo : wb_fifo
				generic map(
					DATA_WIDTH => CORE_DATA_WIDTH,
					FIFO_DEPTH => 4
				)
				port map(
					RST_I    => RST_I,
					WR_CLK_I => CLK_I,
					WR_DAT_I => user_D(user_addr(i)),
					WR_WE_I  => WE_I,
					WR_STB_I => user_stb(user_addr(i)),
					WR_ACK_O => user_ack(user_addr(i)),
					RD_CLK_I => SPI_CLK_I,
					RD_DAT_O => user_Q(user_addr(i)),
					RD_STB_I => fifo_stb,
					RD_ACK_O => fifo_ack,
					FULL     => open,
					EMPTY    => fifo_empty
				);

			user_D(user_addr(i)) <= DAT_I;
		end generate user_fifos;
	end generate user_fifos;

	--Generate WB Latches
	user_latches : if ((2 ** CORE_ADDR_WIDTH) - 4) /= NUMBER_OF_REGISTERS + NUMBER_OF_FIFOS generate
	begin
		user_latches : for i in NUMBER_OF_REGISTERS + NUMBER_OF_FIFOS to ((2 ** CORE_ADDR_WIDTH) - 5) generate
		begin
			--WISHBONE Latches
			latch : wb_latch
				generic map(
					DATA_WIDTH => CORE_DATA_WIDTH
				)
				port map(
					CLK_I => CLK_I,
					RST_I => RST_I,
					DAT_I => user_D(user_addr(i)),
					DAT_O => user_Q(user_addr(i)),
					STB_I => user_stb(user_addr(i)),
					ACK_O => user_ack(user_addr(i))
				);
		end generate user_latches;
	end generate user_latches;

	--Generate user Strobe lines
	user_registers_control : for i in 0 to ((2 ** CORE_ADDR_WIDTH) - 5) generate
	begin
		--Check for valid addr
		user_stb(i) <= (STB_I and CYC_I) when (wb_addr = i) else '0';
	end generate user_registers_control;

	DAT_O <= user_Q(wb_addr);
	ACK_O <= user_ack(wb_addr);

	----------------------------------
	----------{ USER LOGIC }----------
	----------------------------------

	user_logic : spi_m
		generic map(
			SPI_DATA_WIDTH => CORE_DATA_WIDTH,
			SPI_CPHA       => SPI_CPHA,
			SPI_BIG_ENDIAN => SPI_BIG_ENDIAN
		)
		port map(
			RST_I         => RST_I,
			TX_DATA_I     => user_Q(0),
			RX_DATA_O     => user_D(1),
			TX_FEEDBACK_O => user_D(2),
			XFER_COUNT_O  => user_D(3),
			FIFO_STB      => fifo_stb,
			FIFO_ACK      => fifo_ack,
			FIFO_EMPTY    => fifo_empty,
			SPI_CLK_I     => SPI_CLK_I,
			SPI_CE        => SPI_CE,
			SPI_BUS_REQ   => SPI_BUS_REQ,
			SPI_MOSI      => SPI_MOSI,
			SPI_MISO      => SPI_MISO,
			SPI_N_SS      => SPI_N_SS
		);

end Behavioral;