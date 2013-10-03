--
-- _______/\\\\\\\\\_______/\\\________/\\\____/\\\\\\\\\\\____/\\\\\_____/\\\_________/\\\\\________
-- \ ____/\\\///////\\\____\/\\\_______\/\\\___\/////\\\///____\/\\\\\\___\/\\\_______/\\\///\\\_____\
--  \ ___\/\\\_____\/\\\____\/\\\_______\/\\\_______\/\\\_______\/\\\/\\\__\/\\\_____/\\\/__\///\\\___\
--   \ ___\/\\\\\\\\\\\/_____\/\\\\\\\\\\\\\\\_______\/\\\_______\/\\\//\\\_\/\\\____/\\\______\//\\\__\
--    \ ___\/\\\//////\\\_____\/\\\/////////\\\_______\/\\\_______\/\\\\//\\\\/\\\___\/\\\_______\/\\\__\
--     \ ___\/\\\____\//\\\____\/\\\_______\/\\\_______\/\\\_______\/\\\_\//\\\/\\\___\//\\\______/\\\___\
--      \ ___\/\\\_____\//\\\___\/\\\_______\/\\\_______\/\\\_______\/\\\__\//\\\\\\____\///\\\__/\\\_____\
--       \ ___\/\\\______\//\\\__\/\\\_______\/\\\____/\\\\\\\\\\\___\/\\\___\//\\\\\______\///\\\\\/______\
--        \ ___\///________\///___\///________\///____\///////////____\///_____\/////_________\/////________\
--         \ __________________________________________\          \__________________________________________\
--          |:------------------------------------------|: DUGONG :|-----------------------------------------:|
--         / ==========================================/          /========================================= /
--        / =============================================================================================== /
--       / ================  Reconfigurable Hardware Interface for computatioN and radiO  ================ /
--      / ===============================  http://www.rhinoplatform.org  ================================ /
--     / =============================================================================================== /
--
---------------------------------------------------------------------------------------------------------------
-- Company:		UNIVERSITY OF CAPE TOWN
-- Engineer: 		MATTHEW BRIDGES
--
-- Name:		WB_MULTI_LATCH_IP (008)
-- Type:		IP_CORE (4)
-- Description: 	
--
-- Compliance:		DUGONG V0.5
-- ID:			x 0-5-4-008
---------------------------------------------------------------------------------------------------------------
--	ADDR	| NAME		| Type		--
--	0	| BASE_ADDR	| WB_LATCH	--
-- 	1	| HIGH_ADDR	| WB_LATCH	--
-- 	2	| CORE_ID	| WB_LATCH	-- --SEE HEADER
-- 	3	| xFEDCBA98	| WB_REG	-- --TEST_SIGNAL
--	4	| LATCH_D[0]	| WB_LATCH	--
-- 	5	| LATCH_D[1]	| WB_LATCH	--
-- 	6	| LATCH_D[2]	| WB_LATCH	--
-- 	7	| LATCH_D[3]	| WB_LATCH	--
--------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

--NB The DATA_WIDTH and ADDR_WIDTH constants are set in the dprimitives package
entity wb_multi_latch_ip is
	generic(
		BASE_ADDR       : UNSIGNED(ADDR_WIDTH + 3 downto 0) := x"00000000";
		CORE_DATA_WIDTH : NATURAL                           := 32;
		CORE_ADDR_WIDTH : NATURAL                           := 3
	);
	port(
		--System Control Inputs
		CLK_I   : in  STD_LOGIC;
		RST_I   : in  STD_LOGIC;
		--Slave to WB
		WB_MS   : in  WB_MS_type;
		WB_SM   : out WB_SM_type;
		--LATCH Inputs
		LATCH_D : in  DWORD_vector(3 downto 0)
	);
end entity wb_multi_latch_ip;

architecture RTL of wb_multi_latch_ip is
	signal adr_i : STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0);
	signal dat_o : STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
	signal stb_i : STD_LOGIC;
	signal ack_o : STD_LOGIC;
	signal cyc_i : STD_LOGIC;

	component wb_multi_latch is
		generic(
			CORE_DATA_WIDTH : natural := 32;
			CORE_ADDR_WIDTH : natural := 3
		);
		port(
			--System Control Inputs
			CLK_I   : in  STD_LOGIC;
			RST_I   : in  STD_LOGIC;
			--Wishbone Slave Lines
			ADR_I   : in  STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0);
			DAT_O   : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
			STB_I   : in  STD_LOGIC;
			ACK_O   : out STD_LOGIC;
			CYC_I   : in  STD_LOGIC;
			--SPI Interface
			LATCH_D : in  DWORD_vector(3 downto 0)
		);
	end component wb_multi_latch;
begin
	bus_logic : wb_s
		generic map(
			BASE_ADDR       => BASE_ADDR,
			CORE_ID         => x"00054008", -- SEE HEADER
			CORE_DATA_WIDTH => CORE_DATA_WIDTH,
			CORE_ADDR_WIDTH => CORE_ADDR_WIDTH
		)
		port map(
			CLK_I => CLK_I,
			RST_I => RST_I,
			WB_MS => WB_MS,
			WB_SM => WB_SM,
			ADR_I => adr_i,
			DAT_I => open,
			DAT_O => dat_o,
			WE_I  => open,
			STB_I => stb_i,
			ACK_O => ack_o,
			CYC_I => cyc_i
		);

	user_logic : wb_multi_latch
		generic map(
			CORE_DATA_WIDTH => CORE_DATA_WIDTH,
			CORE_ADDR_WIDTH => CORE_ADDR_WIDTH
		)
		port map(
			CLK_I   => CLK_I,
			RST_I   => RST_I,
			ADR_I   => adr_i,
			DAT_O   => dat_o,
			STB_I   => stb_i,
			ACK_O   => ack_o,
			CYC_I   => cyc_i,
			LATCH_D => LATCH_D
		);

end architecture RTL;
