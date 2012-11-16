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

library RHINO_DUGONG;
use RHINO_DUGONG.dcomponents.all;

entity spi_master is
	generic(
		DATA_WIDTH     : natural               := 16;
		ADDR_WIDTH     : natural               := 2;
		SPI_DATA_WIDTH : natural               := 8;
		DEFAULT_DATA   : word_vector(0 to 128) := (others => x"000010000");
		REVERSE_BITS   : boolean               := false
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
		--Serial Peripheral Interface
		SPI_CLK_I : in  STD_LOGIC;
		SPI_CE    : in  STD_LOGIC;
		SPI_MOSI  : out STD_LOGIC;
		SPI_MISO  : in  STD_LOGIC;
		SPI_N_SS  : out STD_LOGIC
	);
end spi_master;

architecture Behavioral of spi_master is
	type ram_type is array (0 to (2 ** ADDR_WIDTH) - 1) of std_logic_vector(DATA_WIDTH downto 0); --One data valid bit
	signal user_mem          : ram_type;
	signal user_mem_defaults : ram_type;

	signal mem_adr : integer;
	signal mem_stb : boolean;
	signal mem_ack : boolean;

	signal idle          : boolean;
	signal shifting      : boolean;
	signal shifting_done : boolean;
	signal reading       : boolean;
--	signal read_after    : boolean;
	signal read          : boolean;

	signal adr                : unsigned(ADDR_WIDTH - 1 downto 0);
	signal write_data         : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal read_data          : std_logic_vector(SPI_DATA_WIDTH - 1 downto 0);
	constant read_instruction : std_logic_vector(DATA_WIDTH - 1 downto 0) := DEFAULT_DATA(128)(DATA_WIDTH - 1 downto 0);
	signal transfer_bit       : integer;

begin
	DEFAULT_MEM : for addr in 0 to (2 ** ADDR_WIDTH) - 1 generate
	begin
		DEFAULT_MSB : if not REVERSE_BITS generate
			user_mem_defaults(addr) <= DEFAULT_DATA(addr)(DATA_WIDTH downto 0);
		end generate DEFAULT_MSB;

		DEFAULT_LSB : if REVERSE_BITS generate
			process(user_mem_defaults(addr))
			begin
				user_mem_defaults(addr)(DATA_WIDTH) <= DEFAULT_DATA(addr)(DATA_WIDTH);
				for i in 0 to DATA_WIDTH - 1 loop
					user_mem_defaults(addr)(i) <= DEFAULT_DATA(addr)(DATA_WIDTH - 1 - i);
				end loop;
			end process;
		end generate DEFAULT_LSB;
	end generate DEFAULT_MEM;

	process(CLK_I)
	begin
		--Perform Clock Rising Edge operations
		if (rising_edge(CLK_I)) then

			--Check for reset
			if (RST_I = '1') then
				DAT_O    <= (others => '0');
				user_mem <= user_mem_defaults;
			--Check for strobe
			elsif (STB_I = '1') then
				DAT_O <= user_mem(mem_adr)(DATA_WIDTH - 1 downto 0);
				--Check for write
				if (WE_I = '1') then
					user_mem(mem_adr) <= '1' & DAT_I;	
				end if;
			elsif (mem_stb) then
				if (reading) then
					user_mem(mem_adr)(SPI_DATA_WIDTH - 1 downto 0) <= read_data;
				else
--					user_mem(mem_adr)(DATA_WIDTH) <= '0';
				end if;
				mem_ack <= true;
			else
				mem_ack <= false;
			end if;
			ACK_O <= STB_I;
		end if;
	end process;
	mem_adr <= to_integer(unsigned(ADR_I)) when (STB_I = '1') else to_integer(adr);

	--SPI Instruction generation process
	process(SPI_CLK_I)
	begin
		if (rising_edge(SPI_CLK_I)) then
			if (RST_I = '1') then
				reading    <= false;
				idle       <= true;
				shifting   <= false;
				reading    <= false;
--				read_after <= false;
				adr        <= (others => '0');
				write_data <= (others => '0');
			elsif (idle) then
				if (SPI_CE = '1') then
					if (user_mem(to_integer(adr))(DATA_WIDTH) = '1') then
						reading    <= false;
						write_data <= user_mem(to_integer(adr))(DATA_WIDTH - 1 downto 0);
					else
						reading                                          <= true;
						write_data(DATA_WIDTH - 1 downto DATA_WIDTH - 8) <= read_instruction(7 downto ADDR_WIDTH) & std_logic_vector(adr);
						write_data(DATA_WIDTH - 9 downto 0)              <= (others => '0');
					end if;
					idle     <= false;
					shifting <= true;
				end if;
			--Check if SPI transfer has completed
			elsif (shifting_done) then
				shifting <= false;
--				if (read_after) then
--					reading    <= true;
--					write_data <= (others => '0');
--					read_after <= false;
--				else
					if (mem_stb and mem_ack) then
						mem_stb <= false;
						idle    <= true;
						adr     <= adr + 1;
					else
						mem_stb <= true;
--					end if;
				end if;
			end if;
		end if;
	end process;

	--SPI Shifter Process
	process(SPI_CLK_I)
	begin
		--Perform Rising Edge operations
		if (rising_edge(SPI_CLK_I)) then
			if (RST_I = '1') then
				shifting_done <= false;
				read          <= false;
				transfer_bit  <= DATA_WIDTH - 1;
				SPI_MOSI      <= '0';
				SPI_N_SS      <= '1';
			elsif (idle) then
				shifting_done <= false;
				transfer_bit  <= DATA_WIDTH - 1;
--			elsif (read_after) then
--				shifting_done <= false;
--				transfer_bit  <= DATA_WIDTH - 1;
			elsif (shifting) then
				if (transfer_bit < 0) then
					shifting_done <= true;
					SPI_MOSI      <= '0';
					SPI_N_SS      <= '1';
					read          <= false;
				else
					if (transfer_bit < SPI_DATA_WIDTH) then
						read <= reading;
					end if;
					SPI_MOSI <= write_data(transfer_bit);
					SPI_N_SS <= '0';
				end if;
				--Decrement Transfer bit;
				transfer_bit <= transfer_bit - 1;
			end if;
		end if;
	end process;

	--SPI Shifter Process
	process(SPI_CLK_I)
	begin
		if (falling_edge(SPI_CLK_I)) then
			if (RST_I = '1') then
				read_data <= (others => '0');
			elsif (read) then
				read_data(transfer_bit + 1) <= SPI_MISO;
			end if;
		end if;
	end process;

end Behavioral;

