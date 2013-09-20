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
-- Name:		
-- Type:		IP_CORE (4)
-- Description: 	An 
--
-- Compliance:		DUGONG V0.3
-- ID:			x 0-
---------------------------------------------------------------------------------------------------------------
--	ADDR	| NAME		| Type		--
--	0	| BASE_ADDR	| WB_LATCH	--
-- 	1	| HIGH_ADDR	| WB_LATCH	--
-- 	2	| CORE_ID	| WB_LATCH	-- --SEE HEADER
-- 	3	| xFEDCBA98	| WB_REG	-- --TEST_SIGNAL
--	4	| SINE_OUT	| WB_LATCH	--
-- 	5	| COS_OUT	| WB_LATCH	--
-- 	6	| FTW		| WB_REG	--
-- 	7	| PHASE		| WB_REG	--
--------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

--NB The DATA_WIDTH and ADDR_WIDTH constants are set in the dprimitives package
entity dds_core_ip is
	generic(
		BASE_ADDR       : UNSIGNED(ADDR_WIDTH + 3 downto 0) := x"00000000";
		CORE_DATA_WIDTH : NATURAL                           := 32;
		CORE_ADDR_WIDTH : NATURAL                           := 3
	);
	port(
		--System Control Inputs
		CLK_I     : in  STD_LOGIC;
		RST_I     : in  STD_LOGIC;
		--Slave to WB
		WB_MS     : in  WB_MS_type;
		WB_SM     : out WB_SM_type;
		--Signal Channel Outputs
		DSP_CLK_I : in  STD_LOGIC;
		CH_A_O    : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
		CH_B_O    : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0)
	);
end dds_core_ip;

architecture Behavioral of dds_core_ip is
	signal adr_i : STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0);
	signal dat_i : STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
	signal dat_o : STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
	signal we_i  : STD_LOGIC;
	signal stb_i : STD_LOGIC;
	signal ack_o : STD_LOGIC;
	signal cyc_i : STD_LOGIC;

	component dds_core
		generic(
			CORE_DATA_WIDTH : natural := 16;
			CORE_ADDR_WIDTH : natural := 3
		);
		port(
			--System Control Inputs
			CLK_I     : in  STD_LOGIC;
			RST_I     : in  STD_LOGIC;
			--Wishbone Slave Lines
			ADR_I     : in  STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0);
			DAT_I     : in  STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
			DAT_O     : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
			WE_I      : in  STD_LOGIC;
			STB_I     : in  STD_LOGIC;
			ACK_O     : out STD_LOGIC;
			CYC_I     : in  STD_LOGIC;
			--Signal Channel Inputs
			DSP_CLK_I : in  STD_LOGIC;
			CH_A_O    : out STD_LOGIC_VECTOR(15 downto 0);
			CH_B_O    : out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component dds_core;

begin
	bus_logic : wb_s
		generic map(
			BASE_ADDR       => BASE_ADDR,
			CORE_ID         => x"00034003", -- SEE HEADER
			CORE_DATA_WIDTH => CORE_DATA_WIDTH,
			CORE_ADDR_WIDTH => CORE_ADDR_WIDTH
		)
		port map(
			CLK_I => CLK_I,
			RST_I => RST_I,
			WB_MS => WB_MS,
			WB_SM => WB_SM,
			ADR_I => adr_i,
			DAT_I => dat_i,
			DAT_O => dat_o,
			WE_I  => we_i,
			STB_I => stb_i,
			ACK_O => ack_o,
			CYC_I => cyc_i
		);

	user_logic : dds_core
		generic map(
			CORE_DATA_WIDTH => CORE_DATA_WIDTH,
			CORE_ADDR_WIDTH => CORE_ADDR_WIDTH
		)
		port map(
			CLK_I     => CLK_I,
			RST_I     => RST_I,
			ADR_I     => adr_i,
			DAT_I     => dat_i,
			DAT_O     => dat_o,
			WE_I      => we_i,
			STB_I     => stb_i,
			ACK_O     => ack_o,
			CYC_I     => cyc_i,
			DSP_CLK_I => DSP_CLK_I,
			CH_A_O    => CH_A_O,
			CH_B_O    => CH_B_O
		);

end Behavioral;

