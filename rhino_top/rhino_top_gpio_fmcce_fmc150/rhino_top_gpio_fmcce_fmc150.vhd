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

entity rhino_top_gpio_fmcce_fmc150 is
	generic(
		NUMBER_OF_MASTERS : NATURAL := 1;
		NUMBER_OF_SLAVES  : NATURAL := 10
	);
	port(
		--System Control Inputs
		SYS_CLK_P       : in    STD_LOGIC;
		SYS_CLK_N       : in    STD_LOGIC;
		SYS_RST         : in    STD_LOGIC;
		--System Control Outputs
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
		FRAME_N         : out   STD_LOGIC
	);
end entity rhino_top_gpio_fmcce_fmc150;

architecture RTL of rhino_top_gpio_fmcce_fmc150 is
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
	signal debug_arm     : DWORD_vector(3 downto 0);
	-----------------------
	-- DSP Signals --
	-----------------------
	signal dsp_clk       : std_logic;
	signal dsp_clk_DIV4  : std_logic;

	signal dac_ready  : STD_LOGIC;
	signal fifo_rd_en : std_logic;

	signal dsp_packet_ch_a : STD_LOGIC_VECTOR(55 downto 0);
	signal dsp_packet_ch_b : STD_LOGIC_VECTOR(55 downto 0);

	component ads62p49_phy is
		generic(
			NUMBER_OF_SAMPLES : natural := 4
		);
		port(
			--System Control Inputs
			RST_I         : in  STD_LOGIC;
			--DSP Packet Signals
			DSP_CLK_I     : in  STD_LOGIC;
			DSP_CLK_DIV_I : in  STD_LOGIC;
			CH_A_PACKET_O : out STD_LOGIC_VECTOR((14 * NUMBER_OF_SAMPLES) - 1 downto 0);
			CH_A_EN_I     : in  STD_LOGIC;
			CH_A_VALID_O  : out STD_LOGIC;
			CH_B_PACKET_O : out STD_LOGIC_VECTOR((14 * NUMBER_OF_SAMPLES) - 1 downto 0);
			CH_B_EN_I     : in  STD_LOGIC;
			CH_B_VALID_O  : out STD_LOGIC;
			-- FMC150 ADC interface
			ADC_DCLK_P    : in  STD_LOGIC;
			ADC_DCLK_N    : in  STD_LOGIC;
			ADC_DATA_A_P  : in  STD_LOGIC_VECTOR(6 downto 0);
			ADC_DATA_A_N  : in  STD_LOGIC_VECTOR(6 downto 0);
			ADC_DATA_B_P  : in  STD_LOGIC_VECTOR(6 downto 0);
			ADC_DATA_B_N  : in  STD_LOGIC_VECTOR(6 downto 0)
		);
	end component;

	component dac3283_phy is
		generic(
			NUMBER_OF_SAMPLES : natural := 4
		);
		port(
			--System Control Inputs
			RST_I         : in  STD_LOGIC;
			--DSP Packet Signals
			DSP_CLK_O     : out STD_LOGIC;
			DSP_CLK_DIV_O : out STD_LOGIC;
			DAC_READY     : out STD_LOGIC;
			CH_A_PACKET_I : in  STD_LOGIC_VECTOR((14 * NUMBER_OF_SAMPLES) - 1 downto 0);
			CH_A_EN_I     : in  STD_LOGIC;
			CH_A_VALID_I  : in  STD_LOGIC;
			CH_B_PACKET_I : in  STD_LOGIC_VECTOR((14 * NUMBER_OF_SAMPLES) - 1 downto 0);
			CH_B_EN_I     : in  STD_LOGIC;
			CH_B_VALID_I  : in  STD_LOGIC;
			-- DAC interface
			FMC150_CLK    : in  STD_LOGIC;
			DAC_DCLK_P    : out STD_LOGIC;
			DAC_DCLK_N    : out STD_LOGIC;
			DAC_DATA_P    : out STD_LOGIC_VECTOR(7 downto 0);
			DAC_DATA_N    : out STD_LOGIC_VECTOR(7 downto 0);
			FRAME_P       : out STD_LOGIC;
			FRAME_N       : out STD_LOGIC;
			-- Testing
			IO_TEST_EN    : in  STD_LOGIC
		);
	end component;

