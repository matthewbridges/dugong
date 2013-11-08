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
-- Name:		RHINO TOP GPIO FMC-CE(003)
-- Type:		Top Level Module (F)
-- Description:		This is the top level module joining all cores and controllers to ports and 
--			top level signals. The addressing of cores is also done in this module
--
-- Compliance:		DUGONG V0.5
-- ID:			x 0-5-F-003
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library unisim;
use unisim.vcomponents.all;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

library DUGONG_MASTER_Lib;
use DUGONG_MASTER_Lib.dcomponents.ALL;

library DUGONG_IP_CORE_Lib;
use DUGONG_IP_CORE_Lib.dcores.ALL;

entity rhino_top_gpio_fmcce_fmc150_dds is
	generic(
		NUMBER_OF_MASTERS : NATURAL := 1;
		NUMBER_OF_SLAVES  : NATURAL := 11
	);
	port(
		--System Control Inputs
		SYS_CLK_P       : in    STD_LOGIC;
		SYS_CLK_N       : in    STD_LOGIC;
		SYS_RST         : in    STD_LOGIC;
		--System Control Outputs
		--SYS_CLK_OUT_P   : out   STD_LOGIC;
		--SYS_CLK_OUT_N   : out   STD_LOGIC;
		SYS_PWR_ON      : out   STD_LOGIC;
		SYS_PLL_Locked  : out   STD_LOGIC;
		--GPMC Interface
		GPMC_CLK_I      : in    STD_LOGIC;
		GPMC_D_B        : inout STD_LOGIC_VECTOR(15 downto 0);
		GPMC_A_I        : in    STD_LOGIC_VECTOR(10 downto 1);
		GPMC_nCS_I      : in    STD_LOGIC_VECTOR(6 downto 0);
		GPMC_nADV_ALE_I : in    STD_LOGIC;
		GPMC_nWE_I      : in    STD_LOGIC;
		GPMC_nOE_I      : in    STD_LOGIC;
		GPMC_WAIT_O     : out   STD_LOGIC;
		--USER LEDs
		LED             : inout STD_LOGIC_VECTOR(7 downto 0);
		-- USER GPIOs
		GPIO            : inout STD_LOGIC_VECTOR(13 downto 0);
		--FMC-CE Peripherals
		FMCCE_LEDs8     : inout STD_LOGIC_VECTOR(7 downto 0);
		FMCCE_switches8 : inout STD_LOGIC_VECTOR(7 downto 0);
		FMCCE_LEDs5     : inout STD_LOGIC_VECTOR(4 downto 0);
		FMCCE_buttons5  : inout STD_LOGIC_VECTOR(4 downto 0);
		--FMC150 CTRL interface
		FMC150_CLK      : in    STD_LOGIC;
		SPI_SCLK_O      : out   STD_LOGIC;
		SPI_MOSI_O      : out   STD_LOGIC;
		ADC_MISO_I      : in    STD_LOGIC;
		ADC_N_SS_O      : out   STD_LOGIC;
		CDC_MISO_I      : in    STD_LOGIC;
		CDC_N_SS_O      : out   STD_LOGIC;
		DAC_MISO_I      : in    STD_LOGIC;
		DAC_N_SS_O      : out   STD_LOGIC;
		MON_MISO_I      : in    STD_LOGIC;
		MON_N_SS_O      : out   STD_LOGIC;
		FMC150_GPIO     : inout STD_LOGIC_VECTOR(7 downto 0);
		-- FMC150 ADC interface
		ADC_DCLK_P      : in    STD_LOGIC;
		ADC_DCLK_N      : in    STD_LOGIC;
		ADC_DATA_A_P    : in    STD_LOGIC_VECTOR(6 downto 0);
		ADC_DATA_A_N    : in    STD_LOGIC_VECTOR(6 downto 0);
		ADC_DATA_B_P    : in    STD_LOGIC_VECTOR(6 downto 0);
		ADC_DATA_B_N    : in    STD_LOGIC_VECTOR(6 downto 0);
		-- FMC150 DAC interface
		DAC_DCLK_P      : out   STD_LOGIC;
		DAC_DCLK_N      : out   STD_LOGIC;
		DAC_DATA_P      : out   STD_LOGIC_VECTOR(7 downto 0);
		DAC_DATA_N      : out   STD_LOGIC_VECTOR(7 downto 0);
		FRAME_P         : out   STD_LOGIC;
		FRAME_N         : out   STD_LOGIC;
		TXENABLE        : out   STD_LOGIC
	);
end entity rhino_top_gpio_fmcce_fmc150_dds;

