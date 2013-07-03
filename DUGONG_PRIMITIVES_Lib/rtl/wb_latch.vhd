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
-- Name:		WB_LATCH (009)
-- Type:		PRIMITIVE (2)
-- Description:		A latch primitive with one port which can take on generic data widths and default values.
--
-- Compliance:		DUGONG V0.3
-- ID:			x 0-3-2-009
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity wb_latch is
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
		STB_I : in  STD_LOGIC;
		ACK_O : out STD_LOGIC
	);
end wb_latch;

architecture Behavioral of wb_latch is
	signal Q   : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal ack : std_logic;

begin
	process(CLK_I, RST_I, STB_I)
	begin
		--RST STATE
		if (RST_I = '1') then
			Q   <= DEFAULT_DATA(DATA_WIDTH - 1 downto 0);
			ack <= '0';
		else
			if (STB_I = '0') then
				ack <= '0';
			else
				--Perform Clock Rising Edge operations
				if (rising_edge(CLK_I)) then
					--WRITING STATE
					Q   <= DAT_I;
					ack <= STB_I;
				end if;
			end if;
		end if;
	end process;

	DAT_O <= Q;
	ACK_O <= ack;

end Behavioral;
