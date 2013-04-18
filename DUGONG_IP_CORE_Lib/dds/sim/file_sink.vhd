library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_textio.all;



use std.textio.all;

entity file_sink is
	generic(
		DATA_WIDTH : natural := 16;
		FILE_NAME  : string  := "sampled_data.out"
	);
	port(
		--System Control Inputs
		CLK_I : in STD_LOGIC;
		RST_I : in STD_LOGIC;
		--Wishbone Slave Lines
		DAT_I : in STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0)
	);
end entity file_sink;

architecture RTL of file_sink is



begin
	process(CLK_I)
	file output_file : TEXT open WRITE_MODE is FILE_NAME;
		variable output_line : line;
		variable output_data : integer; 
	begin
		--Perform Clock Rising Edge operations
		if (rising_edge(CLK_I)) then
			--Check for reset
			if (RST_I = '1') then
				
			else
				output_data := to_integer(SIGNED(DAT_I));
				write(output_line, output_data, RIGHT, 16);
				writeline(output_file, output_line);
			end if;
		end if;
	end process;

end architecture RTL;
