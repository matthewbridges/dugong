--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:39:34 08/31/2012
-- Design Name:   
-- Module Name:   /home/mbridges/Projects/Dugong/rhino_top_tb.vhd
-- Project Name:  Dugong
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: rhino_top
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

ENTITY rhino_top_tb IS
END rhino_top_tb;

ARCHITECTURE behavior OF rhino_top_tb IS

	-- Component Declaration for the Unit Under Test (UUT)

	COMPONENT rhino_top
		PORT(
			SYS_CLK_P : IN  std_logic;
			SYS_CLK_N : IN  std_logic;
			SYS_RST   : IN  std_logic;
			GPIO      : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

	--Inputs
	signal SYS_CLK_P : std_logic := '0';
	signal SYS_CLK_N : std_logic := '1';
	signal SYS_RST   : std_logic := '1';

	--Outputs
	signal GPIO : std_logic_vector(7 downto 0);
	-- No clocks detected in port list. Replace <clock> below with 
	-- appropriate port name 

	constant SYS_CLK_P_period : time := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : rhino_top PORT MAP(
			SYS_CLK_P => SYS_CLK_P,
			SYS_CLK_N => SYS_CLK_N,
			SYS_RST   => SYS_RST,
			GPIO      => GPIO
		);

	-- Clock process definitions
	SYS_CLK_P_process : process
	begin
		SYS_CLK_P <= '0';
		SYS_CLK_N <= '1';
		wait for SYS_CLK_P_period / 2;
		SYS_CLK_P <= '1';
		SYS_CLK_N <= '0';
		wait for SYS_CLK_P_period / 2;
	end process;

	-- Stimulus process
	stim_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;

		wait for SYS_CLK_P_period * 10;

		-- insert stimulus here 
		SYS_RST <= '0';


		wait;
	end process;

END;
