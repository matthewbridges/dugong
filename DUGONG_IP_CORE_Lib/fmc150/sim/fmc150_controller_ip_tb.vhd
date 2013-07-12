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
-- Engineer:		MATTHEW BRIDGES
--
-- Name:		FMC150_CONTROLLER_IP_TB 
-- Type:		TB (F)
-- Description:
--
-- Compliance:		DUGONG V1.4
-- ID:			x 1-4-F
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

entity fmc150_controller_ip_tb IS
end fmc150_controller_ip_tb;

architecture Behavioral of fmc150_controller_ip_tb is

	-- Component Declaration for the Unit Under Test (UUT)
	component fmc150_controller_ip
		generic(
			BASE_ADDR       : UNSIGNED(ADDR_WIDTH + 3 downto 0) := x"00000000";
			CORE_DATA_WIDTH : NATURAL                           := 32;
			CORE_ADDR_WIDTH : NATURAL                           := 4
		);
		port(
			CLK_I          : in  STD_LOGIC;
			RST_I          : in  STD_LOGIC;
			WB_MS          : in  WB_MS_type;
			WB_SM          : out WB_SM_type;
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
			DEBUG          : out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component fmc150_controller_ip;

	--System Control Inputs:
	signal CLK_I : std_logic := '0';
	signal RST_I : std_logic := '1';

	--Slave to WB
	signal WB_MS : WB_MS_type := (others => '0');
	signal WB_SM : WB_SM_type;

	--FMC SPI Interface
	signal SPI_CLK_P_I    : STD_LOGIC := '0';
	signal SPI_CLK_N_I    : STD_LOGIC := '1';
	signal SPI_SCLK_O     : STD_LOGIC;
	signal SPI_MOSI_O     : STD_LOGIC;
	signal ADC_MISO_I     : STD_LOGIC := '0';
	signal ADC_N_SS_O     : STD_LOGIC;
	signal CDC_MISO_I     : STD_LOGIC := '0';
	signal CDC_N_SS_O     : STD_LOGIC;
	signal DAC_MISO_I     : STD_LOGIC := '0';
	signal DAC_N_SS_O     : STD_LOGIC;
	signal ADC_RST        : STD_LOGIC;
	signal CDC_REF_EN     : STD_LOGIC;
	signal CDC_N_RST      : STD_LOGIC;
	signal CDC_N_PD       : STD_LOGIC;
	signal CDC_PLL_STATUS : STD_LOGIC;
	signal DEBUG          : STD_LOGIC_VECTOR(15 downto 0);

	-- Clock period definitions
	constant CLK_I_period     : time := 10 ns;
	constant SPI_CLK_I_period : time := 320 ns;

begin

	-- Instantiate the Unit Under Test (UUT)
	uut : fmc150_controller_ip
		port map(
			CLK_I          => CLK_I,
			RST_I          => RST_I,
			WB_MS          => WB_MS,
			WB_SM          => WB_SM,
			SPI_CLK_P_I    => SPI_CLK_P_I,
			SPI_CLK_N_I    => SPI_CLK_N_I,
			SPI_SCLK_O     => SPI_SCLK_O,
			SPI_MOSI_O     => SPI_MOSI_O,
			ADC_MISO_I     => ADC_MISO_I,
			ADC_N_SS_O     => ADC_N_SS_O,
			CDC_MISO_I     => CDC_MISO_I,
			CDC_N_SS_O     => CDC_N_SS_O,
			DAC_MISO_I     => DAC_MISO_I,
			DAC_N_SS_O     => DAC_N_SS_O,
			ADC_RST        => ADC_RST,
			CDC_REF_EN     => CDC_REF_EN,
			CDC_N_RST      => CDC_N_RST,
			CDC_N_PD       => CDC_N_PD,
			CDC_PLL_STATUS => CDC_PLL_STATUS,
			DEBUG          => DEBUG
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
		SPI_CLK_P_I <= '0';
		SPI_CLK_N_I <= '1';
		wait for SPI_CLK_I_period / 2;
		SPI_CLK_P_I <= '1';
		SPI_CLK_N_I <= '0';
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
		WB_MS <= "111" & x"FEDC1234" & x"0000004"; --Write xFEDCAB98 to 004
		wait until rising_edge(WB_SM(DATA_WIDTH));
		wait until rising_edge(CLK_I);
		WB_MS <= "000" & x"00000000" & x"0000000"; --NULL

		wait until rising_edge(CLK_I);
		WB_MS <= "111" & x"FEDC5678" & x"0000004"; --Write xFEDCAB98 to 004
		wait until rising_edge(WB_SM(DATA_WIDTH));
		wait until rising_edge(CLK_I);
		WB_MS <= "000" & x"00000000" & x"0000000"; --NULL

		wait until rising_edge(CLK_I);
		WB_MS <= "111" & x"FEDC8765" & x"000000C"; --Write xFEDCAB98 to 004
		wait until rising_edge(WB_SM(DATA_WIDTH));
		wait until rising_edge(CLK_I);
		WB_MS <= "000" & x"00000000" & x"0000000"; --NULL

		wait until rising_edge(CLK_I);
		WB_MS <= "111" & x"FEDC4321" & x"0000014"; --Write xFEDCAB98 to 004
		wait until rising_edge(WB_SM(DATA_WIDTH));
		wait until rising_edge(CLK_I);
		WB_MS <= "000" & x"00000000" & x"0000000"; --NULL

		wait;
	end process;

end;
