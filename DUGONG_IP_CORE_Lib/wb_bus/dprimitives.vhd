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
-- Name:		DPRIMITIVES (002)
-- Type:		PACKAGE (1)
-- Description: 	A package containing primitives that are used by the DUGONG IP Cores	
--
-- Compliance:		DUGONG V1.1 (1-1)
-- ID:			x 1-1-1-002
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package dprimitives is
	constant DATA_WIDTH : natural := 32;
	constant ADDR_WIDTH : natural := 12;

	subtype WB_O_type is std_logic_vector(DATA_WIDTH downto 0);
	type WB_O_vector is array (natural range <>) of WB_O_type;

	subtype ADDR_type is unsigned(ADDR_WIDTH - 1 downto 0);

	constant DEFAULT_ADDR : ADDR_TYPE := (others => '0');

	------------------------------
	---- ARM SIDE INTERFACING ----
	------------------------------ 

	component gpmc_s
		generic(
			DATA_WIDTH      : natural               := 32;
			ADDR_WIDTH      : natural               := 25;
			BASE_ADDR       : UNSIGNED(27 downto 0) := x"0000000";
			CORE_DATA_WIDTH : NATURAL               := 16;
			CORE_ADDR_WIDTH : NATURAL               := 2
		);
		port(
			--ARM Slave Lines
			GPMC_MS : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
			GPMC_SM : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0)
		);
	end component gpmc_s;

	------------------------------
	---- WB SIDE INTERFACING ----
	------------------------------ 

	component wb_s is
		generic(
			DATA_WIDTH      : NATURAL               := 32;
			ADDR_WIDTH      : NATURAL               := 12;
			BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
			CORE_DATA_WIDTH : NATURAL               := 16;
			CORE_ADDR_WIDTH : NATURAL               := 3
		);
		port(
			--System Control Inputs
			CLK_I : in  STD_LOGIC;
			RST_I : in  STD_LOGIC;
			--Slave to WB
			WB_I  : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
			WB_O  : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
			--Wishbone Slave Lines (inverted)
			ADR_I : out STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0);
			DAT_I : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
			DAT_O : in  STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
			WE_I  : out STD_LOGIC;
			STB_I : out STD_LOGIC;
			ACK_O : in  STD_LOGIC;
			CYC_I : out STD_LOGIC
		);
	end component;

	component wb_register is
		generic(
			DATA_WIDTH   : NATURAL                       := 32;
			DEFAULT_DATA : STD_LOGIC_VECTOR(31 downto 0) := x"00000000"
		);
		port(
			--System Control Inputs:
			CLK_I : in  STD_LOGIC;
			RST_I : in  STD_LOGIC;
			--WISHBONE SLAVE interface:1-2
			DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			WE_I  : in  STD_LOGIC;
			--SEL_I : in  STD_LOGIC_VECTOR(DATA_WIDTH / 8 - 1 downto 0);
			STB_I : in  STD_LOGIC;
			ACK_O : out STD_LOGIC
		--CYC_I : in   STD_LOGIC;
		);
	end component;

	-------------------------
	---- Memory Elements ----
	-------------------------

	component bram_sync_sp is
		generic(
			DATA_WIDTH : natural := 32;
			ADDR_WIDTH : natural := 10
		);
		port(
			--PORT
			CLK_I : in  STD_LOGIC;
			DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			ADR_I : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
			WE_I  : in  STD_LOGIC
		);
	end component;

end package dprimitives;

package body dprimitives is
end package body dprimitives;