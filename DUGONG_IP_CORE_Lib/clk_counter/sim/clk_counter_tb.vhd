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
-- Name:		CLK_COUNTER_TB
-- Type:		TB (15)
-- Description:
--
-- Compliance:		DUGONG V1.4
-- ID:			x 1-4-F
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

ENTITY clk_counter_tb IS
	generic(
		CORE_DATA_WIDTH : natural := 32;
		CORE_ADDR_WIDTH : natural := 3
	);
END clk_counter_tb;

ARCHITECTURE behavior OF clk_counter_tb IS

	-- Component Declaration for the Unit Under Test (UUT)
	component clk_counter
		generic(
			CORE_DATA_WIDTH : natural := 32;
			CORE_ADDR_WIDTH : natural := 3
		);
		port(
			CLK_I       : in  STD_LOGIC;
			RST_I       : in  STD_LOGIC;
			ADR_I       : in  STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0);
			DAT_I       : in  STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
			DAT_O       : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
			WE_I        : in  STD_LOGIC;
			STB_I       : in  STD_LOGIC;
			ACK_O       : out STD_LOGIC;
			CYC_I       : in  STD_LOGIC;
			TEST_CLOCKS : in  STD_LOGIC_VECTOR(2 downto 0)
		);
	end component clk_counter;

	--System Control Inputs:
	signal CLK_I : std_logic := '0';
	signal RST_I : std_logic := '1';

	--Wishbone Slave interface
	signal ADR_I : STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0) := (others => '0');
	signal DAT_I : STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0) := (others => '0');
	signal DAT_O : STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
	signal WE_I  : STD_LOGIC                                      := '0';
	signal STB_I : STD_LOGIC                                      := '0';
	signal ACK_O : STD_LOGIC                                      := '0';
	signal CYC_I : STD_LOGIC                                      := '0';

	--SPI Interface
	signal TEST_CLOCKS : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');

	-- Clock period definitions
	constant CLK_I_period : time := 10 ns;
	constant CLK_0_period : time := 10 ns;
	constant CLK_1_period : time := 10 ns;
	constant CLK_2_period : time := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : clk_counter
		generic map(
			CORE_DATA_WIDTH => CORE_DATA_WIDTH,
			CORE_ADDR_WIDTH => CORE_ADDR_WIDTH
		)
		port map(
			CLK_I       => CLK_I,
			RST_I       => RST_I,
			ADR_I       => ADR_I,
			DAT_I       => DAT_I,
			DAT_O       => DAT_O,
			WE_I        => WE_I,
			STB_I       => STB_I,
			ACK_O       => ACK_O,
			CYC_I       => CYC_I,
			TEST_CLOCKS => TEST_CLOCKS
		);

	-- Clock process definitions
	CLK_I_process : process
	begin
		CLK_I <= '0';
		wait for CLK_I_period / 2;
		CLK_I <= '1';
		wait for CLK_I_period / 2;
	end process;

	-- Clock process definitions
	CLK_0_process : process
	begin
		TEST_CLOCKS(0) <= '0';
		wait for CLK_0_period / 2;
		TEST_CLOCKS(0) <= '1';
		wait for CLK_0_period / 2;
	end process;

	-- Clock process definitions
	CLK_1_process : process
	begin
		TEST_CLOCKS(1) <= '0';
		wait for CLK_1_period / 2;
		TEST_CLOCKS(1) <= '1';
		wait for CLK_1_period / 2;
	end process;

	-- Clock process definitions
	CLK_2_process : process
	begin
		TEST_CLOCKS(2) <= '0';
		wait for CLK_2_period / 2;
		TEST_CLOCKS(2) <= '1';
		wait for CLK_2_period / 2;
	end process;

	-- Stimulus process
	wb_stim_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;

		RST_I <= '0';

		wait for CLK_I_period * 10;

		-- insert stimulus here
		wait until rising_edge(CLK_I);
		DAT_I <= x"00000000";           --Read from MASER_COUNT
		ADR_I <= "011";                 --ADDR x3
		WE_I  <= '0';                   --Read
		STB_I <= '1';                   --Strobe
		CYC_I <= '1';
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		CYC_I <= '0';
		DAT_I <= x"00000000";
		wait until rising_edge(CLK_I);
		DAT_I <= x"00000000";           --Read from COUNT[[0]
		ADR_I <= "000";                 --ADDR x0
		WE_I  <= '0';                   --Read
		STB_I <= '1';                   --Strobe
		CYC_I <= '1';
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		CYC_I <= '0';
		DAT_I <= x"00000000";
		wait until rising_edge(CLK_I);
		DAT_I <= x"00000100";           --Write to MASTER_COUNT
		ADR_I <= "011";                 --ADDR x3
		WE_I  <= '1';                   --Write
		STB_I <= '1';                   --Strobe
		CYC_I <= '1';
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		CYC_I <= '0';
		DAT_I <= x"00000000";
		wait until rising_edge(CLK_I);
		DAT_I <= x"00000000";           --Read from COUNT[[0]
		ADR_I <= "000";                 --ADDR x0
		WE_I  <= '0';                   --Read
		STB_I <= '1';                   --Strobe
		CYC_I <= '1';
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		CYC_I <= '0';
		DAT_I <= x"00000000";

		wait for CLK_I_period * 256;

		wait until rising_edge(CLK_I);
		DAT_I <= x"00000000";           --Read from COUNT[[0]
		ADR_I <= "000";                 --ADDR x0
		WE_I  <= '0';                   --Read
		STB_I <= '1';                   --Strobe
		CYC_I <= '1';
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		DAT_I <= x"00000000";
		wait until rising_edge(CLK_I);
		DAT_I <= x"00000000";           --Read from Counter 0 
		ADR_I <= "001";                 --ADDR x0
		WE_I  <= '0';                   --Read
		STB_I <= '1';                   --Strobe
		CYC_I <= '1';
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		CYC_I <= '0';
		DAT_I <= x"00000000";
		wait until rising_edge(CLK_I);
		DAT_I <= x"00000000";           --Read from Counter 0 
		ADR_I <= "010";                 --ADDR x0
		WE_I  <= '0';                   --Read
		STB_I <= '1';                   --Strobe
		CYC_I <= '1';
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		CYC_I <= '0';
		DAT_I <= x"00000000";

		wait;
	end process;

END;
