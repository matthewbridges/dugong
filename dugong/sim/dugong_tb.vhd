--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:11:21 08/30/2012
-- Design Name:   
-- Module Name:   /home/mbridges/Projects/Dugong/sim/dugong_tb.vhd
-- Project Name:  Dugong
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
			WB_I  : IN  std_logic_vector(16 downto 0);
			WB_O  : OUT std_logic_vector(30 downto 0)
		);
	END COMPONENT;

	--Inputs
	signal CLK_I : std_logic                     := '0';
	signal RST_I : std_logic                     := '1';
	signal WB_I  : std_logic_vector(16 downto 0) := (others => '0');

	--Outputs
	signal WB_O : std_logic_vector(30 downto 0);
	
	signal temp : std_logic_vector(15 downto 0) := (others => '0');
	
	signal dat_out : std_logic_vector(15 downto 0);
	signal adr_out : std_logic_vector(11 downto 0);
	signal stb : std_logic;
	signal we : std_logic; 
	signal ack : std_logic;

	-- Clock period definitions
	constant CLK_I_period : time := 10 ns;

BEGIN

	dat_out <= WB_O(15 downto 0);
	adr_out <= WB_O(27 downto 16);
	stb <= WB_O(28);
	we <= WB_O(29);
	ack <= WB_I(16);

	-- Instantiate the Unit Under Test (UUT)
	uut : dugong PORT MAP(
			CLK_I => CLK_I,
			RST_I => RST_I,
			WB_I  => WB_I,
			WB_O  => WB_O
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
		RST_I <= '0';

		wait;
	end process;

	ACK_proc : process
	begin
		wait until (rising_edge(WB_O(28)));
		wait until (rising_edge(CLK_I));
		WB_I(15 downto 0) <= temp;		
		temp <= WB_O(15 downto 0);
		WB_I(16) <= '1';
		wait until (rising_edge(CLK_I));
		--wait until (falling_edge(WB_O(28)));
		WB_I(16) <= '0';
		WB_I(15 downto 0) <= x"0000";
	end process;

END;
