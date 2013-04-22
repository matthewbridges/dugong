---------------------------------------------------------------------------------------------------------------
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
--
-- Name:		BRAM
-- Type:		CORE
-- Description: A core containing BRAM/s which can be used for temporary storage of general data	
--
-- Compliance:	DUGONG V1.0
-- ID:			x0001
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bram is
	generic(
		DATA_WIDTH : natural := 32;
		ADDR_WIDTH : natural := 10
	);
	port(
		--System Control Inputs
		CLK_I : in  STD_LOGIC;
		RST_I : in  STD_LOGIC;
		--Wishbone Slave Lines
		DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		ADR_I : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		STB_I : in  STD_LOGIC;
		WE_I  : in  STD_LOGIC;
		--CYC_I : in   STD_LOGIC;
		ACK_O : out STD_LOGIC
	);
end bram;

architecture Behavioral of bram is
	signal we : std_logic_vector(0 downto 0);

	component bram_sp
		port(
			clka  : IN  STD_LOGIC;
			rsta  : IN  STD_LOGIC;
			ena   : IN  STD_LOGIC;
			wea   : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
			addra : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
			dina  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	end component bram_sp;

begin
	inst : bram_sp
		port map(
			clka  => CLK_I,
			rsta  => RST_I,
			ena   => STB_I,
			wea   => we,
			addra => ADR_I,
			dina  => DAT_I,
			douta => DAT_O
		);

	--For code syntactics
	we(0) <= WE_I;

	process(CLK_I)
	begin
		--Perform Clock Rising Edge operations
		if (rising_edge(CLK_I)) then
			--Check for reset
			if (RST_I = '1') then
				ACK_O <= '0';
			else
				ACK_O <= STB_I;
			end if;
		end if;
	end process;
end Behavioral;

	