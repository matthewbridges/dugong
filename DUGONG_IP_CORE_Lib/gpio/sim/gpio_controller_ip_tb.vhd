--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:49:26 08/29/2012
-- Design Name:   
-- Module Name:   /home/mbridges/Projects/Dugong/sim/gpio_controller_ip_tb.vhd
-- Project Name:  Dugong
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: gpio_controller_ip
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
-- USE ieee.numeric_std.ALL;

library DUGONG_IP_CORES;
use DUGONG_IP_CORES.dcores.ALL;

ENTITY gpio_controller_ip_tb IS
END gpio_controller_ip_tb;

ARCHITECTURE behavior OF gpio_controller_ip_tb IS

	--Inputs
	signal CLK_I : std_logic                     := '0';
	signal RST_I : std_logic                     := '1';
	signal WB_I  : std_logic_vector(46 downto 0) := (others => '0');

	--BiDirs
	signal GPIO : std_logic_vector(15 downto 0) := (others => 'Z');

	--Outputs
	signal WB_O : std_logic_vector(32 downto 0);

	-- Clock period definitions
	constant CLK_I_period : time := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : gpio_controller_ip
		port map(
			CLK_I => CLK_I,
			RST_I => RST_I,
			WB_I  => WB_I,
			WB_O  => WB_O,
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

		-- Standard IP Core Tests
		wait until rising_edge(CLK_I);
		WB_I <= "101" & x"000" & x"00000000"; --Read Base Address
		wait until rising_edge(WB_O(32));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"00000000"; --NULL
		wait until rising_edge(CLK_I);
		WB_I <= "101" & x"001" & x"00000000"; --Read High Address
		wait until rising_edge(WB_O(32));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"00000000"; --NULL


		wait until rising_edge(CLK_I);
		WB_I <= "101" & x"006" & x"00000000"; --Read from GPIO_OE
		wait until rising_edge(WB_O(32));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"00000000"; --NULL
		wait until rising_edge(CLK_I);
		WB_I <= "111" & x"004" & x"0000000F"; --Write x000F to GPIO_OUT
		wait until rising_edge(WB_O(32));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"00000000"; --NULL
		wait until rising_edge(CLK_I);
		WB_I <= "101" & x"005" & x"00000000"; --Read from GPIO_IN
		wait until rising_edge(WB_O(32));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"00000000"; --NULL
		GPIO <= x"FF00";
		wait until rising_edge(CLK_I);
		GPIO(7 downto 0) <= (others => 'Z');
		WB_I             <= "111" & x"006" & x"000000FF"; --Write x00FF to GPIO_OE
		wait until rising_edge(WB_O(32));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"00000000"; --NULL
		wait until rising_edge(CLK_I);
		WB_I <= "101" & x"005" & x"00000000"; --Read from GPIO_IN 
		wait until rising_edge(WB_O(32));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"00000000"; --NULL
		wait until rising_edge(CLK_I);
		WB_I <= "111" & x"004" & x"00000000"; --Write x0000 to GPIO_OUT
		wait until rising_edge(WB_O(32));
		wait until rising_edge(CLK_I);
		WB_I              <= "000" & x"000" & x"00000000"; --NULL
		GPIO(15 downto 0) <= (others => 'Z');
		wait until rising_edge(CLK_I);
		WB_I <= "111" & x"006" & x"00000000"; --Write x00FF to GPIO_OE
		wait until rising_edge(WB_O(32));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"00000000"; --NULL

		---------------------------------------
		--- Displays Bug | x0007 cropping up at strange times
		---------------------------------------
		wait until rising_edge(CLK_I);
		WB_I <= "101" & x"000" & x"0000000F"; --Read High Address
		wait until rising_edge(WB_O(32));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"00000000"; --NULL
		wait until rising_edge(CLK_I);
		WB_I <= "111" & x"F04" & x"0000000F"; --Write to Address not in Range
		wait until rising_edge(WB_O(32));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"00000000"; --NULL
		wait;
	end process;

END;
