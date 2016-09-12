--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:10:28 11/06/2012
-- Design Name:   
-- Module Name:   /home/mbridges/Projects/Dugong/ads62p49_parellelizer_tb.vhd
-- Project Name:  Dugong
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ads62p49_parellelizer
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
USE ieee.numeric_std.ALL;

ENTITY ads62p49_parellelizer_tb IS
END ads62p49_parellelizer_tb;

ARCHITECTURE behavior OF ads62p49_parellelizer_tb IS

	-- Component Declaration for the Unit Under Test (UUT)

	component ads62p49_parallelizer is
		port(
			--System Control Inputs
			RST_I        : in  STD_LOGIC;
			--Signal Channel Inputs
			ADC_CLK_O    : out STD_LOGIC;
			CH_A_O       : out STD_LOGIC_VECTOR(13 downto 0);
			CH_B_O       : out STD_LOGIC_VECTOR(13 downto 0);
			-- FMC150 ADC interface
			ADC_DCLK_P   : in  STD_LOGIC;
			ADC_DCLK_N   : in  STD_LOGIC;
			ADC_DATA_A_P : in  STD_LOGIC_VECTOR(6 downto 0);
			ADC_DATA_A_N : in  STD_LOGIC_VECTOR(6 downto 0);
			ADC_DATA_B_P : in  STD_LOGIC_VECTOR(6 downto 0);
			ADC_DATA_B_N : in  STD_LOGIC_VECTOR(6 downto 0)
		);
	end component ads62p49_parallelizer;

	--Inputs
	signal RST_I : std_logic := '1';

	--Outputs
	signal ADC_CLK_O : std_logic;
	signal CH_A_O    : std_logic_vector(13 downto 0);
	signal CH_B_O    : std_logic_vector(13 downto 0);

	signal ADC_DCLK_P   : std_logic                    := '0';
	signal ADC_DCLK_N   : std_logic                    := '0';
	signal ADC_DATA_A_P : std_logic_vector(6 downto 0) := (others => '0');
	signal ADC_DATA_A_N : std_logic_vector(6 downto 0) := (others => '1');
	signal ADC_DATA_B_P : std_logic_vector(6 downto 0) := (others => '0');
	signal ADC_DATA_B_N : std_logic_vector(6 downto 0) := (others => '1');

	signal counter : unsigned(13 downto 0) := (others => '0');

	signal received_count       : unsigned(13 downto 0);
	signal received_count_old   : unsigned(13 downto 0);
	signal received_count_error : std_logic;

	-- Clock period definitions
	constant CLK_I_period    : time := 10 ns;
	constant ADC_DCLK_period : time := 4 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : ads62p49_parallelizer
		port map(
			RST_I        => RST_I,
			ADC_CLK_O    => ADC_CLK_O,
			CH_A_O       => CH_A_O,
			CH_B_O       => CH_B_O,
			ADC_DCLK_P   => ADC_DCLK_P,
			ADC_DCLK_N   => ADC_DCLK_N,
			ADC_DATA_A_P => ADC_DATA_A_P,
			ADC_DATA_A_N => ADC_DATA_A_N,
			ADC_DATA_B_P => ADC_DATA_B_P,
			ADC_DATA_B_N => ADC_DATA_B_N
		);

	-- Clock process definitions
	ADC_DCLK_process : process
	begin
		ADC_DCLK_N <= '0';
		ADC_DCLK_P <= '1';
		wait for ADC_DCLK_period / 2;
		ADC_DCLK_N <= '1';
		ADC_DCLK_P <= '0';
		wait for ADC_DCLK_period / 2;
	end process;

	-- Stimulus process
	stim_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;
		RST_I <= '0';

		wait for CLK_I_period * 10;

		-- insert stimulus here 

		wait;
	end process;

	ADC_PROC : process is
	begin
		wait until falling_edge(ADC_DCLK_P);
		wait for 1 ns;
		ADC_DATA_A_P(0) <= counter(0);
		ADC_DATA_A_P(1) <= counter(2);
		ADC_DATA_A_P(2) <= counter(4);
		ADC_DATA_A_P(3) <= counter(6);
		ADC_DATA_A_P(4) <= counter(8);
		ADC_DATA_A_P(5) <= counter(10);
		ADC_DATA_A_P(6) <= counter(12);
		wait until rising_edge(ADC_DCLK_P);
		wait for 1 ns;
		ADC_DATA_A_P(0) <= counter(1);
		ADC_DATA_A_P(1) <= counter(3);
		ADC_DATA_A_P(2) <= counter(5);
		ADC_DATA_A_P(3) <= counter(7);
		ADC_DATA_A_P(4) <= counter(9);
		ADC_DATA_A_P(5) <= counter(11);
		ADC_DATA_A_P(6) <= counter(13);
		counter         <= counter + 1;

	end process ADC_PROC;

	ADC_DATA_A_N <= not ADC_DATA_A_P;
	ADC_DATA_B_N <= not ADC_DATA_B_P;

	ADC_CHECK_PROC : process(ADC_DCLK_P) is
	begin
		if rising_edge(ADC_DCLK_P) then
			received_count     <= unsigned(CH_A_O);
			received_count_old <= received_count;
			if (received_count /= (received_count_old + 1)) then
				received_count_error <= '1';
			else
				received_count_error <= '0';
			end if;

		end if;
	end process ADC_CHECK_PROC;

END;
