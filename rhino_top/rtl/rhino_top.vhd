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
-- Name:		RHINO TOP (001)
-- Type:		Top Level Module (F)
-- Description:		This is the top level module joining all cores and controllers to ports and 
--			top level signals. The addressing of cores is also done in this module
--
-- Compliance:		DUGONG V1.3
-- ID:			x 1-3-F-001
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

library DUGONG_MASTER_Lib;
use DUGONG_MASTER_Lib.dcomponents.ALL;

library DUGONG_IP_CORE_Lib;
use DUGONG_IP_CORE_Lib.dcores.ALL;

--NB The DATA_WIDTH and ADDR_WIDTH constants are set in the dprimitives package
entity rhino_top is
	generic(
		NUMBER_OF_MASTERS : NATURAL := 2;
		NUMBER_OF_SLAVES  : NATURAL := 5
	);
	port(
		--System Control Inputs
		SYS_CLK_P       : in    STD_LOGIC;
		SYS_CLK_N       : in    STD_LOGIC;
		SYS_RST         : in    STD_LOGIC;
		--System Control Outputs
		SYS_CLK_o       : out   STD_LOGIC;
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
		--WB Status Signals
		WB_GNT_O        : out   STD_LOGIC_VECTOR(NUMBER_OF_MASTERS - 1 downto 0);
		-- USER GPIOs
		GPIO            : inout STD_LOGIC_VECTOR(15 downto 0);
		--USER LEDs
		LED             : inout STD_LOGIC_VECTOR(7 downto 0);
		--Debug GPIOs
		DEBUG           : inout STD_LOGIC_VECTOR(31 downto 0)
	);
end rhino_top;

architecture Behavioral of rhino_top is
	signal sys_con_clk   : std_logic;
	signal sys_con_clk_n : std_logic;
	signal sys_con_rst   : std_logic;
	signal wb_ms_bus     : WB_MS_type;
	signal wb_ms         : WB_MS_vector(NUMBER_OF_MASTERS - 1 downto 0);
	signal wb_sm_bus     : WB_SM_type;
	signal wb_sm         : WB_SM_vector(NUMBER_OF_SLAVES - 1 downto 0);
	signal wb_gnt        : std_logic_vector(NUMBER_OF_MASTERS - 1 downto 0);

	signal debug_top : std_logic_vector(31 downto 0);

begin
	--------------------------------
	-- CLOCKING AND RESET CONTROL --
	--------------------------------

	System_Controller : sys_con
		port map(
			SYS_CLK_P      => SYS_CLK_P,
			SYS_CLK_N      => SYS_CLK_N,
			SYS_CLK_o      => SYS_CLK_o,
			SYS_RST        => SYS_RST,
			SYS_PWR_ON     => SYS_PWR_ON,
			SYS_PLL_Locked => SYS_PLL_Locked,
			CLK_100MHZ     => sys_con_clk,
			CLK_100MHZ_n   => sys_con_clk_n,
			RST_O          => sys_con_rst
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
			DEBUG           => debug_top,
			T_COUNT_O       => open,
			E_COUNT_O       => open
		);

	------------
	-- DUGONG --
	------------

	Central_Control_Unit : dugong_controller
		port map(
			CLK_I     => sys_con_clk,
			CLK_I_n   => sys_con_clk_n,
			RST_I     => sys_con_rst,
			WB_MS     => wb_ms(1),
			WB_SM     => wb_sm_bus,
			GNT_I     => wb_gnt(1),
			T_COUNT_O => open,
			E_COUNT_O => open
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

	WB_GNT_O <= wb_gnt;

	---------------------
	-- DUGONG IP CORES --
	---------------------

	Block_RAM_1 : bram_ip
		generic map(
			BASE_ADDR       => x"04000000",
			CORE_DATA_WIDTH => 32,
			CORE_ADDR_WIDTH => 16
		)
		port map(
			CLK_I => sys_con_clk,
			RST_I => sys_con_rst,
			WB_MS => wb_ms_bus,
			WB_SM => wb_sm(0)
		);

	LEDs_8 : gpio_controller_ip
		generic map(
			BASE_ADDR       => x"08003C00",
			CORE_DATA_WIDTH => 8
		)
		port map(
			CLK_I      => sys_con_clk,
			RST_I      => sys_con_rst,
			WB_MS      => wb_ms_bus,
			WB_SM      => wb_sm(1),
			GPIO_AUX_O => open,
			GPIO_AUX_I => (others => '0'),
			GPIO_B     => LED
		);

	GPIOs_16 : gpio_controller_ip
		GENERIC MAP(
			BASE_ADDR       => x"08003C20",
			CORE_DATA_WIDTH => 16
		)
		PORT MAP(
			CLK_I      => sys_con_clk,
			RST_I      => sys_con_rst,
			WB_MS      => wb_ms_bus,
			WB_SM      => wb_sm(2),
			GPIO_AUX_O => open,
			GPIO_AUX_I => (others => '0'),
			GPIO_B     => GPIO
		);

	Debug_32 : gpio_controller_ip
		GENERIC MAP(
			BASE_ADDR       => x"08003C40",
			CORE_DATA_WIDTH => 32
		)
		PORT MAP(
			CLK_I      => sys_con_clk,
			RST_I      => sys_con_rst,
			WB_MS      => wb_ms_bus,
			WB_SM      => wb_sm(3),
			GPIO_AUX_O => open,
			GPIO_AUX_I => debug_top,
			GPIO_B     => DEBUG
		);

	test : wb_test_slave_ip
		generic map(
			BASE_ADDR => x"10000000"
		)
		port map(
			CLK_I => sys_con_clk,
			RST_I => sys_con_rst,
			WB_MS => wb_ms_bus,
			WB_SM => wb_sm(4)
		);

end Behavioral;