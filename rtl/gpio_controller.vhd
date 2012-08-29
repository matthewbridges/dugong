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

entity gpio_controller is
	generic(
		DATA_WIDTH : natural := 16;
		ADDR_WIDTH : natural := 3;
		GPIO_WIDTH : natural := 8
	);
	port(
		--Wishbone Slave Lines
		RST_I : in  STD_LOGIC;
		CLK_I : in  STD_LOGIC;
		ADR_I : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		WE_I  : in  STD_LOGIC;
		STB_I : in  STD_LOGIC;
		ACK_O : out STD_LOGIC;
		--		CYC_I : in   STD_LOGIC;
		--GPIO Interface
		GPIO  : out STD_LOGIC_VECTOR(GPIO_WIDTH - 1 downto 0)
	);
end gpio_controller;

architecture Behavioral of gpio_controller is
	type ram_type is array (0 to (2 ** ADDR_WIDTH) - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal user_mem : ram_type;
	signal q        : std_logic_vector(DATA_WIDTH - 1 downto 0);

begin
	process(CLK_I)
	begin

		--Perform Clock Rising Edge operations
		if (rising_edge(CLK_I)) then

			--Check for reset
			if (RST_I = '1') then
				q           <= (others => '0');
				user_mem(0) <= (others => '0');

			--Check for strobe
			elsif (STB_I = '1') then
				q <= user_mem(to_integer(unsigned(ADR_I))-8);
				--Check for write
				if (WE_I = '1') then
					user_mem(to_integer(unsigned(ADR_I))-8) <= DAT_I;
				end if;
			end if;

		end if;

	end process;
	ACK_O <= STB_I;
	DAT_O <= q;
	GPIO  <= user_mem(0)(GPIO_WIDTH - 1 downto 0);

end Behavioral;

