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
-- Name:		CLK_COUNTER (007)
-- Type:		USER_LOGIC (5)
-- Description: 	Logic used to measure the relative frequency of clocks in a system. The value of Master
--			count is set by the master, else it will just be counting to 0.
--
-- Compliance:		DUGONG V0.5
-- ID:			x 0-5-5-007
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

entity clk_counter is
	generic(
		COUNT_DATA_WIDTH : natural := 32
	);
	port(
		--System Control Inputs
		CLK_I          : in  STD_LOGIC;
		RST_I          : in  STD_LOGIC;
		--Bus Logic Interface
		MASTER_COUNT_I : in  STD_LOGIC_VECTOR(COUNT_DATA_WIDTH - 1 downto 0);
		COUNT_O0       : out STD_LOGIC_VECTOR(COUNT_DATA_WIDTH - 1 downto 0);
		COUNT_O1       : out STD_LOGIC_VECTOR(COUNT_DATA_WIDTH - 1 downto 0);
		COUNT_O2       : out STD_LOGIC_VECTOR(COUNT_DATA_WIDTH - 1 downto 0);
		--Test Clocks
		TEST_CLOCKS    : in  STD_LOGIC_VECTOR(2 downto 0)
	);
end entity clk_counter;

architecture RTL of clk_counter is
	signal master_count : unsigned(COUNT_DATA_WIDTH - 1 downto 0);
	type count_mem is array (0 to 2) of unsigned(COUNT_DATA_WIDTH - 1 downto 0);
	signal count : count_mem;

	signal read_count : std_logic;
	signal rst_count  : std_logic;
begin
	process(CLK_I, RST_I)
	begin
		-- RESET STATE
		if (RST_I = '1') then
			master_count <= (others => '0'); --Signal Propagation Bug
			read_count   <= '0';
			rst_count    <= '1';
		else
			--Perform Clock Rising Edge operations
			if (rising_edge(CLK_I)) then
				if (rst_count = '1') then
					master_count <= unsigned(MASTER_COUNT_I); --Signal Propagation Bug
					rst_count    <= '0';
				elsif (master_count = 0) then
					-- READING STATE
					if (read_count = '1') then
						COUNT_O0  <= std_logic_vector(count(0));
						COUNT_O1  <= std_logic_vector(count(1));
						COUNT_O2  <= std_logic_vector(count(2));
						rst_count <= '1';
					else
						read_count <= '1';
					end if;
				else
					master_count <= master_count - 1;
					read_count   <= '0';
				end if;
			end if;
		end if;
	end process;

	-- We have multiple clocks- step over every test_clock, instantiating the required elements
	Test_CLOCKS_Processes : for clk_num in 0 to 2 generate
		process(TEST_CLOCKS(clk_num), rst_count)
		begin
			-- RESET STATE
			if (rst_count = '1') then
				count(clk_num) <= (others => '0');
			else
				--Perform Clock Rising Edge operations
				if (rising_edge(TEST_CLOCKS(clk_num))) then
					-- COUNTING STATE
					if (read_count = '0') then
						count(clk_num) <= count(clk_num) + 1;
					end if;
				end if;
			end if;
		end process;
	end generate Test_CLOCKS_Processes;

end architecture RTL;
