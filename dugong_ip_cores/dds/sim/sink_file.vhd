----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:43:41 08/20/2012 
-- Design Name: 
-- Module Name:    src_file - Behavioral 
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

use STD.textio.all;
use work.txt_util.all;
use ieee.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sink_file is
	 generic (
           stim_file:       string  := "file_io.out");
    Port ( clk : in  STD_LOGIC;
           data : in  STD_LOGIC_VECTOR(15 downto 0));
end sink_file;



architecture Behavioral of sink_file is
SIGNAL data_buf :  std_logic_vector(15 downto 0);

begin

	--WRITE DATA FROM FILE
  write_file:
    process (clk) is    -- write file_io.out (when done goes to '1')
      file my_output : TEXT open WRITE_MODE is stim_file;
      -- above declaration should be in architecture declarations for multiple
      variable my_line : LINE;
      variable my_output_line : LINE;
    begin
		if (rising_edge(clk)) then
		  write(my_line, string'("writing file"));
		  writeline(output, my_line);
		  --write(my_output_line, conv_integer(signed(data)));
		  data_buf <= data;
		  write(my_output_line, str(data_buf));
		  writeline(my_output, my_output_line);
		  --write(my_output_line, done);    -- or any other stuff
		  --writeline(my_output, my_output_line);
		end if;
    end process write_file;

end Behavioral;

