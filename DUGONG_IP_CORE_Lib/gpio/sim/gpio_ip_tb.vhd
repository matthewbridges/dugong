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
-- ID:			x 
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

library DUGONG_IP_CORE_Lib;
use DUGONG_IP_CORE_Lib.dcores.ALL;

entity gpio_ip_tb is
	generic(
		CORE_DATA_WIDTH : natural := 16
	);
end gpio_ip_tb;

architecture behavior of gpio_ip_tb is

	--System Control Inputs:
	signal CLK_I : std_logic := '0';
	signal RST_I : std_logic := '1';

	--Slave to WB
	signal WB_MS : WB_MS_type := (others => '0');
	signal WB_SM : WB_SM_type;

	--SPI Interface
	signal GPIO_AUX_IN  : std_logic_vector(CORE_DATA_WIDTH - 1 downto 0);
	signal GPIO_AUX_OUT : std_logic_vector(CORE_DATA_WIDTH - 1 downto 0) := (others => '0');
	signal GPIO_B       : STD_LOGIC_vector(CORE_DATA_WIDTH - 1 downto 0) := (others => 'Z');

	-- Clock period definitions
	constant CLK_I_period : time := 10 ns;

begin

	-- Instantiate the Unit Under Test (UUT)
	uut : gpio_ip
		generic map(
			CORE_DATA_WIDTH => 16
		)
		port map(
			CLK_I        => CLK_I,
			RST_I        => RST_I,
			WB_MS        => WB_MS,
			WB_SM        => WB_SM,
			GPIO_AUX_IN  => GPIO_AUX_IN,
			GPIO_AUX_OUT => GPIO_AUX_OUT,
			GPIO_B       => GPIO_B
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
		WB_MS <= "110" & x"00000000" & x"0000002"; --Read Core ID
		wait until rising_edge(WB_SM(DATA_WIDTH));
		wait until rising_edge(CLK_I);
		WB_MS <= "000" & x"00000000" & x"0000000"; --NULL
		wait until rising_edge(CLK_I);
		WB_MS <= "111" & x"FEDCAB98" & x"0000003"; --Write xFEDCAB98 to 003
		wait until rising_edge(WB_SM(DATA_WIDTH));
		wait until rising_edge(CLK_I);
		WB_MS <= "000" & x"00000000" & x"0000000"; --NULL


		wait until rising_edge(CLK_I);
		WB_MS <= "110" & x"00000000" & x"0000006"; --Read from GPIO_OE
		wait until rising_edge(WB_SM(DATA_WIDTH));
		wait until rising_edge(CLK_I);
		WB_MS <= "000" & x"00000000" & x"0000000"; --NULL
		wait until rising_edge(CLK_I);
		WB_MS <= "111" & x"0000000F" & x"0000004"; --Write x000F to GPIO_OUT
		wait until rising_edge(WB_SM(DATA_WIDTH));
		wait until rising_edge(CLK_I);
		WB_MS <= "000" & x"00000000" & x"0000000"; --NULL
		wait until rising_edge(CLK_I);
		WB_MS <= "110" & x"00000000" & x"0000005"; --Read from GPIO_IN
		wait until rising_edge(WB_SM(DATA_WIDTH));
		wait until rising_edge(CLK_I);
		WB_MS  <= "000" & x"00000000" & x"0000000"; --NULL
		GPIO_B <= x"FF00";
		wait until rising_edge(CLK_I);
		GPIO_B(7 downto 0) <= (others => 'Z');
		WB_MS              <= "111" & x"000000FF" & x"0000006"; --Write x00FF to GPIO_OE
		wait until rising_edge(WB_SM(DATA_WIDTH));
		wait until rising_edge(CLK_I);
		WB_MS <= "000" & x"00000000" & x"0000000"; --NULL
		wait until rising_edge(CLK_I);
		WB_MS <= "110" & x"00000000" & x"0000005"; --Read from GPIO_IN
		wait until rising_edge(WB_SM(DATA_WIDTH));
		wait until rising_edge(CLK_I);
		WB_MS <= "000" & x"00000000" & x"0000000"; --NULL
		wait until rising_edge(CLK_I);
		WB_MS <= "111" & x"00000000" & x"0000004"; --Write x0000 to GPIO_OE
		wait until rising_edge(WB_SM(DATA_WIDTH));
		wait until rising_edge(CLK_I);
		WB_MS  <= "000" & x"00000000" & x"0000000"; --NULL
		GPIO_B <= (others => 'Z');

		wait;
	end process;

end;
