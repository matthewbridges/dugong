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
-- Name:		FMC150_CONTROLLER_IP (001)
-- Type:		PRIMITIVE (5)
-- Description:
--
-- Compliance:		DUGONG V0.3
-- ID:			x 0-3-5-001
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

entity fmc150_controller_ip is
	generic(
		BASE_ADDR       : UNSIGNED(ADDR_WIDTH + 3 downto 0) := x"00000000";
		CORE_DATA_WIDTH : NATURAL                           := 32;
		CORE_ADDR_WIDTH : NATURAL                           := 4
	);
	port(
		--System Control Inputs
		CLK_I          : in  STD_LOGIC;
		RST_I          : in  STD_LOGIC;
		--Slave to WB
		WB_MS          : in  WB_MS_type;
		WB_SM          : out WB_SM_type;
		--Serial Peripheral Interface
		SPI_CLK_P_I    : in  STD_LOGIC;
		SPI_CLK_N_I    : in  STD_LOGIC;
		SPI_SCLK_O     : out STD_LOGIC;
		SPI_MOSI_O     : out STD_LOGIC;
		ADC_MISO_I     : in  STD_LOGIC;
		ADC_N_SS_O     : out STD_LOGIC;
		CDC_MISO_I     : in  STD_LOGIC;
		CDC_N_SS_O     : out STD_LOGIC;
		DAC_MISO_I     : in  STD_LOGIC;
		DAC_N_SS_O     : out STD_LOGIC;
		ADC_RST        : out STD_LOGIC;
		CDC_REF_EN     : out STD_LOGIC;
		CDC_N_RST      : out STD_LOGIC;
		CDC_N_PD       : out STD_LOGIC;
		CDC_PLL_STATUS : in  STD_LOGIC;
		-- Debug
		DEBUG          : out STD_LOGIC_VECTOR(31 downto 0)
	);
end entity fmc150_controller_ip;

architecture RTL of fmc150_controller_ip is
	constant NUMBER_OF_SPI_MASTERS : natural := 3;
	signal wb_sm_internal          : WB_SM_vector(NUMBER_OF_SPI_MASTERS - 1 downto 0); --3 SPI SLAVES

	subtype master_num is natural range 0 to NUMBER_OF_SPI_MASTERS - 1;
	signal master_sel   : master_num := 0;
	signal spi_bus_busy : std_logic;
	signal spi_bus_req  : std_logic_vector(NUMBER_OF_SPI_MASTERS - 1 downto 0);
	signal spi_ce       : std_logic_vector(NUMBER_OF_SPI_MASTERS - 1 downto 0);
	signal spi_mosi     : std_logic_vector(NUMBER_OF_SPI_MASTERS - 1 downto 0);

begin
	--ROUND ROBIN ARBITRATION
	process(CLK_I, RST_I)
	begin
		--RST STATE
		if (RST_I = '1') then
			spi_bus_busy <= '0';
			master_sel   <= 0;
			spi_ce       <= (others => '0');
		else
			--Perform Rising Edge operations
			if (rising_edge(CLK_I)) then
				if (spi_bus_busy = '0') then
					--Give bus to Master = master_sel if it wants it
					if (spi_bus_req(master_sel) = '1') then
						spi_ce(master_sel) <= '1';
						spi_bus_busy       <= '1';
					end if;
				elsif (spi_bus_req(master_sel) = '0') then
					spi_bus_busy <= '0';
					spi_ce       <= (others => '0');
					--Increment master_sel
					if (master_sel = NUMBER_OF_SPI_MASTERS - 1) then
						master_sel <= 0;
					else
						master_sel <= master_sel + 1;
					end if;
				end if;
			end if;
		end if;
	end process;

	CDCE72010_ctrl : spi_m_ip
		generic map(
			BASE_ADDR       => BASE_ADDR,
			CORE_DATA_WIDTH => 32,
			CORE_ADDR_WIDTH => 3
		)
		port map(
			CLK_I       => CLK_I,
			RST_I       => RST_I,
			WB_MS       => WB_MS,
			WB_SM       => wb_sm_internal(0),
			SPI_CLK_I   => SPI_CLK_P_I,
			SPI_CE      => spi_ce(0),
			SPI_BUS_REQ => spi_bus_req(0),
			SPI_MOSI    => spi_mosi(0),
			SPI_MISO    => CDC_MISO_I,
			SPI_N_SS    => CDC_N_SS_O
		);

	ADS62P49_ctrl : spi_m_ip
		generic map(
			BASE_ADDR       => BASE_ADDR + 32,
			CORE_DATA_WIDTH => 16,
			CORE_ADDR_WIDTH => 3
		)
		port map(
			CLK_I       => CLK_I,
			RST_I       => RST_I,
			WB_MS       => WB_MS,
			WB_SM       => wb_sm_internal(1),
			SPI_CLK_I   => SPI_CLK_P_I,
			SPI_CE      => spi_ce(1),
			SPI_BUS_REQ => spi_bus_req(1),
			SPI_MOSI    => spi_mosi(1),
			SPI_MISO    => ADC_MISO_I,
			SPI_N_SS    => ADC_N_SS_O
		);

	DAC3283_ctrl : spi_m_ip
		generic map(
			BASE_ADDR       => BASE_ADDR + 64,
			CORE_DATA_WIDTH => 16,
			CORE_ADDR_WIDTH => 3
		)
		port map(
			CLK_I       => CLK_I,
			RST_I       => RST_I,
			WB_MS       => WB_MS,
			WB_SM       => wb_sm_internal(2),
			SPI_CLK_I   => SPI_CLK_P_I,
			SPI_CE      => spi_ce(2),
			SPI_BUS_REQ => spi_bus_req(2),
			SPI_MOSI    => spi_mosi(2),
			SPI_MISO    => DAC_MISO_I,
			SPI_N_SS    => DAC_N_SS_O
		);

	WB_SM <= wb_sm_internal(0) or wb_sm_internal(1) or wb_sm_internal(2);

	SPI_MOSI_O <= spi_mosi(master_sel);

	--ODDR for Clock Forwarding
	SPI_CLK_ODDR2 : ODDR2
		generic map(
			DDR_ALIGNMENT => "NONE",    -- Sets output alignment to "NONE", "C0", "C1"
			INIT          => '0',       -- Sets initial state of the Q output to '0' or '1'
			SRTYPE        => "SYNC"     -- Specifies "SYNC" or "ASYNC" set/reset
		)
		port map(
			Q  => SPI_SCLK_O,           -- 1-bit output data
			C0 => SPI_CLK_P_I,          -- 1-bit clock input
			C1 => SPI_CLK_N_I,          -- 1-bit clock input
			CE => spi_bus_busy,         -- 1-bit clock enable input
			D0 => '0',                  -- 1-bit data input (associated with C0)
			D1 => '1',                  -- 1-bit data input (associated with C1)
			R  => RST_I,                -- 1-bit reset input
			S  => '0'                   -- 1-bit set input
		);

	ADC_RST    <= RST_I;
	CDC_REF_EN <= '1';
	CDC_N_RST  <= not RST_I;
	CDC_N_PD   <= not RST_I;

	DEBUG(10 downto 0) <= CDC_PLL_STATUS & spi_mosi & spi_ce & spi_bus_req & spi_bus_busy;

end architecture RTL;
