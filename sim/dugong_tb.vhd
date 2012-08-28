--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:31:07 08/07/2012
-- Design Name:   
-- Module Name:   /home/mbridges/Projects/project_Dugong_v0f/dugong_tb.vhd
-- Project Name:  project_Dugong_v0f
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: dugong
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

ENTITY dugong_tb IS
END dugong_tb;

ARCHITECTURE behavior OF dugong_tb IS

	-- Component Declaration for the Unit Under Test (UUT)

	COMPONENT dugong
		PORT(
			CLK_I : IN  std_logic;
			RST_I : IN  std_logic;
			DAT_I : IN  std_logic_vector(15 downto 0);
			DAT_O : OUT std_logic_vector(15 downto 0);
			ADR_O : OUT std_logic_vector(11 downto 0);
			WE_O  : OUT std_logic;
			STB_O : OUT std_logic;
			ACK_I : IN  std_logic;
			CYC_O : OUT std_logic
		);
	END COMPONENT;

	--Inputs
	signal CLK_I : std_logic                     := '0';
	signal RST_I : std_logic                     := '1';
	signal DAT_I : std_logic_vector(15 downto 0) := (others => '0');
	signal ACK_I : std_logic                     := '0';

	--Outputs
	signal DAT_O : std_logic_vector(15 downto 0);
	signal ADR_O : std_logic_vector(11 downto 0);
	signal WE_O  : std_logic;
	signal STB_O : std_logic;
	signal CYC_O : std_logic;

	-- Clock period definitions
	constant CLK_I_period : time := 5 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : dugong PORT MAP(
			CLK_I => CLK_I,
			RST_I => RST_I,
			DAT_I => DAT_I,
			DAT_O => DAT_O,
			ADR_O => ADR_O,
			WE_O  => WE_O,
			STB_O => STB_O,
			ACK_I => ACK_I,
			CYC_O => CYC_O
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
	start_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;

		wait for CLK_I_period * 10;

		-- insert stimulus here 
		RST_I <= '0';

	end process;
	
	ACK_proc : process
	begin
		wait until (rising_edge(STB_O)); 
		wait until (rising_edge(CLK_I));
		ACK_I <= STB_O;
		wait until (falling_edge(STB_O));
		ACK_I <= STB_O;
	end process;
END;
