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
-- Name:		FIFO_SYNC (010)
-- Type:		PRIMITIVE (2)
-- Description:		A FIFO primitive with one read port and one write port which can take on
--			generic data widths.
--
-- Compliance:		DUGONG V0.5
-- ID:			x 0-5-2-010
--
-- Last Modified:	31-MAR-2014
-- Modified By:		MATTHEW BRIDGES
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

entity fifo_sync is
	generic(
		DATA_WIDTH : NATURAL := 32;
		FIFO_DEPTH : NATURAL := 16
	);
	port(
		--System Control Inputs:
		RST_I    : in  STD_LOGIC;
		--WRITE PORT
		WR_CLK_I : in  STD_LOGIC;
		WR_DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		WR_EN_I  : in  STD_LOGIC;
		--READ PORT
		RD_CLK_I : in  STD_LOGIC;
		RD_DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		RD_EN_I  : in  STD_LOGIC;
		--STATUS SIGNALS
		FULL     : out STD_LOGIC;
		EMPTY    : out STD_LOGIC
	);
end fifo_sync;

architecture Behavioral of fifo_sync is
	constant FIFO_ADDR_WIDTH : natural := min_num_of_bits(FIFO_DEPTH) - 1;
	subtype fifo_ptr_type is unsigned(FIFO_ADDR_WIDTH downto 0);
	signal wr_ptr : fifo_ptr_type := (others => '0');
	signal rd_ptr : fifo_ptr_type := (others => '0');

	signal wr_ptr_rd : fifo_ptr_type := (others => '0');
	signal rd_ptr_wr : fifo_ptr_type := (others => '0');

	signal wr_addr : std_logic_vector(FIFO_ADDR_WIDTH - 1 downto 0);
	signal rd_addr : std_logic_vector(FIFO_ADDR_WIDTH - 1 downto 0);

	signal wr_en : std_logic;
	signal rd_en : std_logic;

	signal collision_flag_wr : std_logic;
	signal collision_flag_rd : std_logic;
	signal full_flag         : std_logic;
	signal empty_flag        : std_logic;

begin

	--WRITE Port
	process(WR_CLK_I)
	begin
		--Perform Clock Rising Edge operations
		if (rising_edge(WR_CLK_I)) then
			--RESET STATE (SYNCHRONOUS)
			if (RST_I = '1') then
				wr_ptr    <= (others => '0');
				rd_ptr_wr <= (others => '0');
			else
				--WRITING STATE
				if (wr_en = '1') then
					wr_ptr <= WR_ptr + 1;
				end if;
				rd_ptr_wr <= rd_ptr;
			end if;
		end if;
	end process;

	wr_addr <= std_logic_vector(wr_ptr(FIFO_ADDR_WIDTH - 1 downto 0));
	wr_en   <= WR_EN_I when (full_flag = '0') else '0';

	--READ Port
	process(RD_CLK_I)
	begin
		--Perform Clock Rising Edge operations
		if (rising_edge(RD_CLK_I)) then
			--RESET STATE (SYNCHRONOUS)
			if (RST_I = '1') then
				rd_ptr    <= (others => '0');
				wr_ptr_rd <= (others => '0');
			else
				--READING STATE
				if (rd_en = '1') then
					rd_ptr <= rd_ptr + 1;
				end if;
				wr_ptr_rd <= wr_ptr;
			end if;
		end if;
	end process;

	rd_addr <= std_logic_vector(rd_ptr(FIFO_ADDR_WIDTH - 1 downto 0));
	rd_en   <= RD_EN_I when (empty_flag = '0') else '0';

	collision_flag_wr <= '1' when (rd_ptr_wr(FIFO_ADDR_WIDTH - 1 downto 0) = wr_ptr(FIFO_ADDR_WIDTH - 1 downto 0)) else '0';
	collision_flag_rd <= '1' when (rd_ptr(FIFO_ADDR_WIDTH - 1 downto 0) = wr_ptr_rd(FIFO_ADDR_WIDTH - 1 downto 0)) else '0';
	empty_flag        <= collision_flag_rd and not (rd_ptr(FIFO_ADDR_WIDTH) xor wr_ptr_rd(FIFO_ADDR_WIDTH));
	full_flag         <= collision_flag_wr and (rd_ptr_wr(FIFO_ADDR_WIDTH) xor wr_ptr(FIFO_ADDR_WIDTH));

	mem : bram_sync_dp_simple
		generic map(
			DATA_WIDTH => DATA_WIDTH,
			ADDR_WIDTH => FIFO_ADDR_WIDTH
		)
		port map(
			A_CLK_I => WR_CLK_I,
			A_DAT_I => WR_DAT_I,
			A_ADR_I => wr_addr(FIFO_ADDR_WIDTH - 1 downto 0),
			A_WE_I  => wr_en,
			B_CLK_I => RD_CLK_I,
			B_DAT_O => RD_DAT_O,
			B_ADR_I => rd_addr(FIFO_ADDR_WIDTH - 1 downto 0)
		);

	FULL  <= full_flag;
	EMPTY <= empty_flag;

end Behavioral;