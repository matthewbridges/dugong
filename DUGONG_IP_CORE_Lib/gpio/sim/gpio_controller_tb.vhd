--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:07:48 04/02/2013
-- Design Name:   
-- Module Name:   C:/Users/Matthew Bridges/projects/dugong/dugong_ip_cores/gpio/sim/gpio_controller_tb.vhd
-- Project Name:  dugong
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: gpio_controller
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY gpio_controller_tb IS
END gpio_controller_tb;

ARCHITECTURE behavior OF gpio_controller_tb IS

	-- Component Declaration for the Unit Under Test (UUT)

	component gpio_controller
		generic(
			DATA_WIDTH : natural := 16;
			ADDR_WIDTH : natural := 3
		);
		port(
			CLK_I : in    STD_LOGIC;
			RST_I : in    STD_LOGIC;
			DAT_I : in    STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			DAT_O : out   STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			ADR_I : in    STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
			STB_I : in    STD_LOGIC;
			WE_I  : in    STD_LOGIC;
			ACK_O : out   STD_LOGIC;
			GPIO  : inout STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0)
		);
	end component gpio_controller;

	--Inputs
	signal CLK_I : std_logic                     := '0';
	signal RST_I : std_logic                     := '1';
	signal DAT_I : std_logic_vector(15 downto 0) := (others => '0');
	signal ADR_I : std_logic_vector(2 downto 0)  := (others => '0');
	signal STB_I : std_logic                     := '0';
	signal WE_I  : std_logic                     := '0';

	--BiDirs
	signal GPIO : std_logic_vector(15 downto 0) := (others => 'Z');

	--Outputs
	signal DAT_O : std_logic_vector(15 downto 0);
	signal ACK_O : std_logic;

	-- Clock period definitions
	constant CLK_I_period : time := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : gpio_controller
		port map(
			CLK_I => CLK_I,
			RST_I => RST_I,
			DAT_I => DAT_I,
			DAT_O => DAT_O,
			ADR_I => ADR_I,
			STB_I => STB_I,
			WE_I  => WE_I,
			ACK_O => ACK_O,
			GPIO  => GPIO
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
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		DAT_I <= x"0000";
		wait until rising_edge(CLK_I);
		DAT_I <= x"000F";               --Write x000F to GPIO_OUT
		ADR_I <= "000";                 --ADDR x0
		WE_I  <= '1';                   --Write
		STB_I <= '1';                   --Strobe
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		WE_I  <= '0';
		DAT_I <= x"0000";
		wait until rising_edge(CLK_I);
		DAT_I <= x"0000";               --Read from GPIO_IN 
		ADR_I <= "001";                 --ADDR x1
		WE_I  <= '0';                   --Read
		STB_I <= '1';                   --Strobe
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		DAT_I <= x"0000";
		GPIO  <= x"FF00";
		wait until rising_edge(CLK_I);
		GPIO(7 downto 0) <= (others => 'Z');
		DAT_I            <= x"00FF";    --Write x00FF to GPIO_OE
		ADR_I            <= "010";      --ADDR x0
		WE_I             <= '1';        --Write
		STB_I            <= '1';        --Strobe
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		WE_I  <= '0';
		DAT_I <= x"0000";
		wait until rising_edge(CLK_I);
		DAT_I <= x"0000";               --Read from GPIO_IN 
		ADR_I <= "001";                 --ADDR x1
		WE_I  <= '0';                   --Read
		STB_I <= '1';                   --Strobe
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		DAT_I <= x"0000";
		wait until rising_edge(CLK_I);
		DAT_I <= x"0000";               --Write x0000 to GPIO_OUT
		ADR_I <= "000";                 --ADDR x0
		WE_I  <= '1';                   --Write
		STB_I <= '1';                   --Strobe
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		WE_I  <= '0';
		DAT_I <= x"0000";
		ADR_I <= "000";
		GPIO  <= x"0000";
		wait;
	end process;

END;
