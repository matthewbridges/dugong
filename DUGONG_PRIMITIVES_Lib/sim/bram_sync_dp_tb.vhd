--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:01:30 05/08/2013
-- Design Name:   
-- Module Name:   C:/Users/Matthew Bridges/projects/dugong/DUGONG_IP_CORE_Lib/wb_bus/sim/bram_sync_dp_tb.vhd
-- Project Name:  DUGONG_IP_CORE_Lib
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: bram_sync_dp
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

ENTITY bram_sync_dp_tb IS
END bram_sync_dp_tb;

ARCHITECTURE behavior OF bram_sync_dp_tb IS

	-- Component Declaration for the Unit Under Test (UUT)

	COMPONENT bram_sync_dp
		PORT(
			A_CLK_I : IN  std_logic;
			A_DAT_I : IN  std_logic_vector(31 downto 0);
			A_DAT_O : OUT std_logic_vector(31 downto 0);
			A_ADR_I : IN  std_logic_vector(9 downto 0);
			A_WE_I  : IN  std_logic;
			B_CLK_I : IN  std_logic;
			B_DAT_I : IN  std_logic_vector(31 downto 0);
			B_DAT_O : OUT std_logic_vector(31 downto 0);
			B_ADR_I : IN  std_logic_vector(9 downto 0);
			B_WE_I  : IN  std_logic
		);
	END COMPONENT;

	--Inputs
	signal A_CLK_I : std_logic                     := '0';
	signal A_DAT_I : std_logic_vector(31 downto 0) := (others => '0');
	signal A_ADR_I : std_logic_vector(9 downto 0)  := (others => '1');
	signal A_WE_I  : std_logic                     := '0';
	signal B_CLK_I : std_logic                     := '0';
	signal B_DAT_I : std_logic_vector(31 downto 0) := (others => '0');
	signal B_ADR_I : std_logic_vector(9 downto 0)  := (others => '1');
	signal B_WE_I  : std_logic                     := '0';

	--Outputs
	signal A_DAT_O : std_logic_vector(31 downto 0);
	signal B_DAT_O : std_logic_vector(31 downto 0);
	-- No clocks detected in port list. Replace <clock> below with 
	-- appropriate port name 

	constant A_CLK_I_period : time := 10 ns;
	constant B_CLK_I_period : time := 7 ns;
BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : bram_sync_dp PORT MAP(
			A_CLK_I => A_CLK_I,
			A_DAT_I => A_DAT_I,
			A_DAT_O => A_DAT_O,
			A_ADR_I => A_ADR_I,
			A_WE_I  => A_WE_I,
			B_CLK_I => B_CLK_I,
			B_DAT_I => B_DAT_I,
			B_DAT_O => B_DAT_O,
			B_ADR_I => B_ADR_I,
			B_WE_I  => B_WE_I
		);

	-- Clock process definitions
	A_CLK_I_process : process
	begin
		A_CLK_I <= '0';
		wait for A_CLK_I_period / 2;
		A_CLK_I <= '1';
		wait for A_CLK_I_period / 2;
	end process;

	B_CLK_I_process : process
	begin
		B_CLK_I <= '0';
		wait for B_CLK_I_period / 2;
		B_CLK_I <= '1';
		wait for B_CLK_I_period / 2;
	end process;

	-- Stimulus process
	PORT_A_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;

		wait for A_CLK_I_period * 10;

		wait until rising_edge(A_CLK_I);
		A_ADR_I <= "00" & x"00";        --ADDR x0
		A_WE_I  <= '0';
		-- insert stimulus here
		wait until rising_edge(A_CLK_I);
		A_DAT_I <= x"AAAAAAAA";
		A_ADR_I <= "00" & x"01";        --ADDR x1
		A_WE_I  <= '1';
		wait until rising_edge(A_CLK_I);
		A_WE_I  <= '0';
		A_DAT_I <= x"00000000";
		wait;
	end process;

	PORT_B_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;

		wait for B_CLK_I_period * 10;

		-- insert stimulus here
		wait until rising_edge(B_CLK_I);
		B_DAT_I <= x"BBBBBBBB";
		B_ADR_I <= "00" & x"00";        --ADDR x0
		B_WE_I  <= '1';
		wait until rising_edge(B_CLK_I);
		B_WE_I  <= '0';
		B_DAT_I <= x"00000000";
		wait;
	end process;
END;
