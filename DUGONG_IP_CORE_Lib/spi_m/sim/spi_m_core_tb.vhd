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
-- Name:		GPIO_CONTROLLER_TB
-- Type:		TB (15)
-- Description:
--
-- Compliance:		DUGONG V1.4
-- ID:			x 1-4-F
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

ENTITY spi_m_tb IS
	generic(
		CORE_DATA_WIDTH : NATURAL := 16;
		CORE_ADDR_WIDTH : NATURAL := 3
	);
END spi_m_tb;

ARCHITECTURE behavior OF spi_m_tb IS

	-- Component Declaration for the Unit Under Test (UUT)
	component spi_m
		generic(
			CORE_DATA_WIDTH : natural := 32;
			CORE_ADDR_WIDTH : natural := 3
		);
		port(
			CLK_I       : in  STD_LOGIC;
			RST_I       : in  STD_LOGIC;
			ADR_I       : in  STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0);
			DAT_I       : in  STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
			DAT_O       : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
			WE_I        : in  STD_LOGIC;
			STB_I       : in  STD_LOGIC;
			ACK_O       : out STD_LOGIC;
			CYC_I       : in  STD_LOGIC;
			SPI_CLK_I   : in  STD_LOGIC;
			SPI_CE      : in  STD_LOGIC;
			SPI_BUS_REQ : out STD_LOGIC;
			SPI_MOSI    : out STD_LOGIC;
			SPI_MISO    : in  STD_LOGIC;
			SPI_N_SS    : out STD_LOGIC
		);
	end component spi_m;

	--System Control Inputs:
	signal CLK_I : std_logic := '0';
	signal RST_I : std_logic := '1';

	--Wishbone Slave interface
	signal ADR_I : STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0) := (others => '0');
	signal DAT_I : STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0) := (others => '0');
	signal DAT_O : STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
	signal WE_I  : STD_LOGIC                                      := '0';
	signal STB_I : STD_LOGIC                                      := '0';
	signal ACK_O : STD_LOGIC                                      := '0';
	signal CYC_I : STD_LOGIC                                      := '0';

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

begin

	-- Instantiate the Unit Under Test (UUT)
	uut : spi_m
		generic map(
			CORE_DATA_WIDTH => CORE_DATA_WIDTH,
			CORE_ADDR_WIDTH => CORE_ADDR_WIDTH
		)
		port map(
			CLK_I       => CLK_I,
			RST_I       => RST_I,
			ADR_I       => ADR_I,
			DAT_I       => DAT_I,
			DAT_O       => DAT_O,
			WE_I        => WE_I,
			STB_I       => STB_I,
			ACK_O       => ACK_O,
			CYC_I       => CYC_I,
			SPI_CLK_I   => SPI_CLK_I,
			SPI_CE      => SPI_CE,
			SPI_BUS_REQ => SPI_BUS_REQ,
			SPI_MOSI    => SPI_MOSI,
			SPI_MISO    => SPI_MISO,
			SPI_N_SS    => SPI_N_SS
		);

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
	wb_stim_proc : process
	begin
		-- hold reset state for 500 ns.
		wait for 100 ns;

		RST_I <= '0';

		wait for CLK_I_period * 10;

		-- insert stimulus here
		wait until rising_edge(CLK_I);
		DAT_I <= x"0000";               --Read from SPI count 
		ADR_I <= "011";                 --ADDR x3
		WE_I  <= '0';                   --Read
		STB_I <= '1';                   --Strobe
		CYC_I <= '1';
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		DAT_I <= x"0000";
		wait until rising_edge(CLK_I);
		DAT_I <= x"000F";               --Write to x000F to SPI output
		ADR_I <= "000";                 --ADDR x0
		WE_I  <= '1';                   --Write
		STB_I <= '1';                   --Strobe
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		WE_I  <= '0';
		DAT_I <= x"0000";
		wait until rising_edge(CLK_I);
		DAT_I <= x"0000";               --Read from SPI input 
		ADR_I <= "001";                 --ADDR x1
		WE_I  <= '0';                   --Read
		STB_I <= '1';                   --Strobe
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		DAT_I <= x"0000";
		wait until rising_edge(CLK_I);
		DAT_I <= x"00FF";               --Write to x00FF to SPI output
		ADR_I <= "000";                 --ADDR x0
		WE_I  <= '1';                   --Write
		STB_I <= '1';                   --Strobe
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		DAT_I <= x"0000";
		wait until rising_edge(CLK_I);
		DAT_I <= x"0000";               --Read from SPI input 
		ADR_I <= "001";                 --ADDR x1
		WE_I  <= '0';                   --Read
		STB_I <= '1';                   --Strobe
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		DAT_I <= x"0000";
		wait until rising_edge(CLK_I);
		DAT_I <= x"0000";               --Read from SPI input 
		ADR_I <= "010";                 --ADDR x2
		WE_I  <= '0';                   --Read
		STB_I <= '1';                   --Strobe
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		DAT_I <= x"0000";
		ADR_I <= "000";
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
