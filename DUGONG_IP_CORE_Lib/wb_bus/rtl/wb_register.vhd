--  
--                    
-- _____/\\\\\\\\\_______/\\\________/\\\____/\\\\\\\\\\\____/\\\\\_____/\\\_________/\\\\\_______      
--\____/\\\///////\\\____\/\\\_______\/\\\___\/////\\\///____\/\\\\\\___\/\\\_______/\\\///\\\_____\
-- \___\/\\\_____\/\\\____\/\\\_______\/\\\_______\/\\\_______\/\\\/\\\__\/\\\_____/\\\/__\///\\\___\    
--  \___\/\\\\\\\\\\\/_____\/\\\\\\\\\\\\\\\_______\/\\\_______\/\\\//\\\_\/\\\____/\\\______\//\\\__\   
--   \___\/\\\//////\\\_____\/\\\/////////\\\_______\/\\\_______\/\\\\//\\\\/\\\___\/\\\_______\/\\\__\  
--    \___\/\\\____\//\\\____\/\\\_______\/\\\_______\/\\\_______\/\\\_\//\\\/\\\___\//\\\______/\\\___\
--     \___\/\\\_____\//\\\___\/\\\_______\/\\\_______\/\\\_______\/\\\__\//\\\\\\____\///\\\__/\\\_____\
--      \___\/\\\______\//\\\__\/\\\_______\/\\\____/\\\\\\\\\\\___\/\\\___\//\\\\\______\///\\\\\/______\
--       \___\///________\///___\///________\///____\///////////____\///_____\/////_________\/////________\
--        \                                                                                                \
--         \==============  Reconfigurable Hardware Interface for computatioN and radiO  ===================\
--          \============================  http://www.rhinoplatform.org  ====================================\
--           \================================================================================================\
--
---------------------------------------------------------------------------------------------------------------
-- Company:		UNIVERSITY OF CAPE TOWN
-- Engineer:		MATTHEW BRIDGES
--
-- Name:		WB_REGISTER (001)
-- Type:		PRIMITIVE (2)
-- Description:		A register primitive with one port which can take on generic data widths and default values.
--
-- Compliance:		DUGONG V1.1 (1-1)
-- ID:			x 1-1-2-001
---------------------------------------------------------------------------------------------------------------

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
		--WISHBONE SLAVE interface:1-
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