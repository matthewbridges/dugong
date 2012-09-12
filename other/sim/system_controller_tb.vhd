--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:56:49 09/12/2012
-- Design Name:   
-- Module Name:   /home/mbridges/Projects/Dugong/other/sim/system_controller_tb.vhd
-- Project Name:  Dugong
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: system_controller
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

ENTITY system_controller_tb IS
END system_controller_tb;

ARCHITECTURE behavior OF system_controller_tb IS

	-- Component Declaration for the Unit Under Test (UUT)

	COMPONENT system_controller
		PORT(
			SYS_CLK_P  : IN  std_logic;
			SYS_CLK_N  : IN  std_logic;
			SYS_RST    : IN  std_logic;
			CLK_100MHz : OUT std_logic;
			CLK_200Mhz : OUT std_logic;
			RST_O      : OUT std_logic
		);
	END COMPONENT;

	--Inputs
	signal SYS_CLK_P : std_logic := '0';
	signal SYS_CLK_N : std_logic := '1';
	signal SYS_RST   : std_logic := '1';

	--Outputs
	signal CLK_100MHz : std_logic;
	signal CLK_200Mhz : std_logic;
	signal RST_O      : std_logic;

	-- Clock period definitions
	constant SYS_CLK_period : time := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : system_controller PORT MAP(
			SYS_CLK_P  => SYS_CLK_P,
			SYS_CLK_N  => SYS_CLK_N,
			SYS_RST    => SYS_RST,
			CLK_100MHz => CLK_100MHz,
			CLK_200Mhz => CLK_200Mhz,
			RST_O      => RST_O
		);

	-- Clock process definitions
	SYS_CLK_process : process
	begin
		SYS_CLK_P <= '0';
		SYS_CLK_N <= '1';
		wait for SYS_CLK_period / 2;
		SYS_CLK_P <= '1';
		SYS_CLK_N <= '0';
		wait for SYS_CLK_period / 2;
	end process;

	-- Stimulus process
	stim_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;

		SYS_RST <= '0';

		wait for SYS_CLK_period * 10;

		-- insert stimulus here

		wait for 200 ns;
		SYS_RST <= '1';
		wait for 50 ns;
		SYS_RST <= '0';

		wait;
	end process;

END;
