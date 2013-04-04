--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:04:49 09/28/2012
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

library RHINO_DUGONG;
use RHINO_DUGONG.dcomponents.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY system_controller_tb IS
END system_controller_tb;

ARCHITECTURE behavior OF system_controller_tb IS

	--Inputs
	signal SYS_CLK_P : std_logic := '1';
	signal SYS_CLK_N : std_logic := '0';
	signal SYS_RST   : std_logic := '1';

	--Outputs
	signal SYS_CLK_o      : std_logic;
	signal SYS_PWR_ON     : std_logic;
	signal SYS_PLL_Locked : std_logic;
	signal CLK_123MHZ     : std_logic;
	signal CLK_123MHZ_n   : std_logic;
	signal CLK_246MHZ     : std_logic;
	signal CLK_983MHZ     : std_logic;
	signal CLK_15MHZ      : std_logic;
	signal CLK_15MHZ_n    : std_logic;
	signal RST_O          : std_logic;

	-- Clock period definitions
	constant SYS_CLK_period : time := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : system_controller
		port map(
			SYS_CLK_P      => SYS_CLK_P,
			SYS_CLK_N      => SYS_CLK_N,
			SYS_CLK_o      => SYS_CLK_o,
			SYS_RST        => SYS_RST,
			SYS_PWR_ON     => SYS_PWR_ON,
			SYS_PLL_Locked => SYS_PLL_Locked,
			CLK_123MHZ     => CLK_123MHZ,
			CLK_123MHZ_n   => CLK_123MHZ_n,
			CLK_246MHZ     => CLK_246MHZ,
			CLK_983MHZ     => CLK_983MHZ,
			CLK_15MHZ      => CLK_15MHZ,
			CLK_15MHZ_n    => CLK_15MHZ_n,
			RST_O          => RST_O,
			WB_I           => WB_I,
			WB_O           => WB_O
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

		wait;
	end process;

END;
