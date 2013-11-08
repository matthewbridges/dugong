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
-- Name:		WB_S_TB (002)
-- Type:		TB (F)
-- Description: 		
--
-- Compliance:		DUGONG V1.4
-- ID:			x 1-4-F-002
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

entity rhino_top_tb is
	generic(
		NUMBER_OF_MASTERS : NATURAL := 2;
		NUMBER_OF_SLAVES  : NATURAL := 3
	);
end entity rhino_top_tb;

architecture RTL of rhino_top_tb is

	-- Component Declaration for the Unit Under Test (UUT)
	--NB The DATA_WIDTH and ADDR_WIDTH constants are set in the dprimitives package
	component rhino_top is
		generic(
			NUMBER_OF_MASTERS : NATURAL := 2;
			NUMBER_OF_SLAVES  : NATURAL := 4
		);
		port(
			--System Control Inputs
			SYS_CLK_P       : in    STD_LOGIC;
			SYS_CLK_N       : in    STD_LOGIC;
			SYS_RST         : in    STD_LOGIC;
			--System Control Outputs
			SYS_CLK_o       : out   STD_LOGIC;
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
			--WB Status Signals
			WB_GNT_O        : out   STD_LOGIC_VECTOR(NUMBER_OF_MASTERS - 1 downto 0);
			-- USER GPIOs
			GPIO            : inout STD_LOGIC_VECTOR(15 downto 0);
			--USER LEDs
			LED             : inout STD_LOGIC_VECTOR(7 downto 0);
			--Debug GPIOs
			DEBUG           : inout STD_LOGIC_VECTOR(31 downto 0)
		);
	end component;
	signal SYS_CLK_P       : STD_LOGIC                     := '0';
	signal SYS_CLK_N       : STD_LOGIC                     := '1';
	signal SYS_RST         : STD_LOGIC                     := '1';
	signal SYS_CLK_o       : STD_LOGIC;
	signal SYS_PWR_ON      : STD_LOGIC;
	signal SYS_PLL_Locked  : STD_LOGIC;
	signal GPMC_CLK_I      : STD_LOGIC                     := '0';
	signal GPMC_D_B        : STD_LOGIC_VECTOR(15 downto 0) := (others => 'Z');
	signal GPMC_A_I        : STD_LOGIC_VECTOR(10 downto 1) := (others => '0');
	signal GPMC_nCS_I      : STD_LOGIC_VECTOR(6 downto 0)  := (others => '1');
	signal GPMC_nADV_ALE_I : STD_LOGIC                     := '1';
	signal GPMC_nWE_I      : STD_LOGIC                     := '1';
	signal GPMC_nOE_I      : STD_LOGIC                     := '1';
	signal GPMC_WAIT_O     : STD_LOGIC;
	signal WB_GNT_O        : STD_LOGIC_VECTOR(NUMBER_OF_MASTERS - 1 downto 0);
	signal GPIO            : STD_LOGIC_VECTOR(15 downto 0) := (others => 'Z');
	signal LED             : STD_LOGIC_VECTOR(7 downto 0)  := (others => 'Z');
	signal DEBUG           : STD_LOGIC_VECTOR(31 downto 0) := (others => 'Z');

	signal gpmcfclk    : std_logic := '0';
	signal gpmcclk     : std_logic := '0';
	signal gpmc_clk_en : std_logic := '0';

	-- Clock period definitions
	constant SYS_CLK_I_period : time := 10 ns;
	constant gpmcfclk_period  : time := 6.024 ns;

