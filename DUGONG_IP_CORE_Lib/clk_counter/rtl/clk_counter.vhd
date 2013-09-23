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
-- Type:		CORE (3)
-- Description: 	A core used to measure the relative frequency of clocks in a system. The value of Master
--			count is set by the master, else it will just be counting to 0. There is a 1 cycle 
--			over count as a result of signal propagation.
--
-- Compliance:		DUGONG V0.3
-- ID:			x 0-3-3-007
---------------------------------------------------------------------------------------------------------------
--	ADDR	| NAME		| Type		--
--	0	| COUNT[0]	| WB_LATCH	--
-- 	1	| COUNT[1]	| WB_LATCH	--
-- 	2	| COUNT[2]	| WB_LATCH	--
-- 	3	| MASTER_COUNT	| WB_REG	--
--------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

entity clk_counter is
	generic(
		CORE_DATA_WIDTH : natural := 32;
		CORE_ADDR_WIDTH : natural := 3
	);
	port(
		--System Control Inputs
		CLK_I       : in  STD_LOGIC;
		RST_I       : in  STD_LOGIC;
		--Wishbone Slave Lines
		ADR_I       : in  STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0);
		DAT_I       : in  STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
		DAT_O       : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
		WE_I        : in  STD_LOGIC;
		STB_I       : in  STD_LOGIC;
		ACK_O       : out STD_LOGIC;
		CYC_I       : in  STD_LOGIC;
		--Test Clocks
		TEST_CLOCKS : in  STD_LOGIC_VECTOR(2 downto 0)
	);
end entity clk_counter;

architecture RTL of clk_counter is
	subtype small_int is integer range 0 to 2 ** CORE_ADDR_WIDTH - 5;
	type t is array (0 to (2 ** CORE_ADDR_WIDTH) - 5) of small_int;

	---------------------------------
	--DEFINE MEMORY STRUCTURE HERE --
	---------------------------------
	constant NUMBER_OF_REGISTERS : natural := 1;
	constant NUMBER_OF_FIFOS     : natural := 0;
	constant user_addr           : t       := (3, 0, 1, 2); --Addresses of registers followed by Addresses of FIFOs followed by Addresses of Latches
	--------------------------------------------------
	--	ADDR	| NAME		| Type		--
	--	0	| COUNT[0]	| WB_LATCH	--
	-- 	1	| COUNT[1]	| WB_LATCH	--
	-- 	2	| COUNT[2]	| WB_LATCH	--
	-- 	3	| MASTER_COUNT	| WB_REG	--
	--------------------------------------------------

	----------------------------------------
	--END OF MEMEORY STRUCTURE DEFINITION --
	----------------------------------------

	--User memory architecture
	type ram_type is array (0 to (2 ** CORE_ADDR_WIDTH) - 5) of std_logic_vector(CORE_DATA_WIDTH - 1 downto 0);
	signal user_D   : ram_type                                                := (others => (others => '0'));
	signal user_Q   : ram_type                                                := (others => (others => '0'));
	signal user_stb : std_logic_vector(((2 ** CORE_ADDR_WIDTH) - 5) downto 0) := (others => '0');
	signal user_ack : std_logic_vector(((2 ** CORE_ADDR_WIDTH) - 5) downto 0) := (others => '0');

	signal wb_addr : small_int;

	signal master_count : unsigned(DATA_WIDTH - 1 downto 0);
	type count_mem is array (0 to 2) of unsigned(DATA_WIDTH - 1 downto 0);
	signal count : count_mem;

	signal read_count : std_logic;
	signal rst_count  : std_logic;
