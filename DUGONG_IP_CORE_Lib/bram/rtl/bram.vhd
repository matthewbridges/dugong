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
-- Name:		BRAM (001)
-- Type:		CORE (3)
-- Description: 	A core containing BRAM/s which can be used for temporary storage of general data	
--
-- Compliance:		DUGONG V1.4
-- ID:			x 1-4-3-001
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

entity bram is
	generic(
		DATA_WIDTH : natural := 32;
		ADDR_WIDTH : natural := 10
	);
	port(
		--System Control Inputs
		CLK_I : in  STD_LOGIC;
		RST_I : in  STD_LOGIC;
		--Wishbone Slave Lines
		ADR_I : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		WE_I  : in  STD_LOGIC;
		STB_I : in  STD_LOGIC;
		ACK_O : out STD_LOGIC;
		CYC_I : in  STD_LOGIC
	);
end bram;

architecture Behavioral of bram is
	signal stb : std_logic;
begin
	stb <= STB_I and CYC_I;

	mem : bram_sync_sp
		generic map(
			DATA_WIDTH => DATA_WIDTH,
			ADDR_WIDTH => ADDR_WIDTH
		)
		port map(
			CLK_I => CLK_I,
			RST_I => RST_I,
			ADR_I => ADR_I,
			DAT_I => DAT_I,
			DAT_O => DAT_O,
			STB_I => stb,
			ACK_O => ACK_O,
			WE_I  => WE_I
		);

end Behavioral;

	