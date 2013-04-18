--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:10:50 08/22/2012
-- Design Name:   
-- Module Name:   /home/mbridges/Dugong/tb/program_counter_tb.vhd
-- Project Name:  Dugong
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
END program_counter_tb;

ARCHITECTURE behavior OF program_counter_tb IS

	-- Component Declaration for the Unit Under Test (UUT)

	COMPONENT program_counter
		PORT(
			CLK_I : IN  std_logic;
			RST_I : IN  std_logic;
			DAT_I : IN  std_logic_vector(8 downto 0);
			DAT_O : OUT std_logic_vector(8 downto 0);
			WE_I  : IN  std_logic;
			STB_I : IN  std_logic;
			ACK_O : OUT std_logic
		);
	END COMPONENT;

	--Inputs
	signal CLK_I : std_logic                    := '0';
	signal RST_I : std_logic                    := '1';
	signal DAT_I : std_logic_vector(8 downto 0) := (others => '0');
	signal WE_I  : std_logic                    := '0';
	signal STB_I : std_logic                    := '0';

	--Outputs
	signal DAT_O : std_logic_vector(8 downto 0);
	signal ACK_O : std_logic;

	-- Clock period definitions
	constant CLK_I_period : time := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : program_counter PORT MAP(
			CLK_I => CLK_I,
			RST_I => RST_I,
			DAT_I => DAT_I,
			DAT_O => DAT_O,
			WE_I  => WE_I,
			STB_I => STB_I,
			ACK_O => ACK_O
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
		STB_I <= '1';
		wait until (rising_edge(ACK_O)); 
		wait until (rising_edge(CLK_I));
		STB_I <= '0';
		wait until (rising_edge(CLK_I));
		STB_I <= '1';
		wait until (rising_edge(ACK_O)); 
		wait until (rising_edge(CLK_I));
		STB_I <= '0';
		wait until (rising_edge(CLK_I));
		STB_I <= '1';
		wait until (rising_edge(ACK_O)); 
		wait until (rising_edge(CLK_I));
		STB_I <= '0';
		wait;
	end process;

END;
