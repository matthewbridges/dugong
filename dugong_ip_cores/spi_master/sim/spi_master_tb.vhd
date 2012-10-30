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

use work.dcomponents.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY spi_master_tb IS
END spi_master_tb;

ARCHITECTURE behavior OF spi_master_tb IS

	-- Component Declaration for the Unit Under Test (UUT)

	component spi_master is
		generic(
			DATA_WIDTH     : natural               := 16;
			ADDR_WIDTH     : natural               := 2;
			SPI_DATA_WIDTH : natural               := 8;
			DEFAULT_DATA   : word_vector(0 to 128) := (others => x"0000100E0");
			REVERSE_BITS   : boolean               := false
		);
		port(
			--System Control Inputs
			CLK_I     : in  STD_LOGIC;
			RST_I     : in  STD_LOGIC;
			--Wishbone Slave Lines
			DAT_I     : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			DAT_O     : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			ADR_I     : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
			STB_I     : in  STD_LOGIC;
			WE_I      : in  STD_LOGIC;
			--		CYC_I : in   STD_LOGIC;
			ACK_O     : out STD_LOGIC;
			--Serial Peripheral Interface
			SPI_CLK_I : in  STD_LOGIC;
			SPI_CE    : in  STD_LOGIC;
			SPI_MOSI  : out STD_LOGIC;
			SPI_MISO  : in  STD_LOGIC;
			SPI_N_SS  : out STD_LOGIC
		);
	end component;

	--Inputs
	signal CLK_I     : std_logic                     := '0';
	signal RST_I     : std_logic                     := '1';
	signal DAT_I     : std_logic_vector(15 downto 0) := (others => '0');
	signal ADR_I     : std_logic_vector(4 downto 0)  := (others => '0');
	signal STB_I     : std_logic                     := '0';
	signal WE_I      : std_logic                     := '0';
	signal SPI_CLK_I : std_logic                     := '0';
	signal SPI_CE    : std_logic                     := '0';
	signal SPI_MISO  : std_logic                     := '1';

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
	uut : spi_master
		generic map(
			ADDR_WIDTH => 5,
			DEFAULT_DATA => (
				0 => x"000010070",      --0xXXX & XXPV & 0xAADD
				1 => x"000010101",
				2 => x"000000200",
				3 => x"000010310",
				4 => x"0000104FF",
				5 => x"000000500",
				6 => x"000000600",
				7 => x"000000700",
				8 => x"000010800",
				9 => x"000010980",
				10 => x"000010A00",
				11 => x"000010B80",
				12 => x"000010C00",
				13 => x"000010D80",
				14 => x"000010E00",
				15 => x"000010F80",
				16 => x"000011000",
				17 => x"000011124",
				18 => x"000011202",
				19 => x"000001300",
				20 => x"000001400",
				21 => x"000001500",
				22 => x"000001600",
				23 => x"000011704",
				24 => x"000011883",
				25 => x"000001900",
				26 => x"000001A00",
				27 => x"000001B00",
				28 => x"000001C00",
				29 => x"000001D00",
				30 => x"000011E24",
				31 => x"000011F12",
				128 => x"000000080",
				others => x"000000000"
			)
		)
		PORT MAP(
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
	stim_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 500 ns;

		RST_I <= '0';

		wait for CLK_I_period * 10;

		-- insert stimulus here

		SPI_CE <= '1';

		wait;
	end process;

END;
