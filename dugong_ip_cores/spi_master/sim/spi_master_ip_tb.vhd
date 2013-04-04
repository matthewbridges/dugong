-- TestBench Template 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

library DUGONG_IP_CORES;
use DUGONG_IP_CORES.dcores.ALL;

ENTITY spi_master_ip_tb IS
END spi_master_ip_tb;

ARCHITECTURE behavior OF spi_master_ip_tb IS

	--Inputs
	signal CLK_I     : std_logic                     := '0';
	signal RST_I     : std_logic                     := '1';
	signal WB_I      : STD_LOGIC_VECTOR(46 downto 0) := (others => '0');
	signal SPI_CLK_I : std_logic                     := '0';
	signal SPI_CE    : std_logic                     := '0';
	signal SPI_MISO  : std_logic                     := '1';

	--Outputs
	signal WB_O     : STD_LOGIC_VECTOR(32 downto 0);
	signal SPI_MOSI : std_logic;
	signal SPI_N_SS : std_logic;

	-- Clock period definitions
	constant CLK_I_period     : time := 10 ns;
	constant SPI_CLK_I_period : time := 320 ns;

BEGIN

	-- Component Instantiation
	uut : spi_master_ip
		generic map(
			CORE_ADDR_WIDTH => 6,
			DEFAULT_DATA    => (
				0 => x"000010070",      --0xXXX & XXPV & 0xAADD
				1 => x"000010121",
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
		port map(
			CLK_I     => CLK_I,
			RST_I     => RST_I,
			WB_I      => WB_I,
			WB_O      => WB_O,
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
--  End Test Bench 

END;
