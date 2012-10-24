--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:33:29 10/03/2012
-- Design Name:   
-- Module Name:   /home/mbridges/Projects/Dugong/fmc150/sim/dac3283_serializer_tb.vhd
-- Project Name:  Dugong
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: dac3283_serializer
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

ENTITY dac3283_serializer_tb IS
END dac3283_serializer_tb;

ARCHITECTURE behavior OF dac3283_serializer_tb IS

	-- Component Declaration for the Unit Under Test (UUT)

	COMPONENT dac3283_serializer
		PORT(
			CLK_I      : IN  std_logic;
			RST_I      : IN  std_logic;
			CH_A_I     : IN  std_logic_vector(15 downto 0);
			CH_B_I     : IN  std_logic_vector(15 downto 0);
			DAC_CLK_I  : IN  std_logic;
			DAC_DCLK_P : OUT std_logic;
			DAC_DCLK_N : OUT std_logic;
			DAC_DATA_P : OUT std_logic_vector(7 downto 0);
			DAC_DATA_N : OUT std_logic_vector(7 downto 0);
			FRAME_P    : OUT std_logic;
			FRAME_N    : OUT std_logic;
			TXENABLE   : OUT std_logic;
			DEBUG      : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;

	--Inputs
	signal CLK_I  : std_logic                     := '0';
	signal RST_I  : std_logic                     := '1';
	signal CH_A_I : std_logic_vector(15 downto 0) := (others => '0');
	signal CH_B_I : std_logic_vector(15 downto 0) := (others => '0');
	signal DAC_CLK_I  : std_logic                 := '0';

	--Outputs
	signal DAC_DCLK_P : std_logic;
	signal DAC_DCLK_N : std_logic;
	signal DAC_DATA_P : std_logic_vector(7 downto 0);
	signal DAC_DATA_N : std_logic_vector(7 downto 0);
	signal FRAME_P    : std_logic;
	signal FRAME_N    : std_logic;
	signal TXENABLE   : std_logic;
	signal DEBUG      : std_logic_vector(15 downto 0);

	-- Clock period definitions
	constant CLK_I_period : time := 10 ns;
	constant DAC_CLK_I_period : time := 20 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : dac3283_serializer PORT MAP(
			CLK_I      => CLK_I,
			RST_I      => RST_I,
			CH_A_I     => CH_A_I,
			CH_B_I     => CH_B_I,
			DAC_CLK_I  => DAC_CLK_I,
			DAC_DCLK_P => DAC_DCLK_P,
			DAC_DCLK_N => DAC_DCLK_N,
			DAC_DATA_P => DAC_DATA_P,
			DAC_DATA_N => DAC_DATA_N,
			FRAME_P    => FRAME_P,
			FRAME_N    => FRAME_N,
			TXENABLE   => TXENABLE,
			DEBUG      => DEBUG
		);

	-- Clock process definitions
	CLK_I_process : process
	begin
		CLK_I <= '0';
		wait for CLK_I_period / 2;
		CLK_I <= '1';
		wait for CLK_I_period / 2;
	end process;
	
	-- Clock process definitions
	DAC_CLK_I_process : process
	begin
		DAC_CLK_I <= '0';
		wait for DAC_CLK_I_period / 2;
		DAC_CLK_I <= '1';
		wait for DAC_CLK_I_period / 2;
	end process;

	-- Stimulus process
	stim_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;

		RST_I <= '0';

		--wait until rising_edge(TXENABLE);

		-- insert stimulus here 

		wait until rising_edge(CLK_I);
		CH_A_I <= x"FF00";
		CH_B_I <= x"F00F";
--		wait until rising_edge(CLK_I);
--		CH_A_I <= x"FF00";
--		CH_B_I <= x"EE00";
--		wait until rising_edge(CLK_I);
--		CH_A_I <= x"0000";
--		CH_B_I <= x"0000";

		wait;
	end process;

END;