begin

	---------------------------------
	----------{ BUS LOGIC }----------
	---------------------------------

	--User Memory Address space is equals from 4 up to IP Address(core_addr_width-1:0)
	addr_generate : if (CORE_ADDR_WIDTH /= 3) generate
	begin
		-- Account for offset of 4 due to wb_s status registers
		wb_addr <= to_integer(unsigned(ADR_I) - 4);
	end generate addr_generate;

	addr_generate_2 : if (CORE_ADDR_WIDTH = 3) generate
	begin
		-- Account for offset of 4 due to wb_s status registers
		wb_addr <= to_integer(unsigned(ADR_I(CORE_ADDR_WIDTH - 2 downto 0))) when (ADR_I(CORE_ADDR_WIDTH - 1) = '1') else 0;
	end generate addr_generate_2;

	--Generate WB registers
	user_registers : if (NUMBER_OF_REGISTERS > 0) generate
	begin
		user_registers : for i in 0 to (NUMBER_OF_REGISTERS - 1) generate
		begin
			--WISHBONE Register
			reg : wb_register
				generic map(
					DATA_WIDTH   => CORE_DATA_WIDTH,
					DEFAULT_DATA => x"00000000"
				)
				port map(
					CLK_I => CLK_I,
					RST_I => RST_I,
					DAT_I => user_D(user_addr(i)),
					DAT_O => user_Q(user_addr(i)),
					WE_I  => WE_I,
					STB_I => user_stb(user_addr(i)),
					ACK_O => user_ack(user_addr(i))
				);

			user_D(user_addr(i)) <= DAT_I;
		end generate user_registers;
	end generate user_registers;

	--Generate WB FIFOs
	user_fifos : if (NUMBER_OF_FIFOs > 0) generate
	begin
		user_fifos : for i in NUMBER_OF_REGISTERS to (NUMBER_OF_REGISTERS + NUMBER_OF_FIFOS - 1) generate
		begin
			--WISHBONE FIFOs
			fifo : wb_fifo
				generic map(
					DATA_WIDTH => CORE_DATA_WIDTH,
					FIFO_DEPTH => 4
				)
				port map(
					RST_I    => RST_I,
					WR_CLK_I => CLK_I,
					WR_DAT_I => user_D(user_addr(i)),
					WR_WE_I  => WE_I,
					WR_STB_I => user_stb(user_addr(i)),
					WR_ACK_O => user_ack(user_addr(i)),
					RD_CLK_I => '0',
					RD_DAT_O => user_Q(user_addr(i)),
					RD_STB_I => '0',
					RD_ACK_O => open,
					FULL     => open,
					EMPTY    => open
				);

			user_D(user_addr(i)) <= DAT_I;
		end generate user_fifos;
	end generate user_fifos;

	--Generate WB Latches
	user_latches : if ((2 ** CORE_ADDR_WIDTH) - 4) /= NUMBER_OF_REGISTERS + NUMBER_OF_FIFOS generate
	begin
		user_latches : for i in NUMBER_OF_REGISTERS + NUMBER_OF_FIFOS to ((2 ** CORE_ADDR_WIDTH) - 5) generate
		begin
			--WISHBONE Latches
			latch : wb_latch
				generic map(
					DATA_WIDTH => CORE_DATA_WIDTH
				)
				port map(
					CLK_I => CLK_I,
					RST_I => RST_I,
					DAT_I => user_D(user_addr(i)),
					DAT_O => user_Q(user_addr(i)),
					STB_I => user_stb(user_addr(i)),
					ACK_O => user_ack(user_addr(i))
				);
		end generate user_latches;
	end generate user_latches;

	--Generate user Strobe lines
	user_registers_control : for i in 0 to ((2 ** CORE_ADDR_WIDTH) - 5) generate
	begin
		--Check for valid addr
		user_stb(i) <= (STB_I and CYC_I) when (wb_addr = i) else '0';
	end generate user_registers_control;

	DAT_O <= user_Q(wb_addr);
	ACK_O <= user_ack(wb_addr);

	----------------------------------
	----------{ USER LOGIC }----------
	----------------------------------

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
					master_count <= unsigned(user_Q(3)); --Signal Propagation Bug
					rst_count    <= '0';
				elsif (master_count = 0) then
					-- READING STATE
					if (read_count = '1') then
						user_D(0) <= std_logic_vector(count(0));
						user_D(1) <= std_logic_vector(count(1));
						user_D(2) <= std_logic_vector(count(2));
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
