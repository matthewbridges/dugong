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
-- Name:		GPMC_M_TB (003)
-- Type:		TB (F)
-- Description: 		
--
-- Compliance:		DUGONG V1.3
-- ID:			x 1-3-F-003
---------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

entity dugong_tb is
end dugong_tb;

architecture Behavioral of dugong_tb is
	component dugong_controller
		port(
			CLK_I     : in  STD_LOGIC;
			CLK_I_n   : in  STD_LOGIC;
			RST_I     : in  STD_LOGIC;
			WB_MS     : out WB_MS_type;
			WB_SM     : in  WB_SM_type;
			GNT_I     : in  STD_LOGIC;
			T_COUNT_O : out STD_LOGIC_VECTOR(31 downto 0);
			E_COUNT_O : out STD_LOGIC_VECTOR(31 downto 0)
		);
	end component dugong_controller;

	signal CLK_I     : STD_LOGIC  := '0';
	signal CLK_I_n   : STD_LOGIC  := '1';
	signal RST_I     : STD_LOGIC  := '1';
	signal WB_MS     : WB_MS_type;
	signal WB_SM     : WB_SM_type := (others => '0');
	signal GNT_I     : STD_LOGIC  := '0';
	signal T_COUNT_O : STD_LOGIC_VECTOR(31 downto 0);
	signal E_COUNT_O : STD_LOGIC_VECTOR(31 downto 0);

	-- Clock period definitions
	constant CLK_I_period : time := 10 ns;

begin
	uut : component dugong_controller
		port map(
			CLK_I     => CLK_I,
			CLK_I_n   => CLK_I_n,
			RST_I     => RST_I,
			WB_MS     => WB_MS,
			WB_SM     => WB_SM,
			GNT_I     => GNT_I,
			T_COUNT_O => T_COUNT_O,
			E_COUNT_O => E_COUNT_O
		);

	-- Clock process definitions
	CLK_I_process : process
	begin
		CLK_I   <= '0';
		CLK_I_n <= '1';
		wait for CLK_I_period / 2;
		CLK_I   <= '1';
		CLK_I_n <= '0';
		wait for CLK_I_period / 2;
	end process;

	-- Stimulus process
	wb_stim_proc : process
	begin
		wait until rising_edge(WB_MS(1 + DATA_WIDTH + ADDR_WIDTH));
		wait until rising_edge(CLK_I);
		WB_SM(DATA_WIDTH)              <= '1';
		WB_SM(DATA_WIDTH - 1 downto 0) <= x"FFFFEEEE";
		wait until falling_edge(WB_MS(1 + DATA_WIDTH + ADDR_WIDTH));
		wait until rising_edge(CLK_I);
		WB_SM(DATA_WIDTH)              <= '0';
		WB_SM(DATA_WIDTH - 1 downto 0) <= x"00000000";
	end process;

	stim_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;

		RST_I <= '0';

		wait for CLK_I_period * 10;

		wait for CLK_I_period * 15;
		wait until rising_edge(CLK_I);
		GNT_I <= '1';
		wait;
	end process;

end architecture Behavioral;
