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
-- Name:		WB_MULTI_LATCH (008)
-- Type:		CORE (3)
-- Description: 	
--
-- Compliance:		DUGONG V0.5
-- ID:			x 0-5-3-008
---------------------------------------------------------------------------------------------------------------
--	ADDR	| NAME		| Type		--
--	0	| LATCH_D[0]	| WB_LATCH	--
-- 	1	| LATCH_D[1]	| WB_LATCH	--
-- 	2	| LATCH_D[2]	| WB_LATCH	--
-- 	3	| LATCH_D[3]	| WB_LATCH	--
--------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

entity wb_multi_register_core is
	generic(
		CORE_DATA_WIDTH : natural := 32;
		CORE_ADDR_WIDTH : natural := 3
	);
	port(
		--System Control Inputs
		CLK_I : in  STD_LOGIC;
		RST_I : in  STD_LOGIC;
		--Wishbone Slave Lines
		ADR_I : in  STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0);
		DAT_I : in  STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
		DAT_O : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
		WE_I  : in  STD_LOGIC;
		STB_I : in  STD_LOGIC;
		ACK_O : out STD_LOGIC;
		CYC_I : in  STD_LOGIC;
		--REGISTER Outputs
		Q0    : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
		Q1    : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
		Q2    : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
		Q3    : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0)
	);
end entity wb_multi_register_core;

architecture Behavioral of wb_multi_register_core is
	---------------------------------
	----------{ BUS LOGIC }----------
	---------------------------------

	subtype small_int is integer range 0 to 2 ** CORE_ADDR_WIDTH - 5;
	type t is array (0 to (2 ** CORE_ADDR_WIDTH) - 5) of small_int;

	---------------------------------
	--DEFINE MEMORY STRUCTURE HERE --
	---------------------------------
	constant NUMBER_OF_REGISTERS : natural := 4;
	constant NUMBER_OF_FIFOS     : natural := 0;
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

	signal fifo_clk   : std_logic_vector(NUMBER_OF_FIFOS - 1 downto 0);
	signal fifo_stb   : std_logic_vector(NUMBER_OF_FIFOS - 1 downto 0);
	signal fifo_ack   : std_logic_vector(NUMBER_OF_FIFOS - 1 downto 0);
	signal fifo_empty : std_logic_vector(NUMBER_OF_FIFOS - 1 downto 0);
	signal fifo_full  : std_logic_vector(NUMBER_OF_FIFOS - 1 downto 0);

----------------------------------
----------{ USER LOGIC }----------
----------------------------------

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
					RD_CLK_I => fifo_clk(i),
					RD_DAT_O => user_Q(user_addr(i)),
					RD_STB_I => fifo_stb(i),
					RD_ACK_O => fifo_ack(i),
					FULL     => fifo_full(i),
					EMPTY    => fifo_empty(i)
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

	Q0 <= user_Q(0);
	Q1 <= user_Q(1);
	Q2 <= user_Q(2);
	Q3 <= user_Q(3);

end architecture Behavioral;
