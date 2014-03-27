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
-- Name:		BRAM_SYNC_DP_SIMPLE (006)
-- Type:		PRIMITIVE (2)
-- Description:		A BRAM primitive with one port which can take on generic data and address widths. Takes 
--			advantage of FPGA on chip BRAMs
--
-- Compliance:		DUGONG V1.1 (1-1)
-- ID:			x 1-1-2-006
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

entity wb_bram_sync_dp_simple is
	generic(
		DATA_WIDTH : natural := 32;
		ADDR_WIDTH : natural := 10
	);
	port(
		--System Control Inputs:
		RST_I   : in  STD_LOGIC;
		--PORT A
		A_CLK_I : in  STD_LOGIC;
		A_DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		A_ADR_I : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		A_WE_I  : in  STD_LOGIC;
		A_STB_I : in  STD_LOGIC;
		A_ACK_O : out STD_LOGIC;
		--PORT B
		B_CLK_I : in  STD_LOGIC;
		B_DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		B_ADR_I : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		B_STB_I : in  STD_LOGIC;
		B_ACK_O : out STD_LOGIC
	);
end wb_bram_sync_dp_simple;

architecture Behavioral of wb_bram_sync_dp_simple is
	subtype small_int is integer range 0 to (2 ** ADDR_WIDTH) - 1;

	--	--Shared memory
	type ram_type is array (0 to (2 ** ADDR_WIDTH) - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	--	shared variable mem : ram_type;
	--	signal B_mem_dat    : std_logic_vector(DATA_WIDTH - 1 downto 0);

	--Port A
	signal A_D    : ram_type                                         := (others => (others => '0'));
	signal A_Q    : ram_type                                         := (others => (others => '0'));
	signal A_stb  : std_logic_vector((2 ** ADDR_WIDTH) - 1 downto 0) := (others => '0');
	signal A_ack  : std_logic_vector((2 ** ADDR_WIDTH) - 1 downto 0) := (others => '0');
	signal A_addr : small_int;
	--Port B
	signal B_D    : std_logic_vector(DATA_WIDTH - 1 downto 0)        := (others => '0');
	signal B_addr : small_int;

begin

	--collision_flag <= '1' when (rd_addr(FIFO_ADDR_WIDTH - 1 downto 0) = wr_addr(FIFO_ADDR_WIDTH - 1 downto 0)) else '0';
	--	--Port A
	--	process(A_CLK_I)
	--	begin
	--		--Perform Clock Rising Edge operations
	--		if (rising_edge(A_CLK_I)) then
	--			--WRITING STATE
	--			if (A_WE_I = '1') then
	--				mem(to_integer(unsigned(A_ADR_I))) := A_DAT_I;
	--			end if;
	--		end if;
	--	end process;
	--
	--	B_mem_dat <= mem(to_integer(unsigned(B_ADR_I)));
	--
	--	--Port B
	--	process(B_CLK_I)
	--	begin
	--		--Perform Clock Rising Edge operations
	--		if (rising_edge(B_CLK_I)) then
	--			--READING STATE
	--			B_DAT_O <= B_mem_dat;
	--		end if;
	--	end process;

	--Port A
	A_addr <= to_integer(unsigned(A_ADR_I));

	--Generate Port A WB registers
	user_registers : for i in 0 to ((2 ** ADDR_WIDTH) - 1) generate
	begin
		--WISHBONE Register
		reg : wb_register
			generic map(
				DATA_WIDTH   => DATA_WIDTH,
				DEFAULT_DATA => x"00000000"
			)
			port map(
				CLK_I => A_CLK_I,
				RST_I => RST_I,
				DAT_I => A_D(i),
				DAT_O => A_Q(i),
				WE_I  => A_WE_I,
				STB_I => A_stb(i),
				ACK_O => A_ack(i)
			);

		A_D(i) <= A_DAT_I;
	end generate user_registers;

	--Generate Port A Strobe lines
	user_registers_control : for i in 0 to ((2 ** ADDR_WIDTH) - 1) generate
	begin
		--Check for valid addr
		A_stb(i) <= (A_STB_I) when (A_addr = i) else '0';
	end generate user_registers_control;

	A_ACK_O <= A_ack(A_addr);

	--Port B
	B_addr <= to_integer(unsigned(B_ADR_I));

	--WISHBONE Latch
	reg : wb_latch
		generic map(
			DATA_WIDTH => DATA_WIDTH
		)
		port map(
			CLK_I => B_CLK_I,
			RST_I => RST_I,
			DAT_I => B_D,
			DAT_O => B_DAT_O,
			STB_I => B_STB_I,
			ACK_O => B_ACK_O
		);

	B_D <= A_Q(B_addr);

end Behavioral;