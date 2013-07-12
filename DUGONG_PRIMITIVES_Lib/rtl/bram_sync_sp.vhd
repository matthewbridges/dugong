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
-- Name:		BRAM_SYNC_SP (005)
-- Type:		PRIMITIVE (2)
-- Description:		A BRAM primitive with one ports which can take on generic data and address widths.
--			Takes advantage of FPGA on chip BRAMs
--
-- Compliance:		DUGONG V0.3
-- ID:			x 0-3-2-005
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bram_sync_sp is
	generic(
		DATA_WIDTH : natural := 32;
		ADDR_WIDTH : natural := 10
	);
	port(
		--System Control Inputs:
		CLK_I : in  STD_LOGIC;
		RST_I : in  STD_LOGIC;
		--PORT
		ADR_I : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		STB_I : in  STD_LOGIC;
		ACK_O : out STD_LOGIC;
		WE_I  : in  STD_LOGIC
	);
end bram_sync_sp;

architecture Behavioral of bram_sync_sp is
	--Shared memory
	type ram_type is array (0 to (2 ** ADDR_WIDTH) - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal mem : ram_type;
	signal mem_adr : unsigned(ADDR_WIDTH - 1 downto 0);
	signal ack     : std_logic;

begin
	process(CLK_I, RST_I, STB_I)
	begin
		--RESET STATE
		if (RST_I = '1') then
			ack <= '0';
		else
			if (STB_I = '0') then
				ack <= '0';
			else
				--Perform Clock Rising Edge operations
				if (rising_edge(CLK_I)) then
					--WRITING STATE
					if ((STB_I and WE_I) = '1') then
						mem(to_integer(unsigned(ADR_I))) <= DAT_I;
					end if;
					--READING STATE
					mem_adr <= unsigned(ADR_I);
					ack     <= STB_I;
				end if;
			end if;
		end if;
	end process;

	DAT_O <= mem(to_integer(mem_adr));
	ACK_O <= ack;

end Behavioral;

