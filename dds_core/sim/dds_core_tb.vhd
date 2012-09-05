--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:36:14 09/05/2012
-- Design Name:   
-- Module Name:   /home/mbridges/Projects/Dugong/dds_core_tb.vhd
-- Project Name:  Dugong
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: dds_core
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

ENTITY dds_core_tb IS
END dds_core_tb;

ARCHITECTURE behavior OF dds_core_tb IS

	component sink_file
		generic(stim_file : string := "file_io.out");
		port(clk  : in STD_LOGIC;
			 data : in STD_LOGIC_VECTOR(11 downto 0));
	end component sink_file;

	-- Component Declaration for the Unit Under Test (UUT)
	component dds_core
		generic(DATA_WIDTH : natural := 16;
			    ADDR_WIDTH : natural := 4);
		port(CLK_I : in  STD_LOGIC;
			 RST_I : in  STD_LOGIC;
			 DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			 DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			 ADR_I : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
			 STB_I : in  STD_LOGIC;
			 WE_I  : in  STD_LOGIC;
			 ACK_O : out STD_LOGIC);
	end component dds_core;

	--Inputs
	signal CLK_I : std_logic                     := '0';
	signal RST_I : std_logic                     := '1';
	signal DAT_I : std_logic_vector(11 downto 0) := (others => '0');
	signal ADR_I : std_logic_vector(3 downto 0)  := (others => '0');
	signal STB_I : std_logic                     := '0';
	signal WE_I  : std_logic                     := '0';

	--Outputs
	signal DAT_O : std_logic_vector(11 downto 0);
	signal ACK_O : std_logic;

	-- Clock period definitions
	constant CLK_I_period : time := 10 ns;

BEGIN

	sink : sink_file
		port map(
			clk  => CLK_I,
			data => DAT_O
		);

	-- Instantiate the Unit Under Test (UUT)
	uut : dds_core
		generic map(DATA_WIDTH => 12,
			        ADDR_WIDTH => 4)
		port map(CLK_I => CLK_I,
			     RST_I => RST_I,
			     DAT_I => DAT_I,
			     DAT_O => DAT_O,
			     ADR_I => ADR_I,
			     STB_I => STB_I,
			     WE_I  => WE_I,
			     ACK_O => ACK_O);

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
		ADR_I <= x"C"; 

		wait;
	end process;

END;
