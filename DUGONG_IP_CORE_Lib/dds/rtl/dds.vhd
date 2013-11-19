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
-- Type:		USER_LOGIC (5)
-- Description: 	
--
-- Compliance:		DUGONG V0.3
-- ID:			x 0-5-5-005
---------------------------------------------------------------------------------------------------------------

--y[t] = A*sin(2*pi*f*t + phi)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

use work.sine_lut_pkg.ALL;

entity dds is
	generic(
		AMPL_WIDTH  : natural := 16;
		PHASE_WIDTH : natural := 16
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

	signal sin_lut_addr : unsigned(LUT_ADDR_WIDTH downto 0);
	signal cos_lut_addr : unsigned(LUT_ADDR_WIDTH downto 0);

	constant offset_90 : unsigned(LUT_ADDR_WIDTH downto 0) := (LUT_ADDR_WIDTH - 1 => '1', others => '0');

	signal sin_magnitude   : unsigned(AMPL_WIDTH - 2 downto 0);
	signal cos_magnitude   : unsigned(AMPL_WIDTH - 2 downto 0);
	signal sin_magnitude_2 : unsigned(AMPL_WIDTH - 2 downto 0);
	signal cos_magnitude_2 : unsigned(AMPL_WIDTH - 2 downto 0);

	signal invert_sin   : std_logic;
	signal invert_cos   : std_logic;
	signal invert_sin_2 : std_logic;
	signal invert_cos_2 : std_logic;

	signal sin_ampl : signed(AMPL_WIDTH - 1 downto 0);
	signal cos_ampl : signed(AMPL_WIDTH - 1 downto 0);

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
				phase_accum <= (others => '0');
				phase       <= (others => '0');
			else
				-- Phase Accumulator
				phase_accum <= phase_accum + unsigned(PHASE_INCREMENT);

				-- Add Phase Offset
				phase <= phase_accum + unsigned(PHASE_OFFSET);
			end if;
		end if;
	end process;

	process(CLK_I)
	begin
		if (rising_edge(CLK_I)) then
			sin_lut_addr    <= phase(PHASE_WIDTH - 1 downto PHASE_WIDTH - LUT_ADDR_WIDTH - 1);
			cos_lut_addr    <= phase(PHASE_WIDTH - 1 downto PHASE_WIDTH - LUT_ADDR_WIDTH - 1) + offset_90;
			--Second stage of pipelining
			sin_magnitude   <= sine(to_integer(sin_lut_addr(LUT_ADDR_WIDTH - 1 downto 0)));
			cos_magnitude   <= sine(to_integer(cos_lut_addr(LUT_ADDR_WIDTH - 1 downto 0)));
			invert_sin      <= sin_lut_addr(LUT_ADDR_WIDTH);
			invert_cos      <= cos_lut_addr(LUT_ADDR_WIDTH);
			--Add another stage to pipeline to allow for memory access latency
			sin_magnitude_2 <= sin_magnitude;
			cos_magnitude_2 <= cos_magnitude;
			invert_sin_2    <= invert_sin;
			invert_cos_2    <= invert_cos;
		end if;
	end process;

	process(CLK_I)
	begin
		--Perform Clock Rising Edge operations
		if (rising_edge(CLK_I)) then
			--Check for reset
			if (RST_I = '1') then
				sin_ampl <= (others => '0');
				cos_ampl <= (AMPL_WIDTH - 1 => '0', others => '1');
			else
				if (invert_sin_2 = '1') then
					sin_ampl <= -signed(resize(sin_magnitude_2, 16));
				else
					sin_ampl <= signed(resize(sin_magnitude_2, 16));
				end if;

				if (invert_cos_2 = '1') then
					cos_ampl <= -signed(resize(cos_magnitude_2, 16));
				else
					cos_ampl <= signed(resize(cos_magnitude_2, 16));
				end if;
			end if;
		end if;
	end process;

	SIN_OUT <= std_logic_vector(sin_ampl);
	COS_OUT <= std_logic_vector(cos_ampl);

end Behavioral;