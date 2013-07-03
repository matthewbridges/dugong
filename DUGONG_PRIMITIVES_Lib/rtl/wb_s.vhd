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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

--NB The DATA_WIDTH and ADDR_WIDTH constants are set in the dprimitives package
entity wb_s is
	generic(
		BASE_ADDR       : UNSIGNED(ADDR_WIDTH + 3 downto 0) := x"00000000";
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
	--WB
	alias adr_ms  : std_logic_vector(ADDR_WIDTH - 1 downto 0) is WB_MS(ADDR_WIDTH - 1 downto 0);
	alias dat_ms  : std_logic_vector(DATA_WIDTH - 1 downto 0) is WB_MS(DATA_WIDTH + ADDR_WIDTH - 1 downto ADDR_WIDTH);
	signal dat_sm : std_logic_vector(DATA_WIDTH - 1 downto 0);
	alias we_ms   : std_logic is WB_MS(ADDR_WIDTH + DATA_WIDTH);
	alias stb_ms  : std_logic is WB_MS(ADDR_WIDTH + DATA_WIDTH + 1);
	alias cyc_ms  : std_logic is WB_MS(ADDR_WIDTH + DATA_WIDTH + 2);
	signal ack_sm : std_logic;

	--Addressing Architecture
	signal core_addr : unsigned(CORE_ADDR_WIDTH - 1 downto 0) := (others => '0');
	signal core_sel  : std_logic                              := '0';
	signal user_sel  : std_logic                              := '0';

	--User memory architecture
	type ram_type is array (0 to 3) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal core_mem : ram_type                 := (others => (others => '0'));
	signal stb      : std_logic_vector(0 to 3) := (others => '0');
	signal ack      : std_logic_vector(0 to 3) := (others => '0');

begin

	--Core Address --> equals WB_ADR_MS(core_addr_width-1:0)
	core_addr <= unsigned(adr_ms(CORE_ADDR_WIDTH - 1 downto 0));
	core_sel  <= '1' when (unsigned(adr_ms(ADDR_WIDTH - 1 downto CORE_ADDR_WIDTH)) = BASE_ADDR(ADDR_WIDTH + 1 downto CORE_ADDR_WIDTH + 2)) else '0';
	user_sel  <= core_sel when core_addr > 3 else '0';

	--Generate Bus registers
	bus_registers : for addr in 0 to 3 generate
	begin
		--Check for valid addr
		stb(addr) <= (stb_ms and core_sel) when core_addr = addr else '0';

		--WISHBONE Register
		reg : wb_register
			generic map(
				DATA_WIDTH   => DATA_WIDTH,
				DEFAULT_DATA => x"AAAA7777"
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
	--WB_SM <= ack_sm & "00" & adr_ms & "00" when core_sel = '1' else (others => '0');

	--WB Input Ports
	DAT_I <= dat_ms(CORE_DATA_WIDTH - 1 downto 0);
	ADR_I <= std_logic_vector(core_addr - 4) when ((user_sel and core_sel) = '1') else (others => '0');
	WE_I  <= we_ms;
	STB_I <= stb_ms and user_sel;
	cyc_I <= cyc_ms and user_sel;

end Behavioral;
