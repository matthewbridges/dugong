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
-- Name:		SYS_CON_TB
-- Type:		TB (15)
-- Description:
--
-- Compliance:		DUGONG V0.3
-- ID:			x 0-3-F-
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

entity sys_con_tb is
end sys_con_tb;

architecture behavior of sys_con_tb is
	signal SYS_CLK_P      : std_logic := '0';
	signal SYS_CLK_N      : std_logic := '0';
	signal SYS_CLK_o      : std_logic;
	signal SYS_RST        : std_logic := '0';
	signal SYS_PWR_ON     : std_logic;
	signal SYS_PLL_Locked : std_logic;
	signal CLK_100MHZ_P   : std_logic;
	signal CLK_100MHZ_N   : std_logic;
	signal RST_O          : std_logic;
	signal CLK_10MHZ_P     : STD_LOGIC;
	signal CLK_10MHZ_N     : STD_LOGIC;

	-- Clock period definitions
	constant SYS_CLK_period : time := 10 ns;

begin

	-- Instantiate the Unit Under Test (UUT)
	uut : sys_con
		port map(
			SYS_CLK_P      => SYS_CLK_P,
			SYS_CLK_N      => SYS_CLK_N,
			SYS_CLK_o      => SYS_CLK_o,
			SYS_RST        => SYS_RST,
			SYS_PWR_ON     => SYS_PWR_ON,
			SYS_PLL_Locked => SYS_PLL_Locked,
			CLK_100MHZ_P   => CLK_100MHZ_P,
			CLK_100MHZ_N   => CLK_100MHZ_N,
			RST_O          => RST_O,
			CLK_10MHZ_P     => CLK_10MHZ_P,
			CLK_10MHZ_N     => CLK_10MHZ_N
		);

	-- Clock process definitions
	SYS_CLK_process : process
	begin
		SYS_CLK_P <= '0';
		SYS_CLK_N <= '1';
		wait for SYS_CLK_period / 2;
		SYS_CLK_P <= '1';
		SYS_CLK_N <= '0';
		wait for SYS_CLK_period / 2;
	end process;

	-- Stimulus process
	stim_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;

		SYS_RST <= '0';

		wait for SYS_CLK_period * 10;

		-- insert stimulus here 

		wait;
	end process;

end;