architecture RTL of rhino_top_gpio_fmcce_fmc150_dds is
	--------------------------------
	-- CLOCKING AND RESET CONTROL --
	--------------------------------
	signal sys_con_clk   : std_logic;
	signal sys_con_clk_n : std_logic;
	signal sys_con_rst   : std_logic;
	signal clk_10MHz_P   : std_logic;
	signal clk_10MHz_N   : std_logic;
	---------------------------
	-- Bussing Interconnects --
	---------------------------
	signal wb_ms_bus     : WB_MS_type;
	signal wb_ms         : WB_MS_vector(NUMBER_OF_MASTERS - 1 downto 0);
	signal wb_sm_bus     : WB_SM_type;
	signal wb_sm         : WB_SM_vector(NUMBER_OF_SLAVES - 1 downto 0);
	signal wb_gnt        : std_logic_vector(NUMBER_OF_MASTERS - 1 downto 0);
	-----------------------
	-- Debugging Signals --
	-----------------------
	signal test_clocks1  : STD_LOGIC_VECTOR(2 downto 0);
	signal test_clocks2  : STD_LOGIC_VECTOR(2 downto 0);
	signal adc_clk       : std_logic;
	signal fmc150_clk_b  : std_logic;
	signal debug_arm     : DWORD_vector(3 downto 0);

	signal dds_ch_a : STD_LOGIC_VECTOR(15 downto 0);
	signal dds_ch_b : STD_LOGIC_VECTOR(15 downto 0);

	signal adc_ch_a : STD_LOGIC_VECTOR(15 downto 0);
	signal adc_ch_b : STD_LOGIC_VECTOR(15 downto 0);

	component ads62p49_parallelizer is
		port(
			--System Control Inputs
			RST_I        : in  STD_LOGIC;
			--Signal Channel Inputs
			ADC_CLK_O    : out STD_LOGIC;
			CH_A_O       : out STD_LOGIC_VECTOR(13 downto 0);
			CH_B_O       : out STD_LOGIC_VECTOR(13 downto 0);
			-- FMC150 ADC interface
			ADC_DCLK_P   : in  STD_LOGIC;
			ADC_DCLK_N   : in  STD_LOGIC;
			ADC_DATA_A_P : in  STD_LOGIC_VECTOR(6 downto 0);
			ADC_DATA_A_N : in  STD_LOGIC_VECTOR(6 downto 0);
			ADC_DATA_B_P : in  STD_LOGIC_VECTOR(6 downto 0);
			ADC_DATA_B_N : in  STD_LOGIC_VECTOR(6 downto 0)
		);
	end component ads62p49_parallelizer;

	component dac3283_serializer is
		port(
			--System Control Inputs
			RST_I      : in  STD_LOGIC;
			--Signal Channel Inputs
			DSP_CLK_I  : in  STD_LOGIC;
			CH_A_I     : in  STD_LOGIC_VECTOR(15 downto 0);
			CH_B_I     : in  STD_LOGIC_VECTOR(15 downto 0);
			-- DAC interface
			DAC_DCLK_P : out STD_LOGIC;
			DAC_DCLK_N : out STD_LOGIC;
			DAC_DATA_P : out STD_LOGIC_VECTOR(7 downto 0);
			DAC_DATA_N : out STD_LOGIC_VECTOR(7 downto 0);
			FRAME_P    : out STD_LOGIC;
			FRAME_N    : out STD_LOGIC;
			TXENABLE   : out STD_LOGIC;
			-- Testing
			IO_TEST_EN : in  STD_LOGIC
		);
	end component dac3283_serializer;

