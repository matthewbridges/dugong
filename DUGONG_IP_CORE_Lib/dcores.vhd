--  
--                    
-- _____/\\\\\\\\\_______/\\\________/\\\____/\\\\\\\\\\\____/\\\\\_____/\\\_________/\\\\\_______      
--\____/\\\///////\\\____\/\\\_______\/\\\___\/////\\\///____\/\\\\\\___\/\\\_______/\\\///\\\_____\
-- \___\/\\\_____\/\\\____\/\\\_______\/\\\_______\/\\\_______\/\\\/\\\__\/\\\_____/\\\/__\///\\\___\    
--  \___\/\\\\\\\\\\\/_____\/\\\\\\\\\\\\\\\_______\/\\\_______\/\\\//\\\_\/\\\____/\\\______\//\\\__\   
--   \___\/\\\//////\\\_____\/\\\/////////\\\_______\/\\\_______\/\\\\//\\\\/\\\___\/\\\_______\/\\\__\  
--    \___\/\\\____\//\\\____\/\\\_______\/\\\_______\/\\\_______\/\\\_\//\\\/\\\___\//\\\______/\\\___\
--     \___\/\\\_____\//\\\___\/\\\_______\/\\\_______\/\\\_______\/\\\__\//\\\\\\____\///\\\__/\\\_____\
--      \___\/\\\______\//\\\__\/\\\_______\/\\\____/\\\\\\\\\\\___\/\\\___\//\\\\\______\///\\\\\/______\
--       \___\///________\///___\///________\///____\///////////____\///_____\/////_________\/////________\
--        \                                                                                                \
--         \==============  Reconfigurable Hardware Interface for computatioN and radiO  ===================\
--          \============================  http://www.rhinoplatform.org  ====================================\
--           \================================================================================================\
--
---------------------------------------------------------------------------------------------------------------
-- Company:		UNIVERSITY OF CAPE TOWN
-- Engineer: 		MATTHEW BRIDGES
--
-- Name:		DPRIMITIVES (001)
-- Type:		PACKAGE (1)
-- Description:		A package containing DUGONG IP Cores
--
-- Compliance:		DUGONG V1.1 (1-1)
-- ID:			x 1-1-1-001
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package dcores is

	---------------------------
	---- WISHBONE IP CORES ----
	---------------------------

	component bram_ip
		generic(
			DATA_WIDTH      : NATURAL               := 32;
			ADDR_WIDTH      : NATURAL               := 12;
			BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
			CORE_DATA_WIDTH : NATURAL               := 32;
			CORE_ADDR_WIDTH : NATURAL               := 10
		);
		port(
			--System Control Inputs
			CLK_I : in  STD_LOGIC;
			RST_I : in  STD_LOGIC;
			--Slave to WB
			WB_I  : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
			WB_O  : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0)
		);
	end component bram_ip;

	component clk_counter_ip
		generic(
			DATA_WIDTH      : NATURAL                       := 32;
			ADDR_WIDTH      : NATURAL                       := 12;
			BASE_ADDR       : UNSIGNED(11 downto 0)         := x"000";
			CORE_DATA_WIDTH : NATURAL                       := 32;
			CORE_ADDR_WIDTH : NATURAL                       := 3;
			MASTER_CNT      : std_logic_vector(31 downto 0) := x"07530000"
		);
		port(
			--System Control Inputs
			CLK_I       : in  STD_LOGIC;
			RST_I       : in  STD_LOGIC;
			--Slave to WHISHBONE
			WB_I        : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
			WB_O        : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
			--Test Clocks
			TEST_CLOCKS : in  STD_LOGIC_VECTOR((2 ** CORE_ADDR_WIDTH) - 6 downto 0)
		);
	end component clk_counter_ip;

	component dds_core_ip
		generic(
			DATA_WIDTH      : NATURAL               := 32;
			ADDR_WIDTH      : NATURAL               := 12;
			BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
			CORE_DATA_WIDTH : NATURAL               := 16;
			CORE_ADDR_WIDTH : NATURAL               := 3
		);
		port(
			--System Control Inputs
			CLK_I     : in  STD_LOGIC;
			RST_I     : in  STD_LOGIC;
			--Slave to WHISHBONE
			WB_I      : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
			WB_O      : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
			--Signal Channel Outputs
			DSP_CLK_I : in  STD_LOGIC;
			CH_A_O    : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
			CH_B_O    : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0)
		);
	end component dds_core_ip;

	component gpio_controller_ip
		generic(
			DATA_WIDTH      : NATURAL               := 32;
			ADDR_WIDTH      : NATURAL               := 12;
			BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
			CORE_DATA_WIDTH : NATURAL               := 16;
			CORE_ADDR_WIDTH : NATURAL               := 3
		);
		port(
			--System Control Inputs
			CLK_I : in    STD_LOGIC;
			RST_I : in    STD_LOGIC;
			--Slave to WHISHBONE
			WB_I  : in    STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
			WB_O  : out   STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
			--GPIO Interface
			GPIO  : inout STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0)
		);
	end component gpio_controller_ip;

	component spi_m_ip
		generic(
			DATA_WIDTH      : NATURAL               := 32;
			ADDR_WIDTH      : NATURAL               := 12;
			BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
			CORE_DATA_WIDTH : NATURAL               := 16;
			CORE_ADDR_WIDTH : NATURAL               := 3);
		port(
			--System Control Inputs
			CLK_I     : in  STD_LOGIC;
			RST_I     : in  STD_LOGIC;
			--Slave to WHISHBONE
			WB_I      : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
			WB_O      : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
			--Serial Peripheral Interface
			SPI_CLK_I : in  STD_LOGIC;
			SPI_CE    : in  STD_LOGIC;
			SPI_MOSI  : out STD_LOGIC;
			SPI_MISO  : in  STD_LOGIC;
			SPI_N_SS  : out STD_LOGIC
		);
	end component spi_m_ip;

end package dcores;

package body dcores is
end package body dcores;
