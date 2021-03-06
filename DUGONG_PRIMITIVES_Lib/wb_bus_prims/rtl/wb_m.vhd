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
-- Name:		WB_M (003)
-- Type:		PRIMITIVE (2)
-- Description:		A primitive for Wishbone masters which works as a front-end to the system. This primitive
--			controls monitors the arbiter grant signals, and ensures that only valid signals are
--			received by the master. This primitive also triggers timeouts and counts transfers.
--
-- Compliance:		DUGONG V0.3
-- ID:			x 0-3-2-003
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
		--Wishbone Master Interface (inverted)
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

	constant MAX_TRANSFER_CYCLES : natural := 8;

	signal cycle_count      : unsigned(3 downto 0);
	signal transfer_timeout : std_logic;

	signal transfer_complete : std_logic;
	signal transfer_failed   : std_logic;
	signal lock              : std_logic;

	signal transfer_count : unsigned(31 downto 0);
	signal error_count    : unsigned(31 downto 0);

begin
	CYCLE_COUNTER_proc : process(CLK_I) is
	begin
		if rising_edge(CLK_I) then
			if STB_O = '0' then
				cycle_count      <= (others => '0');
				transfer_timeout <= '0';
			else
				cycle_count <= cycle_count + 1;

				if (cycle_count > (MAX_TRANSFER_CYCLES - 1)) then
					transfer_timeout <= '1';
				else
					transfer_timeout <= '0';
				end if;
			end if;
		end if;
	end process CYCLE_COUNTER_proc;

	name : process(CLK_I) is
	begin
		if rising_edge(CLK_I) then
			if RST_I = '1' then
				transfer_complete <= '0';
				transfer_failed   <= '0';
				lock              <= '0';
			else
				if (STB_O = '1') then
					if ((ack_sm and GNT_I) = '1') then
						if (lock = '0') then
							transfer_complete <= '1';
							lock              <= '1';
						else
							transfer_complete <= '0';
						end if;
					elsif (transfer_timeout = '1') then
						if (lock = '0') then
							transfer_failed <= '1';
							lock            <= '1';
						else
							transfer_failed <= '0';
						end if;
					end if;
				else
					transfer_complete <= '0';
					transfer_failed   <= '0';
					lock              <= '0';
				end if;
			end if;
		end if;
	end process name;

	TRANSFER_COUNTERS_proc : process(CLK_I) is
	begin
		if rising_edge(CLK_I) then
			if RST_I = '1' then
				transfer_count <= (others => '0');
				error_count    <= (others => '0');
			else
				if (transfer_complete = '1') then
					transfer_count <= transfer_count + 1;
				end if;

				if (transfer_failed = '1') then
					error_count <= error_count + 1;
				end if;
			end if;
		end if;
	end process TRANSFER_COUNTERS_proc;

	process(CLK_I, RST_I)
	begin
		--RST STATE
		if (RST_I = '1') then
			ERR_I <= '0';
		else
			if (falling_edge(CLK_I)) then
				if (STB_O = '0') then
					ERR_I <= '0';
				else
					ERR_I <= transfer_timeout;
				end if;
			end if;
		end if;
	end process;

	T_COUNT_O <= std_logic_vector(transfer_count);
	E_COUNT_O <= std_logic_vector(error_count);

	--WB Output Ports
	WB_MS <= (CYC_O & STB_O & WE_O & DAT_O & ADR_O);

	--WB Input Ports
	DAT_I <= dat_sm;
	ACK_I <= ack_sm and GNT_I;

end Behavioral;

