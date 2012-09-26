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

entity spi_master is
	generic(
		DATA_WIDTH     : natural := 8;
		ADDR_WIDTH     : natural := 5;
		SPI_INST_WIDTH : natural := 8;
		SPI_DATA_WIDTH : natural := 8
	);
	port(
		--System Control Inputs
		CLK_I    : in  STD_LOGIC;
		RST_I    : in  STD_LOGIC;
		--Wishbone Slave Lines
		DAT_I    : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DAT_O    : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		ADR_I    : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		STB_I    : in  STD_LOGIC;
		WE_I     : in  STD_LOGIC;
		--		CYC_I : in   STD_LOGIC;
		ACK_O    : out STD_LOGIC;
		--Serial Peripheral Interface
		SCLK_I   : in  STD_LOGIC;
		SPI_CLK  : out STD_LOGIC;
		SPI_MOSI : out STD_LOGIC;
		SPI_MISO : in  STD_LOGIC;
		SPI_N_SS : out STD_LOGIC
	);
end spi_master;

architecture Behavioral of spi_master is
	type ram_type is array (0 to (2 ** ADDR_WIDTH) - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal user_mem   : ram_type;
	signal data_valid : std_logic_vector(0 to (2 ** ADDR_WIDTH) - 1) := (others => '0');
	signal mem_adr    : integer;
	--	constant MSB : natural := SPI_INST_WIDTH + SPI_DATA_WIDTH - 1;

	signal idle     : boolean;
	signal shifting : boolean;
	signal reading  : boolean;

	signal mem_stb : boolean;
	signal mem_ack : boolean;

	signal adr           : unsigned(ADDR_WIDTH - 1 downto 0);
	signal transfer_data : std_logic_vector(SPI_DATA_WIDTH - 1 downto 0);
	signal transfer_inst : std_logic_vector(SPI_INST_WIDTH - 1 downto 0);
	signal transfer_bit  : integer;

begin
	process(CLK_I)
	begin

		--Perform Clock Rising Edge operations
		if (rising_edge(CLK_I)) then

			--Check for reset
			if (RST_I = '1') then
				DAT_O      <= (others => '0');
				user_mem(23)   <= "00000100";
				data_valid(23) <= '1';
			--Check for strobe
			elsif (STB_I = '1') then
				DAT_O <= user_mem(mem_adr);
				--Check for write
				if (WE_I = '1') then
					user_mem(mem_adr)   <= DAT_I;
					data_valid(mem_adr) <= '1';
				end if;
			elsif (mem_stb) then
				if (reading) then
					user_mem(mem_adr) <= transfer_data;
				else
--					data_valid(mem_adr) <= '0';
				end if;
				mem_ack <= true;
			else
				mem_ack <= false;
			end if;
			ACK_O <= STB_I;
		end if;
	end process;

	mem_adr <= to_integer(unsigned(ADR_I)) when (STB_I = '1') else to_integer(adr);

	--SPI Shifter Process
	process(SCLK_I)
	begin
		--Perform Rising Edge operations
		if (rising_edge(SCLK_I)) then
			if (RST_I = '1') then
				adr      <= (others => '0');
				idle     <= true;
				SPI_CLK  <= '0';
				SPI_MOSI <= '0';
				SPI_N_SS <= '1';
			----			elsif (STB_I = '0') then
			----				--Check if there is Data Pending then start new SPI Transfer
			elsif (idle) then
				transfer_inst(ADDR_WIDTH - 1 downto 0) <= std_logic_vector(adr);
				transfer_inst(SPI_INST_WIDTH - 2) <= '0';
				transfer_inst(SPI_INST_WIDTH - 3) <= '0';

				if (data_valid(to_integer(adr)) = '1') then
					transfer_inst(SPI_INST_WIDTH - 1) <= '0';
					reading                           <= false;
					transfer_data                     <= user_mem(to_integer(adr));
				else
					transfer_inst(SPI_INST_WIDTH - 1) <= '1';
					reading                           <= true;
				end if;

				transfer_bit <= SPI_INST_WIDTH + SPI_DATA_WIDTH - 1;
				idle         <= false;

			--Check if SPI transfer has completed
			elsif (mem_stb and mem_ack) then
				mem_stb <= false;
				idle    <= true;
				adr     <= adr + 1;
			else
				SPI_CLK <= '0';
				if (transfer_bit < 0) then
					mem_stb  <= true;
					shifting <= false;
					SPI_MOSI <= '0';
				elsif (transfer_bit < 8) then
					if (reading) then
						SPI_MOSI                    <= '0';
						transfer_data(transfer_bit) <= SPI_MISO;
					else
						SPI_MOSI <= transfer_data(transfer_bit);
					end if;
				else
					SPI_MOSI <= transfer_inst(transfer_bit - 8);
					shifting <= true;
				end if;
				--Decrement Transfer bit;
				SPI_N_SS     <= '0';
				transfer_bit <= transfer_bit - 1;
			end if;

		end if;
		--Perform Falling Edge operations
		if (falling_edge(SCLK_I)) then
			if (shifting) then
				SPI_CLK <= '1';
			else
				SPI_N_SS <= '1';
			end if;
		end if;
	end process;

end Behavioral;

