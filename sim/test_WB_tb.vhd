--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:29:27 08/28/2012
-- Design Name:   
-- Module Name:   /home/mbridges/Projects/Dugong/test_WB_tb.vhd
-- Project Name:  Dugong
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: test_WB
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

ENTITY test_WB_tb IS
END test_WB_tb;

ARCHITECTURE behavior OF test_WB_tb IS

	-- Component Declaration for the Unit Under Test (UUT)

	COMPONENT test_WB
		PORT(
			CLK_I   : IN std_logic;
			RST_I   : IN std_logic;
			DAT_I   : OUT std_logic_vector(15 downto 0);
			DAT_O   : IN  std_logic_vector(15 downto 0);
			ADR_O   : IN  std_logic_vector(11 downto 0);
			WE_O    : IN  std_logic;
			STB_O   : IN  std_logic;
			ACK_I   : OUT std_logic;
			CYC_O   : IN  std_logic;
			s_DAT_I : OUT std_logic_vector(15 downto 0);
			s_DAT_O : IN  std_logic_vector(15 downto 0);
			ADR_I   : OUT std_logic_vector(11 downto 0);
			WE_I    : OUT std_logic;
			STB_I   : OUT std_logic;
			ACK_O   : IN  std_logic;
			CYC_I   : OUT std_logic
		);
	END COMPONENT;

	--Inputs
	signal CLK_I   : std_logic := '0';
	signal RST_I   : std_logic := '1';	
	signal DAT_O   : std_logic_vector(15 downto 0) := (others => '0');
	signal ADR_O   : std_logic_vector(11 downto 0) := (others => '0');
	signal WE_O    : std_logic                     := '0';
	signal STB_O   : std_logic                     := '0';
	signal CYC_O   : std_logic                     := '0';
	signal s_DAT_O : std_logic_vector(15 downto 0) := (others => '0');
	signal ACK_O   : std_logic                     := '0';

	--Outputs
	signal DAT_I   : std_logic_vector(15 downto 0);
	signal ACK_I   : std_logic;
	signal s_DAT_I : std_logic_vector(15 downto 0);
	signal ADR_I   : std_logic_vector(11 downto 0);
	signal WE_I    : std_logic;
	signal STB_I   : std_logic;
	signal CYC_I   : std_logic;

	-- Clock period definitions
	constant CLK_I_period : time := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : test_WB PORT MAP(
			CLK_I   => CLK_I,
			RST_I   => RST_I,
			DAT_I   => DAT_I,
			DAT_O   => DAT_O,
			ADR_O   => ADR_O,
			WE_O    => WE_O,
			STB_O   => STB_O,
			ACK_I   => ACK_I,
			CYC_O   => CYC_O,
			s_DAT_I => s_DAT_I,
			s_DAT_O => s_DAT_O,
			ADR_I   => ADR_I,
			WE_I    => WE_I,
			STB_I   => STB_I,
			ACK_O   => ACK_O,
			CYC_I   => CYC_I
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
	stim_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;
		RST_I <= '0';
		wait for CLK_I_period * 10;

		-- insert stimulus here
		ADR_O <= "000000001011";
		wait for 22 ns;
		STB_O <= '1';
		wait for 40 ns;
		DAT_O <= x"F0F0";
		wait for 20 ns;
		WE_O <= '1';
		wait for 20 ns;
		STB_O <= '0';
		wait for 20 ns;
		ADR_O <= x"F0F";

		wait;
	end process;
END;