begin
	uut : component rhino_top
		port map(
			SYS_CLK_P       => SYS_CLK_P,
			SYS_CLK_N       => SYS_CLK_N,
			SYS_RST         => SYS_RST,
			SYS_CLK_o       => SYS_CLK_o,
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
			WB_GNT_O        => WB_GNT_O,
			GPIO            => GPIO,
			LED             => LED,
			DEBUG           => DEBUG
		);

	-- Clock process definitions
	CLK_I_process : process
	begin
		SYS_CLK_P <= '0';
		SYS_CLK_N <= '1';
		wait for SYS_CLK_I_period / 2;
		SYS_CLK_P <= '1';
		SYS_CLK_N <= '0';
		wait for SYS_CLK_I_period / 2;
	end process;

	gpmcfclk_process : process
	begin
		gpmcfclk <= '0';
		wait for gpmcfclk_period / 2;
		gpmcfclk <= '1';
		wait for gpmcfclk_period / 2;
	end process;

	gpmcclk_process : process
	begin
		wait until rising_edge(gpmcfclk);
		wait until rising_edge(gpmcfclk);
		gpmcclk <= '0';
		wait until rising_edge(gpmcfclk);
		wait until rising_edge(gpmcfclk);
		gpmcclk <= '1';
	end process;

	GPMC_CLK_I <= gpmcclk and gpmc_clk_en;

	-- Stimulus process
	wb_stim_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;

		SYS_RST <= '0';

		wait for SYS_CLK_I_period * 10;

		wait;
	end process;

	gpmc_stim_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;

		wait for gpmcfclk_period * 100;

		--WRITE OPERATION
		wait until rising_edge(gpmcfclk);
		GPMC_nADV_ALE_I <= '1';
		GPMC_A_I        <= "0000000000";
		GPMC_D_B        <= x"1E08";
		gpmc_clk_en     <= '1';
		wait until falling_edge(gpmcfclk);
		GPMC_nCS_I <= "1111101";
		wait until falling_edge(gpmcfclk);
		GPMC_nADV_ALE_I <= '0';
		wait until falling_edge(gpmcfclk);
		wait until falling_edge(gpmcfclk);
		wait until falling_edge(gpmcfclk);
		wait until falling_edge(gpmcfclk);
		GPMC_nADV_ALE_I <= '1';
		wait until rising_edge(gpmcfclk);
		GPMC_D_B <= x"FFFF";
		wait until falling_edge(gpmcfclk);
		GPMC_nWE_I <= '0';
		wait until falling_edge(gpmcfclk);
		wait until falling_edge(gpmcfclk);
		wait until falling_edge(gpmcfclk);
		wait until falling_edge(gpmcfclk);
		GPMC_nWE_I <= '1';
		wait until rising_edge(gpmcfclk);
		GPMC_nCS_I <= "1111111";
		wait until rising_edge(gpmcfclk);
		gpmc_clk_en     <= '0';
		GPMC_nADV_ALE_I <= '0';
		GPMC_A_I        <= "0000000000";
		GPMC_D_B        <= (others => 'Z');
		--WORD 2
		wait until rising_edge(gpmcfclk);
		GPMC_nADV_ALE_I <= '1';
		GPMC_A_I        <= "0000000000";
		GPMC_D_B        <= x"1E09";
		gpmc_clk_en     <= '1';
		wait until falling_edge(gpmcfclk);
		GPMC_nCS_I <= "1111101";
		wait until falling_edge(gpmcfclk);
		GPMC_nADV_ALE_I <= '0';
		wait until falling_edge(gpmcfclk);
		wait until falling_edge(gpmcfclk);
		wait until falling_edge(gpmcfclk);
		wait until falling_edge(gpmcfclk);
		GPMC_nADV_ALE_I <= '1';
		wait until rising_edge(gpmcfclk);
		GPMC_D_B <= x"FFFF";
		wait until falling_edge(gpmcfclk);
		GPMC_nWE_I <= '0';
		wait until falling_edge(gpmcfclk);
		wait until falling_edge(gpmcfclk);
		wait until falling_edge(gpmcfclk);
		wait until falling_edge(gpmcfclk);
		GPMC_nWE_I <= '1';
		wait until rising_edge(gpmcfclk);
		GPMC_nCS_I <= "1111111";
		wait until rising_edge(gpmcfclk);
		gpmc_clk_en     <= '0';
		GPMC_nADV_ALE_I <= '0';
		GPMC_A_I        <= "0000000000";
		GPMC_D_B        <= (others => 'Z');

		--READ Operation
		wait until rising_edge(gpmcfclk);
		GPMC_nADV_ALE_I <= '1';
		GPMC_A_I        <= "0000000000";
		GPMC_D_B        <= x"1E08";
		gpmc_clk_en     <= '1';
		wait until falling_edge(gpmcfclk);
		GPMC_nCS_I <= "1111101";
		wait until falling_edge(gpmcfclk);
		GPMC_nADV_ALE_I <= '0';
		wait until falling_edge(gpmcfclk);
		wait until falling_edge(gpmcfclk);
		wait until falling_edge(gpmcfclk);
		wait until falling_edge(gpmcfclk);
		GPMC_nADV_ALE_I <= '1';
		wait until rising_edge(gpmcfclk);
		GPMC_D_B <= (others => 'Z');
		wait until falling_edge(gpmcfclk);
		GPMC_nOE_I <= '0';
		wait until falling_edge(gpmcfclk);
		wait until falling_edge(gpmcfclk);
		wait until falling_edge(gpmcfclk);
		wait until falling_edge(gpmcfclk);
		GPMC_nOE_I <= '1';
		wait until rising_edge(gpmcfclk);
		GPMC_nCS_I <= "1111111";
		wait until falling_edge(gpmcfclk);
		gpmc_clk_en     <= '0';
		GPMC_nADV_ALE_I <= '0';
		GPMC_A_I        <= "0000000000";
		--WORD 2
		wait until rising_edge(gpmcfclk);
		GPMC_nADV_ALE_I <= '1';
		GPMC_A_I        <= "0000000000";
		GPMC_D_B        <= x"1E09";
		gpmc_clk_en     <= '1';
		wait until falling_edge(gpmcfclk);
		GPMC_nCS_I <= "1111101";
		wait until falling_edge(gpmcfclk);
		GPMC_nADV_ALE_I <= '0';
		wait until falling_edge(gpmcfclk);
		wait until falling_edge(gpmcfclk);
		wait until falling_edge(gpmcfclk);
		wait until falling_edge(gpmcfclk);
		GPMC_nADV_ALE_I <= '1';
		wait until rising_edge(gpmcfclk);
		GPMC_D_B <= (others => 'Z');
		wait until falling_edge(gpmcfclk);
		GPMC_nOE_I <= '0';
		wait until falling_edge(gpmcfclk);
		wait until falling_edge(gpmcfclk);
		wait until falling_edge(gpmcfclk);
		wait until falling_edge(gpmcfclk);
		GPMC_nOE_I <= '1';
		wait until rising_edge(gpmcfclk);
		GPMC_nCS_I <= "1111111";
		wait until falling_edge(gpmcfclk);
		gpmc_clk_en     <= '0';
		GPMC_nADV_ALE_I <= '0';
		GPMC_A_I        <= "0000000000";

		wait;
	end process;

end architecture RTL;