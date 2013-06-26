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
use IEEE.numeric_std.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

entity gpmc_m_tb is
	generic(
		GPMC_ADDR_WIDTH : natural := 28
	);
end entity gpmc_m_tb;

architecture Behavioral of gpmc_m_tb is

	--System Control Inputs:
	signal CLK_I : std_logic := '0';
	signal RST_I : std_logic := '1';

	--Wishbone Master Lines
	signal ADR_O : STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
	signal DAT_I : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0) := (others => '0');
	signal DAT_O : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
	signal WE_O  : STD_LOGIC;
	signal STB_O : STD_LOGIC;
	signal ACK_I : STD_LOGIC                                 := '0';
	signal CYC_O : STD_LOGIC;
	signal ERR_I : STD_LOGIC                                 := '0';

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
	signal DEBUG : STD_LOGIC_VECTOR(31 downto 0);

	signal gpmcfclk    : std_logic := '0';
	signal gpmcclk     : std_logic := '0';
	signal gpmc_clk_en : std_logic := '0';

	-- Clock period definitions
	constant CLK_I_period    : time := 10 ns;
	constant gpmcfclk_period : time := 6.024 ns;

begin
	uut : gpmc_m
		generic map(
			GPMC_ADDR_WIDTH => GPMC_ADDR_WIDTH
		)
		port map(
			CLK_I           => CLK_I,
			RST_I           => RST_I,
			ADR_O           => ADR_O,
			DAT_I           => DAT_I,
			DAT_O           => DAT_O,
			WE_O            => WE_O,
			STB_O           => STB_O,
			ACK_I           => ACK_I,
			CYC_O           => CYC_O,
			ERR_I           => ERR_I,
			GPMC_CLK_I      => GPMC_CLK_I,
			GPMC_D_B        => GPMC_D_B,
			GPMC_A_I        => GPMC_A_I,
			GPMC_nCS_I      => GPMC_nCS_I,
			GPMC_nADV_ALE_I => GPMC_nADV_ALE_I,
			GPMC_nWE_I      => GPMC_nWE_I,
			GPMC_nOE_I      => GPMC_nOE_I,
			GPMC_WAIT_O     => GPMC_WAIT_O,
			DEBUG           => DEBUG
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
		wait until rising_edge(STB_O);
		wait until rising_edge(CLK_I);
		ACK_I <= '1';
		DAT_I <= x"FFFFEEEE";
		wait until falling_edge(STB_O);
		wait until rising_edge(CLK_I);
		ACK_I <= '0';
		DAT_I <= x"00000000";
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

end architecture Behavioral;


