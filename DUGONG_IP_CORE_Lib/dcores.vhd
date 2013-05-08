--  
--                    
--_____/\\\\\\\\\_______/\\\________/\\\____/\\\\\\\\\\\____/\\\\\_____/\\\_________/\\\\\_________      
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
-- Engineer: 	MATTHEW BRIDGES
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package dcores is
	subtype dword is std_logic_vector(35 downto 0);
	type word_vector is array (natural range <>) of dword;
	--	type SLV_2D is array (natural range <>, natural range <>) of std_logic;

	subtype WB_O_type is std_logic_vector(32 downto 0);
	type WB_O_vector is array (natural range <>) of WB_O_type;

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

	component spi_master_ip
		generic(
			DATA_WIDTH      : NATURAL               := 32;
			ADDR_WIDTH      : NATURAL               := 12;
			BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
			CORE_DATA_WIDTH : NATURAL               := 16;
			CORE_ADDR_WIDTH : NATURAL               := 3;
			SPI_DATA_WIDTH  : natural               := 8;
			DEFAULT_DATA    : word_vector(0 to 128) := (others => x"000010000");
			REVERSE_BITS    : boolean               := false
		);
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
	end component spi_master_ip;

	component gpmc_interface_ip
		generic(
			DATA_WIDTH      : NATURAL               := 32;
			ADDR_WIDTH      : NATURAL               := 12;
			BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
			CORE_DATA_WIDTH : NATURAL               := 32;
			CORE_ADDR_WIDTH : NATURAL               := 10
		);
		port(
			--System Control Inputs
			CLK_I         : in    STD_LOGIC;
			RST_I         : in    STD_LOGIC;
			--Slave to WHISHBONE
			WB_I          : in    STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
			WB_O          : out   STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
			--GPMC Interface
			GPMC_CLK      : in    STD_LOGIC;
			GPMC_D        : inout STD_LOGIC_VECTOR(15 downto 0);
			GPMC_A        : in    STD_LOGIC_VECTOR(10 downto 1);
			GPMC_nCS      : in    STD_LOGIC;
			GPMC_nWE      : in    STD_LOGIC;
			GPMC_nOE      : in    STD_LOGIC;
			GPMC_nADV_ALE : in    STD_LOGIC
		);
	end component gpmc_interface_ip;

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
			--Slave to WHISHBONE
			WB_I  : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
			WB_O  : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0)
		);
	end component bram_ip;

	component wb_s is
		generic(
			DATA_WIDTH      : NATURAL               := 32;
			ADDR_WIDTH      : NATURAL               := 12;
			BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
			CORE_DATA_WIDTH : NATURAL               := 16;
			CORE_ADDR_WIDTH : NATURAL               := 3
		);
		port(
			--System Control Inputs
			CLK_I : in  STD_LOGIC;
			RST_I : in  STD_LOGIC;
			--Slave to WHISHBONE
			WB_I  : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
			WB_O  : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
			--Wishbone Slave Lines (inverted)
			DAT_I : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
			DAT_O : in  STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
			ADR_I : out STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0);
			STB_I : out STD_LOGIC;
			WE_I  : out STD_LOGIC;
			CYC_I : out STD_LOGIC;
			ACK_O : in  STD_LOGIC
		);
	end component;

	component wb_intercon is
		generic(
			NUMBER_OF_CORES : NATURAL := 4
		);
		port(
			--Slave to WB
			WB_O_bus : out WB_O_type;
			WB_O     : in  WB_O_vector(NUMBER_OF_CORES - 1 downto 0)
		);
	end component;

	component wb_register is
		generic(
			DATA_WIDTH   : NATURAL                       := 16;
			DEFAULT_DATA : STD_LOGIC_VECTOR(63 downto 0) := x"0000000000000000"
		);
		port(
			--System Control Inputs:
			CLK_I : in  STD_LOGIC;
			RST_I : in  STD_LOGIC;
			--WISHBONE SLAVE interface:
			DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			WE_I  : in  STD_LOGIC;
			--SEL_I : in  STD_LOGIC_VECTOR(DATA_WIDTH / 8 - 1 downto 0);
			STB_I : in  STD_LOGIC;
			ACK_O : out STD_LOGIC
		--CYC_I : in   STD_LOGIC;
		);
	end component;
end package dcores;

package body dcores is
end package body dcores;
