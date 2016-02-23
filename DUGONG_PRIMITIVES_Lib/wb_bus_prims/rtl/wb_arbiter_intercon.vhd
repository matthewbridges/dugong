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
-- Name:		WB_ARBITER_INTERCON (004)
-- Type:		PRIMITIVE (2)
-- Description:		This primitive is used to Arbitrate between masters in a multi-master system. It is also
--			used to connect up the multiple slaves. The CYC_O signals from the masters are used to 
--			trigger the Arbiter. The WB_GNT_O signal is used to grant the master rights to the bus.
--
-- Compliance:		DUGONG V0.3
-- ID:			x 0-3-2-004
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

--NB The DATA_WIDTH and ADDR_WIDTH constants are set in the dprimitives package
entity wb_arbiter_intercon is
	generic(
		NUMBER_OF_MASTERS : NATURAL := 2;
		NUMBER_OF_SLAVES  : NATURAL := 3
	);
	port(
		--System Control Inputs
		CLK_I     : in  STD_LOGIC;
		RST_I     : in  STD_LOGIC;
		--Masters to WB
		WB_MS     : in  WB_MS_vector(NUMBER_OF_MASTERS - 1 downto 0);
		WB_MS_BUS : out WB_MS_type;
		--Slaves to WB
		WB_SM     : in  WB_SM_vector(NUMBER_OF_SLAVES - 1 downto 0);
		WB_SM_BUS : out WB_SM_type;
		--Master Arbitration
		WB_GNT_O  : out STD_LOGIC_VECTOR(NUMBER_OF_MASTERS - 1 downto 0)
	);
end wb_arbiter_intercon;

architecture Behavioral of wb_arbiter_intercon is
	signal wb_cyc : std_logic_vector(NUMBER_OF_MASTERS - 1 downto 0);

	subtype master_num is natural range 0 to NUMBER_OF_MASTERS - 1;
	signal master_sel : master_num := 0;

	signal bus_busy : std_logic := '0';

	signal temp_sm : WB_SM_vector(NUMBER_OF_SLAVES - 1 downto 0);

begin
	single_master_system : if NUMBER_OF_MASTERS = 1 generate
	begin
		WB_GNT_O(0) <= '1';
		WB_MS_BUS   <= WB_MS(0);
	end generate single_master_system;

	multi_master_system : if NUMBER_OF_MASTERS > 1 generate
	begin
		--Generate wb_cyc registers
		wb_cyc_registers : for i in 0 to NUMBER_OF_MASTERS - 1 generate
		begin
			wb_cyc(i) <= WB_MS(i)(2 + ADDR_WIDTH + DATA_WIDTH);
		end generate wb_cyc_registers;

		--Arbiter
		process(CLK_I, RST_I)
		begin
			--RST STATE
			if (RST_I = '1') then
				bus_busy   <= '0';
				master_sel <= 0;
				WB_GNT_O   <= (others => '0');
			else
				--Perform Rising Edge operations
				if (falling_edge(CLK_I)) then
					if (bus_busy = '0') then
						--Give bus to Master = master_sel if it wants it
						if (wb_cyc(master_sel) = '1') then
							WB_GNT_O(master_sel) <= '1';
							bus_busy             <= '1';
						end if;
					elsif (wb_cyc(master_sel) = '0') then
						bus_busy <= '0';
						WB_GNT_O <= (others => '0');
					end if;
				end if;

				if (rising_edge(CLK_I)) then
					if (bus_busy = '0') then
						--Increment master_sel
						if (master_sel = NUMBER_OF_MASTERS - 1) then
							master_sel <= 0;
						else
							master_sel <= master_sel + 1;
						end if;
					end if;
				end if;
			end if;
		end process;

		name : process(CLK_I) is
		begin
			if rising_edge(CLK_I) then
				if (bus_busy = '0') then
					WB_MS_BUS(2 + ADDR_WIDTH + DATA_WIDTH downto ADDR_WIDTH + DATA_WIDTH) <= (others => '0');
				else
					WB_MS_BUS(2 + ADDR_WIDTH + DATA_WIDTH downto ADDR_WIDTH + DATA_WIDTH) <= WB_MS(master_sel)(2 + ADDR_WIDTH + DATA_WIDTH downto ADDR_WIDTH + DATA_WIDTH);
				end if;
				WB_MS_BUS <= WB_MS(master_sel);
			end if;
		end process name;

	end generate multi_master_system;

	--Create OR-Gate Tree for Wishbone Slave to Master Lines
	temp_sm(0) <= WB_SM(0);
	--Generate wb_sm OR-Gates
	wb_sm_or_gates : for i in 1 to NUMBER_OF_SLAVES - 1 generate
	begin
		temp_sm(i) <= WB_SM(i) or temp_sm(i - 1);
	end generate wb_sm_or_gates;
	--Output the Result
	WB_SM_BUS <= temp_sm(NUMBER_OF_SLAVES - 1);

end Behavioral;
