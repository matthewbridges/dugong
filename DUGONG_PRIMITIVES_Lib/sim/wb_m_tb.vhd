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

entity wb_m_tb is
end entity wb_m_tb;

architecture Behavioral of wb_m_tb is
	--System Control Inputs:
	signal CLK_I : std_logic := '0';
	signal RST_I : std_logic := '1';

	--Master to WB
	signal WB_MS : WB_MS_type;
	signal WB_SM : WB_SM_type := (others => '0');

	--Wishbone Slave interface (inverted) 1-2
	signal ADR_O     : STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0) := (others => '0');
	signal DAT_I     : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
	signal DAT_O     : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0) := (others => '0');
	signal WE_O      : STD_LOGIC                                 := '0';
	signal STB_O     : STD_LOGIC                                 := '0';
	signal ACK_I     : STD_LOGIC;
	signal CYC_O     : STD_LOGIC                                 := '0';
	signal ERR_I     : STD_LOGIC;
	signal GNT_I     : STD_LOGIC                                 := '0';
	signal T_COUNT_O : STD_LOGIC_VECTOR(31 downto 0);
	signal E_COUNT_O : STD_LOGIC_VECTOR(31 downto 0);

	signal ack_err : std_logic;

	-- Clock period definitions
	constant CLK_I_period : time := 10 ns;

begin
	uut : wb_m
		port map(
			CLK_I     => CLK_I,
			RST_I     => RST_I,
			WB_MS     => WB_MS,
			WB_SM     => WB_SM,
			ADR_O     => ADR_O,
			DAT_I     => DAT_I,
			DAT_O     => DAT_O,
			STB_O     => STB_O,
			WE_O      => WE_O,
			ACK_I     => ACK_I,
			CYC_O     => CYC_O,
			ERR_I     => ERR_I,
			GNT_I     => GNT_I,
			T_COUNT_O => T_COUNT_O,
			E_COUNT_O => E_COUNT_O
		);

	-- Clock process definitions
	CLK_I_process : process
	begin
		CLK_I <= '0';
		wait for CLK_I_period / 2;
		CLK_I <= '1';
		wait for CLK_I_period / 2;
	end process;

	ack_err <= ACK_I or ERR_I;

	-- Stimulus process
	wb_stim_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;

		RST_I <= '0';

		wait for CLK_I_period * 10;

		-- 
		wait until rising_edge(CLK_I);
		STB_O <= '1';
		wait until rising_edge(ack_err);
		STB_O <= '0';
		wait until rising_edge(CLK_I);
		STB_O <= '1';
		wait until rising_edge(ack_err);
		STB_O <= '0';
		wait until rising_edge(CLK_I);
		STB_O <= '1';
		GNT_I <= '1';
		wait until rising_edge(ack_err);
		STB_O <= '0';
		wait;
	end process;

	-- Stimulus process
	wb_slave_proc : process
	begin
		wait until rising_edge(STB_O);
		wait until rising_edge(CLK_I);
		WB_SM(DATA_WIDTH)              <= '1';
		WB_SM(DATA_WIDTH - 1 downto 0) <= x"FFFFEEEE";
		wait until falling_edge(STB_O);
		wait until rising_edge(CLK_I);
		WB_SM(DATA_WIDTH)              <= '0';
		WB_SM(DATA_WIDTH - 1 downto 0) <= x"00000000";
	end process;

end architecture Behavioral;
