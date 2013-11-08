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
	component dac3283_serializer is
		port(
			--System Control Inputs
			CLK_I      : in  STD_LOGIC;
			RST_I      : in  STD_LOGIC;
			--Signal Channel Inputs
			DSP_CLK_I  : in  STD_LOGIC;
			CH_A_I     : in  STD_LOGIC_VECTOR(15 downto 0);
			CH_B_I     : in  STD_LOGIC_VECTOR(15 downto 0);
			-- DAC interface
			DAC_DCLK_P : out STD_LOGIC;
			DAC_DCLK_N : out STD_LOGIC;
			DAC_DATA_P : out STD_LOGIC_VECTOR(7 downto 0);
			DAC_DATA_N : out STD_LOGIC_VECTOR(7 downto 0);
			FRAME_P    : out STD_LOGIC;
			FRAME_N    : out STD_LOGIC;
			TXENABLE   : out STD_LOGIC;
		-- Testing
		IO_TEST_EN : in  STD_LOGIC
		);
	end component dac3283_serializer;

	--Inputs
	signal CLK_I     : std_logic                     := '0';
	signal RST_I     : std_logic                     := '1';
	signal CH_A_I    : std_logic_vector(15 downto 0) := (others => '0');
	signal CH_B_I    : std_logic_vector(15 downto 0) := (others => '0');
	signal DSP_CLK_I : std_logic                     := '0';

	--Outputs
	signal DAC_DCLK_P : std_logic;
	signal DAC_DCLK_N : std_logic;
	signal DAC_DATA_P : std_logic_vector(7 downto 0);
	signal DAC_DATA_N : std_logic_vector(7 downto 0);
	signal FRAME_P    : std_logic;
	signal FRAME_N    : std_logic;
	signal TXENABLE   : std_logic;
	signal IO_TEST_EN : STD_LOGIC := '1';

	-- Clock period definitions
	constant CLK_I_period     : time := 10 ns;
	constant DSP_CLK_I_period : time := 20 ns;
	

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : dac3283_serializer
		port map(
			CLK_I      => CLK_I,
			 RST_I      => RST_I,
			 DSP_CLK_I  => DSP_CLK_I,
			 CH_A_I     => CH_A_I,
			 CH_B_I     => CH_B_I,
			 DAC_DCLK_P => DAC_DCLK_P,
			 DAC_DCLK_N => DAC_DCLK_N,
			 DAC_DATA_P => DAC_DATA_P,
			 DAC_DATA_N => DAC_DATA_N,
			 FRAME_P    => FRAME_P,
			 FRAME_N    => FRAME_N,
			 TXENABLE   => TXENABLE,
			 IO_TEST_EN => IO_TEST_EN
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
	DSP_CLK_I_process : process
	begin
		DSP_CLK_I <= '0';
		wait for DSP_CLK_I_period / 2;
		DSP_CLK_I <= '1';
		wait for DSP_CLK_I_period / 2;
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
