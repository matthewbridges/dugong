--                    
-- _______/\\\\\\\\\_______/\\\________/\\\____/\\\\\\\\\\\____/\\\\\_____/\\\_________/\\\\\_________     
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
-- Name:		GPIO_CONTROLLER(002)
-- Type:		CORE (3)
-- Description: 	A core for controlling GPIO of differing widths. Includes a streaming interface
--			for asynchronous digital IO. This allows bypassing the WB Bus.
--
-- Compliance:		DUGONG V1.3
-- ID:			x 1-3-3-002
---------------------------------------------------------------------------------------------------------------
-- ADDR	-> REG_NAME
-- 0 	-> GPIO_OUT_REG
-- 1	-> N/A
-- 2	-> DIR
-- 3	-> STREAM
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

entity gpio_controller is
	generic(
		DATA_WIDTH : natural := 16;
		ADDR_WIDTH : natural := 3
	);
	port(
		--System Control Inputs
		CLK_I         : in    STD_LOGIC;
		RST_I         : in    STD_LOGIC;
		--Wishbone Slave Lines
		ADR_I         : in    STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		DAT_I         : in    STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DAT_O         : out   STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		WE_I          : in    STD_LOGIC;
		STB_I         : in    STD_LOGIC;
		ACK_O         : out   STD_LOGIC;
		--CYC_I : in   STD_LOGIC;
		--GPIO Stream Interface
		GPIO_STREAM_O : out   STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		GPIO_STREAM_I : in    STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		--GPIO Interface
		GPIO_B        : inout STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0)
	);
end gpio_controller;

architecture Behavioral of gpio_controller is

	--User memory architecture
	type ram_type is array (0 to (2 ** ADDR_WIDTH) - 5) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal user_mem  : ram_type                                     := (others => (others => '0'));
	signal user_addr : integer                                      := 0;
	signal stb       : std_logic_vector(0 to (2 ** ADDR_WIDTH) - 5) := (others => '0');
	signal ack       : std_logic_vector(0 to (2 ** ADDR_WIDTH) - 5) := (others => '0');

	--GPIO internal signal
	signal gpio : std_logic_vector(DATA_WIDTH - 1 downto 0);

begin

	--User Memory Address --> equals IP Address(core_addr_width-1:0) - 4
	user_addr <= to_integer(unsigned(ADR_I));

	--Generate GPIO registers
	user_registers : for addr in 0 to (2 ** ADDR_WIDTH) - 5 generate
	begin
		--Check for valid addr
		stb(addr) <= STB_I when user_addr = addr else '0';

		--WISHBONE Register
		reg : wb_register
			generic map(
				DATA_WIDTH => DATA_WIDTH
			)
			port map(
				CLK_I => CLK_I,
				RST_I => RST_I,
				DAT_I => DAT_I,
				DAT_O => user_mem(addr),
				WE_I  => WE_I,
				STB_I => stb(addr),
				ACK_O => ack(addr)
			);

	end generate user_registers;

	DAT_O <= user_mem(user_addr);
	ACK_O <= ack(user_addr);

	--Generate GPIO tri-state buffers and multiplexors for each GPIO pin
	gpio_control_buffers : for gpio_num in 0 to DATA_WIDTH - 1 generate
		gpio(gpio_num)          <= GPIO_STREAM_I(gpio_num) when user_mem(3)(gpio_num) = '1' else user_mem(0)(gpio_num); -- STREAM REG Control
		GPIO_B(gpio_num)        <= gpio(gpio_num) when user_mem(2)(gpio_num) = '1' else 'Z'; -- DIRECTION Control
		GPIO_STREAM_O(gpio_num) <= GPIO_B(gpio_num) when user_mem(2)(gpio_num) = '0' else '0';
	end generate gpio_control_buffers;

end Behavioral;

