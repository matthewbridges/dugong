--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:00:22 07/31/2012
-- Design Name:   
-- Module Name:   /home/mbridges/Projects/project_Dugong_v0a/program_counter_tb.vhd
-- Project Name:  project_Dugong_v0a
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: program_counter
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

ENTITY program_counter_tb IS
	generic(
		DATA_WIDTH : natural := 9;
		PROG_SIZE  : natural := 15
	);
END program_counter_tb;

ARCHITECTURE behavior OF program_counter_tb IS

	-- Component Declaration for the Unit Under Test (UUT)

	COMPONENT program_counter
		generic(
			DATA_WIDTH : natural := 9;
			PROG_SIZE  : natural := 4
		);
		PORT(
			EN_I  : IN  std_logic;
			LD_I  : IN  std_logic;
			CLK_I : IN  std_logic;
			RST_I : IN  std_logic;
			DAT_O : OUT std_logic_vector(DATA_WIDTH - 1 downto 0);
			DAT_I : IN  std_logic_vector(DATA_WIDTH - 1 downto 0)
		);
	END COMPONENT;

	--Inputs
	signal EN_I  : std_logic                                 := '0';
	signal LD_I  : std_logic                                 := '0';
	signal CLK_I : std_logic                                 := '0';
	signal RST_I : std_logic                                 := '0';
	signal DAT_I : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');

	--Outputs
	signal DAT_O : std_logic_vector(DATA_WIDTH - 1 downto 0);

	-- Clock period definitions
	constant CLK_I_period : time := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : program_counter
		GENERIC MAP(
			DATA_WIDTH => DATA_WIDTH,
			PROG_SIZE  => PROG_SIZE
		)
		PORT MAP(
			EN_I  => EN_I,
			LD_I  => LD_I,
			CLK_I => CLK_I,
			RST_I => RST_I,
			DAT_O => DAT_O,
			DAT_I => DAT_I
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

		wait for CLK_I_period * 10;

		-- insert stimulus here 
		EN_I <= '1';

		wait;
	end process;

END;
