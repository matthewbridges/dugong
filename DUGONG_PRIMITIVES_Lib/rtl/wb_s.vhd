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
-- Name:		WB_S (002)
-- Type:		PRIMITIVE (2)
-- Description:		A primitive which performs the bus logic of all IP Core slaves on the wishbone bus. It can
--			take on generic data and address widths and a generic Address. DATA_WIDTH and ADDRESS_WIDTH
--			should be set by the top level module and coincide with the widths of the Master.
-- 
-- Compliance:		DUGONG V0.3
-- ID:			x 0-3-2-002
---------------------------------------------------------------------------------------------------------------
--	ADDR	| NAME		| Type		--
--	0	| BASE_ADDR	| WB_LATCH	--
-- 	1	| HIGH_ADDR	| WB_LATCH	--
-- 	2	| CORE_ID	| WB_LATCH	--
-- 	3	| xFEDCBA98	| WB_REG	--  --TEST_SIGNAL
--------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

--NB The DATA_WIDTH and ADDR_WIDTH constants are set in the dprimitives package
entity wb_s is
	generic(
		BASE_ADDR       : UNSIGNED(ADDR_WIDTH + 3 downto 0) := x"00000000";
		CORE_ID         : UNSIGNED(31 downto 0)             := x"00032002"; -- SEE HEADER
		CORE_DATA_WIDTH : NATURAL                           := 16;
		CORE_ADDR_WIDTH : NATURAL                           := 3
	);
	port(
		--System Control Inputs
		CLK_I : in  STD_LOGIC;
		RST_I : in  STD_LOGIC;
		--Slave to WB
		WB_MS : in  WB_MS_type;
		WB_SM : out WB_SM_type;
		--Wishbone Slave Interface (inverted)
		ADR_I : out STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0);
		DAT_I : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
		DAT_O : in  STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
		WE_I  : out STD_LOGIC;
		STB_I : out STD_LOGIC;
		ACK_O : in  STD_LOGIC;
		CYC_I : out STD_LOGIC
	);
end wb_s;

architecture Behavioral of wb_s is
	--User memory architecture
	type ram_type is array (0 to 3) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal core_mem            : ram_type := (others => (others => '0'));
	constant core_mem_defaults : ram_type := (std_logic_vector(BASE_ADDR), std_logic_vector(BASE_ADDR + (((2 ** CORE_ADDR_WIDTH) * 4) - 1)), std_logic_vector(CORE_ID), x"FEDCBA98");

	signal stb : std_logic_vector(0 to 3) := (others => '0');
	signal ack : std_logic_vector(0 to 3) := (others => '0');

	--Addressing Architecture
	signal core_addr : unsigned(CORE_ADDR_WIDTH - 1 downto 0) := (others => '0');
	signal core_sel  : std_logic                              := '0';
	signal user_sel  : std_logic                              := '0';

	--Wishbone Slave Lines
	alias adr_ms  : std_logic_vector(ADDR_WIDTH - 1 downto 0) is WB_MS(ADDR_WIDTH - 1 downto 0);
	alias dat_ms  : std_logic_vector(DATA_WIDTH - 1 downto 0) is WB_MS(DATA_WIDTH + ADDR_WIDTH - 1 downto ADDR_WIDTH);
	signal dat_sm : std_logic_vector(DATA_WIDTH - 1 downto 0);
	alias we_ms   : std_logic is WB_MS(ADDR_WIDTH + DATA_WIDTH);
	alias stb_ms  : std_logic is WB_MS(ADDR_WIDTH + DATA_WIDTH + 1);
	alias cyc_ms  : std_logic is WB_MS(ADDR_WIDTH + DATA_WIDTH + 2);
	signal ack_sm : std_logic;

begin

	--Core Address --> equals WB_ADR_MS(core_addr_width-1:0)
	core_addr <= unsigned(adr_ms(CORE_ADDR_WIDTH - 1 downto 0));
	core_sel  <= '1' when (adr_ms(ADDR_WIDTH - 1 downto CORE_ADDR_WIDTH) = std_logic_vector(BASE_ADDR(ADDR_WIDTH + 1 downto CORE_ADDR_WIDTH + 2))) else '0';
	user_sel  <= '0' when (adr_ms(CORE_ADDR_WIDTH - 1 downto 2) = std_logic_vector(BASE_ADDR(CORE_ADDR_WIDTH - 1 downto 2))) else core_sel; --Equivalent to core_addr > 3

	--Generate CORE Status Constants
	bus_constants : for addr in 0 to 2 generate
	begin
		--Check for valid addr
		stb(addr) <= (stb_ms and core_sel) when core_addr = addr else '0';

		--WISHBONE Constants
		wb_constant : wb_const
			generic map(
				DATA_WIDTH   => DATA_WIDTH,
				DEFAULT_DATA => core_mem_defaults(addr)
			)
			port map(
				CLK_I => CLK_I,
				RST_I => RST_I,
				DAT_O => core_mem(addr),
				STB_I => stb(addr),
				ACK_O => ack(addr)
			);

	end generate bus_constants;

	--Generate Bus registers
	bus_registers : for addr in 3 to 3 generate
	begin
		--Check for valid addr
		stb(addr) <= (stb_ms and core_sel) when core_addr = addr else '0';

		--WISHBONE Register
		reg : wb_register
			generic map(
				DATA_WIDTH   => DATA_WIDTH,
				DEFAULT_DATA => core_mem_defaults(addr)
			)
			port map(
				CLK_I => CLK_I,
				RST_I => RST_I,
				DAT_I => dat_ms,
				DAT_O => core_mem(addr),
				WE_I  => we_ms,
				STB_I => stb(addr),
				ACK_O => ack(addr)
			);

	end generate bus_registers;

	--WB Output Ports
	ack_sm                               <= ACK_O when (user_sel = '1') else ack(to_integer(core_addr(1 downto 0)));
	dat_sm(CORE_DATA_WIDTH - 1 downto 0) <= DAT_O when (user_sel = '1') else core_mem(to_integer(core_addr(1 downto 0)))(CORE_DATA_WIDTH - 1 downto 0);

	data_reduction : if (CORE_DATA_WIDTH < DATA_WIDTH) generate
		dat_sm(DATA_WIDTH - 1 downto CORE_DATA_WIDTH) <= (others => '0') when (user_sel = '1') else core_mem(to_integer(core_addr(1 downto 0)))(DATA_WIDTH - 1 downto CORE_DATA_WIDTH);
	end generate data_reduction;

	--Generate WB Output Port buffers for each line
	WB_SM <= ack_sm & dat_sm when core_sel = '1' else (others => '0');

	--WB Input Ports
	DAT_I <= dat_ms(CORE_DATA_WIDTH - 1 downto 0);
	WE_I  <= we_ms;

	--Synchronise Address sent to User_core
	process(CLK_I, RST_I)
	begin
		--RST STATE
		if (RST_I = '1') then
			ADR_I <= (others => '0');
		else
			--Perform Falling Edge operations
			if (rising_edge(CLK_I)) then
				if (user_sel = '0') then
					ADR_I <= (others => '0');
					STB_I <= '0';
					cyc_I <= '0';
				else
					ADR_I <= std_logic_vector(core_addr - 4);
					STB_I <= stb_ms and user_sel;
					cyc_I <= cyc_ms and user_sel;
				end if;
			end if;
		end if;
	end process;

end Behavioral;
