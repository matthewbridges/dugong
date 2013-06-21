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
-- Name:		WB_M (003)
-- Type:		PRIMITIVE (2)
-- Description:		
--
-- Compliance:		DUGONG V1.4
-- ID:			x 1-4-2-004
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

--NB The DATA_WIDTH and ADDR_WIDTH constants are set in the dprimitives package
entity wb_m is
	port(
		--System Control Inputs
		CLK_I : in  STD_LOGIC;
		RST_I : in  STD_LOGIC;
		--Master to WB
		WB_MS : out WB_MS_type;
		WB_SM : in  WB_SM_type;
		--Wishbone Master Lines (inverted)
		ADR_O : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		DAT_I : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DAT_O : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		STB_O : in  STD_LOGIC;
		WE_O  : in  STD_LOGIC;
		ACK_I : out STD_LOGIC;
		CYC_O : in  STD_LOGIC;
		ERR_I : out STD_LOGIC;
		--Wishbone Arbitration Signal
		GNT_I : in  STD_LOGIC
	);
end wb_m;

architecture Behavioral of wb_m is
	alias dat_sm : std_logic_vector(DATA_WIDTH - 1 downto 0) is WB_SM(DATA_WIDTH - 1 downto 0);
	alias ack_sm : std_logic is WB_SM(DATA_WIDTH);

	signal count : unsigned(3 downto 0);

begin
	process(CLK_I, RST_I)
	begin
		--RST STATE
		if (RST_I = '1') then
			count <= x"0";
			ERR_I <= '0';
		else
			if (rising_edge(CLK_I)) then
				--CORRECT TERMINATION STATE
				if ((ack_sm and GNT_I) = '1') then
					count <= x"0";
					ERR_I <= '0';
				--TIMEOUT STATE
				elsif (count = 15) then
					count <= x"0";
					ERR_I <= '1';
				-- COUNTING STATE
				elsif (STB_O = '1') then
					count <= count + 1;
					ERR_I <= '0';
				end if;
			end if;
		end if;
	end process;

	--WB Output Ports
	WB_MS <= (CYC_O & STB_O & WE_O & DAT_O & ADR_O);

	--WB Input Ports
	DAT_I <= dat_sm;
	ACK_I <= ack_sm and GNT_I;

end Behavioral;

