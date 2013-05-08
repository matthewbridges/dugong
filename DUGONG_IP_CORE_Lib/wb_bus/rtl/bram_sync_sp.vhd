--  
--                    
--_____/\\\\\\\\\_______/\\\________/\\\____/\\\\\\\\\\\____/\\\\\_____/\\\_________/\\\\\_________      
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
-- Engineer: 	MATTHEW BRIDGES
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bram_sync_sp is
	generic(
		DATA_WIDTH : natural := 32;
		ADDR_WIDTH : natural := 10
	);
	port(
		--PORT
		CLK_I : in  STD_LOGIC;
		DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		ADR_I : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		WE_I  : in  STD_LOGIC
	);
end bram_sync_sp;

architecture Behavioral of bram_sync_sp is
	--Shared memory
	type ram_type is array (0 to (2 ** ADDR_WIDTH) - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal mem     : ram_type;
	signal mem_adr : integer := 0;

begin
	process(CLK_I)
	begin
		--Perform Clock Rising Edge operations
		if (rising_edge(CLK_I)) then
			--WRITING STATE
			if (WE_I = '1') then
				mem(to_integer(unsigned(ADR_I))) <= DAT_I;
			end if;
			--READING STATE
			mem_adr <= to_integer(unsigned(ADR_I));
		end if;
	end process;

	DAT_O <= mem(mem_adr);

end Behavioral;

