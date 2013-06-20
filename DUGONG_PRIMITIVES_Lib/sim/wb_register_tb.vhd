---------------------------------------------------------------------------------------------------------------
--                    
--______/\\\\\\\\\_______/\\\________/\\\____/\\\\\\\\\\\____/\\\\\_____/\\\_________/\\\\\________      
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
-- Engineer: 		MATTHEW BRIDGES
--
-- Name:		WB_REGISTER_TB (001)
-- Type:		TB (F)
-- Description: 		
--
-- Compliance:		DUGONG V1.1
-- ID:			x 1-1-F-001
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library DUGONG_IP_CORE_Lib;
use DUGONG_IP_CORE_Lib.dprimitives.ALL;

entity wb_register_tb is
	generic(
		DATA_WIDTH   : NATURAL                       := 32;
		DEFAULT_DATA : STD_LOGIC_VECTOR(31 downto 0) := x"00000000"
	);
end entity wb_register_tb;

architecture Behavioral of wb_register_tb is

	--System Control Inputs:
	signal CLK_I : std_logic                                 := '0';
	signal RST_I : std_logic                                 := '1';
	--WISHBONE SLAVE interface: 1-2
	signal DAT_I : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
	signal DAT_O : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal WE_I  : std_logic                                 := '0';
	signal STB_I : std_logic                                 := '0';
	signal ACK_O : std_logic;

	-- Clock period definitions
	constant CLK_I_period : time := 10 ns;

begin
	uut : component wb_register
		generic map(
			DATA_WIDTH   => DATA_WIDTH,
			DEFAULT_DATA => DEFAULT_DATA
		)
		port map(
			CLK_I => CLK_I,
			RST_I => RST_I,
			DAT_I => DAT_I,
			DAT_O => DAT_O,
			WE_I  => WE_I,
			STB_I => STB_I,
			ACK_O => ACK_O
		);

	-- Clock process definitions
	CLK_I_process : process
	begin
		CLK_I <= '0';
		wait for CLK_I_period / 2;
		CLK_I <= '1';
		wait for CLK_I_period / 2;
	end process;

	-- Stimulus process
	wb_stim_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;

		RST_I <= '0';

		wait for CLK_I_period * 10;

		wait until rising_edge(CLK_I);
		DAT_I <= x"00000000";           --Read
		WE_I  <= '0';                   --Read
		STB_I <= '1';                   --Strobe
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		WE_I  <= '0';
		DAT_I <= x"00000000";
		wait until rising_edge(CLK_I);
		DAT_I <= x"FEDCBA98";           --Write xFEDCBA98
		WE_I  <= '1';                   --Write
		STB_I <= '1';                   --Strobe
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		WE_I  <= '0';
		DAT_I <= x"00000000";
		wait until rising_edge(CLK_I);
		DAT_I <= x"00000000";           --Read
		WE_I  <= '0';                   --Read
		STB_I <= '1';                   --Strobe
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		WE_I  <= '0';
		DAT_I <= x"00000000";

		wait;
	end process;

end Behavioral;
