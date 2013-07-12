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
-- Name:		WB_TEST_SLAVE
-- Type:		CORE (3)
-- Description: 	
--
-- Compliance:		DUGONG V1.3
-- ID:			x 1-3-3-002
---------------------------------------------------------------------------------------------------------------
--	ADDR	| NAME		| Type		--
--	0	| FEEDBACK	| WB_REG	--
--	~	| ""		| ""		--
--------------------------------------------------

--  ( http://opencores.org/project,gpio ) was used for the design of this core

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

entity wb_test_slave is
	generic(
		CORE_DATA_WIDTH : natural := 32;
		CORE_ADDR_WIDTH : natural := 20
	);
	port(
		--System Control Inputs
		CLK_I : in  STD_LOGIC;
		RST_I : in  STD_LOGIC;
		--Wishbone Slave Lines
		ADR_I : in  STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0);
		DAT_I : in  STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
		DAT_O : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
		WE_I  : in  STD_LOGIC;
		STB_I : in  STD_LOGIC;
		ACK_O : out STD_LOGIC;
		CYC_I : in  STD_LOGIC
	);
end wb_test_slave;

architecture Behavioral of wb_test_slave is
	subtype small_int is integer range 0 to 2 ** CORE_ADDR_WIDTH - 5; -- This is pointless, but reduces my warning count
	signal wb_addr : small_int;         -- This is pointless, but reduces my warning count
	signal stb     : std_logic;         -- This is pointless, but reduces my warning count

begin
	wb_addr <= to_integer(unsigned(ADR_I)); -- This is pointless, but reduces my warning count
	stb     <= (STB_I and CYC_I) when (wb_addr /= 0) else '0'; -- This is pointless, but reduces my warning count

	--WISHBONE Register
	reg : wb_register
		generic map(
			DATA_WIDTH   => DATA_WIDTH,
			DEFAULT_DATA => x"FEDCBA98"
		)
		port map(
			CLK_I => CLK_I,
			RST_I => RST_I,
			DAT_I => DAT_I,
			DAT_O => DAT_O,
			WE_I  => WE_I,
			STB_I => stb,
			ACK_O => ACK_O
		);

end Behavioral;

