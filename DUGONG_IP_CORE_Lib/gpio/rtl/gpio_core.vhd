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
-- Name:		GPIO_CONTROLLER (002)
-- Type:		CORE (3)
-- Description: 	A core for controlling GPIO of differing widths. Includes an auxiliary interface
--			for streaming digital IO. This allows bypassing the WB Bus.
--
-- Compliance:		DUGONG V0.5
-- ID:			x 0-5-3-002
---------------------------------------------------------------------------------------------------------------
--	ADDR	| NAME		| Type		--
--	0	| GPIO_OUT	| WB_REG	--
-- 	1	| GPIO_IN	| WB_LATCH	--
-- 	2	| OUTPUT_EN	| WB_REG	--
-- 	3	| AUX_EN	| WB_REG	--
--------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

entity gpio_core is
	generic(
		CORE_DATA_WIDTH : natural := 16;
		CORE_ADDR_WIDTH : natural := 3
	);
	port(
		--System Control Inputs
		CLK_I        : in    STD_LOGIC;
		RST_I        : in    STD_LOGIC;
		--Wishbone Slave Lines
		ADR_I        : in    STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0);
		DAT_I        : in    STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
		DAT_O        : out   STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
		WE_I         : in    STD_LOGIC;
		STB_I        : in    STD_LOGIC;
		ACK_O        : out   STD_LOGIC;
		CYC_I        : in    STD_LOGIC;
		--GPIO Auxiliary Interface
		GPIO_AUX_IN  : out   STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
		GPIO_AUX_OUT : in    STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
		--GPIO Interface
		GPIO_B       : inout STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0)
	);
end gpio_core;

architecture Behavioral of gpio_core is
	---------------------------------
	----------{ BUS LOGIC }----------
	---------------------------------

	subtype small_int is integer range 0 to 2 ** CORE_ADDR_WIDTH - 5;
	type t is array (0 to (2 ** CORE_ADDR_WIDTH) - 5) of small_int;

	---------------------------------
	--DEFINE MEMORY STRUCTURE HERE --
	---------------------------------
	constant NUMBER_OF_REGISTERS : natural := 3;
	constant NUMBER_OF_FIFOS     : natural := 0;
	constant user_addr           : t       := (0, 2, 3, 1); --Addresses of registers followed by Addresses of FIFOs followed by Addresses of Latches
	--------------------------------------------------
	--	ADDR	| NAME		| Type		--
	--	0	| GPIO_OUT	| WB_REG	--
	-- 	1	| GPIO_IN	| WB_LATCH	--
	-- 	2	| Output_Enable	| WB_REG	--
	-- 	3	| AUX_Enable	| WB_REG	--
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

	----------------------------------
	----------{ USER LOGIC }----------
	----------------------------------

	component gpio
		generic(
			GPIO_WIDTH : natural := 16
		);
		port(
			--Bus Logic Interface
			GPIO_OUT     : in    STD_LOGIC_VECTOR(GPIO_WIDTH - 1 downto 0);
			GPIO_IN      : out   STD_LOGIC_VECTOR(GPIO_WIDTH - 1 downto 0);
			OUTPUT_EN    : in    STD_LOGIC_VECTOR(GPIO_WIDTH - 1 downto 0);
			AUX_EN       : in    STD_LOGIC_VECTOR(GPIO_WIDTH - 1 downto 0);
			--GPIO Auxiliary Interface
			GPIO_AUX_IN  : out   STD_LOGIC_VECTOR(GPIO_WIDTH - 1 downto 0);
			GPIO_AUX_OUT : in    STD_LOGIC_VECTOR(GPIO_WIDTH - 1 downto 0);
			--GPIO Interface
			GPIO_B       : inout STD_LOGIC_VECTOR(GPIO_WIDTH - 1 downto 0)
		);
	end component gpio;

begin
	---------------------------------
	----------{ BUS LOGIC }----------
	---------------------------------

	wb_addr <= to_integer(unsigned(ADR_I));

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

	user_logic : gpio
		generic map(
			GPIO_WIDTH => CORE_DATA_WIDTH
		)
		port map(
			GPIO_OUT     => user_Q(0),
			GPIO_IN      => user_D(1),
			OUTPUT_EN    => user_Q(2),
			AUX_EN       => user_Q(3),
			GPIO_AUX_IN  => GPIO_AUX_IN,
			GPIO_AUX_OUT => GPIO_AUX_OUT,
			GPIO_B       => GPIO_B
		);

end Behavioral;

