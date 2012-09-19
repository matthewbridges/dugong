library ieee;
use ieee.std_logic_1164.all;

entity spi_master_ip_tb is
end entity spi_master_ip_tb;

architecture RTL of spi_master_ip_tb is
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
			 SPI_CLK  : out STD_LOGIC;
			 SPI_MOSI : out STD_LOGIC;
			 SPI_MISO : in  STD_LOGIC;
			 SPI_N_SS : out STD_LOGIC);
	end component spi_master_ip;

	signal clk_i    : std_logic;
	constant period : time := 10 ns;
	signal RST_I    : STD_LOGIC;
	signal WB_I     : STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
	signal WB_O     : STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
	signal SPI_CLK  : STD_LOGIC;
	signal SPI_MOSI : STD_LOGIC;
	signal SPI_MISO : STD_LOGIC;
	signal SPI_N_SS : STD_LOGIC;

begin
	clock_driver : process
	begin
		clk_i <= '0';
		wait for period / 2;
		clk_i <= '1';
		wait for period / 2;
	end process clock_driver;

	inst : spi_master_ip
		generic map(DATA_WIDTH      => DATA_WIDTH,
			        ADDR_WIDTH      => ADDR_WIDTH,
			        BASE_ADDR       => BASE_ADDR,
			        CORE_DATA_WIDTH => CORE_DATA_WIDTH,
			        CORE_ADDR_WIDTH => CORE_ADDR_WIDTH)
		port map(CLK_I    => CLK_I,
			     RST_I    => RST_I,
			     WB_I     => WB_I,
			     WB_O     => WB_O,
			     SPI_CLK  => SPI_CLK,
			     SPI_MOSI => SPI_MOSI,
			     SPI_MISO => SPI_MISO,
			     SPI_N_SS => SPI_N_SS);

end architecture RTL;
