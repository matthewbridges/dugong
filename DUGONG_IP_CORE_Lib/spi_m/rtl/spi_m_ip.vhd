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
-- Name:		SPI_M (003)
-- Type:		IP_CORE (4)
-- Description: 	An IP core which forwards SPI data out to OFF-CHIP SPI slaves. Has a generic CORE_DATA_WIDTH
--			which corresponds to the length of the SPI data transfer. No assumptions are made as to
--			the content of the data. The input has a FIFO, however, it is up to the user to ensure 
--			that the data rate does not exceed the SPI's capacity. Excess data is just ignored.
--
-- Compliance:		DUGONG V0.5
-- ID:			x 0-5-4-003
--
-- Last Modified:	31-OCT-2013
-- Modified By:		MATTHEW BRIDGES
---------------------------------------------------------------------------------------------------------------
--	ADDR	| NAME		| Type		--
--	0	| BASE_ADDR	| WB_LATCH	--
-- 	1	| HIGH_ADDR	| WB_LATCH	--
-- 	2	| CORE_ID	| WB_LATCH	-- --SEE HEADER
-- 	3	| xFEDCBA98	| WB_REG	-- --TEST_SIGNAL
--	4	| TX_DATA	| WB_FIFO	--
-- 	5	| RX_DATA	| WB_LATCH	--
-- 	6	| TX_FEEDBACK	| WB_LATCH	--
-- 	7	| XFER_COUNT	| WB_LATCH	--
--------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

--NB The DATA_WIDTH and ADDR_WIDTH constants are set in the dprimitives package
entity spi_m_ip is
	generic(
		BASE_ADDR       : UNSIGNED(ADDR_WIDTH + 3 downto 0) := x"00000000";
		CORE_DATA_WIDTH : NATURAL                           := 32;
		CORE_ADDR_WIDTH : NATURAL                           := 3;
		SPI_CPHA        : std_logic                         := '0';
		SPI_CPOL        : std_logic                         := '0';
		SPI_SCLK_OUT_EN : std_logic                         := '1';
		SPI_BIG_ENDIAN  : std_logic                         := '1'
	);
	port(
		--System Control Inputs
		CLK_I         : in  STD_LOGIC;
		RST_I         : in  STD_LOGIC;
		--Slave to WB
		WB_MS         : in  WB_MS_type;
		WB_SM         : out WB_SM_type;
		--SPI Control Signals
		SPI_CLK_P_I   : in  STD_LOGIC;
		SPI_CLK_N_I   : in  STD_LOGIC;
		SPI_BUS_REQ_O : out STD_LOGIC;
		SPI_ENABLE_I  : in  STD_LOGIC;
		SPI_BUSY_O    : out STD_LOGIC;
		SPI_CPOL_O    : out STD_LOGIC;
		--SPI Interface
		SPI_SCLK      : out STD_LOGIC;
		SPI_MOSI      : out STD_LOGIC;
		SPI_MISO      : in  STD_LOGIC;
		SPI_nSS       : out STD_LOGIC
	);
end spi_m_ip;

architecture Behavioral of spi_m_ip is
	signal adr_i : STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0);
	signal dat_i : STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
	signal dat_o : STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
	signal we_i  : STD_LOGIC;
	signal stb_i : STD_LOGIC;
	signal ack_o : STD_LOGIC;
	signal cyc_i : STD_LOGIC;

	component spi_m_core
		generic(
			CORE_DATA_WIDTH : natural   := 32;
			CORE_ADDR_WIDTH : natural   := 3;
			SPI_CPHA        : std_logic := '0';
			SPI_CPOL        : std_logic := '0';
			SPI_SCLK_OUT_EN : std_logic := '1';
			SPI_BIG_ENDIAN  : std_logic := '1'
		);
		port(
			--System Control Inputs
			CLK_I         : in  STD_LOGIC;
			RST_I         : in  STD_LOGIC;
			--Wishbone Slave Lines
			ADR_I         : in  STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0);
			DAT_I         : in  STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
			DAT_O         : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
			WE_I          : in  STD_LOGIC;
			STB_I         : in  STD_LOGIC;
			ACK_O         : out STD_LOGIC;
			CYC_I         : in  STD_LOGIC;
			--SPI Control Signals
			SPI_CLK_P_I   : in  STD_LOGIC;
			SPI_CLK_N_I   : in  STD_LOGIC;
			SPI_BUS_REQ_O : out STD_LOGIC;
			SPI_ENABLE_I  : in  STD_LOGIC;
			SPI_BUSY_O    : out STD_LOGIC;
			SPI_CPOL_O    : out STD_LOGIC;
			--SPI Interface
			SPI_SCLK      : out STD_LOGIC;
			SPI_MOSI      : out STD_LOGIC;
			SPI_MISO      : in  STD_LOGIC;
			SPI_nSS       : out STD_LOGIC
		);
	end component spi_m_core;

begin
	bus_logic : wb_s
		generic map(
			BASE_ADDR       => BASE_ADDR,
			CORE_ID         => x"00054003", -- SEE HEADER
			CORE_DATA_WIDTH => CORE_DATA_WIDTH,
			CORE_ADDR_WIDTH => CORE_ADDR_WIDTH
		)
		port map(
			CLK_I => CLK_I,
			RST_I => RST_I,
			WB_MS => WB_MS,
			WB_SM => WB_SM,
			ADR_I => adr_i,
			DAT_I => dat_i,
			DAT_O => dat_o,
			WE_I  => we_i,
			STB_I => stb_i,
			ACK_O => ack_o,
			CYC_I => cyc_i
		);

	user_core : spi_m_core
		generic map(
			CORE_DATA_WIDTH => CORE_DATA_WIDTH,
			CORE_ADDR_WIDTH => CORE_ADDR_WIDTH,
			SPI_CPHA        => SPI_CPHA,
			SPI_CPOL        => SPI_CPOL,
			SPI_SCLK_OUT_EN => SPI_SCLK_OUT_EN,
			SPI_BIG_ENDIAN  => SPI_BIG_ENDIAN
		)
		port map(
			CLK_I         => CLK_I,
			RST_I         => RST_I,
			ADR_I         => adr_i,
			DAT_I         => dat_i,
			DAT_O         => dat_o,
			WE_I          => we_i,
			STB_I         => stb_i,
			ACK_O         => ack_o,
			CYC_I         => cyc_i,
			SPI_CLK_P_I   => SPI_CLK_P_I,
			SPI_CLK_N_I   => SPI_CLK_N_I,
			SPI_BUS_REQ_O => SPI_BUS_REQ_O,
			SPI_ENABLE_I  => SPI_ENABLE_I,
			SPI_BUSY_O    => SPI_BUSY_O,
			SPI_CPOL_O    => SPI_CPOL_O,
			SPI_SCLK      => SPI_SCLK,
			SPI_MOSI      => SPI_MOSI,
			SPI_MISO      => SPI_MISO,
			SPI_nSS       => SPI_nSS
		);

end Behavioral;

