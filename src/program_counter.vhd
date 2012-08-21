----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:46:17 07/31/2012 
-- Design Name: 
-- Module Name:    program_counter - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

entity program_counter is
	generic(
		DATA_WIDTH : natural := 16;
		ADDR_WIDTH : natural := 3;
		INST_WIDTH : natural := 20;
		PROG_SIZE  : natural := 4
	);
	port(
		EN_I  : in  STD_LOGIC;
		LD_I  : in  STD_LOGIC;
		-- Lines
		CLK_I : in  STD_LOGIC;
		RST_I : in  STD_LOGIC;
		DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0)
	);
end program_counter;

architecture Behavioral of program_counter is
	signal pc : unsigned(DATA_WIDTH - 1 downto 0) := (others => '0');

begin
	process(CLK_I)
	begin

		--Perform Clock Rising Edge operations
		if (rising_edge(CLK_I)) then

			--Check for reset
			if (RST_I = '1') then
				pc <= (others => '0');
			elsif (LD_I = '1') then
				pc <= unsigned(DAT_I);
			elsif (EN_I = '1') then
				pc <= pc + 1;
			else
				pc <= pc;
			end if;

		end if;

	end process;

	DAT_O <= std_logic_vector(pc);

end Behavioral;

