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
-- Name:		WB_S_TB (002)
-- Type:		TB (F)
-- Description: 		
--
-- Compliance:		DUGONG V1.1
-- ID:			x 1-1-F-002
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

library DUGONG_IP_CORE_Lib;
use DUGONG_IP_CORE_Lib.dprimitives.ALL;

entity wb_s_tb is
	generic(
		DATA_WIDTH      : NATURAL               := 32;
		ADDR_WIDTH      : NATURAL               := 12;
		BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
		CORE_DATA_WIDTH : NATURAL               := 16;
		CORE_ADDR_WIDTH : NATURAL               := 3
	);
end entity wb_s_tb;

architecture RTL of wb_s_tb is

	--System Control Inputs:
	signal CLK_I : std_logic := '0';
	signal RST_I : std_logic := '1';

	--Slave to WB
	signal WB_I : STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0) := (others => '0');
	signal WB_O : STD_LOGIC_VECTOR(DATA_WIDTH downto 0);

	--Wishbone Slave interface (inverted) 1-2
	signal ADR_I : STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0);
	signal DAT_I : STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
	signal DAT_O : STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0) := (others => '0');
	signal WE_I  : STD_LOGIC;
	signal STB_I : STD_LOGIC;
	signal ACK_O : STD_LOGIC                                      := '0';
	signal CYC_I : STD_LOGIC;

	-- Clock period definitions
	constant CLK_I_period : time := 10 ns;

begin
	uut : wb_s
		generic map(
			DATA_WIDTH      => DATA_WIDTH,
			ADDR_WIDTH      => ADDR_WIDTH,
			BASE_ADDR       => BASE_ADDR,
			CORE_DATA_WIDTH => CORE_DATA_WIDTH,
			CORE_ADDR_WIDTH => CORE_ADDR_WIDTH
		)
		port map(
			CLK_I => CLK_I,
			RST_I => RST_I,
			WB_I  => WB_I,
			WB_O  => WB_O,
			ADR_I => ADR_I,
			DAT_I => DAT_I,
			DAT_O => DAT_O,
			WE_I  => WE_I,
			STB_I => STB_I,
			ACK_O => ACK_O,
			CYC_I => CYC_I
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

		-- Standard IP Core Tests
		wait until rising_edge(CLK_I);
		WB_I <= "101" & x"00000000" & x"000"; --Read Base Address
		wait until rising_edge(WB_O(32));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"00000000" & x"000"; --NULL
		wait until rising_edge(CLK_I);
		WB_I <= "101" & x"00000000" & x"001"; --Read High Address
		wait until rising_edge(WB_O(32));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"00000000" & x"000"; --NULL

		wait until rising_edge(CLK_I);
		WB_I <= "111" & x"FEDCAB98" & x"004"; --Write xFEDCAB98 to 004
		wait until rising_edge(CLK_I);
		ACK_O <= '1';
		wait until rising_edge(WB_O(32));
		wait until rising_edge(CLK_I);
		WB_I  <= "000" & x"00000000" & x"000"; --NULL
		ACK_O <= '0';

		wait until rising_edge(CLK_I);
		WB_I <= "111" & x"FEDCAB98" & x"008"; --Write xFEDCAB98 to 008

		wait;
	end process;

end architecture RTL;
