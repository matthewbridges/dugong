--  
--                    
-- _____/\\\\\\\\\_______/\\\________/\\\____/\\\\\\\\\\\____/\\\\\_____/\\\_________/\\\\\_______      
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
-- Name:		DCOMPONENTS (003)
-- Type:		PACKAGE (1)
-- Description: 	A package containing components that are used by the DUGONG controller	
--
-- Compliance:		DUGONG V1.1 (1-1)
-- ID:			x 1-1-1-003
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package dcomponents is
	subtype WB_O_type is std_logic_vector(32 downto 0);
	type WB_O_vector is array (natural range <>) of WB_O_type;

	component wb_m is
		generic(
			DATA_WIDTH : natural := 32;
			ADDR_WIDTH : natural := 12
		);
		port(
			--System Control Inputs
			--		CLK_I : in  STD_LOGIC;
			--		RST_I : in  STD_LOGIC;
			--Master to WB
			WB_MS : out STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
			WB_SM : in  STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
			--Wishbone Master Lines (inverted)
			DAT_I : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			DAT_O : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			ADR_O : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
			STB_O : in  STD_LOGIC;
			WE_O  : in  STD_LOGIC;
			CYC_O : in  STD_LOGIC;
			ACK_I : out STD_LOGIC
		);
	end component;

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
	end component sys_con;

	component dugong_controller
		generic(
			DATA_WIDTH : natural := 32;
			ADDR_WIDTH : natural := 12
		);
		port(
			--System Control Inputs
			CLK_I   : in  STD_LOGIC;
			CLK_I_n : in  STD_LOGIC;
			RST_I   : in  STD_LOGIC;
			--Master to WB
			WB_I    : in  STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
			WB_O    : out STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0)
		);
	end component;

end package dcomponents;

package body dcomponents is
end package body dcomponents;
