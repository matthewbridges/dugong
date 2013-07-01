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
use IEEE.numeric_std.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

entity wb_s_tb is
	generic(
		BASE_ADDR       : UNSIGNED(31 downto 0) := x"00000000";
		CORE_DATA_WIDTH : NATURAL               := 16;
		CORE_ADDR_WIDTH : NATURAL               := 3
	);
end entity wb_s_tb;

architecture Behavioral of wb_s_tb is

	--System Control Inputs:
	signal CLK_I : std_logic := '0';
	signal RST_I : std_logic := '1';

	--Slave to WB
	signal WB_MS : WB_MS_type := (others => '0');
	signal WB_SM : WB_SM_type;

	--Wishbone Slave interface (inverted) 1-2
	signal ADR_I : STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0);
	signal DAT_I : STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
	signal DAT_O : STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0) := (others => '0');
	signal WE_I  : STD_LOGIC;
	signal STB_I : STD_LOGIC;
	signal ACK_O : STD_LOGIC                                      := '0';
	signal CYC_I : STD_LOGIC;

	-- Clock period definitions
	constant CLK_I_period : time := 10 ns;

begin
	uut : wb_s
		generic map(
			BASE_ADDR       => BASE_ADDR,
			CORE_DATA_WIDTH => CORE_DATA_WIDTH,
			CORE_ADDR_WIDTH => CORE_ADDR_WIDTH
		)
		port map(
			CLK_I => CLK_I,
			RST_I => RST_I,
			WB_MS => WB_MS,
			WB_SM => WB_SM,
			ADR_I => ADR_I,
			DAT_I => DAT_I,
			DAT_O => DAT_O,
			WE_I  => WE_I,
			STB_I => STB_I,
			ACK_O => ACK_O,
			CYC_I => CYC_I
		);

	-- Clock process definitions
	CLK_I_process : process
	begin
		CLK_I <= '0';
		wait for CLK_I_period / 2;
		CLK_I <= '1';
		wait for CLK_I_period / 2;
	end process;

	-- Stimulus process
	wb_slave_proc : process
	begin
		wait until rising_edge(STB_I);
		wait until rising_edge(CLK_I);
		ACK_O <= '1';
		DAT_O <= x"FFEE";
		wait until falling_edge(STB_I);
		wait until rising_edge(CLK_I);
		ACK_O <= '0';
	end process;

	-- Stimulus process
	wb_stim_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;

		RST_I <= '0';
		WB_MS <= "111" & x"FEDCBA98" & x"FFFFFFF";

		wait for CLK_I_period * 10;

		-- Standard IP Core Tests
		wait until rising_edge(CLK_I);
		WB_MS <= "110" & x"00000000" & x"0000000"; --Read Base Address
		wait until rising_edge(WB_SM(DATA_WIDTH));
		wait until rising_edge(CLK_I);
		WB_MS <= "000" & x"00000000" & x"0000000"; --NULL
		wait until rising_edge(CLK_I);
		WB_MS <= "110" & x"00000000" & x"0000001"; --Read High Address
		wait until rising_edge(WB_SM(DATA_WIDTH));
		wait until rising_edge(CLK_I);
		WB_MS <= "000" & x"00000000" & x"0000000"; --NULL

		wait until rising_edge(CLK_I);
		WB_MS <= "111" & x"FEDCAB98" & x"0000004"; --Write xFEDCAB98 to 004
		wait until rising_edge(WB_SM(DATA_WIDTH));
		wait until rising_edge(CLK_I);
		WB_MS <= "000" & x"00000000" & x"0000000"; --NULL

		wait until rising_edge(CLK_I);
		WB_MS <= "111" & x"FEDCAB98" & x"0000008"; --Write xFEDCAB98 to 008

		wait;
	end process;

end architecture Behavioral;
