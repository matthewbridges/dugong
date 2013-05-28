---------------------------------------------------------------------------------------------------------------
--                    
--______/\\\\\\\\\_______/\\\________/\\\____/\\\\\\\\\\\____/\\\\\_____/\\\_________/\\\\\________      
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
-- Name:		RHINO TOP (001)
-- Type:		Top Level Module (F)
-- Description:		This is the top level module joining all cores and controllers to ports and top level signals	
--			The addressing of cores is also done in this module
--
-- Compliance:		DUGONG V1.1
-- ID:			x 1-1-F-001
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library dugong_lib;
use dugong_lib.dcomponents.ALL;

library DUGONG_IP_CORE_Lib;
use DUGONG_IP_CORE_Lib.dcores.ALL;

entity rhino_top is
	generic(
		DATA_WIDTH      : natural := 32;
		ADDR_WIDTH      : natural := 12;
		NUMBER_OF_CORES : NATURAL := 4
	);
	port(
		--System Control Inputs
		SYS_CLK_P      : in    STD_LOGIC;
		SYS_CLK_N      : in    STD_LOGIC;
		SYS_RST        : in    STD_LOGIC;
		--System Control Outputs
		SYS_CLK_o      : out   STD_LOGIC;
		SYS_PWR_ON     : out   STD_LOGIC;
		SYS_PLL_Locked : out   STD_LOGIC;
		-- USER GPIOs
		GPIO           : inout STD_LOGIC_VECTOR(15 downto 0);
		--USER LEDs
		LED            : inout STD_LOGIC_VECTOR(7 downto 0);
		--Debug GPIOs
		DEBUG          : inout STD_LOGIC_VECTOR(31 downto 0)
	);
end rhino_top;

architecture Behavioral of rhino_top is
	signal sys_con_clk   : std_logic;
	signal sys_con_clk_n : std_logic;
	signal sys_con_rst   : std_logic;
	signal wb_ms         : std_logic_vector(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
	signal wb_sm_bus     : std_logic_vector(DATA_WIDTH downto 0);
	signal wb_sm         : WB_O_vector(NUMBER_OF_CORES - 1 downto 0);

begin
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

	Central_Control_Unit : dugong_controller
		generic map(DATA_WIDTH => DATA_WIDTH,
			    ADDR_WIDTH => ADDR_WIDTH
		)
		port map(
			CLK_I   => sys_con_clk,
			CLK_I_n => sys_con_clk_n,
			RST_I   => sys_con_rst,
			WB_I    => wb_sm_bus,
			WB_O    => wb_ms
		);

	wb_sm_bus <= wb_sm(0) or wb_sm(1) or wb_sm(2) or wb_sm(3);

	---------------------
	-- DUGONG IP CORES --
	---------------------

	Block_RAM_1 : bram_ip
		generic map(
			DATA_WIDTH => DATA_WIDTH,
			ADDR_WIDTH => ADDR_WIDTH,
			BASE_ADDR  => x"E00"
		)
		port map(
			CLK_I => sys_con_clk,
			RST_I => sys_con_rst,
			WB_I  => wb_ms,
			WB_O  => wb_sm(0)
		);

	LEDs_8 : gpio_controller_ip
		generic map(DATA_WIDTH      => DATA_WIDTH,
			    ADDR_WIDTH      => ADDR_WIDTH,
			    BASE_ADDR       => x"F00",
			    CORE_DATA_WIDTH => 8
		)
		port map(
			CLK_I => sys_con_clk,
			RST_I => sys_con_rst,
			WB_I  => wb_ms,
			WB_O  => wb_sm(1),
			GPIO  => LED
		);

	GPIOs_16 : gpio_controller_ip
		GENERIC MAP(
			DATA_WIDTH      => DATA_WIDTH,
			ADDR_WIDTH      => ADDR_WIDTH,
			BASE_ADDR       => x"F08",
			CORE_DATA_WIDTH => 16
		)
		PORT MAP(
			CLK_I => sys_con_clk,
			RST_I => sys_con_rst,
			WB_I  => wb_ms,
			WB_O  => wb_sm(2),
			GPIO  => GPIO
		);

	Debug_32 : gpio_controller_ip
		GENERIC MAP(
			DATA_WIDTH      => DATA_WIDTH,
			ADDR_WIDTH      => ADDR_WIDTH,
			BASE_ADDR       => x"F10",
			CORE_DATA_WIDTH => 32
		)
		PORT MAP(
			CLK_I => sys_con_clk,
			RST_I => sys_con_rst,
			WB_I  => wb_ms,
			WB_O  => wb_sm(3),
			GPIO  => DEBUG
		);

end Behavioral;

