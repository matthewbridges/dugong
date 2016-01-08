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
			RST_I          : in  STD_LOGIC;
			--Signal Channel Inputs
			DAC_CLK_O      : out STD_LOGIC;
			DAC_CLK_DIV4_O : out STD_LOGIC;
			DAC_READY      : out STD_LOGIC;
			CH_C_I         : in  STD_LOGIC_VECTOR(15 downto 0);
			CH_D_I         : in  STD_LOGIC_VECTOR(15 downto 0);
			-- DAC interface
			FMC150_CLK     : in  STD_LOGIC;
			DAC_DCLK_P     : out STD_LOGIC;
			DAC_DCLK_N     : out STD_LOGIC;
			DAC_DATA_P     : out STD_LOGIC_VECTOR(7 downto 0);
			DAC_DATA_N     : out STD_LOGIC_VECTOR(7 downto 0);
			FRAME_P        : out STD_LOGIC;
			FRAME_N        : out STD_LOGIC;
			-- Testing
			IO_TEST_EN     : in  STD_LOGIC
		);
	end component dac3283_serializer;

	--Inputs

	signal RST_I          : std_logic                     := '1';
	signal DAC_CLK_O      : std_logic                     := '0';
	signal DAC_CLK_DIV4_O : std_logic                     := '0';
	signal DAC_READY      : std_logic                     := '0';
	signal CH_C_I         : std_logic_vector(15 downto 0) := (others => '0');
	signal CH_D_I         : std_logic_vector(15 downto 0) := (others => '0');
	signal FMC150_CLK     : std_logic                     := '0';

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
	constant FMC150_CLK_period : time := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : dac3283_serializer
		port map(
			RST_I          => RST_I,
			DAC_CLK_O      => DAC_CLK_O,
			DAC_CLK_DIV4_O => DAC_CLK_DIV4_O,
			DAC_READY      => DAC_READY,
			CH_C_I         => CH_C_I,
			CH_D_I         => CH_D_I,
			FMC150_CLK     => FMC150_CLK,
			DAC_DCLK_P     => DAC_DCLK_P,
			DAC_DCLK_N     => DAC_DCLK_N,
			DAC_DATA_P     => DAC_DATA_P,
			DAC_DATA_N     => DAC_DATA_N,
			FRAME_P        => FRAME_P,
			FRAME_N        => FRAME_N,
			IO_TEST_EN     => IO_TEST_EN
		);

	-- Clock process definitions
	FMC150_CLK_process : process
	begin
		FMC150_CLK <= '0';
		wait for FMC150_CLK_period / 2;
		FMC150_CLK <= '1';
		wait for FMC150_CLK_period / 2;
	end process;

	-- Stimulus process
	stim_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;

		RST_I <= '0';

		--wait until rising_edge(TXENABLE);

		-- insert stimulus here 

		wait until rising_edge(DAC_CLK_O);
		CH_C_I <= x"FF00";
		CH_D_I <= x"F00F";
		--		wait until rising_edge(CLK_I);
		--		CH_A_I <= x"FF00";
		--		CH_B_I <= x"EE00";
		--		wait until rising_edge(CLK_I);
		--		CH_A_I <= x"0000";
		--		CH_B_I <= x"0000";

		wait;
	end process;

END;
