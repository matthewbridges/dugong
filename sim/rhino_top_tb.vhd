-------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:40:19 09/26/2012
-- Design Name:   
-- Module Name:   /home/mbridges/Projects/Dugong/other/sim/system_controller_tb.vhd
-- Project Name:  Dugong
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: system_controller
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

ENTITY rhino_top_tb IS
END rhino_top_tb;

ARCHITECTURE behavior OF rhino_top_tb IS

	-- Component Declaration for the Unit Under Test (UUT)

	component rhino_top
		port(SYS_CLK_P   : in  STD_LOGIC;
			 SYS_CLK_N   : in  STD_LOGIC;
			 SYS_RST     : in  STD_LOGIC;
			 GPIO        : out STD_LOGIC_VECTOR(15 downto 0);
			 LED         : out STD_LOGIC_VECTOR(7 downto 0);
			 CLK_TO_FPGA : in  STD_LOGIC;
			 CLK_AB_P    : in  STD_LOGIC;
			 CLK_AB_N    : in  STD_LOGIC;
			 SPI_SCLK    : out STD_LOGIC;
			 SPI_SDATA   : out STD_LOGIC;
			 DAC_N_EN    : out STD_LOGIC;
			 DAC_SDO     : in  STD_LOGIC;
			 DEBUG :out STD_LOGIC_VECTOR(3 downto 0));
	end component rhino_top;

	--Inputs
	signal SYS_CLK_P : std_logic := '0';
	signal SYS_CLK_N : std_logic := '1';
	signal SYS_RST   : std_logic := '1';
	signal CLK_TO_FPGA : STD_LOGIC := '0';
	signal CLK_AB_P : STD_LOGIC := '0';
	signal DAC_SDO : STD_LOGIC := '0';		
	
	--Outputs
	signal GPIO : STD_LOGIC_VECTOR(15 downto 0);
	signal LED : STD_LOGIC_VECTOR(7 downto 0);
	signal SPI_SCLK : STD_LOGIC;
	signal SPI_SDATA : STD_LOGIC;
	signal DAC_N_EN : STD_LOGIC;
	signal DEBUG    : STD_LOGIC_VECTOR(3 downto 0);

	-- Clock period definitions
	constant SYS_CLK_P_period : time := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : rhino_top
		port map(SYS_CLK_P   => SYS_CLK_P,
			     SYS_CLK_N   => SYS_CLK_N,
			     SYS_RST     => SYS_RST,
			     GPIO        => GPIO,
			     LED         => LED,
			     CLK_TO_FPGA => CLK_TO_FPGA,
			     CLK_AB_P    => CLK_AB_P,
			     CLK_AB_N    => CLK_AB_P,
			     SPI_SCLK    => SPI_SCLK,
			     SPI_SDATA   => SPI_SDATA,
			     DAC_N_EN    => DAC_N_EN,
			     DAC_SDO     => DAC_SDO,
				  DEBUG => DEBUG);

	-- Clock process definitions
	SYS_CLK_P_process : process
	begin
		SYS_CLK_P <= '0';
		SYS_CLK_N <= '1';
		wait for SYS_CLK_P_period / 2;
		SYS_CLK_P <= '1';
		SYS_CLK_N <= '0';
		wait for SYS_CLK_P_period / 2;
	end process;

	-- Stimulus process
	stim_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;

		SYS_RST <= '0';

		wait for SYS_CLK_P_period * 10;

		-- insert stimulus here 

		wait;
	end process;

END;
