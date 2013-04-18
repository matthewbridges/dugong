----------------------------------------------------------------------------------
-- Company: University of Cape Town
-- Engineer: Matthew Bridges 
-- 
-- Create Date:    11:43:28 06/19/2012 
-- Design Name: 
-- Module Name:    spi_master - Behavioral 
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

entity spi_m is
	generic(
		DATA_WIDTH : natural := 16;
		ADDR_WIDTH : natural := 3
	);
	port(
		--System Control Inputs
		CLK_I     : in  STD_LOGIC;
		RST_I     : in  STD_LOGIC;
		--Wishbone Slave Lines
		DAT_I     : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DAT_O     : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		ADR_I     : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		STB_I     : in  STD_LOGIC;
		WE_I      : in  STD_LOGIC;
		--		CYC_I : in   STD_LOGIC;
		ACK_O     : out STD_LOGIC;
		--SPI Interface
		SPI_CLK_I : in  STD_LOGIC;
		SPI_CE    : in  STD_LOGIC;
		SPI_MOSI  : out STD_LOGIC;
		SPI_MISO  : in  STD_LOGIC;
		SPI_N_SS  : out STD_LOGIC
	);
end spi_m;

architecture Behavioral of spi_m is
	--Core user memory architecture
	type ram_type is array (0 to (2 ** ADDR_WIDTH) - 5) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal user_mem : ram_type;
	signal mem_adr  : integer := 0;
	--Dual-port signaling
	signal mem_stb  : boolean;
	signal mem_ack  : boolean;
	--Dual-port lock
	signal lock     : std_logic;

	--SPI Specific Signals	
	signal idle     : boolean;
	signal shifting : boolean;

	signal write_data   : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal read_data    : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal transfer_bit : integer;

	signal count : unsigned(DATA_WIDTH - 1 downto 0);

begin
	process(CLK_I)
	begin

		--Perform Clock Rising Edge operations
		if (rising_edge(CLK_I)) then
			--Check for reset
			if (RST_I = '1') then
				ACK_O       <= '0';
				user_mem(3) <= std_logic_vector(count);
				mem_ack     <= false;
				lock        <= '0';

			else
				DAT_O   <= user_mem(mem_adr);
				mem_ack <= mem_stb;
				--Check for internal strobe	
				if (mem_stb) then
					user_mem(1) <= read_data;
					user_mem(2) <= write_data;
					user_mem(3) <= std_logic_vector(count);
					lock        <= '0';
				else
					--Check for external strobe
					if (STB_I = '1') then
						case mem_adr is
							--Lockable memory
							when 0 =>
								if (lock = '0') then
									--Check for write
									if (WE_I = '1') then
										user_mem(mem_adr) <= DAT_I;
										lock              <= '1';
									end if;
									ACK_O <= '1';
								end if;
							--Read-only memory
							when 1 | 2 | 3 =>
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
				end if;
			end if;
		end if;
	end process;
	--Core Memory Address --> equals IP Address(core_addr_width-1:0) - 4
	mem_adr <= to_integer(unsigned(ADR_I));

	--SPI Instruction generation process
	process(SPI_CLK_I)
	begin
		if (rising_edge(SPI_CLK_I)) then
			-- RESET STATE
			if (RST_I = '1') then
				idle     <= true;
				shifting <= false;
				SPI_MOSI <= '0';
				SPI_N_SS <= '1';
				count    <= (others => '0');
				mem_stb  <= false;
			-- IDLE STATE
			elsif (idle) then
				transfer_bit <= DATA_WIDTH - 1;
				if (SPI_CE = '1' and lock = '1') then
					write_data <= user_mem(0);
					count      <= count + 1;
					idle       <= false;
				end if;
			--SHIFTING STATE
			else
				if (transfer_bit < 0) then
					shifting <= false;
					SPI_MOSI <= '0';
					SPI_N_SS <= '1';
					if (mem_stb and mem_ack) then
						mem_stb <= false;
						idle    <= true;
					else
						mem_stb <= true;
					end if;
				else
					shifting     <= true;
					SPI_MOSI     <= write_data(transfer_bit);
					SPI_N_SS     <= '0';
					--Decrement Transfer bit;
					transfer_bit <= transfer_bit - 1;
				end if;
			end if;
		end if;
	end process;

	--SPI Shifter Process
	process(SPI_CLK_I)
	begin
		if (falling_edge(SPI_CLK_I)) then
			if (RST_I = '1') then
				read_data <= (others => '0');
			elsif (shifting) then
				read_data(transfer_bit + 1) <= SPI_MISO;
			end if;
		end if;
	end process;

end Behavioral;

