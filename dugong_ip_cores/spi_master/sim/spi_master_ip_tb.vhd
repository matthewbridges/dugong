-- TestBench Template 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY spi_master_ip_tb IS
END spi_master_ip_tb;

ARCHITECTURE behavior OF spi_master_ip_tb IS

	-- Component Declaration for the Unit Under Test (UUT)
	component spi_master_ip
		generic(DATA_WIDTH      : NATURAL               := 16;
			    ADDR_WIDTH      : NATURAL               := 12;
			    BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
			    CORE_DATA_WIDTH : NATURAL               := 8;
			    CORE_ADDR_WIDTH : NATURAL               := 5);
		port(CLK_I    : in  STD_LOGIC;
			 RST_I    : in  STD_LOGIC;
			 WB_I     : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
			 WB_O     : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
			 SCLK_I   : in  STD_LOGIC;
			 SPI_CLK  : out STD_LOGIC;
			 SPI_MOSI : out STD_LOGIC;
			 SPI_MISO : in  STD_LOGIC;
			 SPI_N_SS : out STD_LOGIC);
	end component spi_master_ip;

	--Inputs
	signal CLK_I    : STD_LOGIC                     := '0';
	signal RST_I    : STD_LOGIC                     := '1';
	signal WB_I     : STD_LOGIC_VECTOR(30 downto 0) := (others => '0');
	signal SCLK_I   : STD_LOGIC                     := '0';
	signal SPI_MISO : STD_LOGIC                     := '0';

	--Outputs
	signal WB_O     : STD_LOGIC_VECTOR(16 downto 0);
	signal SPI_CLK  : STD_LOGIC;
	signal SPI_MOSI : STD_LOGIC;
	signal SPI_N_SS : STD_LOGIC;

	-- Clock period definitions
	constant clk_period  : time := 10 ns;
	constant sclk_period : time := 160 ns;

BEGIN
	inst : spi_master_ip
		port map(CLK_I    => CLK_I,
			     RST_I    => RST_I,
			     WB_I     => WB_I,
			     WB_O     => WB_O,
			     SCLK_I   => SCLK_I,
			     SPI_CLK  => SPI_CLK,
			     SPI_MOSI => SPI_MOSI,
			     SPI_MISO => SPI_MISO,
			     SPI_N_SS => SPI_N_SS);

	-- Clock process definitions
	clk_process : process
	begin
		CLK_I <= '0';
		wait for clk_period / 2;
		CLK_I <= '1';
		wait for clk_period / 2;
	end process;

	sclk_process : process
	begin
		SCLK_I <= '0';
		wait for sclk_period / 2;
		SCLK_I <= '1';
		wait for sclk_period / 2;
	end process;

	-- Stimulus process
	stim_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;
		RST_I <= '0';
		wait for clk_period * 10;

		-- insert stimulus here 
		wait until rising_edge(CLK_I);
		WB_I <= "111" & x"008" & x"000F";
		wait until rising_edge(WB_O(16));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"0000";
		wait until rising_edge(CLK_I);
		WB_I <= "101" & x"008" & x"00FF";
		wait until rising_edge(WB_O(16));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"0000";
		wait until rising_edge(CLK_I);
		WB_I <= "101" & x"003" & x"0000";
		wait until rising_edge(WB_O(16));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"0000";
		wait until rising_edge(CLK_I);
		WB_I <= "111" & x"00F" & x"000F";
		wait until rising_edge(WB_O(16));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"0000";
		wait until rising_edge(CLK_I);
		WB_I <= "111" & x"017" & x"00FF";
		wait until rising_edge(WB_O(16));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"0000";
		wait until rising_edge(CLK_I);
		WB_I <= "101" & x"01F" & x"0000";
		wait until rising_edge(WB_O(16));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"0000";
		wait;

		wait;
	end process;
END;
