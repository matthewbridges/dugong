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
-- Engineer:		MATTHEW BRIDGES
--
-- Name:		WB_ARBITER_TB 
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

entity wb_arbiter_intercon_tb is
	generic(
		NUMBER_OF_MASTERS : NATURAL := 2;
		NUMBER_OF_SLAVES  : NATURAL := 4
	);
end entity wb_arbiter_intercon_tb;

architecture RTL of wb_arbiter_intercon_tb is
	signal CLK_I     : STD_LOGIC                                    := '0';
	signal RST_I     : STD_LOGIC                                    := '1';
	signal WB_MS     : WB_MS_vector(NUMBER_OF_MASTERS - 1 downto 0) := (others => (others => '0'));
	signal WB_MS_BUS : WB_MS_type;
	signal WB_SM     : WB_SM_vector(NUMBER_OF_SLAVES - 1 downto 0)  := (others => (others => '0'));
	signal WB_SM_BUS : WB_SM_type;
	signal WB_GNT_O  : STD_LOGIC_VECTOR(NUMBER_OF_MASTERS - 1 downto 0);

	signal ack0 : std_logic;
	signal ack1 : std_logic;

	-- Clock period definitions
	constant CLK_I_period    : time := 10 ns;
	constant gpmcfclk_period : time := 6.024 ns;

begin
	uut : wb_arbiter_intercon
		generic map(
			NUMBER_OF_MASTERS => NUMBER_OF_MASTERS,
			NUMBER_OF_SLAVES  => NUMBER_OF_SLAVES
		)
		port map(
			CLK_I     => CLK_I,
			RST_I     => RST_I,
			WB_MS     => WB_MS,
			WB_MS_BUS => WB_MS_BUS,
			WB_SM     => WB_SM,
			WB_SM_BUS => WB_SM_BUS,
			WB_GNT_O  => WB_GNT_O
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
		wait until rising_edge(WB_MS_BUS(1 + DATA_WIDTH + ADDR_WIDTH));
		wait until rising_edge(CLK_I);
		WB_SM(0)(DATA_WIDTH)              <= '1';
		WB_SM(0)(DATA_WIDTH - 1 downto 0) <= x"FFFFEEEE";
		wait until falling_edge(WB_MS_BUS(1 + DATA_WIDTH + ADDR_WIDTH));
		wait until rising_edge(CLK_I);
		WB_SM(0)(DATA_WIDTH)              <= '0';
		WB_SM(0)(DATA_WIDTH - 1 downto 0) <= x"00000000";
	end process;

	ack1 <= WB_GNT_O(1) and (WB_SM_BUS(DATA_WIDTH));

	dugong_wb_stim_proc : process
	begin
		-- hold reset state for 500 ns.
		wait for 100 ns;

		RST_I <= '0';

		wait for CLK_I_period * 10;

		-- Standard IP Core Tests
		wait until rising_edge(CLK_I);
		WB_MS(1) <= "110" & x"00000000" & x"2000000"; --Read Base Address
		wait until rising_edge(ack1);
		wait until rising_edge(CLK_I);
		WB_MS(1)(2 + DATA_WIDTH + ADDR_WIDTH downto DATA_WIDTH + ADDR_WIDTH) <= "000"; --NULL
		wait until rising_edge(CLK_I);
		WB_MS(1) <= "110" & x"00000000" & x"2000001"; --Read High Address
		wait until rising_edge(ack1);
		wait until rising_edge(CLK_I);
		WB_MS(1)(2 + DATA_WIDTH + ADDR_WIDTH downto DATA_WIDTH + ADDR_WIDTH) <= "000"; --NULL

		wait;
	end process;

	ack0 <= WB_GNT_O(0) and (WB_SM_BUS(DATA_WIDTH));

	arm_wb_stim_proc : process
	begin
		-- hold reset state for 500 ns.
		wait for 100 ns;

		wait for gpmcfclk_period * 20;

		-- Standard IP Core Tests
		wait until rising_edge(CLK_I);
		WB_MS(0) <= "110" & x"00000000" & x"1000000"; --Read Base Address
		wait until rising_edge(ack0);
		wait until rising_edge(CLK_I);
		WB_MS(0)(2 + DATA_WIDTH + ADDR_WIDTH downto DATA_WIDTH + ADDR_WIDTH) <= "000"; --NULL
		wait until rising_edge(CLK_I);
		WB_MS(0) <= "110" & x"00000000" & x"1000001"; --Read High Address
		wait until rising_edge(ack0);
		wait until rising_edge(CLK_I);
		WB_MS(0)(2 + DATA_WIDTH + ADDR_WIDTH downto DATA_WIDTH + ADDR_WIDTH) <= "000"; --NULL

		wait;
	end process;

end architecture RTL;
