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
		CLK_I     : in  STD_LOGIC;
		RST_I     : in  STD_LOGIC;
		--Master to WB
		WB_MS     : out WB_MS_type;
		WB_SM     : in  WB_SM_type;
		--Wishbone Master Lines (inverted)
		ADR_O     : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		DAT_I     : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DAT_O     : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		WE_O      : in  STD_LOGIC;
		STB_O     : in  STD_LOGIC;
		ACK_I     : out STD_LOGIC;
		CYC_O     : in  STD_LOGIC;
		--Wishbone Error Signal
		ERR_I     : out STD_LOGIC;
		--Wishbone Arbitration Signal
		GNT_I     : in  STD_LOGIC;
		--STATUS SIGNALS
		T_COUNT_O : out STD_LOGIC_VECTOR(31 downto 0);
		E_COUNT_O : out STD_LOGIC_VECTOR(31 downto 0)
	);
end wb_m;

architecture Behavioral of wb_m is
	alias dat_sm : std_logic_vector(DATA_WIDTH - 1 downto 0) is WB_SM(DATA_WIDTH - 1 downto 0);
	alias ack_sm : std_logic is WB_SM(DATA_WIDTH);

	signal cycle_count : unsigned(3 downto 0);
	signal error       : std_logic;

	signal transfer_count : unsigned(31 downto 0);
	signal error_count    : unsigned(31 downto 0);
	signal lock           : std_logic;

begin
	process(CLK_I, RST_I, STB_O, error)
	begin
		--RST STATE
		if (RST_I = '1') then
			cycle_count    <= (others => '0');
			error          <= '0';
			transfer_count <= (others => '0');
			error_count    <= (others => '0');
			lock           <= '0';
		else
			if ((STB_O = '0') and (error = '1')) then
				cycle_count <= (others => '0');
				error       <= '0';
				lock        <= '0';
			else
				if (rising_edge(CLK_I)) then
					--CORRECT TERMINATION STATE
					if ((ack_sm and GNT_I) = '1') then
						cycle_count <= (others => '0');
						error       <= '0';
						if (lock = '0') then
							transfer_count <= transfer_count + 1;
							lock           <= '1';
						end if;
					--TIMEOUT STATE
					elsif (cycle_count = 10) then
						error <= '1';
						if (lock = '0') then
							error_count <= error_count + 1;
							lock        <= '1';
						end if;
					-- COUNTING STATE
					elsif (STB_O = '1') then
						cycle_count <= cycle_count + 1;
						error       <= '0';
						lock        <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;

	ERR_I <= error;

	T_COUNT_O <= std_logic_vector(transfer_count);
	E_COUNT_O <= std_logic_vector(error_count);

	--WB Output Ports
	WB_MS <= (CYC_O & STB_O & WE_O & DAT_O & ADR_O);

	--WB Input Ports
	DAT_I <= dat_sm;
	ACK_I <= ack_sm and GNT_I;

end Behavioral;

