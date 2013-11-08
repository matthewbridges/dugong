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
-- Name:		GPIO_IP_TB (
-- Type:		TB (F)
-- Description:
--
-- Compliance:		DUGONG V0.5
-- ID:			x 0-5-F-002
--
-- Last Modified:	08-NOV-2013
-- Modified By:		MATTHEW BRIDGES
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

entity rhino_top_gpio_tb is
end entity rhino_top_gpio_tb;

architecture RTL of rhino_top_gpio_tb is

	-- Component Declaration for the Unit Under Test (UUT)
	--NB The DATA_WIDTH and ADDR_WIDTH constants are set in the dprimitives package
	component rhino_top_gpio is
		generic(
			NUMBER_OF_MASTERS : NATURAL := 1;
			NUMBER_OF_SLAVES  : NATURAL := 3
		);
		port(
			--System Control Inputs
			SYS_CLK_P       : in    STD_LOGIC;
			SYS_CLK_N       : in    STD_LOGIC;
			SYS_RST         : in    STD_LOGIC;
			--System Control Outputs
			SYS_PWR_ON      : out   STD_LOGIC;
			SYS_PLL_Locked  : out   STD_LOGIC;
			--GPMC Interface
			GPMC_CLK_I      : in    STD_LOGIC;
			GPMC_D_B        : inout STD_LOGIC_VECTOR(15 downto 0);
			GPMC_A_I        : in    STD_LOGIC_VECTOR(10 downto 1);
			GPMC_nCS_I      : in    STD_LOGIC_VECTOR(6 downto 0);
			GPMC_nADV_ALE_I : in    STD_LOGIC;
			GPMC_nWE_I      : in    STD_LOGIC;
			GPMC_nOE_I      : in    STD_LOGIC;
			GPMC_WAIT_O     : out   STD_LOGIC;
			--USER GPIOs
			GPIO            : inout STD_LOGIC_VECTOR(15 downto 0);
			--USER LEDs
			LED             : inout STD_LOGIC_VECTOR(7 downto 0)
		);
	end component rhino_top_gpio;

	--System Control Inputs
	signal SYS_CLK_P       : STD_LOGIC                     := '0';
	signal SYS_CLK_N       : STD_LOGIC                     := '1';
	signal SYS_RST         : STD_LOGIC                     := '1';
	--System Control Outputs
	signal SYS_PWR_ON      : STD_LOGIC;
	signal SYS_PLL_Locked  : STD_LOGIC;
	--GPMC Interface
	signal GPMC_CLK_I      : STD_LOGIC                     := '0';
	signal GPMC_D_B        : STD_LOGIC_VECTOR(15 downto 0) := (others => 'Z');
	signal GPMC_A_I        : STD_LOGIC_VECTOR(10 downto 1) := (others => '0');
	signal GPMC_nCS_I      : STD_LOGIC_VECTOR(6 downto 0)  := (others => '1');
	signal GPMC_nADV_ALE_I : STD_LOGIC                     := '1';
	signal GPMC_nWE_I      : STD_LOGIC                     := '1';
	signal GPMC_nOE_I      : STD_LOGIC                     := '1';
	signal GPMC_WAIT_O     : STD_LOGIC;

	signal GPIO : STD_LOGIC_VECTOR(15 downto 0) := (others => 'Z');
	signal LED  : STD_LOGIC_VECTOR(7 downto 0)  := (others => 'Z');

	--Internal Signals
	signal gpmc_fclk   : std_logic := '0';
	signal gpmcclk     : std_logic := '0';
	signal gpmc_clk_en : std_logic := '0';

	-- Clock period definitions
	constant SYS_CLK_I_period : time := 10 ns;
	constant gpmc_fclk_period : time := 6.024 ns;

begin
	uut : rhino_top_gpio
		port map(
			SYS_CLK_P       => SYS_CLK_P,
			SYS_CLK_N       => SYS_CLK_N,
			SYS_RST         => SYS_RST,
			SYS_PWR_ON      => SYS_PWR_ON,
			SYS_PLL_Locked  => SYS_PLL_Locked,
			GPMC_CLK_I      => GPMC_CLK_I,
			GPMC_D_B        => GPMC_D_B,
			GPMC_A_I        => GPMC_A_I,
			GPMC_nCS_I      => GPMC_nCS_I,
			GPMC_nADV_ALE_I => GPMC_nADV_ALE_I,
			GPMC_nWE_I      => GPMC_nWE_I,
			GPMC_nOE_I      => GPMC_nOE_I,
			GPMC_WAIT_O     => GPMC_WAIT_O,
			GPIO            => GPIO,
			LED             => LED
		);

	-- Clock process definitions
	SYS_CLK_I_process : process
	begin
		SYS_CLK_P <= '0';
		SYS_CLK_N <= '1';
		wait for SYS_CLK_I_period / 2;
		SYS_CLK_P <= '1';
		SYS_CLK_N <= '0';
		wait for SYS_CLK_I_period / 2;
	end process;

	gpmc_fclk_process : process
	begin
		gpmc_fclk <= '0';
		wait for gpmc_fclk_period / 2;
		gpmc_fclk <= '1';
		wait for gpmc_fclk_period / 2;
	end process;

	gpmcclk_process : process
	begin
		wait until rising_edge(gpmc_fclk);
		gpmcclk <= '0';
		wait until rising_edge(gpmc_fclk);
		gpmcclk <= '1';
	end process;

	GPMC_CLK_I <= gpmcclk and gpmc_clk_en;

	-- Stimulus process
	sys_stim_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;

		SYS_RST <= '0';

		wait for SYS_CLK_I_period * 40;

		wait;
	end process;

	gpmc_stim_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;

		wait for gpmc_fclk_period * 60;

		--READ Operation: WORD 1
		wait until rising_edge(gpmcclk); --0 Cycles
		GPMC_nADV_ALE_I <= '1';
		GPMC_A_I        <= "0000000000";
		GPMC_D_B        <= x"0006";
		gpmc_clk_en     <= '1';
		wait until rising_edge(gpmc_fclk); --1 Cycles
		GPMC_nCS_I      <= "1111101";
		GPMC_nADV_ALE_I <= '0';
		wait until rising_edge(gpmc_fclk); --2 Cycles
		wait until rising_edge(gpmc_fclk); --3 Cycles
		GPMC_nADV_ALE_I <= '1';
		wait until rising_edge(gpmc_fclk); --4 Cycles
		GPMC_D_B <= (others => 'Z');
		wait until rising_edge(gpmc_fclk); --5 Cycles
		GPMC_nOE_I <= '0';
		wait until rising_edge(gpmc_fclk); --6 Cycles
		wait for gpmc_fclk_period * 24;
		wait until rising_edge(gpmc_fclk);
		GPMC_nOE_I <= '1';
		wait until rising_edge(gpmc_fclk);
		GPMC_nCS_I <= "1111111";
		wait until rising_edge(gpmc_fclk);
		gpmc_clk_en     <= '0';
		GPMC_nADV_ALE_I <= '0';
		GPMC_A_I        <= "0000000000";
		--READ Operation: WORD 2
		wait until rising_edge(gpmcclk); --0 Cycles
		GPMC_nADV_ALE_I <= '1';
		GPMC_A_I        <= "0000000000";
		GPMC_D_B        <= x"0007";
		gpmc_clk_en     <= '1';
		wait until rising_edge(gpmc_fclk); --1 Cycles
		GPMC_nCS_I      <= "1111101";
		GPMC_nADV_ALE_I <= '0';
		wait until rising_edge(gpmc_fclk); --2 Cycles
		wait until rising_edge(gpmc_fclk); --3 Cycles
		GPMC_nADV_ALE_I <= '1';
		wait until rising_edge(gpmc_fclk); --4 Cycles
		GPMC_D_B <= (others => 'Z');
		wait until rising_edge(gpmc_fclk); --5 Cycles
		GPMC_nOE_I <= '0';
		wait until rising_edge(gpmc_fclk); --6 Cycles
		wait for gpmc_fclk_period * 24;
		wait until rising_edge(gpmc_fclk);
		GPMC_nOE_I <= '1';
		wait until rising_edge(gpmc_fclk);
		GPMC_nCS_I <= "1111111";
		wait until rising_edge(gpmc_fclk);
		gpmc_clk_en     <= '0';
		GPMC_nADV_ALE_I <= '0';
		GPMC_A_I        <= "0000000000";

		wait for gpmc_fclk_period * 4;

		--Write Operation: WORD 1
		wait until rising_edge(gpmcclk); --0 Cycles
		GPMC_nADV_ALE_I <= '1';
		GPMC_A_I        <= "0000000000";
		GPMC_D_B        <= x"0006";
		gpmc_clk_en     <= '1';
		wait until rising_edge(gpmc_fclk); --1 Cycles
		GPMC_nCS_I      <= "1111101";
		GPMC_nADV_ALE_I <= '0';
		wait until rising_edge(gpmc_fclk); --2 Cycles
		wait until rising_edge(gpmc_fclk); --3 Cycles
		GPMC_nADV_ALE_I <= '1';
		wait until rising_edge(gpmc_fclk); --4 Cycles
		GPMC_D_B <= x"4321";
		wait until rising_edge(gpmc_fclk); --5 Cycles
		GPMC_nWE_I <= '0';
		wait until rising_edge(gpmc_fclk); --6 Cycles
		wait until rising_edge(gpmc_fclk); --7 Cycles
		GPMC_nWE_I <= '1';
		wait until rising_edge(gpmc_fclk);
		GPMC_nCS_I <= "1111111";
		wait until rising_edge(gpmc_fclk);
		gpmc_clk_en     <= '0';
		GPMC_nADV_ALE_I <= '0';
		GPMC_A_I        <= "0000000000";
		--Write Operation: WORD 2
		wait until rising_edge(gpmcclk); --0 Cycles
		GPMC_nADV_ALE_I <= '1';
		GPMC_A_I        <= "0000000000";
		GPMC_D_B        <= x"0007";
		gpmc_clk_en     <= '1';
		wait until rising_edge(gpmc_fclk); --1 Cycles
		GPMC_nCS_I      <= "1111101";
		GPMC_nADV_ALE_I <= '0';
		wait until rising_edge(gpmc_fclk); --2 Cycles
		wait until rising_edge(gpmc_fclk); --3 Cycles
		GPMC_nADV_ALE_I <= '1';
		wait until rising_edge(gpmc_fclk); --4 Cycles
		GPMC_D_B <= x"8765";
		wait until rising_edge(gpmc_fclk); --5 Cycles
		GPMC_nWE_I <= '0';
		wait until rising_edge(gpmc_fclk); --6 Cycles
		wait until rising_edge(gpmc_fclk); --7 Cycles
		GPMC_nWE_I <= '1';
		wait until rising_edge(gpmc_fclk);
		GPMC_nCS_I <= "1111111";
		wait until rising_edge(gpmc_fclk);
		gpmc_clk_en     <= '0';
		GPMC_nADV_ALE_I <= '0';
		GPMC_A_I        <= "0000000000";

		wait for gpmc_fclk_period * 4;

		--READ Operation: WORD 1
		wait until rising_edge(gpmcclk); --0 Cycles
		GPMC_nADV_ALE_I <= '1';
		GPMC_A_I        <= "0000000000";
		GPMC_D_B        <= x"0006";
		gpmc_clk_en     <= '1';
		wait until rising_edge(gpmc_fclk); --1 Cycles
		GPMC_nCS_I      <= "1111101";
		GPMC_nADV_ALE_I <= '0';
		wait until rising_edge(gpmc_fclk); --2 Cycles
		wait until rising_edge(gpmc_fclk); --3 Cycles
		GPMC_nADV_ALE_I <= '1';
		wait until rising_edge(gpmc_fclk); --4 Cycles
		GPMC_D_B <= (others => 'Z');
		wait until rising_edge(gpmc_fclk); --5 Cycles
		GPMC_nOE_I <= '0';
		wait until rising_edge(gpmc_fclk); --6 Cycles
		wait for gpmc_fclk_period * 24;
		wait until rising_edge(gpmc_fclk);
		GPMC_nOE_I <= '1';
		wait until rising_edge(gpmc_fclk);
		GPMC_nCS_I <= "1111111";
		wait until rising_edge(gpmc_fclk);
		gpmc_clk_en     <= '0';
		GPMC_nADV_ALE_I <= '0';
		GPMC_A_I        <= "0000000000";
		--READ Operation: WORD 2
		wait until rising_edge(gpmcclk); --0 Cycles
		GPMC_nADV_ALE_I <= '1';
		GPMC_A_I        <= "0000000000";
		GPMC_D_B        <= x"0007";
		gpmc_clk_en     <= '1';
		wait until rising_edge(gpmc_fclk); --1 Cycles
		GPMC_nCS_I      <= "1111101";
		GPMC_nADV_ALE_I <= '0';
		wait until rising_edge(gpmc_fclk); --2 Cycles
		wait until rising_edge(gpmc_fclk); --3 Cycles
		GPMC_nADV_ALE_I <= '1';
		wait until rising_edge(gpmc_fclk); --4 Cycles
		GPMC_D_B <= (others => 'Z');
		wait until rising_edge(gpmc_fclk); --5 Cycles
		GPMC_nOE_I <= '0';
		wait until rising_edge(gpmc_fclk); --6 Cycles
		wait for gpmc_fclk_period * 24;
		wait until rising_edge(gpmc_fclk);
		GPMC_nOE_I <= '1';
		wait until rising_edge(gpmc_fclk);
		GPMC_nCS_I <= "1111111";
		wait until rising_edge(gpmc_fclk);
		gpmc_clk_en     <= '0';
		GPMC_nADV_ALE_I <= '0';
		GPMC_A_I        <= "0000000000";

		--Write Operation: WORD 1
		wait until rising_edge(gpmcclk); --0 Cycles
		GPMC_nADV_ALE_I <= '1';
		GPMC_A_I        <= "0000000000";
		GPMC_D_B        <= x"000C";
		gpmc_clk_en     <= '1';
		wait until rising_edge(gpmc_fclk); --1 Cycles
		GPMC_nCS_I      <= "1111101";
		GPMC_nADV_ALE_I <= '0';
		wait until rising_edge(gpmc_fclk); --2 Cycles
		wait until rising_edge(gpmc_fclk); --3 Cycles
		GPMC_nADV_ALE_I <= '1';
		wait until rising_edge(gpmc_fclk); --4 Cycles
		GPMC_D_B <= x"00FF";
		wait until rising_edge(gpmc_fclk); --5 Cycles
		GPMC_nWE_I <= '0';
		wait until rising_edge(gpmc_fclk); --6 Cycles
		wait until rising_edge(gpmc_fclk); --7 Cycles
		GPMC_nWE_I <= '1';
		wait until rising_edge(gpmc_fclk);
		GPMC_nCS_I <= "1111111";
		wait until rising_edge(gpmc_fclk);
		gpmc_clk_en     <= '0';
		GPMC_nADV_ALE_I <= '0';
		GPMC_A_I        <= "0000000000";
		--Write Operation: WORD 2
		wait until rising_edge(gpmcclk); --0 Cycles
		GPMC_nADV_ALE_I <= '1';
		GPMC_A_I        <= "0000000000";
		GPMC_D_B        <= x"000D";
		gpmc_clk_en     <= '1';
		wait until rising_edge(gpmc_fclk); --1 Cycles
		GPMC_nCS_I      <= "1111101";
		GPMC_nADV_ALE_I <= '0';
		wait until rising_edge(gpmc_fclk); --2 Cycles
		wait until rising_edge(gpmc_fclk); --3 Cycles
		GPMC_nADV_ALE_I <= '1';
		wait until rising_edge(gpmc_fclk); --4 Cycles
		GPMC_D_B <= x"0000";
		wait until rising_edge(gpmc_fclk); --5 Cycles
		GPMC_nWE_I <= '0';
		wait until rising_edge(gpmc_fclk); --6 Cycles
		wait until rising_edge(gpmc_fclk); --7 Cycles
		GPMC_nWE_I <= '1';
		wait until rising_edge(gpmc_fclk);
		GPMC_nCS_I <= "1111111";
		wait until rising_edge(gpmc_fclk);
		gpmc_clk_en     <= '0';
		GPMC_nADV_ALE_I <= '0';
		GPMC_A_I        <= "0000000000";

		wait for gpmc_fclk_period * 4;

		--Write Operation: WORD 1
		wait until rising_edge(gpmcclk); --0 Cycles
		GPMC_nADV_ALE_I <= '1';
		GPMC_A_I        <= "0000000000";
		GPMC_D_B        <= x"0008";
		gpmc_clk_en     <= '1';
		wait until rising_edge(gpmc_fclk); --1 Cycles
		GPMC_nCS_I      <= "1111101";
		GPMC_nADV_ALE_I <= '0';
		wait until rising_edge(gpmc_fclk); --2 Cycles
		wait until rising_edge(gpmc_fclk); --3 Cycles
		GPMC_nADV_ALE_I <= '1';
		GPMC_D_B <= x"0055";
		wait until rising_edge(gpmc_fclk); --4 Cycles
		GPMC_nWE_I <= '0';
		wait until rising_edge(gpmc_fclk); --5 Cycles
		wait until rising_edge(gpmc_fclk); --6 Cycles
		GPMC_nWE_I <= '1';
		GPMC_nCS_I <= "1111111";
		wait until rising_edge(gpmc_fclk);--7 Cycles
		gpmc_clk_en     <= '0';
		GPMC_nADV_ALE_I <= '0';
		GPMC_A_I        <= "0000000000";
		--Write Operation: WORD 2
		wait until rising_edge(gpmcclk); --0 Cycles
		GPMC_nADV_ALE_I <= '1';
		GPMC_A_I        <= "0000000000";
		GPMC_D_B        <= x"0009";
		gpmc_clk_en     <= '1';
		wait until rising_edge(gpmc_fclk); --1 Cycles
		GPMC_nCS_I      <= "1111101";
		GPMC_nADV_ALE_I <= '0';
		wait until rising_edge(gpmc_fclk); --2 Cycles
		wait until rising_edge(gpmc_fclk); --3 Cycles
		GPMC_nADV_ALE_I <= '1';
		wait until rising_edge(gpmc_fclk); --4 Cycles
		GPMC_D_B <= x"0000";
		wait until rising_edge(gpmc_fclk); --5 Cycles
		GPMC_nWE_I <= '0';
		wait until rising_edge(gpmc_fclk); --6 Cycles
		wait until rising_edge(gpmc_fclk); --7 Cycles
		GPMC_nWE_I <= '1';
		wait until rising_edge(gpmc_fclk);
		GPMC_nCS_I <= "1111111";
		wait until rising_edge(gpmc_fclk);
		gpmc_clk_en     <= '0';
		GPMC_nADV_ALE_I <= '0';
		GPMC_A_I        <= "0000000000";

		wait for gpmc_fclk_period * 4;

		--Write Operation: WORD 1
		wait until rising_edge(gpmcclk); --0 Cycles
		GPMC_nADV_ALE_I <= '1';
		GPMC_A_I        <= "0000000000";
		GPMC_D_B        <= x"0008";
		gpmc_clk_en     <= '1';
		wait until rising_edge(gpmc_fclk); --1 Cycles
		GPMC_nCS_I      <= "1111101";
		GPMC_nADV_ALE_I <= '0';
		wait until rising_edge(gpmc_fclk); --2 Cycles
		wait until rising_edge(gpmc_fclk); --3 Cycles
		GPMC_nADV_ALE_I <= '1';
		wait until rising_edge(gpmc_fclk); --4 Cycles
		GPMC_D_B <= x"00AA";
		wait until rising_edge(gpmc_fclk); --5 Cycles
		GPMC_nWE_I <= '0';
		wait until rising_edge(gpmc_fclk); --6 Cycles
		wait until rising_edge(gpmc_fclk); --7 Cycles
		GPMC_nWE_I <= '1';
		wait until rising_edge(gpmc_fclk);
		GPMC_nCS_I <= "1111111";
		wait until rising_edge(gpmc_fclk);
		gpmc_clk_en     <= '0';
		GPMC_nADV_ALE_I <= '0';
		GPMC_A_I        <= "0000000000";
		--Write Operation: WORD 2
		wait until rising_edge(gpmcclk); --0 Cycles
		GPMC_nADV_ALE_I <= '1';
		GPMC_A_I        <= "0000000000";
		GPMC_D_B        <= x"0009";
		gpmc_clk_en     <= '1';
		wait until rising_edge(gpmc_fclk); --1 Cycles
		GPMC_nCS_I      <= "1111101";
		GPMC_nADV_ALE_I <= '0';
		wait until rising_edge(gpmc_fclk); --2 Cycles
		wait until rising_edge(gpmc_fclk); --3 Cycles
		GPMC_nADV_ALE_I <= '1';
		wait until rising_edge(gpmc_fclk); --4 Cycles
		GPMC_D_B <= x"0000";
		wait until rising_edge(gpmc_fclk); --5 Cycles
		GPMC_nWE_I <= '0';
		wait until rising_edge(gpmc_fclk); --6 Cycles
		wait until rising_edge(gpmc_fclk); --7 Cycles
		GPMC_nWE_I <= '1';
		wait until rising_edge(gpmc_fclk);
		GPMC_nCS_I <= "1111111";
		wait until rising_edge(gpmc_fclk);
		gpmc_clk_en     <= '0';
		GPMC_nADV_ALE_I <= '0';
		GPMC_A_I        <= "0000000000";

		wait for gpmc_fclk_period * 4;

		wait;
	end process;

end architecture RTL;
