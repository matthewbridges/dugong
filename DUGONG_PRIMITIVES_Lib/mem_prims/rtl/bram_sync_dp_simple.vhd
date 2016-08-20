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
-- Engineer: 	MATTHEW BRIDGES
--
-- Name:		BRAM_SYNC_DP_SIMPLE (006)
-- Type:		PRIMITIVE (2)
-- Description:	A BRAM primitive with one read port and one write ports. Ports
--				can take on generic data and address widths but not independently.
--				This core takes advantage of FPGA on chip BRAMs if size is large
--				enough to make it efficient.
--
-- Compliance:	DUGONG V0.5
-- ID:			x 0-5-2-006
--
-- Last Modified:	20-AUG-2016
-- Modified By:		MATTHEW BRIDGES
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bram_sync_dp_simple is
	generic(
		DATA_WIDTH : natural := 32;
		ADDR_WIDTH : natural := 10
	);
	port(
		--PORT A
		A_CLK_I : in  STD_LOGIC;
		A_DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		A_ADR_I : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		A_WE_I  : in  STD_LOGIC;
		--PORT B
		B_CLK_I : in  STD_LOGIC;
		B_DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		B_ADR_I : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0)
	);
end bram_sync_dp_simple;

architecture Behavioral of bram_sync_dp_simple is
	--Shared memory
	type ram_type is array (0 to (2 ** ADDR_WIDTH) - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	shared variable mem : ram_type;
	signal A_mem_adr    : unsigned(ADDR_WIDTH - 1 downto 0);
	signal B_mem_adr    : unsigned(ADDR_WIDTH - 1 downto 0);

	signal B_dat : std_logic_vector(DATA_WIDTH - 1 downto 0);

	attribute shreg_extract : string;
	attribute shreg_extract of B_dat : signal is "no";

begin

	--Port A
	process(A_CLK_I)
	begin
		--Perform Clock Rising Edge operations
		if (rising_edge(A_CLK_I)) then
			--WRITING STATE
			if (A_WE_I = '1') then
				mem(to_integer(A_mem_adr)) := A_DAT_I;
			end if;
		end if;
	end process;

	A_mem_adr <= unsigned(A_ADR_I);

	--Port B
	process(B_CLK_I)
	begin
		--Perform Clock Rising Edge operations
		if (rising_edge(B_CLK_I)) then
			--READING STATE
			B_dat <= mem(to_integer(B_mem_adr));
		end if;
	end process;

	B_mem_adr <= unsigned(B_ADR_I);

	B_DAT_O <= B_dat;

end Behavioral;
