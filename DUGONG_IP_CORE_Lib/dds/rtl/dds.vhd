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
-- Name:		DDS (005)
-- Type:		CORE (3)
-- Description: 	
--
-- Compliance:		DUGONG V0.3
-- ID:			x 0-3-3-005
---------------------------------------------------------------------------------------------------------------
--	ADDR	| NAME		| Type		--
--	0	| SINE_OUT	| WB_LATCH	--
-- 	1	| COS_OUT	| WB_LATCH	--
-- 	2	| FTW		| WB_REG	--
-- 	3	| PHASE		| WB_REG	--
--------------------------------------------------

--y[t] = A*sin(2*pi*f*t + phi)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

entity dds is
	generic(
		AMPL_WIDTH     : natural := 16;
		PHASE_WIDTH    : natural := 16;
		LUT_ADDR_WIDTH : natural := 6
	);
	port(
		--System Control Inputs
		CLK_I           : in  STD_LOGIC;
		RST_I           : in  STD_LOGIC;
		--Bus Logic Interface
		SIN_OUT         : out STD_LOGIC_VECTOR(AMPL_WIDTH - 1 downto 0);
		COS_OUT         : out STD_LOGIC_VECTOR(AMPL_WIDTH - 1 downto 0);
		PHASE_INCREMENT : in  STD_LOGIC_VECTOR(PHASE_WIDTH - 1 downto 0);
		PHASE_OFFSET    : in  STD_LOGIC_VECTOR(PHASE_WIDTH - 1 downto 0)
	);
end entity dds;

architecture Behavioral of dds is
	signal phase       : unsigned(PHASE_WIDTH - 1 downto 0);
	signal phase_accum : unsigned(PHASE_WIDTH - 1 downto 0);
	signal invert_sin : std_logic;
	signal invert_cos : std_logic;
	
	signal sin_ampl : signed(AMPL_WIDTH - 1 downto 0);
	signal cos_ampl : signed(AMPL_WIDTH - 1 downto 0);
	
	type lut_type is array (0 to 2 ** LUT_ADDR_WIDTH - 1) of signed(AMPL_WIDTH - 1 downto 0);
	signal sin_lut_addr : unsigned(LUT_ADDR_WIDTH - 1 downto 0);
	signal cos_lut_addr : unsigned(LUT_ADDR_WIDTH - 1 downto 0);
	constant sine       : lut_type := (
		0      => to_signed(0,
			AMPL_WIDTH),
		1      => to_signed(810,
			AMPL_WIDTH),
		2      => to_signed(1620,
			AMPL_WIDTH),
		3      => to_signed(2429,
			AMPL_WIDTH),
		4      => to_signed(3237,
			AMPL_WIDTH),
		5      => to_signed(4042,
			AMPL_WIDTH),
		6      => to_signed(4845,
			AMPL_WIDTH),
		7      => to_signed(5646,
			AMPL_WIDTH),
		8      => to_signed(6442,
			AMPL_WIDTH),
		9      => to_signed(7235,
			AMPL_WIDTH),
		10     => to_signed(8023,
			AMPL_WIDTH),
		11     => to_signed(8806,
			AMPL_WIDTH),
		12     => to_signed(9584,
			AMPL_WIDTH),
		13     => to_signed(10357,
			AMPL_WIDTH),
		14     => to_signed(11122,
			AMPL_WIDTH),
		15     => to_signed(11881,
			AMPL_WIDTH),
		16     => to_signed(12633,
			AMPL_WIDTH),
		17     => to_signed(13377,
			AMPL_WIDTH),
		18     => to_signed(14113,
			AMPL_WIDTH),
		19     => to_signed(14840,
			AMPL_WIDTH),
		20     => to_signed(15558,
			AMPL_WIDTH),
		21     => to_signed(16266,
			AMPL_WIDTH),
		22     => to_signed(16965,
			AMPL_WIDTH),
		23     => to_signed(17653,
			AMPL_WIDTH),
		24     => to_signed(18331,
			AMPL_WIDTH),
		25     => to_signed(18997,
			AMPL_WIDTH),
		26     => to_signed(19651,
			AMPL_WIDTH),
		27     => to_signed(20294,
			AMPL_WIDTH),
		28     => to_signed(20924,
			AMPL_WIDTH),
		29     => to_signed(21541,
			AMPL_WIDTH),
		30     => to_signed(22145,
			AMPL_WIDTH),
		31     => to_signed(22736,
			AMPL_WIDTH),
		32     => to_signed(23313,
			AMPL_WIDTH),
		33     => to_signed(23875,
			AMPL_WIDTH),
		34     => to_signed(24423,
			AMPL_WIDTH),
		35     => to_signed(24956,
			AMPL_WIDTH),
		36     => to_signed(25473,
			AMPL_WIDTH),
		37     => to_signed(25975,
			AMPL_WIDTH),
		38     => to_signed(26461,
			AMPL_WIDTH),
		39     => to_signed(26931,
			AMPL_WIDTH),
		40     => to_signed(27385,
			AMPL_WIDTH),
		41     => to_signed(27821,
			AMPL_WIDTH),
		42     => to_signed(28241,
			AMPL_WIDTH),
		43     => to_signed(28643,
			AMPL_WIDTH),
		44     => to_signed(29028,
			AMPL_WIDTH),
		45     => to_signed(29395,
			AMPL_WIDTH),
		46     => to_signed(29744,
			AMPL_WIDTH),
		47     => to_signed(30075,
			AMPL_WIDTH),
		48     => to_signed(30388,
			AMPL_WIDTH),
		49     => to_signed(30682,
			AMPL_WIDTH),
		50     => to_signed(30957,
			AMPL_WIDTH),
		51     => to_signed(31213,
			AMPL_WIDTH),
		52     => to_signed(31450,
			AMPL_WIDTH),
		53     => to_signed(31668,
			AMPL_WIDTH),
		54     => to_signed(31866,
			AMPL_WIDTH),
		55     => to_signed(32045,
			AMPL_WIDTH),
		56     => to_signed(32205,
			AMPL_WIDTH),
		57     => to_signed(32344,
			AMPL_WIDTH),
		58     => to_signed(32464,
			AMPL_WIDTH),
		59     => to_signed(32564,
			AMPL_WIDTH),
		60     => to_signed(32644,
			AMPL_WIDTH),
		61     => to_signed(32704,
			AMPL_WIDTH),
		62     => to_signed(32744,
			AMPL_WIDTH),
		63     => to_signed(32764,
			AMPL_WIDTH),
		others => to_signed(0,
			AMPL_WIDTH)
	);

