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
-- Engineer:	MATTHEW BRIDGES
--
-- Name:		WB_REGISTER_TB (001)
-- Type:		TB (F)
-- Description: 		
--
-- Compliance:	DUGONG V1.1
-- ID:			x 1-1-F-001
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

entity wb_fifo_tb is
end entity wb_fifo_tb;

architecture Behavioral of wb_fifo_tb is
	signal RST_I    : STD_LOGIC                                 := '1';
	signal WR_CLK_I : STD_LOGIC                                 := '0';
	signal WR_DAT_I : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0) := (others => '0');
	signal WR_WE_I  : STD_LOGIC                                 := '0';
	signal WR_STB_I : STD_LOGIC                                 := '0';
	signal WR_ACK_O : STD_LOGIC;
	signal RD_CLK_I : STD_LOGIC                                 := '0';
	signal RD_DAT_O : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
	signal RD_STB_I : STD_LOGIC                                 := '0';
	signal RD_ACK_O : STD_LOGIC;
	signal FULL     : STD_LOGIC;
	signal EMPTY    : STD_LOGIC;

	signal n         : unsigned(DATA_WIDTH - 1 downto 0) := (0=>'1', others => '0');

	-- Clock period definitions
	constant WR_CLK_I_period : time := 10 ns;
	constant RD_CLK_I_period : time := 24 ns;

begin
	uut : wb_fifo
		generic map(
			DATA_WIDTH => DATA_WIDTH,
			FIFO_DEPTH => 16
		)
		port map(
			RST_I    => RST_I,
			WR_CLK_I => WR_CLK_I,
			WR_DAT_I => WR_DAT_I,
			WR_WE_I  => WR_WE_I,
			WR_STB_I => WR_STB_I,
			WR_ACK_O => WR_ACK_O,
			RD_CLK_I => RD_CLK_I,
			RD_DAT_O => RD_DAT_O,
			RD_STB_I => RD_STB_I,
			RD_ACK_O => RD_ACK_O,
			FULL     => FULL,
			EMPTY    => EMPTY
		);

	-- Clock process definitions
	WR_CLK_I_process : process
	begin
		WR_CLK_I <= '0';
		wait for WR_CLK_I_period / 2;
		WR_CLK_I <= '1';
		wait for WR_CLK_I_period / 2;
	end process;

	RD_CLK_I_process : process
	begin
		RD_CLK_I <= '0';
		wait for RD_CLK_I_period / 2;
		RD_CLK_I <= '1';
		wait for RD_CLK_I_period / 2;
	end process;

	-- Stimulus process
	wb_stim_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;

		RST_I <= '0';

		wait for 100 ns;

		WR_WE_I <= '1';

		wait;
	end process;

	wr_stim_proc : process
	begin
		wait until rising_edge(WR_CLK_I) and (RST_I = '0');
		WR_STB_I <= '1';
		WR_DAT_I <= std_logic_vector(n);
		wait until rising_edge(WR_ACK_O);
		wait until rising_edge(WR_CLK_I);
		WR_STB_I <= '0';
		WR_DAT_I <= (others => '0');
	end process;

	rd_stim_proc : process
	begin
		wait until rising_edge(RD_CLK_I);
		RD_STB_I <= '1';
		wait until rising_edge(RD_ACK_O);
		wait until rising_edge(RD_CLK_I);
		RD_STB_I <= '0';
	end process;

	counter_proc : process
	begin
		wait until rising_edge(WR_CLK_I);
		n <= n + 1;
	end process;

end architecture Behavioral;
