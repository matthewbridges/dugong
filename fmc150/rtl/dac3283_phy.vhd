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
-- Name:		
-- Type:		
-- Description:		
--
-- Compliance:	DUGONG V0.5
-- ID:			x 0-5-
--
-- Last Modified:	21-NOV-2013
-- Modified By:		MATTHEW BRIDGES
---------------------------------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

entity dac3283_phy is
	generic(
		NUMBER_OF_SAMPLES : natural := 4
	);
	port(
		--System Control Inputs
		RST_I         : in  STD_LOGIC;
		--DSP Packet Signals
		DSP_CLK_O     : out STD_LOGIC;
		DSP_CLK_DIV_O : out STD_LOGIC;
		DAC_READY     : out STD_LOGIC;
		CH_A_PACKET_I : in  STD_LOGIC_VECTOR((14 * NUMBER_OF_SAMPLES) - 1 downto 0);
		CH_A_EN_I     : in  STD_LOGIC;
		CH_A_VALID_I  : in  STD_LOGIC;
		CH_B_PACKET_I : in  STD_LOGIC_VECTOR((14 * NUMBER_OF_SAMPLES) - 1 downto 0);
		CH_B_EN_I     : in  STD_LOGIC;
		CH_B_VALID_I  : in  STD_LOGIC;
		-- DAC interface
		FMC150_CLK    : in  STD_LOGIC;
		DAC_DCLK_P    : out STD_LOGIC;
		DAC_DCLK_N    : out STD_LOGIC;
		DAC_DATA_P    : out STD_LOGIC_VECTOR(7 downto 0);
		DAC_DATA_N    : out STD_LOGIC_VECTOR(7 downto 0);
		FRAME_P       : out STD_LOGIC;
		FRAME_N       : out STD_LOGIC;
		-- Testing
		IO_TEST_EN    : in  STD_LOGIC
	);
end entity dac3283_phy;

architecture RTL of dac3283_phy is
	signal dsp_clk      : std_logic;
	signal dsp_clk_DIV4 : std_logic;

	signal dac_ch_a : STD_LOGIC_VECTOR(13 downto 0);
	signal dac_ch_b : STD_LOGIC_VECTOR(13 downto 0);

	signal dac_16_ch_a : STD_LOGIC_VECTOR(15 downto 0);
	signal dac_16_ch_b : STD_LOGIC_VECTOR(15 downto 0);

	component dac3283_serializer is
		port(
			--System Control Inputs
			RST_I          : in  STD_LOGIC;
			--Signal Channel Inputs
			DAC_CLK_O      : out STD_LOGIC;
			DAC_CLK_DIV4_O : out STD_LOGIC;
			DAC_READY      : out STD_LOGIC;
			CH_C_I         : in  STD_LOGIC_VECTOR(15 downto 0);
			CH_D_I         : in  STD_LOGIC_VECTOR(15 downto 0);
			-- DAC interface
			FMC150_CLK     : in  STD_LOGIC;
			DAC_DCLK_P     : out STD_LOGIC;
			DAC_DCLK_N     : out STD_LOGIC;
			DAC_DATA_P     : out STD_LOGIC_VECTOR(7 downto 0);
			DAC_DATA_N     : out STD_LOGIC_VECTOR(7 downto 0);
			FRAME_P        : out STD_LOGIC;
			FRAME_N        : out STD_LOGIC;
			-- Testing
			IO_TEST_EN     : in  STD_LOGIC
		);
	end component dac3283_serializer;

begin
	dsp_rx_ch_a : dsp_rx
		generic map(
			DATA_WIDTH        => 14,
			NUMBER_OF_SAMPLES => 4
		)
		port map(
			RST_I         => RST_I,
			DSP_CLK_I     => dsp_clk,
			DSP_CLK_DIV_I => dsp_clk_DIV4,
			DSP_SAMPLE_O  => dac_ch_a,
			DSP_PACKET_I  => CH_A_PACKET_I
		);

	dsp_rx_ch_b : dsp_rx
		generic map(
			DATA_WIDTH        => 14,
			NUMBER_OF_SAMPLES => 4
		)
		port map(
			RST_I         => RST_I,
			DSP_CLK_I     => dsp_clk,
			DSP_CLK_DIV_I => dsp_clk_DIV4,
			DSP_SAMPLE_O  => dac_ch_b,
			DSP_PACKET_I  => CH_B_PACKET_I
		);

	dac_16_ch_a <= dac_ch_a & dac_ch_a(13) & dac_ch_a(13);
	dac_16_ch_b <= dac_ch_b & dac_ch_b(13) & dac_ch_b(13);

	dac : dac3283_serializer
		port map(
			RST_I          => RST_I,
			DAC_CLK_O      => dsp_clk,
			DAC_CLK_DIV4_O => dsp_clk_DIV4,
			DAC_READY      => DAC_READY,
			CH_C_I         => dac_16_ch_a,
			CH_D_I         => dac_16_ch_b,
			FMC150_CLK     => FMC150_CLK,
			DAC_DCLK_P     => DAC_DCLK_P,
			DAC_DCLK_N     => DAC_DCLK_N,
			DAC_DATA_P     => DAC_DATA_P,
			DAC_DATA_N     => DAC_DATA_N,
			FRAME_P        => FRAME_P,
			FRAME_N        => FRAME_N,
			IO_TEST_EN     => IO_TEST_EN
		);

	DSP_CLK_O     <= dsp_clk;
	DSP_CLK_DIV_O <= dsp_clk_DIV4;

end architecture RTL;