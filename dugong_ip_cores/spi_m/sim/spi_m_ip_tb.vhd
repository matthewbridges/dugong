-- TestBench Template 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

library RHINO_DUGONG;
use RHINO_DUGONG.dcomponents.all;

ENTITY spi_m_ip_tb IS
END spi_m_ip_tb;

ARCHITECTURE behavior OF spi_m_ip_tb IS

	-- Component Declaration
	component spi_m_ip
		generic(
			DATA_WIDTH      : NATURAL               := 32;
			ADDR_WIDTH      : NATURAL               := 12;
			BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
			CORE_DATA_WIDTH : NATURAL               := 16;
			CORE_ADDR_WIDTH : NATURAL               := 3
		);
		port(
			CLK_I     : in  STD_LOGIC;
			RST_I     : in  STD_LOGIC;
			WB_I      : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
			WB_O      : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
			SPI_CLK_I : in  STD_LOGIC;
			SPI_CE    : in  STD_LOGIC;
			SPI_MOSI  : out STD_LOGIC;
			SPI_MISO  : in  STD_LOGIC;
			SPI_N_SS  : out STD_LOGIC
		);
	end component spi_m_ip;

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
	stim_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;
		RST_I <= '0';
		wait for CLK_I_period * 10;

		SPI_CE <= '1';

		-- insert stimulus here 
		wait until rising_edge(CLK_I);
		WB_I <= "111" & x"004" & x"0000000F"; --Write to SPI output
		wait until rising_edge(WB_O(32));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"00000000"; --NULL
		wait until rising_edge(CLK_I);
		WB_I <= "111" & x"004" & x"000000FF"; --Write to SPI output
		wait until rising_edge(WB_O(32));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"00000000"; --NULL
		wait until rising_edge(CLK_I);
		WB_I <= "111" & x"004" & x"00000FFF"; --Write to SPI output
		wait until rising_edge(WB_O(32));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"00000000"; --NULL
		wait until rising_edge(CLK_I);
		WB_I <= "101" & x"005" & x"0000000F"; --Read last SPI input
		wait until rising_edge(WB_O(32));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"00000000"; --NULL
		wait;
	end process;

--  End Test Bench 

END;
