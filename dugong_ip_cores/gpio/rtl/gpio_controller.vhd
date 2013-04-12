----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:04:58 06/20/2012 
-- Design Name: 
-- Module Name:    bram_sync_sp - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library DUGONG_IP_CORES;
use DUGONG_IP_CORES.dcores.ALL;

entity gpio_controller is
	generic(
		DATA_WIDTH : natural := 16;
		ADDR_WIDTH : natural := 3
	);
	port(
		--System Control Inputs
		CLK_I : in    STD_LOGIC;
		RST_I : in    STD_LOGIC;
		--Wishbone Slave Lines
		DAT_I : in    STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DAT_O : out   STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		ADR_I : in    STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		STB_I : in    STD_LOGIC;
		WE_I  : in    STD_LOGIC;
		--CYC_I : in   STD_LOGIC;
		ACK_O : out   STD_LOGIC;
		--GPIO Interface
		GPIO  : inout STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0)
	);
end gpio_controller;

architecture Behavioral of gpio_controller is
	--Core user memory architecture
	type ram_type is array (0 to (2 ** ADDR_WIDTH) - 5) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal user_mem : ram_type := (others => (others => '0'));
	type array_type is array (0 to (2 ** ADDR_WIDTH) - 5) of std_logic;
	signal stb     : array_type;        -- := (others => '0');
	signal ack     : array_type;
	signal mem_adr : integer := 0;

begin

	--Generate GPIO registers
	user_core_registers : for addr in 0 to (2 ** ADDR_WIDTH) - 5 generate
	--Check for valid addr
	--stb(addr) <= STB_I when mem_adr = addr else '0';
	--
	begin
		stb(addr) <= STB_I when mem_adr = addr else '0';

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

	end generate user_core_registers;

	--Core Memory Address --> equals IP Address(core_addr_width-1:0) - 4
	mem_adr <= to_integer(unsigned(ADR_I));
	DAT_O   <= user_mem(mem_adr);
	ACK_O <= ack(mem_adr);

	--Generate GIO tri-state buffers for each gpio pin
	gpio_tristate_buffers : for gpio_num in 0 to DATA_WIDTH - 1 generate
		GPIO(gpio_num) <= user_mem(0)(gpio_num) when user_mem(2)(gpio_num) = '1' else 'Z';
	end generate gpio_tristate_buffers;

end Behavioral;

