--
-- _______/\\\\\\\\\_______/\\\________/\\\____/\\\\\\\\\\\____/\\\\\_____/\\\_________/\\\\\________
-- \ ____/\\\///////\\\____\/\\\_______\/\\\___\/////\\\///____\/\\\\\\___\/\\\_______/\\\///\\\_____\
--  \ ___\/\\\_____\/\\\____\/\\\_______\/\\\_______\/\\\_______\/\\\/\\\__\/\\\_____/\\\/__\///\\\___\
--   \ ___\/\\\\\\\\\\\/_____\/\\\\\\\\\\\\\\\_______\/\\\_______\/\\\//\\\_\/\\\____/\\\______\//\\\__\
--    \ ___\/\\\//////\\\_____\/\\\/////////\\\_______\/\\\_______\/\\\\//\\\\/\\\___\/\\\_______\/\\\__\
--     \ ___\/\\\____\//\\\____\/\\\_______\/\\\_______\/\\\_______\/\\\_\//\\\/\\\___\//\\\______/\\\___\
--      \ ___\/\\\_____\//\\\___\/\\\_______\/\\\_______\/\\\_______\/\\\__\//\\\\\\____\///\\\__/\\\_____\
--       \ ___\/\\\______\//\\\__\/\\\_______\/\\\____/\\\\\\\\\\\___\/\\\___\//\\\\\______\///\\\\\/______\
--        \ ___\///________\///___\///________\///____\///////////____\///_____\/////_________\/////________\
--         \ __________________________________________\          \__________________________________________\
--          |:------------------------------------------|: DUGONG :|-----------------------------------------:|
--         / ==========================================/          /========================================= /
--        / =============================================================================================== /
--       / ================  Reconfigurable Hardware Interface for computatioN and radiO  ================ /
--      / ===============================  http://www.rhinoplatform.org  ================================ /
--     / =============================================================================================== /
--
---------------------------------------------------------------------------------------------------------------
-- Company:		UNIVERSITY OF CAPE TOWN
-- Engineer: 		MATTHEW BRIDGES
--
-- Name:		SPI_M_TB (003)
-- Type:		TB (15)
-- Description: 	
--
-- Compliance:		DUGONG V0.5
-- ID:			x 0-5-F-003
--
-- Last Modified:	31-OCT-2013
-- Modified By:		MATTHEW BRIDGES
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity spi_m_tb is
	generic(
		SPI_DATA_WIDTH  : natural   := 32;
		SPI_CPHA        : std_logic := '1';
		SPI_CPOL        : std_logic := '0';
		SPI_SCLK_OUT_EN : std_logic := '1';
		SPI_BIG_ENDIAN  : std_logic := '1'
	);
end spi_m_tb;

architecture Behavioral of spi_m_tb is

	-- Component Declaration for the Unit Under Test (UUT)
	component spi_m is
		generic(
			SPI_DATA_WIDTH  : natural   := 32;
			SPI_CPHA        : std_logic := '0';
			SPI_CPOL        : std_logic := '0';
			SPI_SCLK_OUT_EN : std_logic := '1';
			SPI_BIG_ENDIAN  : std_logic := '1'
		);
		port(
			--System Control Inputs
			RST_I         : in  STD_LOGIC;
			--Bus Logic Interface
			TX_DATA_I     : in  STD_LOGIC_VECTOR(SPI_DATA_WIDTH - 1 downto 0);
			RX_DATA_O     : out STD_LOGIC_VECTOR(SPI_DATA_WIDTH - 1 downto 0);
			TX_FEEDBACK_O : out STD_LOGIC_VECTOR(SPI_DATA_WIDTH - 1 downto 0);
			XFER_COUNT_O  : out STD_LOGIC_VECTOR(SPI_DATA_WIDTH - 1 downto 0);
			--SPI Control Signals
			SPI_CLK_P_I   : in  STD_LOGIC;
			SPI_CLK_N_I   : in  STD_LOGIC;
			SPI_ENABLE_I  : in  STD_LOGIC;
			SPI_BUSY_O    : out STD_LOGIC;
			SPI_CPOL_O    : out STD_LOGIC;
			--SPI Interface
			SPI_SCLK      : out STD_LOGIC;
			SPI_MOSI      : out STD_LOGIC;
			SPI_MISO      : in  STD_LOGIC;
			SPI_nSS       : out STD_LOGIC
		);
	end component spi_m;

	--System Control Inputs:
	signal RST_I : std_logic := '1';

	--Bus Logic Interface
	signal TX_DATA_I     : STD_LOGIC_VECTOR(SPI_DATA_WIDTH - 1 downto 0) := (others => '0');
	signal RX_DATA_O     : STD_LOGIC_VECTOR(SPI_DATA_WIDTH - 1 downto 0);
	signal TX_FEEDBACK_O : STD_LOGIC_VECTOR(SPI_DATA_WIDTH - 1 downto 0);
	signal XFER_COUNT_O  : STD_LOGIC_VECTOR(SPI_DATA_WIDTH - 1 downto 0);

	--SPI Control Signals
	signal SPI_CLK_P_I  : STD_LOGIC := '0';
	signal SPI_CLK_N_I  : STD_LOGIC := '0';
	signal SPI_ENABLE_I : STD_LOGIC := '0';
	signal SPI_BUSY_O   : STD_LOGIC;
	signal SPI_CPOL_O   : STD_LOGIC;

	--SPI Interface
	signal SPI_SCLK : STD_LOGIC;
	signal SPI_MOSI : std_logic;
	signal SPI_MISO : std_logic := 'Z';
	signal SPI_nSS  : std_logic;

	-- Clock period definitions
	constant SPI_CLK_I_period : time := 100 ns;

