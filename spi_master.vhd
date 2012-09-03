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
		DATA_WIDTH : natural := 16;
		ADDR_WIDTH : natural := 5;
		SPI_DATA_WIDTH : natural := 16
	);
	port(
		--Wishbone Slave Lines
		RST_I    : in  STD_LOGIC;
		CLK_I    : in  STD_LOGIC;
		ADR_I    : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		DAT_I    : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DAT_O    : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		WE_I     : in  STD_LOGIC;
		STB_I    : in  STD_LOGIC;
		ACK_O    : out STD_LOGIC;
		--CYC_I : in    STD_LOGIC
		--Serial Peripheral Interface
		SPI_CLK  : out STD_LOGIC;
		SPI_MOSI : out STD_LOGIC;
		SPI_MISO : in  STD_LOGIC;
		SPI_N_SS : out STD_LOGIC
	);
end spi_master;

architecture Behavioral of spi_master is
	type ram_type is array (0 to (2 ** ADDR_WIDTH) - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	type ram_valid_type is array (0 to (2 ** ADDR_WIDTH) - 1) of boolean;
	signal user_mem            : ram_type;
	shared variable data_valid : ram_valid_type;
	signal q                   : std_logic_vector(DATA_WIDTH - 1 downto 0);

	signal sclk  : std_logic;
	constant MSB : natural := SPI_DATA_WIDTH - 1;

	signal idle     : boolean;
	signal shifting : boolean;

	signal adr          : unsigned(ADDR_WIDTH - 1 downto 0);
	signal transfer     : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal transfer_bit : integer;

begin
	process(CLK_I)
	begin

		--Perform Clock Rising Edge operations
		if (rising_edge(CLK_I)) then

			--Check for reset
			if (RST_I = '1') then
				q <= (others => '0');

			--Check for strobe
			elsif (STB_I = '1') then
				q <= user_mem(to_integer(unsigned(ADR_I)));
				--Check for write
				if (WE_I = '1') then
					user_mem(to_integer(unsigned(ADR_I)))   <= DAT_I;
					data_valid(to_integer(unsigned(ADR_I))) := true;
				end if;
			end if;
		end if;
	end process;

	--SPI Shifter Process
	process(sclk)
	begin
		--Perform Rising Edge operations
		if (rising_edge(sclk)) then
			if (RST_I = '1') then
				adr  <= (others => '0');
				idle <= true;
				-- Prevent interrupting a read/write cycle
				if(not shifting) then
					SPI_CLK <= '0';
					SPI_MOSI <= '0';
					SPI_N_SS <= '1';
				end if;
				
			elsif (STB_I = '0') then
				--Check if there is Data Pending then start new SPI Transfer
				if (idle) then
					if (data_valid(to_integer(adr))) then
						transfer                    <= user_mem(to_integer(adr));
						data_valid(to_integer(adr)) := false;
						transfer_bit                <= MSB;
						shifting                    <= true;
						idle                        <= false;
						adr                         <= adr + 1;
					end if;
				end if;
			end if;

			--Check if SPI transfer is in progress
			if (shifting) then
				--Decrement Transfer bit;
				transfer_bit <= transfer_bit - 1;
				SPI_CLK <= '1';
			--Set all SPI signals to default state
			else
				--SPI_MOSI <= '0';
				SPI_N_SS <= '1';
			end if;
		end if;
		--Perform Falling Edge operations
		if (falling_edge(sclk)) then
			if (shifting) then
				--Check if SPI transfer has completed
				if (transfer_bit < 0) then
					shifting <= false;
					SPI_MOSI <= '0';
				else
					SPI_N_SS <= '0';
					SPI_MOSI <= transfer(transfer_bit);
				end if;
				
				SPI_CLK <= '0';
				
			--When state is not shifting set idle true	
			else
				idle <= true;
			end if;
		--
		end if;
	--
	end process;
	ACK_O   <= STB_I;
	DAT_O   <= q;
	sclk    <= CLK_I;

end Behavioral;

