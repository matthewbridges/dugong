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
-- Name:		DCORES (001)
-- Type:		PACKAGE (1)
-- Description:		A package containing DUGONG IP Cores
--
-- Compliance:		DUGONG V0.3
-- ID:			x 0-3-1-001
--
-- Last Modified:	31-OCT-2013
-- Modified By:		MATTHEW BRIDGES
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

package dcores is

	---------------------------
	---- WISHBONE IP CORES ----
	---------------------------

	component bram_ip
		generic(
			BASE_ADDR       : UNSIGNED(ADDR_WIDTH + 3 downto 0) := x"00000000";
			CORE_DATA_WIDTH : NATURAL                           := 32;
			CORE_ADDR_WIDTH : NATURAL                           := 10
		);
		port(
			--System Control Inputs
			CLK_I : in  STD_LOGIC;
			RST_I : in  STD_LOGIC;
			--Slave to WB
			WB_MS : in  WB_MS_type;
			WB_SM : out WB_SM_type
		);
	end component bram_ip;

	component clk_counter_ip
		generic(
			BASE_ADDR       : UNSIGNED(ADDR_WIDTH + 3 downto 0) := x"00000000";
			CORE_DATA_WIDTH : NATURAL                           := 32;
			CORE_ADDR_WIDTH : NATURAL                           := 3
		);
		port(
			--System Control Inputs
			CLK_I       : in  STD_LOGIC;
			RST_I       : in  STD_LOGIC;
			--Slave to WB
			WB_MS       : in  WB_MS_type;
			WB_SM       : out WB_SM_type;
			--Test Clocks
			TEST_CLOCKS : in  STD_LOGIC_VECTOR(2 downto 0)
		);
	end component clk_counter_ip;

	component dds_ip
		generic(
			BASE_ADDR       : UNSIGNED(ADDR_WIDTH + 3 downto 0) := x"00000000";
			CORE_DATA_WIDTH : NATURAL                           := 16;
			CORE_ADDR_WIDTH : NATURAL                           := 3
		);
		port(
			--System Control Inputs
			CLK_I     : in  STD_LOGIC;
			RST_I     : in  STD_LOGIC;
			--Slave to WB
			WB_MS     : in  WB_MS_type;
			WB_SM     : out WB_SM_type;
			--Signal Channel Outputs
			DSP_CLK_I : in  STD_LOGIC;
			CH_A_O    : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
			CH_B_O    : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0)
		);
	end component dds_ip;

	component gpio_ip
		generic(
			BASE_ADDR       : UNSIGNED(ADDR_WIDTH + 3 downto 0) := x"00000000";
			CORE_DATA_WIDTH : NATURAL                           := 16;
			CORE_ADDR_WIDTH : NATURAL                           := 3
		);
		port(
			--System Control Inputs
			CLK_I        : in    STD_LOGIC;
			RST_I        : in    STD_LOGIC;
			--Slave to WB
			WB_MS        : in    WB_MS_type;
			WB_SM        : out   WB_SM_type;
			--GPIO Auxiliary Interface
			GPIO_AUX_IN  : out   STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
			GPIO_AUX_OUT : in    STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
			--GPIO Interface
			GPIO_B       : inout STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0)
		);
	end component gpio_ip;

	component spi_m_ip
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
	end component spi_m_ip;

	component wb_multi_latch_ip is
		generic(
			BASE_ADDR       : UNSIGNED(ADDR_WIDTH + 3 downto 0) := x"00000000";
			CORE_DATA_WIDTH : NATURAL                           := 32;
			CORE_ADDR_WIDTH : NATURAL                           := 3
		);
		port(
			--System Control Inputs
			CLK_I   : in  STD_LOGIC;
			RST_I   : in  STD_LOGIC;
			--Slave to WB
			WB_MS   : in  WB_MS_type;
			WB_SM   : out WB_SM_type;
			--LATCH Inputs
			LATCH_D : in  DWORD_vector(3 downto 0)
		);
	end component wb_multi_latch_ip;

	component wb_test_slave_ip is
		generic(
			BASE_ADDR       : UNSIGNED(ADDR_WIDTH + 3 downto 0) := x"00000000";
			CORE_DATA_WIDTH : NATURAL                           := 32;
			CORE_ADDR_WIDTH : NATURAL                           := 24
		);
		port(
			--System Control Inputs
			CLK_I : in  STD_LOGIC;
			RST_I : in  STD_LOGIC;
			--Slave to WB
			WB_MS : in  WB_MS_type;
			WB_SM : out WB_SM_type
		);
	end component wb_test_slave_ip;

	------------------------------------
	---- ADVANCED WISHBONE IP CORES ----
	------------------------------------

	component fmc150_controller_ip is
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
			SPI_SCLK_O  : out   STD_LOGIC;
			SPI_MOSI_O  : out   STD_LOGIC;
			ADC_MISO_I  : in    STD_LOGIC;
			ADC_N_SS_O  : out   STD_LOGIC;
			CDC_MISO_I  : in    STD_LOGIC;
			CDC_N_SS_O  : out   STD_LOGIC;
			DAC_MISO_I  : in    STD_LOGIC;
			DAC_N_SS_O  : out   STD_LOGIC;
			MON_MISO_I  : in    STD_LOGIC;
			MON_N_SS_O  : out   STD_LOGIC;
			FMC150_GPIO : inout STD_LOGIC_VECTOR(7 downto 0);
			-- Debug
			DEBUG       : out   STD_LOGIC_VECTOR(31 downto 0)
		);
	end component fmc150_controller_ip;

end package dcores;

package body dcores is
end package body dcores;
