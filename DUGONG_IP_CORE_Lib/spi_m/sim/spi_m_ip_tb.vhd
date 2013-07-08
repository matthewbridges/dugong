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
-- Name:		SPI_M_IP_TB (
-- Type:		TB (F)
-- Description:
--
-- Compliance:		DUGONG V0.3
-- ID:			x 1-4-F
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

library DUGONG_IP_CORE_Lib;
use DUGONG_IP_CORE_Lib.dcores.ALL;

entity spi_m_ip_tb is
end spi_m_ip_tb;

architecture Behavioral of spi_m_ip_tb is

	--System Control Inputs:
	signal CLK_I : std_logic := '0';
	signal RST_I : std_logic := '1';

	--Slave to WB
	signal WB_MS : WB_MS_type := (others => '0');
	signal WB_SM : WB_SM_type;

	--SPI Interface
	signal SPI_CLK_I   : std_logic := '0';
	signal SPI_CE      : std_logic := '0';
	signal SPI_BUS_REQ : STD_LOGIC;
	signal SPI_MOSI    : std_logic;
	signal SPI_MISO    : std_logic := '0';
	signal SPI_N_SS    : std_logic;

	-- Clock period definitions
	constant CLK_I_period     : time := 10 ns;
	constant SPI_CLK_I_period : time := 320 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : spi_m_ip
		port map(CLK_I       => CLK_I,
			 RST_I       => RST_I,
			 WB_MS       => WB_MS,
			 WB_SM       => WB_SM,
			 SPI_CLK_I   => SPI_CLK_I,
			 SPI_CE      => SPI_CE,
			 SPI_BUS_REQ => SPI_BUS_REQ,
			 SPI_MOSI    => SPI_MOSI,
			 SPI_MISO    => SPI_MISO,
			 SPI_N_SS    => SPI_N_SS);

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
	wb_master_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;

		RST_I <= '0';
		WB_MS <= "111" & x"FEDCBA98" & x"FFFFFFF";

		wait for CLK_I_period * 10;

		-- Standard IP Core Tests
		wait until rising_edge(CLK_I);
		WB_MS <= "110" & x"00000000" & x"0000000"; --Read Base Address
		wait until rising_edge(WB_SM(DATA_WIDTH));
		wait until rising_edge(CLK_I);
		WB_MS <= "000" & x"00000000" & x"0000000"; --NULL
		wait until rising_edge(CLK_I);
		WB_MS <= "110" & x"00000000" & x"0000001"; --Read High Address
		wait until rising_edge(WB_SM(DATA_WIDTH));
		wait until rising_edge(CLK_I);
		WB_MS <= "000" & x"00000000" & x"0000000"; --NULL

		wait until rising_edge(CLK_I);
		WB_MS <= "111" & x"FEDCAB98" & x"0000004"; --Write xFEDCAB98 to 004
		wait until rising_edge(WB_SM(DATA_WIDTH));
		wait until rising_edge(CLK_I);
		WB_MS <= "000" & x"00000000" & x"0000000"; --NULL
--
--		wait until rising_edge(CLK_I);
--		WB_MS <= "111" & x"FEDCAB98" & x"0000007"; --Write xFEDCAB98 to 008

		wait;
	end process;

	-- Stimulus process
	spi_stim_proc : process
	begin
		wait until rising_edge(SPI_BUS_REQ);
		SPI_CE <= '1';
		wait until falling_edge(SPI_N_SS);
		wait for SPI_CLK_I_period * 4;
		SPI_MISO <= '1';
		wait for SPI_CLK_I_period * 8;
		SPI_MISO <= '0';
		wait until falling_edge(SPI_BUS_REQ);
		SPI_CE <= '0';
	end process;

end;
