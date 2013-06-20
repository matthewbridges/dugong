----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:04:58 06/20/2012 
-- Design Name: 
-- Module Name:    wb_ram_sp - Behavioral 
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

entity wb_ram_sp is
	generic(
		DATA_WIDTH : natural := 16;
		ADDR_WIDTH : natural := 10
	);
	port(
		--System Control Inputs:
		CLK_I : in  STD_LOGIC;
		RST_I : in  STD_LOGIC;
		--WISHBONE SLAVE interface:
		ADR_I : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		WE_I  : in  STD_LOGIC;
		--SEL_I : in  STD_LOGIC_VECTOR(DATA_WIDTH / 8 - 1 downto 0);
		STB_I : in  STD_LOGIC;
		ACK_O : out STD_LOGIC
	--CYC_I : in   STD_LOGIC;
	);
end wb_ram_sp;

architecture Behavioral of wb_ram_sp is
	--Declaration of type and signal of a 2^ADDR_WIDTH element RAM
	--with each element being DATA_WIDTH bit wide.
	type ram_type is array (0 to (2 ** ADDR_WIDTH) - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal mem     : ram_type := (others => (others => '0'));
	signal mem_adr : integer  := 0;
	signal Q       : std_logic_vector(DATA_WIDTH - 1 downto 0);

begin
	process(CLK_I)
	begin
		--Perform Clock Rising Edge operations
		if (rising_edge(CLK_I)) then
			--RST STATE
			if (RST_I = '1') then
				Q <= (others => '0');
			else
				--WRITING STATE
				if ((STB_I and WE_I) = '1') then
					mem(mem_adr) <= DAT_I;
				end if;
				--IDLE or READING STATE
				Q <= mem(mem_adr);
			end if;
		end if;
	end process;
	--Memory Address
	mem_adr <= to_integer(unsigned(ADR_I));
	ACK_O   <= STB_I;
	DAT_O   <= Q;

end Behavioral;