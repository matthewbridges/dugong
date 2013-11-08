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
-- Name:		RHINO TOP GPIO (002)
-- Type:		Top Level Module (F)
-- Description:		This is a top level module joining all cores and controllers to ports and 
--			top level signals. The addressing of cores is also done in this module.
--			This top level module has 1 master, the ARM, on-board GPIOs16 and on-board LEDs8
--
-- Compliance:		DUGONG V0.5
-- ID:			x 0-5-F-002
--
-- Last Modified:	08-NOV-2013
-- Modified By:		MATTHEW BRIDGES
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

entity rhino_top_gpio is
	generic(
		NUMBER_OF_MASTERS : NATURAL := 1;
		NUMBER_OF_SLAVES  : NATURAL := 3
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
		--USER GPIOs
		GPIO            : inout STD_LOGIC_VECTOR(15 downto 0);
		--USER LEDs
		LED             : inout STD_LOGIC_VECTOR(7 downto 0)
	);
end entity rhino_top_gpio;

architecture RTL of rhino_top_gpio is
	--------------------------------
	-- CLOCKING AND RESET CONTROL --
	--------------------------------
	signal sys_con_clk   : std_logic;
	signal sys_con_clk_n : std_logic;
	signal sys_con_rst   : std_logic;
	---------------------------
	-- Bussing Interconnects --
	---------------------------
	signal wb_ms_bus     : WB_MS_type;
	signal wb_ms         : WB_MS_vector(NUMBER_OF_MASTERS - 1 downto 0);
	signal wb_sm_bus     : WB_SM_type;
	signal wb_sm         : WB_SM_vector(NUMBER_OF_SLAVES - 1 downto 0);
	signal wb_gnt        : std_logic_vector(NUMBER_OF_MASTERS - 1 downto 0);

	signal debug_arm : DWORD_vector(3 downto 0);

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
			CLK_10MHz_P    => open,
			CLK_10MHz_N    => open
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
			DEBUG           => debug_arm(2),
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

	GPIOs_16 : gpio_ip
		GENERIC MAP(
			BASE_ADDR       => x"08000020",
			CORE_DATA_WIDTH => 16
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

	-------------------------
	---- DEBUGGING CORES ----
	-------------------------

	debug_latches : wb_multi_latch_ip
		generic map(
			BASE_ADDR => x"08F00000"
		)
		port map(
			CLK_I   => sys_con_clk,
			RST_I   => sys_con_rst,
			WB_MS   => wb_ms_bus,
			WB_SM   => wb_sm(2),
			LATCH_D => debug_arm
		);
		
		debug_arm(3) <= debug_arm(2);

end architecture RTL;
