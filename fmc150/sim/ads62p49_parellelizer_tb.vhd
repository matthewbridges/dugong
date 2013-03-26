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
--USE ieee.numeric_std.ALL;
 
ENTITY ads62p49_parellelizer_tb IS
END ads62p49_parellelizer_tb;
 
ARCHITECTURE behavior OF ads62p49_parellelizer_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
	COMPONENT ads62p49_parellelizer
		GENERIC(
			DATA_WIDTH : natural := 16;
			ADDR_WIDTH : natural := 5
		);
		PORT(
			--System Control Inputs
			CLK_I        : in  STD_LOGIC;
			RST_I        : in  STD_LOGIC;
			--Signal Channel Inputs
			DSP_CLK_I    : in  STD_LOGIC;
			CH_A_O       : out STD_LOGIC_VECTOR(15 downto 0);
			CH_B_O       : out STD_LOGIC_VECTOR(15 downto 0);
			-- FMC150 ADC interface
			ADC_DCLK_P   : in  STD_LOGIC;
			ADC_DCLK_N   : in  STD_LOGIC;
			ADC_DATA_A_P : in  STD_LOGIC_VECTOR(6 downto 0);
			ADC_DATA_A_N : in  STD_LOGIC_VECTOR(6 downto 0);
			ADC_DATA_B_P : in  STD_LOGIC_VECTOR(6 downto 0);
			ADC_DATA_B_N : in  STD_LOGIC_VECTOR(6 downto 0);
			-- Debug
			DEBUG        : out STD_LOGIC_VECTOR(15 downto 0)
		);
	END COMPONENT;
    

   --Inputs
   signal CLK_I : std_logic := '0';
   signal RST_I : std_logic := '1';
   signal DSP_CLK_I : std_logic := '0';
   signal ADC_DCLK_P : std_logic := '0';
   signal ADC_DCLK_N : std_logic := '0';
   signal ADC_DATA_A_P : std_logic_vector(6 downto 0) := (others => '0');
   signal ADC_DATA_A_N : std_logic_vector(6 downto 0) := (others => '1');
   signal ADC_DATA_B_P : std_logic_vector(6 downto 0) := (others => '0');
   signal ADC_DATA_B_N : std_logic_vector(6 downto 0) := (others => '1');
   
   --Outputs
   signal CH_A_O : std_logic_vector(15 downto 0);
   signal CH_B_O : std_logic_vector(15 downto 0);
   signal DEBUG  : std_logic_vector(15 downto 0);
   
   -- Clock period definitions
   constant CLK_I_period : time := 10 ns;
   constant DSP_CLK_I_period : time := 4 ns;
   constant ADC_DCLK_period : time := 4 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ads62p49_parellelizer PORT MAP (
          CLK_I => CLK_I,
          RST_I => RST_I,
          DSP_CLK_I => DSP_CLK_I,
          CH_A_O => CH_A_O,
          CH_B_O => CH_B_O,
          ADC_DCLK_P => ADC_DCLK_P,
          ADC_DCLK_N => ADC_DCLK_N,
          ADC_DATA_A_P => ADC_DATA_A_P,
          ADC_DATA_A_N => ADC_DATA_A_N,
          ADC_DATA_B_P => ADC_DATA_B_P,
          ADC_DATA_B_N => ADC_DATA_B_N,
          DEBUG => DEBUG
        );

   -- Clock process definitions
   CLK_I_process :process
   begin
		CLK_I <= '0';
		wait for CLK_I_period/2;
		CLK_I <= '1';
		wait for CLK_I_period/2;
   end process;
   
      DSP_CLK_I_process :process
   begin
		DSP_CLK_I <= '0';
		wait for DSP_CLK_I_period/2;
		DSP_CLK_I <= '1';
		wait for DSP_CLK_I_period/2;
   end process;
   
    -- Clock process definitions
   ADC_DCLK_process :process
   begin
		ADC_DCLK_N <= '0';
		ADC_DCLK_P <= '1';
		wait for ADC_DCLK_period/2;
		ADC_DCLK_N <= '1';
		ADC_DCLK_P <= '0';
		wait for ADC_DCLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
      RST_I <= '0';

      wait for CLK_I_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
