--                    
-- _______/\\\\\\\\\_______/\\\________/\\\____/\\\\\\\\\\\____/\\\\\_____/\\\_________/\\\\\_________     
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
-- Engineer:		MATTHEW BRIDGES
--
-- Name:		
-- Type:		TB (F)
-- Description: 		
--
-- Compliance:		DUGONG V1.1
-- ID:			x 1-1-F-001
--
-- Last Modified:	21-NOV-2013
-- Modified By:		MATTHEW BRIDGES
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

entity dsp_tx_rx_tb is
	generic(
		DATA_WIDTH        : NATURAL := 16;
		NUMBER_OF_SAMPLES : NATURAL := 4
	);
end entity dsp_tx_rx_tb;

architecture Behavioral of dsp_tx_rx_tb is
	signal RST_I         : STD_LOGIC                                 := '1';
	signal DSP_CLK_I     : STD_LOGIC                                 := '0';
	signal DSP_CLK_DIV_I : STD_LOGIC                                 := '0';
	signal DSP_SAMPLE_I  : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0) := (others => '0');
	signal DSP_SAMPLE_O  : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0) := (others => '0');

	signal dsp_packet : STD_LOGIC_VECTOR((DATA_WIDTH * NUMBER_OF_SAMPLES) - 1 downto 0) := (others => '0');

	signal n : unsigned(DATA_WIDTH - 1 downto 0) := (0 => '1', others => '0');

	-- Clock period definitions
	constant DSP_CLK_I_period     : time := 4.069 ns;
	constant DSP_CLK_DIV_I_period : time := DSP_CLK_I_period * NUMBER_OF_SAMPLES;

begin
	uut1 : dsp_tx
		generic map(
			DATA_WIDTH        => DATA_WIDTH,
			NUMBER_OF_SAMPLES => NUMBER_OF_SAMPLES
		)
		port map(
			RST_I         => RST_I,
			DSP_CLK_I     => DSP_CLK_I,
			DSP_CLK_DIV_I => DSP_CLK_DIV_I,
			DSP_SAMPLE_I  => DSP_SAMPLE_I,
			DSP_PACKET_O  => dsp_packet
		);

	uut2 : dsp_rx
		generic map(
			DATA_WIDTH        => DATA_WIDTH,
			NUMBER_OF_SAMPLES => NUMBER_OF_SAMPLES
		)
		port map(
			RST_I         => RST_I,
			DSP_CLK_I     => DSP_CLK_I,
			DSP_CLK_DIV_I => DSP_CLK_DIV_I,
			DSP_SAMPLE_O  => DSP_SAMPLE_O,
			DSP_PACKET_I  => dsp_packet
		);

	-- Clock process definitions
	DSP_CLK_I_process : process
	begin
		DSP_CLK_I <= '0';
		wait for DSP_CLK_I_period / 2;
		DSP_CLK_I <= '1';
		wait for DSP_CLK_I_period / 2;
	end process;

	DSP_CLK_DIV_I_process : process
	begin
		DSP_CLK_DIV_I <= '0';
		wait for DSP_CLK_DIV_I_period / 2;
		DSP_CLK_DIV_I <= '1';
		wait for DSP_CLK_DIV_I_period / 2;
	end process;

	-- Stimulus process
	wb_stim_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;

		RST_I <= '0';

		wait for 100 ns;

		wait;
	end process;

	wr_stim_proc : process
	begin
		wait until rising_edge(DSP_CLK_I);
		DSP_SAMPLE_I <= std_logic_vector(n);
	end process;

	counter_proc : process
	begin
		wait until rising_edge(DSP_CLK_I);
		n <= n + 1;
	end process;

end architecture Behavioral;
