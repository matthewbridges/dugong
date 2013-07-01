--                    
-- _______/\\\\\\\\\_______/\\\________/\\\____/\\\\\\\\\\\____/\\\\\_____/\\\_________/\\\\\_________     
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
-- Engineer:		MATTHEW BRIDGES
--
-- Name:		WB_TEST_SLAVE_IP
-- Type:		IP CORE (4)
-- Description: 	An IP core for controlling GPIO of differing widths. Includes a streaming interface
--			for asynchronous digital IO. This allows bypassing the WB Bus.	
--
-- Compliance:		DUGONG V1.4
-- ID:			x 1-4-4-
---------------------------------------------------------------------------------------------------------------
--	ADDR	| NAME		| Type		--
--	0	| N/A		| WB_REG	--
-- 	1	| N/A		| WB_REG	--
-- 	2	| N/A		| WB_REG	--
-- 	3	| N/A		| WB_REG	--
--	4	| FEEDBACK	| WB_REG	--
--	~	| ""		| ""		--
--------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

--NB The DATA_WIDTH and ADDR_WIDTH constants are set in the dprimitives package
entity wb_test_slave_ip is
	generic(
		BASE_ADDR       : UNSIGNED(ADDR_WIDTH + 3 downto 0) := x"00000000";
		CORE_DATA_WIDTH : NATURAL                           := 32;
		CORE_ADDR_WIDTH : NATURAL                           := 24
	);
	port(
		--System Control Inputs
		CLK_I      : in    STD_LOGIC;
		RST_I      : in    STD_LOGIC;
		--Slave to WB
		WB_MS      : in    WB_MS_type;
		WB_SM      : out   WB_SM_type
	);
end wb_test_slave_ip;

architecture Behavioral of wb_test_slave_ip is
	signal adr_i : STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0);
	signal dat_i : STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
	signal dat_o : STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
	signal we_i  : STD_LOGIC;
	signal stb_i : STD_LOGIC;
	signal ack_o : STD_LOGIC;
	signal cyc_i : STD_LOGIC;

	component wb_test_slave is
		generic(
			DATA_WIDTH : natural := 32;
			ADDR_WIDTH : natural := 20
		);
		port(
			--System Control Inputs
			CLK_I : in  STD_LOGIC;
			RST_I : in  STD_LOGIC;
			--Wishbone Slave Lines
			ADR_I : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
			DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			WE_I  : in  STD_LOGIC;
			STB_I : in  STD_LOGIC;
			ACK_O : out STD_LOGIC;
			CYC_I : in  STD_LOGIC
		);
	end component;

begin
	bus_logic : wb_s
		generic map(
			BASE_ADDR       => BASE_ADDR,
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

	user_logic : wb_test_slave
		generic map(
			DATA_WIDTH => CORE_DATA_WIDTH,
			ADDR_WIDTH => CORE_ADDR_WIDTH
		)
		port map(
			CLK_I => CLK_I,
			RST_I => RST_I,
			ADR_I => ADR_I,
			DAT_I => DAT_I,
			DAT_O => DAT_O,
			WE_I  => WE_I,
			STB_I => STB_I,
			ACK_O => ACK_O,
			CYC_I => CYC_I
		);

end Behavioral;


