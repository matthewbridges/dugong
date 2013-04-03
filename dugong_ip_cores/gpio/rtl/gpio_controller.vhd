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
	signal user_mem : ram_type;
	signal mem_adr  : integer := 0;

begin
	process(CLK_I)
	begin

		--Perform Clock Rising Edge operations
		if (rising_edge(CLK_I)) then
			--Check for reset
			if (RST_I = '1') then
				ACK_O       <= '0';
				user_mem(2) <= (others => '0');
			--				mem_ack     <= false;
			--				lock        <= '0';

			else
				DAT_O <= user_mem(mem_adr);
				--				mem_ack <= mem_stb;
				--				--Check for internal strobe	
				--				if (mem_stb) then
				--					user_mem(1) <= read_data;
				--					user_mem(2) <= write_data;
				--					user_mem(3) <= std_logic_vector(count);
				--					lock        <= '0';
				--				else
				--Check for external strobe
				if (STB_I = '1') then
					case mem_adr is
						--							--Lockable memory
						--							when 0 =>
						--								if (lock = '0') then
						--									--Check for write
						--									if (WE_I = '1') then
						--										user_mem(mem_adr) <= DAT_I;
						--										lock              <= '1';
						--									end if;
						--									ACK_O <= '1';
						--								end if;
						--Read-only memory
						when 1 =>
							ACK_O <= '1';
						--Not Lockable, read/write memory
						when others =>
							--Check for write
							if (WE_I = '1') then
								user_mem(mem_adr) <= DAT_I;
							end if;
							ACK_O <= '1';
					end case;
				else
					ACK_O <= '0';
				end if;
			--				end if;
			end if;
			user_mem(1) <= GPIO;
		end if;
	end process;
	--Core Memory Address --> equals IP Address(core_addr_width-1:0) - 4
	mem_adr <= to_integer(unsigned(ADR_I));

	gpio_tristate_buffers : for gpio_num in 0 to DATA_WIDTH - 1 generate
		GPIO(gpio_num)        <= user_mem(0)(gpio_num) when user_mem(2)(gpio_num) = '1' else 'Z';
	end generate gpio_tristate_buffers;

end Behavioral;

