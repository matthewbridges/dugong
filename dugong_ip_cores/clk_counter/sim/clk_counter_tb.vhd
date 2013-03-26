--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:01:03 09/14/2012
-- Design Name:   
-- Module Name:   /home/mbridges/Projects/Dugong/other/sim/clk_counter_tb.vhd
-- Project Name:  Dugong
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: clk_counter
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

ENTITY clk_counter_tb IS
END clk_counter_tb;

ARCHITECTURE behavior OF clk_counter_tb IS

	-- Component Declaration for the Unit Under Test (UUT)
	component clk_counter
		generic(
			DATA_WIDTH : natural                       := 32;
			ADDR_WIDTH : natural                       := 2;
			MASTER_CNT : std_logic_vector(26 downto 0) := "111" & x"52FFFF"
		);
		port(
			CLK_I       : in  STD_LOGIC;
			RST_I       : in  STD_LOGIC;
			DAT_O       : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			ADR_I       : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
			STB_I       : in  STD_LOGIC;
			ACK_O       : out STD_LOGIC;
			TEST_CLOCKS : in  STD_LOGIC_VECTOR((2 ** ADDR_WIDTH) - 1 downto 0)
		);
	end component clk_counter;

	--Inputs
	signal CLK_I       : std_logic                    := '0';
	signal RST_I       : std_logic                    := '1';
	signal ADR_I       : std_logic_vector(1 downto 0) := "01";
	signal STB_I       : std_logic                    := '1';
	signal TEST_CLOCKS : std_logic_vector(3 downto 0) := (others => '0');

	--Outputs
	signal DAT_O : std_logic_vector(31 downto 0);
	signal ACK_O : std_logic;

	-- Clock period definitions
	constant CLK_I_period : time := 10 ns;
	constant CLK_A_period : time := 1 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : clk_counter
		generic map(
			MASTER_CNT => "000" & x"000032"
		)
		port map(
			CLK_I       => CLK_I,
			RST_I       => RST_I,
			DAT_O       => DAT_O,
			ADR_I       => ADR_I,
			STB_I       => STB_I,
			ACK_O       => ACK_O,
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
	CLK_A_process : process
	begin
		TEST_CLOCKS(0) <= '0';
		TEST_CLOCKS(1) <= '0';
		TEST_CLOCKS(2) <= '0';
		TEST_CLOCKS(3) <= '0';
		wait for CLK_A_period / 2;
		TEST_CLOCKS(0) <= '1';
		TEST_CLOCKS(1) <= '1';
		TEST_CLOCKS(2) <= '1';
		TEST_CLOCKS(3) <= '1';
		wait for CLK_A_period / 2;
	end process;

	-- Stimulus process
	stim_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;

		RST_I <= '0';

		wait for CLK_I_period * 10;

		-- insert stimulus here 

		wait;
	end process;

END;
