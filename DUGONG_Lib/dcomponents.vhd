--                    
-- _______/\\\\\\\\\_______/\\\________/\\\____/\\\\\\\\\\\____/\\\\\_____/\\\_________/\\\\\_________     
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
-- Name:		DCOMPONENTS (003)
-- Type:		PACKAGE (1)
-- Description: 	A package containing components that are used by the DUGONG controller	
--
-- Compliance:		DUGONG V1.1 (1-1)
-- ID:			x 1-1-1-003
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

package dcomponents is
	component sys_con
		port(
			--System Clock Differential Inputs 100MHz
			SYS_CLK_P      : in  STD_LOGIC;
			SYS_CLK_N      : in  STD_LOGIC;
			--System Clock Differential Outputs 100MHz
			SYS_CLK_o      : out STD_LOGIC;
			--System Reset Input
			SYS_RST        : in  STD_LOGIC;
			--System Status
			SYS_PWR_ON     : out STD_LOGIC;
			SYS_PLL_Locked : out STD_LOGIC;
			--System Control Outputs
			CLK_100MHZ     : out STD_LOGIC;
			CLK_100MHZ_n   : out STD_LOGIC;
			RST_O          : out STD_LOGIC
		);
	end component;

	component gpmc_wb_bridge is
		port(
			--System Control Inputs
			CLK_I           : in    STD_LOGIC;
			RST_I           : in    STD_LOGIC;
			--Master to WB
			WB_MS           : out   WB_MS_type;
			WB_SM           : in    WB_SM_type;
			GNT_I           : in    STD_LOGIC;
			--GPMC Interface
			GPMC_CLK_I      : in    STD_LOGIC;
			GPMC_D_B        : inout STD_LOGIC_VECTOR(15 downto 0);
			GPMC_A_I        : in    STD_LOGIC_VECTOR(10 downto 1);
			GPMC_nCS_I      : in    STD_LOGIC_VECTOR(6 downto 0);
			GPMC_nADV_ALE_I : in    STD_LOGIC;
			GPMC_nWE_I      : in    STD_LOGIC;
			GPMC_nOE_I      : in    STD_LOGIC;
			GPMC_WAIT_O     : out   STD_LOGIC;
			--Debugging Signal
			DEBUG           : out   STD_LOGIC_VECTOR(31 downto 0)
		);
	end component;

	component dugong_controller
		port(
			--System Control Inputs
			CLK_I   : in  STD_LOGIC;
			CLK_I_n : in  STD_LOGIC;
			RST_I   : in  STD_LOGIC;
			--Master to WB
			WB_MS   : out WB_MS_type;
			WB_SM   : in  WB_SM_type;
			GNT_I   : in  STD_LOGIC
		);
	end component;

end package dcomponents;

package body dcomponents is
end package body dcomponents;