begin
	--------------------------------
	-- CLOCKING AND RESET CONTROL --
	--------------------------------

	System_Controller : sys_con
		port map(
			SYS_CLK_P      => SYS_CLK_P,
			SYS_CLK_N      => SYS_CLK_N,
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

	process(dsp_clk_DIV4)
	begin
		--Perform Clock Rising Edge operations
		if (rising_edge(dsp_clk_DIV4)) then
			if (sys_con_rst = '1') then
				fifo_rd_en <= '0';
			else
				fifo_rd_en <= dac_ready;
			end if;
		end if;
	end process;

	adc : ads62p49_phy
		generic map(
			NUMBER_OF_SAMPLES => 4
		)
		port map(
			RST_I         => sys_con_rst,
			DSP_CLK_I     => dsp_clk,
			DSP_CLK_DIV_I => dsp_clk_DIV4,
			CH_A_PACKET_O => dsp_packet_ch_a,
			CH_A_EN_I     => fifo_rd_en,
			CH_A_VALID_O  => open,
			CH_B_PACKET_O => dsp_packet_ch_b,
			CH_B_EN_I     => fifo_rd_en,
			CH_B_VALID_O  => open,
			ADC_DCLK_P    => ADC_DCLK_P,
			ADC_DCLK_N    => ADC_DCLK_N,
			ADC_DATA_A_P  => ADC_DATA_A_P,
			ADC_DATA_A_N  => ADC_DATA_A_N,
			ADC_DATA_B_P  => ADC_DATA_B_P,
			ADC_DATA_B_N  => ADC_DATA_B_N
		);

	dac : dac3283_phy
		generic map(
			NUMBER_OF_SAMPLES => 4
		)
		port map(
			RST_I         => sys_con_rst,
			DSP_CLK_O     => dsp_clk,
			DSP_CLK_DIV_O => dsp_clk_DIV4,
			DAC_READY     => DAC_READY,
			CH_A_PACKET_I => dsp_packet_ch_a,
			CH_A_EN_I     => '1',
			CH_A_VALID_I  => '1',
			CH_B_PACKET_I => dsp_packet_ch_b,
			CH_B_EN_I     => '1',
			CH_B_VALID_I  => '1',
			FMC150_CLK    => FMC150_CLK,
			DAC_DCLK_P    => DAC_DCLK_P,
			DAC_DCLK_N    => DAC_DCLK_N,
			DAC_DATA_P    => DAC_DATA_P,
			DAC_DATA_N    => DAC_DATA_N,
			FRAME_P       => FRAME_P,
			FRAME_N       => FRAME_N,
			IO_TEST_EN    => '0'
		);

	-------------------------
	---- DEBUGGING CORES ----
	-------------------------

--	test_clocks1 <= clk_10MHz_P & clk_10MHz_N & sys_con_clk_n;
--
--	clk_counter_1 : clk_counter_ip
--		generic map(
--			BASE_ADDR => x"07000000"
--		)
--		port map(
--			CLK_I       => sys_con_clk,
--			RST_I       => sys_con_rst,
--			WB_MS       => wb_ms_bus,
--			WB_SM       => wb_sm(7),
--			TEST_CLOCKS => test_clocks1
--		);
--
--	test_clocks2 <= dsp_clk & dsp_clk_DIV4 & sys_con_clk_n;
--
--	clk_counter_2 : clk_counter_ip
--		generic map(
--			BASE_ADDR => x"07000020"
--		)
--		port map(
--			CLK_I       => sys_con_clk,
--			RST_I       => sys_con_rst,
--			WB_MS       => wb_ms_bus,
--			WB_SM       => wb_sm(8),
--			TEST_CLOCKS => test_clocks2
--		);

	debug_latches : wb_multi_latch_ip
		generic map(
			BASE_ADDR => x"08F00000"
		)
		port map(
			CLK_I   => sys_con_clk,
			RST_I   => sys_con_rst,
			WB_MS   => wb_ms_bus,
			WB_SM   => wb_sm(9),
			LATCH_D => debug_arm
		);

	debug_arm(2) <= debug_arm(0);
	debug_arm(3) <= debug_arm(1);

end architecture RTL;
