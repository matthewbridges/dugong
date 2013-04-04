-- TestBench Template 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

library dugong_ip_cores;
use dugong_ip_cores.dcores.ALL;

ENTITY spi_m_ip_tb IS
END spi_m_ip_tb;

ARCHITECTURE behavior OF spi_m_ip_tb IS

	--Inputs
	signal CLK_I     : std_logic                     := '0';
	signal RST_I     : std_logic                     := '1';
	signal WB_I      : STD_LOGIC_VECTOR(46 downto 0) := (others => '0');
	signal SPI_CLK_I : std_logic                     := '0';
	signal SPI_CE    : std_logic                     := '0';
	signal SPI_MISO  : std_logic                     := '0';

	--Outputs
	signal WB_O     : STD_LOGIC_VECTOR(32 downto 0);
	signal SPI_MOSI : std_logic;
	signal SPI_N_SS : std_logic;

	-- Clock period definitions
	constant CLK_I_period     : time := 10 ns;
	constant SPI_CLK_I_period : time := 320 ns;

BEGIN

	-- Component Instantiation
	uut : spi_m_ip
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
	wb_stim_proc : process
	begin
		-- hold reset state for 500 ns.
		wait for 500 ns;

		RST_I <= '0';

		wait for CLK_I_period * 10;

		-- Standard IP Core Tests
		wait until rising_edge(CLK_I);
		WB_I <= "101" & x"000" & x"00000000"; --Read Base Address
		wait until rising_edge(WB_O(32));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"00000000"; --NULL
		wait until rising_edge(CLK_I);
		WB_I <= "101" & x"001" & x"00000000"; --Read High Address
		wait until rising_edge(WB_O(32));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"00000000"; --NULL

		--SPI Specific Tests
		wait until rising_edge(CLK_I);
		WB_I <= "101" & x"007" & x"00000000"; --Read from SPI count--ADDR x7
		wait until rising_edge(WB_O(32));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"00000000"; --NULL
		wait until rising_edge(CLK_I);
		WB_I <= "111" & x"004" & x"0000000F"; --Write to x000F to SPI output--ADDR x4
		wait until rising_edge(WB_O(32));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"00000000"; --NULL
		wait until rising_edge(CLK_I);
		WB_I <= "101" & x"005" & x"00000000"; --Read from SPI input--ADDR x5
		wait until rising_edge(WB_O(32));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"00000000"; --NULL
		wait until rising_edge(CLK_I);
		WB_I <= "111" & x"004" & x"000000FF"; --Write to x00FF to SPI output--ADDR x4
		wait until rising_edge(WB_O(32));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"00000000"; --NULL
		wait until rising_edge(CLK_I);
		WB_I <= "101" & x"005" & x"00000000"; --Read from SPI input--ADDR x5
		wait until rising_edge(WB_O(32));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"00000000"; --NULL
		wait until rising_edge(CLK_I);
		WB_I <= "101" & x"006" & x"00000000"; --Read from SPI input--ADDR x6
		wait until rising_edge(WB_O(32));
		WB_I <= "000" & x"000" & x"00000000"; --NULL
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

--  End Test Bench 

END;