begin

	-- Instantiate the Unit Under Test (UUT)
	uut : spi_m
		generic map(
			SPI_DATA_WIDTH  => SPI_DATA_WIDTH,
			SPI_CPHA        => SPI_CPHA,
			SPI_CPOL        => SPI_CPOL,
			SPI_SCLK_OUT_EN => SPI_SCLK_OUT_EN,
			SPI_BIG_ENDIAN  => SPI_BIG_ENDIAN
		)
		port map(
			RST_I         => RST_I,
			TX_DATA_I     => TX_DATA_I,
			RX_DATA_O     => RX_DATA_O,
			TX_FEEDBACK_O => TX_FEEDBACK_O,
			XFER_COUNT_O  => XFER_COUNT_O,
			SPI_CLK_P_I   => SPI_CLK_P_I,
			SPI_CLK_N_I   => SPI_CLK_N_I,
			SPI_ENABLE_I  => SPI_ENABLE_I,
			SPI_BUSY_O    => SPI_BUSY_O,
			SPI_CPOL_O    => SPI_CPOL_O,
			SPI_SCLK      => SPI_SCLK,
			SPI_MOSI      => SPI_MOSI,
			SPI_MISO      => SPI_MISO,
			SPI_nSS       => SPI_nSS
		);

	-- Clock process definitions
	SPI_CLK_I_process : process
	begin
		SPI_CLK_P_I <= '0';
		SPI_CLK_N_I <= '1';
		wait for SPI_CLK_I_period / 2;
		SPI_CLK_P_I <= '1';
		SPI_CLK_N_I <= '0';
		wait for SPI_CLK_I_period / 2;
	end process;

	-- Stimulus process
	wb_stim_proc : process
	begin
		-- hold reset state for 500 ns.
		wait for 500 ns;

		RST_I <= '0';

		wait for SPI_CLK_I_period * 5;

		-- insert stimulus here
		wait until rising_edge(SPI_CLK_P_I);
		TX_DATA_I    <= x"FEDC4321";
		SPI_ENABLE_I <= '1';

		wait until rising_edge(SPI_BUSY_O);
		wait until rising_edge(SPI_CLK_P_I);
		SPI_ENABLE_I <= '0';

		wait;
	end process;

	-- Stimulus process
	spi_stim_proc : process
	begin
		wait until falling_edge(SPI_nSS);
		if (SPI_CPHA = '1') then
			wait for SPI_CLK_I_period / 2;
		end if;
		SPI_MISO <= '0';
		wait for SPI_CLK_I_period * 4;
		SPI_MISO <= '1';
		wait for SPI_CLK_I_period * 8;
		SPI_MISO <= '0';
		wait for SPI_CLK_I_period * 6;
		SPI_MISO <= '1';
		wait for SPI_CLK_I_period * 6;
		SPI_MISO <= '0';
		wait for SPI_CLK_I_period * 4;
		SPI_MISO <= '1';
		wait for SPI_CLK_I_period * 4;
		SPI_MISO <= 'Z';
	end process;

end Behavioral;