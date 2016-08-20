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
-- Name:		GPMC_WB_BRIDGE_TB
-- Type:		TB (F)
-- Description: 		
--
-- Compliance:		DUGONG V1.3
-- ID:			x 1-3-F-003
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

library DUGONG_MASTER_Lib;
use DUGONG_MASTER_Lib.dcomponents.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

--NB The DATA_WIDTH and ADDR_WIDTH constants are set in the dprimitives package
entity gpmc_wb_bridge_tb is
end entity gpmc_wb_bridge_tb;

architecture RTL of gpmc_wb_bridge_tb is
	signal CLK_I : STD_LOGIC  := '0';
	signal RST_I : STD_LOGIC  := '1';
	signal WB_MS : WB_MS_type;
	signal WB_SM : WB_SM_type := (others => '0');
	signal GNT_I : STD_LOGIC  := '0';

	--GPMC Interface
	signal GPMC_CLK_I      : STD_LOGIC                     := '0';
	signal GPMC_D_B        : STD_LOGIC_VECTOR(15 downto 0) := (others => 'Z');
	signal GPMC_A_I        : STD_LOGIC_VECTOR(10 downto 1) := (others => '0');
	signal GPMC_nCS_I      : STD_LOGIC_VECTOR(6 downto 0)  := (others => '1');
	signal GPMC_nADV_ALE_I : STD_LOGIC                     := '0';
	signal GPMC_nWE_I      : STD_LOGIC                     := '1';
	signal GPMC_nOE_I      : STD_LOGIC                     := '1';
	signal GPMC_WAIT_O     : STD_LOGIC;

	--Debugging
	signal DEBUG     : STD_LOGIC_VECTOR(31 downto 0);
	signal T_COUNT_O : STD_LOGIC_VECTOR(31 downto 0);
	signal E_COUNT_O : STD_LOGIC_VECTOR(31 downto 0);

	signal gpmcfclk    : std_logic := '0';
	signal gpmcclk     : std_logic := '0';
	signal gpmc_clk_en : std_logic := '0';

	-- Clock period definitions
	constant CLK_I_period    : time := 10 ns;
	constant gpmcfclk_period : time := 6.024 ns;

begin
	uut : component gpmc_wb_bridge
		port map(
			CLK_I           => CLK_I,
			RST_I           => RST_I,
			WB_MS           => WB_MS,
			WB_SM           => WB_SM,
			GNT_I           => GNT_I,
			GPMC_CLK_I      => GPMC_CLK_I,
			GPMC_D_B        => GPMC_D_B,
			GPMC_A_I        => GPMC_A_I,
			GPMC_nCS_I      => GPMC_nCS_I,
			GPMC_nADV_ALE_I => GPMC_nADV_ALE_I,
			GPMC_nWE_I      => GPMC_nWE_I,
			GPMC_nOE_I      => GPMC_nOE_I,
			GPMC_WAIT_O     => GPMC_WAIT_O,
			DEBUG           => DEBUG,
			T_COUNT_O       => T_COUNT_O,
			E_COUNT_O       => E_COUNT_O
		);

	-- Clock process definitions
	CLK_I_process : process
	begin
		CLK_I <= '0';
		wait for CLK_I_period / 2;
		CLK_I <= '1';
		wait for CLK_I_period / 2;
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
		wait until rising_edge(WB_MS(1 + DATA_WIDTH + ADDR_WIDTH));
		GNT_I <= '1';
		wait until rising_edge(CLK_I);
		WB_SM(DATA_WIDTH) <= '1';
		WB_SM(DATA_WIDTH - 1 downto 0) <= x"FFFFEEEE";
		wait until falling_edge(WB_MS(1 + DATA_WIDTH + ADDR_WIDTH));
		GNT_I <= '0';
		wait until rising_edge(CLK_I);
		WB_SM(DATA_WIDTH) <= '0';
		WB_SM(DATA_WIDTH - 1 downto 0) <= x"00000000";
	end process;

	gpmc_stim_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;

		RST_I <= '0';

		wait for gpmcfclk_period * 10;

		--WRITE OPERATION
		wait until rising_edge(gpmcfclk);
		GPMC_nADV_ALE_I <= '1';
		GPMC_A_I        <= "0000000000";
		GPMC_D_B        <= x"1E08";
		gpmc_clk_en     <= '1';
		wait until falling_edge(gpmcfclk);
		GPMC_nCS_I <= "1111110";
		wait until falling_edge(gpmcfclk);
		GPMC_nADV_ALE_I <= '0';
		wait until falling_edge(gpmcfclk);
		wait until falling_edge(gpmcfclk);
		wait until falling_edge(gpmcfclk);
		wait until falling_edge(gpmcfclk);
		GPMC_nADV_ALE_I <= '1';
		wait until rising_edge(gpmcfclk);
		GPMC_D_B <= x"BA98";
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
		GPMC_nCS_I <= "1111110";
		wait until falling_edge(gpmcfclk);
		GPMC_nADV_ALE_I <= '0';
		wait until falling_edge(gpmcfclk);
		wait until falling_edge(gpmcfclk);
		wait until falling_edge(gpmcfclk);
		wait until falling_edge(gpmcfclk);
		GPMC_nADV_ALE_I <= '1';
		wait until rising_edge(gpmcfclk);
		GPMC_D_B <= x"FEDC";
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
		GPMC_D_B        <= x"E000";
		gpmc_clk_en     <= '1';
		wait until falling_edge(gpmcfclk);
		GPMC_nCS_I <= "1111110";
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
		GPMC_D_B        <= x"E001";
		gpmc_clk_en     <= '1';
		wait until falling_edge(gpmcfclk);
		GPMC_nCS_I <= "1111110";
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