begin
	--------------------------------
	-- CLOCKING AND RESET CONTROL --
	--------------------------------

	System_Controller : sys_con
		port map(
			SYS_CLK_P      => SYS_CLK_P,
			SYS_CLK_N      => SYS_CLK_N,
			--SYS_CLK_OUT_P  => SYS_CLK_OUT_P,
			--SYS_CLK_OUT_N  => SYS_CLK_OUT_N,
			SYS_RST        => SYS_RST,
			SYS_PWR_ON     => SYS_PWR_ON,
			SYS_PLL_Locked => SYS_PLL_Locked,
			CLK_100MHz_P   => sys_con_clk,
			CLK_100MHz_N   => sys_con_clk_n,
			RST_O          => sys_con_rst,
			CLK_10MHz_P    => clk_10MHz_P,
			CLK_10MHz_N    => clk_10MHz_N
		);

	--------------------------
	-- ARM SIDE INTERFACING --
	--------------------------

	ARM_Interface : gpmc_wb_bridge
		port map(
			CLK_I           => sys_con_clk,
			RST_I           => sys_con_rst,
			WB_MS           => wb_ms(0),
			WB_SM           => wb_sm_bus,
			GNT_I           => wb_gnt(0),
			GPMC_CLK_I      => GPMC_CLK_I,
			GPMC_D_B        => GPMC_D_B,
			GPMC_A_I        => GPMC_A_I,
			GPMC_nCS_I      => GPMC_nCS_I,
			GPMC_nADV_ALE_I => GPMC_nADV_ALE_I,
			GPMC_nWE_I      => GPMC_nWE_I,
			GPMC_nOE_I      => GPMC_nOE_I,
			GPMC_WAIT_O     => GPMC_WAIT_O,
			DEBUG           => open,
			T_COUNT_O       => debug_arm(0),
			E_COUNT_O       => debug_arm(1)
		);

	---------------------------
	-- Bussing Interconnects --
	---------------------------

	WB_Intercon : wb_arbiter_intercon
		generic map(
			NUMBER_OF_MASTERS => NUMBER_OF_MASTERS,
			NUMBER_OF_SLAVES  => NUMBER_OF_SLAVES
		)
		port map(
			CLK_I     => sys_con_clk,
			RST_I     => sys_con_rst,
			WB_MS     => wb_ms,
			WB_MS_BUS => wb_ms_bus,
			WB_SM     => wb_sm,
			WB_SM_BUS => wb_sm_bus,
			WB_GNT_O  => wb_gnt
		);

	-----------------------
	-- Wishbone IP CORES --
	-----------------------

	LEDs_8 : gpio_ip
		generic map(
			BASE_ADDR       => x"08000000",
			CORE_DATA_WIDTH => 8
		)
		port map(
			CLK_I        => sys_con_clk,
			RST_I        => sys_con_rst,
			WB_MS        => wb_ms_bus,
			WB_SM        => wb_sm(0),
			GPIO_AUX_IN  => open,
			GPIO_AUX_OUT => (others => '0'),
			GPIO_B       => LED
		);

	GPIOs_14 : gpio_ip
		GENERIC MAP(
			BASE_ADDR       => x"08000020",
			CORE_DATA_WIDTH => 14
		)
		PORT MAP(
			CLK_I        => sys_con_clk,
			RST_I        => sys_con_rst,
			WB_MS        => wb_ms_bus,
			WB_SM        => wb_sm(1),
			GPIO_AUX_IN  => open,
			GPIO_AUX_OUT => (others => '0'),
			GPIO_B       => GPIO
		);

	FMC_CE_LEDs8 : gpio_ip
		GENERIC MAP(
			BASE_ADDR       => x"08001000",
			CORE_DATA_WIDTH => 8
		)
		PORT MAP(
			CLK_I        => sys_con_clk,
			RST_I        => sys_con_rst,
			WB_MS        => wb_ms_bus,
			WB_SM        => wb_sm(2),
			GPIO_AUX_IN  => open,
			GPIO_AUX_OUT => (others => '0'),
			GPIO_B       => FMCCE_LEDs8
		);

	FMC_CE_switches8 : gpio_ip
		GENERIC MAP(
			BASE_ADDR       => x"08001020",
			CORE_DATA_WIDTH => 8
		)
		PORT MAP(
			CLK_I        => sys_con_clk,
			RST_I        => sys_con_rst,
			WB_MS        => wb_ms_bus,
			WB_SM        => wb_sm(3),
			GPIO_AUX_IN  => open,
			GPIO_AUX_OUT => (others => '0'),
			GPIO_B       => FMCCE_switches8
		);

	FMC_CE_LEDs5 : gpio_ip
		GENERIC MAP(
			BASE_ADDR       => x"08001040",
			CORE_DATA_WIDTH => 5
		)
		PORT MAP(
			CLK_I        => sys_con_clk,
			RST_I        => sys_con_rst,
			WB_MS        => wb_ms_bus,
			WB_SM        => wb_sm(4),
			GPIO_AUX_IN  => open,
			GPIO_AUX_OUT => (others => '0'),
			GPIO_B       => FMCCE_LEDs5
		);

	FMC_CE_buttons5 : gpio_ip
		GENERIC MAP(
			BASE_ADDR       => x"08001060",
			CORE_DATA_WIDTH => 5
		)
		PORT MAP(
			CLK_I        => sys_con_clk,
			RST_I        => sys_con_rst,
			WB_MS        => wb_ms_bus,
			WB_SM        => wb_sm(5),
			GPIO_AUX_IN  => open,
			GPIO_AUX_OUT => (others => '0'),
			GPIO_B       => FMCCE_buttons5
		);

	------------------------------------
	---- ADVANCED WISHBONE IP CORES ----
	------------------------------------

	FMC150_Controller : fmc150_controller_ip
		generic map(
			BASE_ADDR => x"09000000"
		)
		port map(
			CLK_I       => sys_con_clk,
			RST_I       => sys_con_rst,
			WB_MS       => wb_ms_bus,
			WB_SM       => wb_sm(6),
			SPI_CLK_P_I => clk_10MHZ_P,
			SPI_CLK_N_I => clk_10MHZ_N,
			SPI_SCLK_O  => SPI_SCLK_O,
			SPI_MOSI_O  => SPI_MOSI_O,
			ADC_MISO_I  => ADC_MISO_I,
			ADC_N_SS_O  => ADC_N_SS_O,
			CDC_MISO_I  => CDC_MISO_I,
			CDC_N_SS_O  => CDC_N_SS_O,
			DAC_MISO_I  => DAC_MISO_I,
			DAC_N_SS_O  => DAC_N_SS_O,
			MON_MISO_I  => MON_MISO_I,
			MON_N_SS_O  => MON_N_SS_O,
			FMC150_GPIO => FMC150_GPIO,
			DEBUG       => open
		);

	------------------------------------
	---- DSP WISHBONE IP CORES ----
	------------------------------------

	dds : dds_ip
		generic map(
			BASE_ADDR => x"10000000"
		)
		port map(
			CLK_I     => sys_con_clk,
			RST_I     => sys_con_rst,
			WB_MS     => wb_ms_bus,
			WB_SM     => wb_sm(7),
			DSP_CLK_I => fmc150_clk_b,
			CH_A_O    => dds_ch_a,
			CH_B_O    => dds_ch_b
		);

	adc : ads62p49_parallelizer
		port map(
			RST_I        => sys_con_rst,
			ADC_CLK_O    => adc_clk,
			CH_A_O       => adc_ch_a(15 downto 2),
			CH_B_O       => adc_ch_b(15 downto 2),
			ADC_DCLK_P   => ADC_DCLK_P,
			ADC_DCLK_N   => ADC_DCLK_N,
			ADC_DATA_A_P => ADC_DATA_A_P,
			ADC_DATA_A_N => ADC_DATA_A_N,
			ADC_DATA_B_P => ADC_DATA_B_P,
			ADC_DATA_B_N => ADC_DATA_B_N
		);

	adc_ch_a(1 downto 0) <= "00";
	adc_ch_b(1 downto 0) <= "00";

	dac : dac3283_serializer
		port map(
			RST_I      => sys_con_rst,
			DSP_CLK_I  => fmc150_clk_b,
			CH_A_I     => dds_ch_a,
			CH_B_I     => adc_ch_b,
			DAC_DCLK_P => DAC_DCLK_P,
			DAC_DCLK_N => DAC_DCLK_N,
			DAC_DATA_P => DAC_DATA_P,
			DAC_DATA_N => DAC_DATA_N,
			FRAME_P    => FRAME_P,
			FRAME_N    => FRAME_N,
			TXENABLE   => TXENABLE,
			IO_TEST_EN => '0'
		);

	-------------------------
	---- DEBUGGING CORES ----
	-------------------------

	test_clocks1 <= clk_10MHz_P & clk_10MHz_N & sys_con_clk_n;

	clk_counter_1 : clk_counter_ip
		generic map(
			BASE_ADDR => x"07000000"
		)
		port map(
			CLK_I       => sys_con_clk,
			RST_I       => sys_con_rst,
			WB_MS       => wb_ms_bus,
			WB_SM       => wb_sm(8),
			TEST_CLOCKS => test_clocks1
		);

	FMC150_CLK_IBUFG : IBUFG
		generic map(
			IOSTANDARD => "LVCMOS33"
		)
		port map(
			O => fmc150_clk_b,
			I => FMC150_CLK
		);

	test_clocks2 <= adc_clk & fmc150_clk_b & sys_con_clk_n;

	clk_counter_2 : clk_counter_ip
		generic map(
			BASE_ADDR => x"07000020"
		)
		port map(
			CLK_I       => sys_con_clk,
			RST_I       => sys_con_rst,
			WB_MS       => wb_ms_bus,
			WB_SM       => wb_sm(9),
			TEST_CLOCKS => test_clocks2
		);

	debug_latches : wb_multi_latch_ip
		generic map(
			BASE_ADDR => x"08F00000"
		)
		port map(
			CLK_I   => sys_con_clk,
			RST_I   => sys_con_rst,
			WB_MS   => wb_ms_bus,
			WB_SM   => wb_sm(10),
			LATCH_D => debug_arm
		);

	debug_arm(2) <= dds_ch_b & dds_ch_a;
	debug_arm(3) <= adc_ch_a & adc_ch_b;

end architecture RTL;
