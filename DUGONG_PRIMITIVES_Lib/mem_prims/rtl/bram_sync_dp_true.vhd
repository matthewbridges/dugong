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
-- Name:		BRAM_SYNC_DP_TRUE (006)
-- Type:		PRIMITIVE (2)
-- Description:	A BRAM primitive with two read/write ports. Ports can take on 
--				generic data and address widths but not independently. This core
--				takes advantage of FPGA on chip BRAMs if size is large enough to
--				make it efficient.
--
-- Compliance:	DUGONG V0.5
-- ID:			x 1-1-2-006
--
-- Last Modified:	28-MAR-2013
-- Modified By:		MATTHEW BRIDGES
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bram_sync_dp_true is
	generic(
		DATA_WIDTH : natural := 32;
		ADDR_WIDTH : natural := 10
	);
	port(
		--PORT A
		A_CLK_I : in  STD_LOGIC;
		A_DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		A_DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		A_ADR_I : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		A_WE_I  : in  STD_LOGIC;
		--PORT B
		B_CLK_I : in  STD_LOGIC;
		B_DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		B_DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		B_ADR_I : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		B_WE_I  : in  STD_LOGIC
	);
end bram_sync_dp_true;

architecture Behavioral of bram_sync_dp_true is
	--Shared memory
	type ram_type is array (0 to (2 ** ADDR_WIDTH) - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	shared variable mem : ram_type;
	signal A_mem_adr    : unsigned(ADDR_WIDTH - 1 downto 0);
	signal B_mem_adr    : unsigned(ADDR_WIDTH - 1 downto 0);
begin

	--Port A
	process(A_CLK_I)
	begin
		--Perform Clock Rising Edge operations
		if (rising_edge(A_CLK_I)) then
			--WRITING STATE
			if (A_WE_I = '1') then
				mem(to_integer(unsigned(A_ADR_I))) := A_DAT_I;
			end if;
			--READING STATE
			A_mem_adr <= unsigned(A_ADR_I);
		end if;
	end process;

	A_DAT_O <= mem(to_integer(A_mem_adr));

	--Port B
	process(B_CLK_I)
	begin
		--Perform Clock Rising Edge operations
		if (rising_edge(B_CLK_I)) then
			--WRITING STATE
			if (B_WE_I = '1') then
				mem(to_integer(unsigned(B_ADR_I))) := B_DAT_I;
			end if;
			--READING STATE
			B_mem_adr <= unsigned(B_ADR_I);
		end if;
	end process;

	B_DAT_O <= mem(to_integer(B_mem_adr));

end Behavioral;

