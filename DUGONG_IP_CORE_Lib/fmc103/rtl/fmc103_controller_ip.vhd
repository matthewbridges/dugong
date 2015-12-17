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
-- Name:		FMC103_CONTROLLER_IP (001)
-- Type:		PRIMITIVE (5)
-- Description:
--
-- Compliance:		DUGONG V0.3
-- ID:			x 0-3-5-001
--
-- Last Modified:	31-OCT-2013
-- Modified By:		MATTHEW BRIDGES
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

library DUGONG_IP_CORE_Lib;
use DUGONG_IP_CORE_Lib.dcores.ALL;

library unisim;
use unisim.vcomponents.all;

entity fmc103_controller_ip is
	generic(
		BASE_ADDR       : UNSIGNED(ADDR_WIDTH + 3 downto 0) := x"00000000";
		CORE_DATA_WIDTH : NATURAL                           := 32;
		CORE_ADDR_WIDTH : NATURAL                           := 4
	);
	port(
		--System Control Inputs
		CLK_I       : in    STD_LOGIC;
		RST_I       : in    STD_LOGIC;
		--Slave to WB
		WB_MS       : in    WB_MS_type;
		WB_SM       : out   WB_SM_type;
		--Serial Peripheral Interface
		SPI_CLK_P_I : in    STD_LOGIC;
		SPI_CLK_N_I : in    STD_LOGIC;
		AD9510_SCLK_O  : out   STD_LOGIC;
		AD9510_MOSI_O  : out   STD_LOGIC;
		AD9510_MISO_I  : in    STD_LOGIC;
		AD9510_N_SS_O  : out   STD_LOGIC;
		FMC103_GPIO : inout STD_LOGIC_VECTOR(0 downto 0);
		-- Debug
		DEBUG       : out   STD_LOGIC_VECTOR(31 downto 0)
	);
end entity fmc103_controller_ip;

architecture RTL of fmc103_controller_ip is
	constant NUMBER_OF_IP_SLAVES : natural := 2;
	signal wb_sm_internal        : WB_SM_vector(NUMBER_OF_IP_SLAVES - 1 downto 0); --3 SPI SLAVES

	constant NUMBER_OF_SPI_MASTERS : natural := 1;
	subtype master_num is natural range 0 to NUMBER_OF_SPI_MASTERS - 1;
	signal master_sel        : master_num := 0;
	signal spi_sclk_selected : std_logic;
	signal spi_cpol_selected : std_logic;

	signal spi_busy     : std_logic;
	signal spi_cpol_out : std_logic;
	signal spi_sclk     : std_logic;
	signal spi_mosi     : std_logic;
	signal spi_n_ss     : std_logic;

begin
	AD9510_ctrl : spi_m_ip
		generic map(
			BASE_ADDR       => BASE_ADDR,
			CORE_DATA_WIDTH => 24,
			SPI_CPHA        => '0',
			SPI_CPOL        => '0',
			SPI_SCLK_OUT_EN => '0',
			SPI_BIG_ENDIAN  => '0'
		)
		port map(
			CLK_I         => CLK_I,
			RST_I         => RST_I,
			WB_MS         => WB_MS,
			WB_SM         => wb_sm_internal(0),
			SPI_CLK_P_I   => SPI_CLK_P_I,
			SPI_CLK_N_I   => SPI_CLK_N_I,
			SPI_BUS_REQ_O => open,
			SPI_ENABLE_I  => '1',
			SPI_BUSY_O    => spi_busy,
			SPI_CPOL_O    => spi_cpol_out,
			SPI_SCLK      => spi_sclk,
			SPI_MOSI      => spi_mosi,
			SPI_MISO      => AD9510_MISO_I,
			SPI_nSS       => spi_n_ss
		);

	AD9510_N_SS_O <= spi_n_ss;

	spi_sclk_selected <= spi_sclk;
	spi_cpol_selected <= spi_cpol_out;

	AD9510_MOSI_O <= spi_mosi;

	--ODDR for Clock Forwarding
	SPI_SCLK_ODDR2 : ODDR2
		generic map(
			DDR_ALIGNMENT => "C0",      -- Sets output alignment to "NONE", "C0", "C1"
			INIT          => '0',       -- Sets initial state of the Q output to '0' or '1'
			SRTYPE        => "ASYNC"    -- Specifies "SYNC" or "ASYNC" set/reset
		)
		port map(
			Q  => AD9510_SCLK_O,           -- 1-bit output data
			C0 => SPI_CLK_P_I,          -- 1-bit clock input
			C1 => SPI_CLK_N_I,          -- 1-bit clock input
			CE => '1',                  -- 1-bit clock enable input
			D0 => spi_sclk_selected,    -- 1-bit data input (associated with C0)
			D1 => spi_cpol_selected,    -- 1-bit data input (associated with C1)
			R  => RST_I,                -- 1-bit reset input
			S  => '0'                   -- 1-bit set input
		);

	FMC103_GPIO_CONTROLLER : gpio_ip
		generic map(
			BASE_ADDR       => BASE_ADDR + 32,
			CORE_DATA_WIDTH => 1
		)
		port map(
			CLK_I        => CLK_I,
			RST_I        => RST_I,
			WB_MS        => WB_MS,
			WB_SM        => wb_sm_internal(1),
			GPIO_AUX_IN  => open,
			GPIO_AUX_OUT => (others => '0'),
			GPIO_B       => FMC103_GPIO
		);

	WB_SM <= wb_sm_internal(0) or wb_sm_internal(1);

--	DEBUG(31 downto 28) <= wb_sm_internal(3)(DATA_WIDTH) & wb_sm_internal(2)(DATA_WIDTH) & wb_sm_internal(1)(DATA_WIDTH) & wb_sm_internal(0)(DATA_WIDTH);
--	DEBUG(27 downto 0)  <= spi_n_ss & spi_mosi & spi_busy & spi_enable & spi_bus_req & spi_cpol_out & spi_sclk;

end architecture RTL;
