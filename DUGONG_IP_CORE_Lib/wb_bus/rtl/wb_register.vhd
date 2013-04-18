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

entity wb_register is
	generic(
		DATA_WIDTH   : NATURAL                       := 16;
		DEFAULT_DATA : STD_LOGIC_VECTOR(63 downto 0) := x"0000000000000000"
	);
	port(
		--System Control Inputs:
		CLK_I : in  STD_LOGIC;
		RST_I : in  STD_LOGIC;
		--WISHBONE SLAVE interface:
		DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		WE_I  : in  STD_LOGIC;
		--SEL_I : in  STD_LOGIC_VECTOR(DATA_WIDTH / 8 - 1 downto 0);
		STB_I : in  STD_LOGIC;
		ACK_O : out STD_LOGIC
	--CYC_I : in   STD_LOGIC;
	);
end wb_register;

architecture Behavioral of wb_register is
	signal Q : std_logic_vector(DATA_WIDTH - 1 downto 0) := DEFAULT_DATA(DATA_WIDTH - 1 downto 0);

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
					Q <= DAT_I;
				--IDLE or READING STATE
				else
					Q <= Q;
				end if;
			end if;
		end if;
	end process;
	ACK_O <= STB_I;
	DAT_O <= Q;

end Behavioral;