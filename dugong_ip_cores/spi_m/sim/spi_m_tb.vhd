--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   07:49:27 10/16/2012
-- Design Name:   
-- Module Name:   /home/mbridges/Projects/Dugong/spi_master_tb.vhd
-- Project Name:  Dugong
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: spi_master
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

library RHINO_DUGONG;
use RHINO_DUGONG.dcomponents.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY spi_m_tb IS
END spi_m_tb;

ARCHITECTURE behavior OF spi_m_tb IS

	-- Component Declaration for the Unit Under Test (UUT)

	component spi_m
		generic(
			DATA_WIDTH : natural := 16;
			ADDR_WIDTH : natural := 3
		);
		port(
			CLK_I     : in  STD_LOGIC;
			RST_I     : in  STD_LOGIC;
			DAT_I     : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			DAT_O     : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			ADR_I     : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
			STB_I     : in  STD_LOGIC;
			WE_I      : in  STD_LOGIC;
			ACK_O     : out STD_LOGIC;
			SPI_CLK_I : in  STD_LOGIC;
			SPI_CE    : in  STD_LOGIC;
			SPI_MOSI  : out STD_LOGIC;
			SPI_MISO  : in  STD_LOGIC;
			SPI_N_SS  : out STD_LOGIC
		);
	end component spi_m;

	--Inputs
	signal CLK_I     : std_logic                     := '0';
	signal RST_I     : std_logic                     := '1';
	signal DAT_I     : std_logic_vector(15 downto 0) := (others => '0');
	signal ADR_I     : std_logic_vector(2 downto 0)  := (others => '0');
	signal STB_I     : std_logic                     := '0';
	signal WE_I      : std_logic                     := '0';
	signal SPI_CLK_I : std_logic                     := '0';
	signal SPI_CE    : std_logic                     := '0';
	signal SPI_MISO  : std_logic                     := '0';

	--Outputs
	signal DAT_O    : std_logic_vector(15 downto 0);
	signal ACK_O    : std_logic;
	signal SPI_MOSI : std_logic;
	signal SPI_N_SS : std_logic;

	-- Clock period definitions
	constant CLK_I_period     : time := 10 ns;
	constant SPI_CLK_I_period : time := 320 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : spi_m
		port map(
			CLK_I     => CLK_I,
			RST_I     => RST_I,
			DAT_I     => DAT_I,
			DAT_O     => DAT_O,
			ADR_I     => ADR_I,
			STB_I     => STB_I,
			WE_I      => WE_I,
			ACK_O     => ACK_O,
			SPI_CLK_I => SPI_CLK_I,
			SPI_CE    => SPI_CE,
			SPI_MOSI  => SPI_MOSI,
			SPI_MISO  => SPI_MISO,
			SPI_N_SS  => SPI_N_SS
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
	SPI_CLK_I_process : process
	begin
		SPI_CLK_I <= '0';
		wait for SPI_CLK_I_period / 2;
		SPI_CLK_I <= '1';
		wait for SPI_CLK_I_period / 2;
	end process;

	-- Stimulus process
	wb_stim_proc : process
	begin
		-- hold reset state for 500 ns.
		wait for 500 ns;

		RST_I <= '0';

		wait for CLK_I_period * 10;

		-- insert stimulus here
		wait until rising_edge(CLK_I);
		DAT_I <= x"0000";               --Read from SPI count 
		ADR_I <= "011";                 --ADDR x3
		WE_I  <= '0';                   --Read
		STB_I <= '1';                   --Strobe
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		DAT_I <= x"0000";
		wait until rising_edge(CLK_I);
		DAT_I <= x"000F";               --Write to x000F to SPI output
		ADR_I <= "000";                 --ADDR x0
		WE_I  <= '1';                   --Write
		STB_I <= '1';                   --Strobe
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		WE_I  <= '0';
		DAT_I <= x"0000";
		wait until rising_edge(CLK_I);
		DAT_I <= x"0000";               --Read from SPI input 
		ADR_I <= "001";                 --ADDR x1
		WE_I  <= '0';                   --Read
		STB_I <= '1';                   --Strobe
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		DAT_I <= x"0000";
		wait until rising_edge(CLK_I);
		DAT_I <= x"00FF";               --Write to x00FF to SPI output
		ADR_I <= "000";                 --ADDR x0
		WE_I  <= '1';                   --Write
		STB_I <= '1';                   --Strobe
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		DAT_I <= x"0000";
		wait until rising_edge(CLK_I);
		DAT_I <= x"0000";               --Read from SPI input 
		ADR_I <= "001";                 --ADDR x1
		WE_I  <= '0';                   --Read
		STB_I <= '1';                   --Strobe
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		DAT_I <= x"0000";
		wait until rising_edge(CLK_I);
		DAT_I <= x"0000";               --Read from SPI input 
		ADR_I <= "010";                 --ADDR x2
		WE_I  <= '0';                   --Read
		STB_I <= '1';                   --Strobe
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		DAT_I <= x"0000";
		ADR_I <= "000";
		
		wait;
	end process;

	-- Stimulus process
	spi_stim_proc : process
	begin
		-- hold reset state for 500 ns.
		wait for 800 ns;

		SPI_CE <= '1';

		wait until falling_edge(SPI_N_SS);
		wait for SPI_CLK_I_period * 8;
		SPI_MISO <= '1';
		wait for SPI_CLK_I_period * 8;
		SPI_MISO <= '0';

		wait;
	end process;

END;