begin
	----------------------------------
	----------{ USER LOGIC }----------
	----------------------------------
	process(CLK_I)
	begin
		--Perform Clock Rising Edge operations
		if (rising_edge(CLK_I)) then
			--Check for reset
			if (RST_I = '1') then
				phase_accum  <= (others => '0');
				phase        <= (others => '0');
				sin_lut_addr <= (others => '0');
				cos_lut_addr <= (others => '0');
			else
				case (phase(PHASE_WIDTH - 2)) is
					when '0'    => sin_lut_addr <= phase(PHASE_WIDTH - 3 downto PHASE_WIDTH - LUT_ADDR_WIDTH - 2);
					when '1'    => sin_lut_addr <= (2 ** LUT_ADDR_WIDTH - 1) - phase(PHASE_WIDTH - 3 downto PHASE_WIDTH - LUT_ADDR_WIDTH - 2);
					when others => sin_lut_addr <= (others => '0');
				end case;
				--				
				case (phase(PHASE_WIDTH - 2)) is
					when '1'    => cos_lut_addr <= phase(PHASE_WIDTH - 3 downto PHASE_WIDTH - LUT_ADDR_WIDTH - 2);
					when '0'    => cos_lut_addr <= (2 ** LUT_ADDR_WIDTH - 1) - phase(PHASE_WIDTH - 3 downto PHASE_WIDTH - LUT_ADDR_WIDTH - 2);
					when others => cos_lut_addr <= (others => '0');
				end case;

				phase_accum <= phase_accum + unsigned(PHASE_INCREMENT);
				phase       <= phase_accum + unsigned(PHASE_OFFSET);
				invert_sin  <= phase(PHASE_WIDTH - 1);
				invert_cos  <= phase(PHASE_WIDTH - 1) xor phase(PHASE_WIDTH - 2);
			end if;
		end if;
	end process;

	sin_ampl <= sine(to_integer(sin_lut_addr));
	cos_ampl <= sine(to_integer(cos_lut_addr));

	SIN_OUT <= std_logic_vector(sin_ampl) when (invert_sin = '0') else std_logic_vector(-sin_ampl);
	COS_OUT <= std_logic_vector(cos_ampl) when (invert_cos = '0') else std_logic_vector(-cos_ampl);

end Behavioral;