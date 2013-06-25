--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:02:19 08/03/2012
-- Design Name:   
-- Module Name:   /home/mbridges/Projects/project_Dugong_v0d/inst_mem_tb.vhd
-- Project Name:  project_Dugong_v0d
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: inst_mem
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

ENTITY inst_mem_tb IS
END inst_mem_tb;

ARCHITECTURE behavior OF inst_mem_tb IS

	-- Component Declaration for the Unit Under Test (UUT)

	COMPONENT inst_mem
		PORT(
			clka  : IN  STD_LOGIC;
			addra : IN  STD_LOGIC_VECTOR(8 DOWNTO 0);
			douta : OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
		);
	END COMPONENT;

	--Inputs
	signal CLK_I : std_logic                    := '1';
	signal ADR_I : std_logic_vector(8 downto 0) := (others => '0');

	--Outputs
	signal DAT_O : std_logic_vector(47 downto 0);

	-- Clock period definitions
	constant CLK_I_period : time := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : inst_mem
		port map(
			clka  => CLK_I,
			addra => ADR_I,
			douta => DAT_O
		);

	-- Clock process definitions
	CLK_I_process : process
	begin
		CLK_I <= '1';
		wait for CLK_I_period / 2;
		CLK_I <= '0';
		wait for CLK_I_period / 2;
	end process;

	-- Stimulus process
	stim_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;

		wait for CLK_I_period * 10;

		-- insert stimulus here 
		wait for 20 ns;
		ADR_I <= '0' & x"00";
		wait for 20 ns;
		ADR_I <= '0' & x"01";
		wait for 20 ns;
		ADR_I <= '0' & x"02";
		wait for 20 ns;
		ADR_I <= '0' & x"03";
		wait for 20 ns;
		ADR_I <= '0' & x"04";
		wait for 20 ns;
		ADR_I <= '0' & x"05";
		wait for 20 ns;
		ADR_I <= '0' & x"06";
		wait for 20 ns;
		ADR_I <= '0' & x"07";
		wait for 20 ns;
		ADR_I <= '0' & x"08";
		wait for 20 ns;
		ADR_I <= '0' & x"09";
		wait for 20 ns;
		ADR_I <= '0' & x"0A";
		wait for 20 ns;
		ADR_I <= '0' & x"0B";
		wait for 20 ns;
		ADR_I <= '0' & x"0C";
		wait for 20 ns;
		ADR_I <= '0' & x"0D";
		wait for 20 ns;
		ADR_I <= '0' & x"0E";
		wait for 20 nS;
		ADR_I <= '0' & x"0F";
		wait;
	end process;

END;
