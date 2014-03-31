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
-- Name:		
-- Type:		
-- Description:		
--
-- Compliance:		DUGONG V0.5
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

entity ads62p49_phy is
	generic(
		NUMBER_OF_SAMPLES : natural := 4
	);
	port(
		--System Control Inputs
		RST_I         : in  STD_LOGIC;
		--DSP Packet Signals
		DSP_CLK_I     : in  STD_LOGIC;
		DSP_CLK_DIV_I : in  STD_LOGIC;
		CH_A_PACKET_O : out STD_LOGIC_VECTOR((14 * NUMBER_OF_SAMPLES) - 1 downto 0);
		CH_A_EN_I     : in  STD_LOGIC;
		CH_A_VALID_O  : out STD_LOGIC;
		CH_B_PACKET_O : out STD_LOGIC_VECTOR((14 * NUMBER_OF_SAMPLES) - 1 downto 0);
		CH_B_EN_I     : in  STD_LOGIC;
		CH_B_VALID_O  : out STD_LOGIC;
		-- FMC150 ADC interface
		ADC_DCLK_P    : in  STD_LOGIC;
		ADC_DCLK_N    : in  STD_LOGIC;
		ADC_DATA_A_P  : in  STD_LOGIC_VECTOR(6 downto 0);
		ADC_DATA_A_N  : in  STD_LOGIC_VECTOR(6 downto 0);
		ADC_DATA_B_P  : in  STD_LOGIC_VECTOR(6 downto 0);
		ADC_DATA_B_N  : in  STD_LOGIC_VECTOR(6 downto 0)
	);
end entity ads62p49_phy;

architecture RTL of ads62p49_phy is
	signal adc_clk : std_logic;

	signal adc_ch_a : STD_LOGIC_VECTOR(13 downto 0);
	signal adc_ch_b : STD_LOGIC_VECTOR(13 downto 0);

	signal fifo_out_ch_a : STD_LOGIC_VECTOR(13 downto 0);
	signal fifo_out_ch_b : STD_LOGIC_VECTOR(13 downto 0);

	component ads62p49_parallelizer is
		port(
			--System Control Inputs
			RST_I        : in  STD_LOGIC;
			--Signal Channel Inputs
			ADC_CLK_O    : out STD_LOGIC;
			CH_A_O       : out STD_LOGIC_VECTOR(13 downto 0);
			CH_B_O       : out STD_LOGIC_VECTOR(13 downto 0);
			-- FMC150 ADC interface
			ADC_DCLK_P   : in  STD_LOGIC;
			ADC_DCLK_N   : in  STD_LOGIC;
			ADC_DATA_A_P : in  STD_LOGIC_VECTOR(6 downto 0);
			ADC_DATA_A_N : in  STD_LOGIC_VECTOR(6 downto 0);
			ADC_DATA_B_P : in  STD_LOGIC_VECTOR(6 downto 0);
			ADC_DATA_B_N : in  STD_LOGIC_VECTOR(6 downto 0)
		);
	end component;

begin
	adc_external_interface : ads62p49_parallelizer
		port map(
			RST_I        => RST_I,
			ADC_CLK_O    => adc_clk,
			CH_A_O       => adc_ch_a,
			CH_B_O       => adc_ch_b,
			ADC_DCLK_P   => ADC_DCLK_P,
			ADC_DCLK_N   => ADC_DCLK_N,
			ADC_DATA_A_P => ADC_DATA_A_P,
			ADC_DATA_A_N => ADC_DATA_A_N,
			ADC_DATA_B_P => ADC_DATA_B_P,
			ADC_DATA_B_N => ADC_DATA_B_N
		);

	fifo_ch_a : fifo_sync
		generic map(
			DATA_WIDTH => 14,
			FIFO_DEPTH => 1024
		)
		port map(
			RST_I    => RST_I,
			WR_CLK_I => adc_clk,
			WR_DAT_I => adc_ch_a,
			WR_EN_I  => '1',
			RD_CLK_I => DSP_CLK_I,
			RD_DAT_O => fifo_out_ch_a,
			RD_EN_I  => CH_A_EN_I,
			FULL     => open,
			EMPTY    => open
		);

	fifo_ch_b : fifo_sync
		generic map(
			DATA_WIDTH => 14,
			FIFO_DEPTH => 1024
		)
		port map(
			RST_I    => RST_I,
			WR_CLK_I => adc_clk,
			WR_DAT_I => adc_ch_b,
			WR_EN_I  => '1',
			RD_CLK_I => DSP_CLK_I,
			RD_DAT_O => fifo_out_ch_b,
			RD_EN_I  => CH_B_EN_I,
			FULL     => open,
			EMPTY    => open
		);

	dsp_tx_ch_a : dsp_tx
		generic map(
			DATA_WIDTH        => 14,
			NUMBER_OF_SAMPLES => 4
		)
		port map(
			RST_I         => RST_I,
			DSP_CLK_I     => DSP_CLK_I,
			DSP_CLK_DIV_I => DSP_CLK_DIV_I,
			DSP_SAMPLE_I  => fifo_out_ch_a,
			DSP_PACKET_O  => CH_A_PACKET_O
		);

	dsp_tx_ch_b : dsp_tx
		generic map(
			DATA_WIDTH        => 14,
			NUMBER_OF_SAMPLES => 4
		)
		port map(
			RST_I         => RST_I,
			DSP_CLK_I     => DSP_CLK_I,
			DSP_CLK_DIV_I => DSP_CLK_DIV_I,
			DSP_SAMPLE_I  => fifo_out_ch_b,
			DSP_PACKET_O  => CH_B_PACKET_O
		);
end architecture RTL;
