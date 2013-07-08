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
-- Name:		GPIO_CONTROLLER_TB 
-- Type:		TB (F)
-- Description: 		
--
-- Compliance:		DUGONG V1.4
-- ID:			x 1-4-F
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

ENTITY gpio_controller_tb IS
	generic(
		DATA_WIDTH : NATURAL := 16;
		ADDR_WIDTH : NATURAL := 3
	);
END gpio_controller_tb;

ARCHITECTURE behavior OF gpio_controller_tb IS

	-- Component Declaration for the Unit Under Test (UUT)
	component gpio_controller
		generic(
			DATA_WIDTH          : natural := 16;
			ADDR_WIDTH          : natural := 3;
			NUMBER_OF_REGISTERS : natural := 3
		);
		port(
			--System Control Inputs
			CLK_I      : in    STD_LOGIC;
			RST_I      : in    STD_LOGIC;
			--Wishbone Slave Lines
			ADR_I      : in    STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
			DAT_I      : in    STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			DAT_O      : out   STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			WE_I       : in    STD_LOGIC;
			STB_I      : in    STD_LOGIC;
			ACK_O      : out   STD_LOGIC;
			CYC_I      : in    STD_LOGIC;
			--GPIO Auxiliary Interface
			GPIO_AUX_O : out   STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			GPIO_AUX_I : in    STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			--GPIO Interface
			GPIO_B     : inout STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0)
		);
	end component gpio_controller;

	--System Control Inputs:
	signal CLK_I : std_logic := '0';
	signal RST_I : std_logic := '1';

	--Wishbone Slave interface
	signal ADR_I : STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0) := (others => '0');
	signal DAT_I : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0) := (others => '0');
	signal DAT_O : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
	signal WE_I  : STD_LOGIC                                 := '0';
	signal STB_I : STD_LOGIC                                 := '0';
	signal ACK_O : STD_LOGIC                                 := '0';
	signal CYC_I : STD_LOGIC                                 := '0';

	signal GPIO_AUX_O : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
	signal GPIO_AUX_I : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0) := (others => '0');

	signal GPIO_B : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => 'Z');

	-- Clock period definitions
	constant CLK_I_period : time := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : gpio_controller
		generic map(
			DATA_WIDTH => DATA_WIDTH,
			ADDR_WIDTH => ADDR_WIDTH
		)
		port map(CLK_I      => CLK_I,
			 RST_I      => RST_I,
			 ADR_I      => ADR_I,
			 DAT_I      => DAT_I,
			 DAT_O      => DAT_O,
			 WE_I       => WE_I,
			 STB_I      => STB_I,
			 ACK_O      => ACK_O,
			 CYC_I      => CYC_I,
			 GPIO_AUX_O => GPIO_AUX_O,
			 GPIO_AUX_I => GPIO_AUX_I,
			 GPIO_B     => GPIO_B);

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
		-- hold reset state for 500 ns.
		wait for 500 ns;

		RST_I <= '0';

		wait for CLK_I_period * 10;

		-- insert stimulus here
		wait until rising_edge(CLK_I);
		DAT_I <= x"0000";               --Read from GPIO_OE 
		ADR_I <= "010";                 --ADDR x3
		WE_I  <= '0';                   --Read
		STB_I <= '1';                   --Strobe
		CYC_I <= '1';
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		CYC_I <= '0';
		DAT_I <= x"0000";
		wait until rising_edge(CLK_I);
		DAT_I <= x"000F";               --Write x000F to GPIO_OUT
		ADR_I <= "000";                 --ADDR x0
		WE_I  <= '1';                   --Write
		STB_I <= '1';                   --Strobe
		CYC_I <= '1';
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		WE_I  <= '0';
		CYC_I <= '0';
		DAT_I <= x"0000";
		wait until rising_edge(CLK_I);
		DAT_I <= x"0000";               --Read from GPIO_IN 
		ADR_I <= "001";                 --ADDR x1
		WE_I  <= '0';                   --Read
		STB_I <= '1';                   --Strobe
		CYC_I <= '1';
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I  <= '0';                  --NULL
		CYC_I  <= '0';
		DAT_I  <= x"0000";
		GPIO_B <= x"FF00";
		wait until rising_edge(CLK_I);
		GPIO_B(7 downto 0) <= (others => 'Z');
		DAT_I              <= x"00FF";  --Write x00FF to GPIO_OE
		ADR_I              <= "010";    --ADDR x0
		WE_I               <= '1';      --Write
		STB_I              <= '1';      --Strobe
		CYC_I              <= '1';
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		WE_I  <= '0';
		CYC_I <= '0';
		DAT_I <= x"0000";
		wait until rising_edge(CLK_I);
		DAT_I <= x"0000";               --Read from GPIO_IN 
		ADR_I <= "001";                 --ADDR x1
		WE_I  <= '0';                   --Read
		STB_I <= '1';                   --Strobe
		CYC_I <= '1';
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		CYC_I <= '0';
		DAT_I <= x"0000";
		wait until rising_edge(CLK_I);
		DAT_I <= x"0000";               --Write x0000 to GPIO_OUT
		ADR_I <= "000";                 --ADDR x0
		WE_I  <= '1';                   --Write
		STB_I <= '1';                   --Strobe
		CYC_I <= '1';
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I  <= '0';                  --NULL
		WE_I   <= '0';
		CYC_I  <= '0';
		DAT_I  <= x"0000";
		ADR_I  <= "000";
		GPIO_B <= x"0000";
		wait;
	end process;

END;
