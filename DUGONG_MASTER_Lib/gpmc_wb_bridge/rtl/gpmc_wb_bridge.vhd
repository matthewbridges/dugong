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
-- Name:		GPIO_CONTOLLER_IP (002)
-- Type:		IP CORE (4)
-- Description: 	An IP core for controlling GPIO of differing widths. Includes a streaming interface
--			for asynchronous digital IO. This allows bypassing the WB Bus.	
--
-- Compliance:		DUGONG V1.5
-- ID:			x 1-5-4-002
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

--NB The DATA_WIDTH and ADDR_WIDTH constants are set in the dprimitives package
entity gpmc_wb_bridge is
	port(
		--System Control Inputs
		CLK_I           : in    STD_LOGIC;
		RST_I           : in    STD_LOGIC;
		--Master to WB
		WB_MS           : out   WB_MS_type;
		WB_SM           : in    WB_SM_type;
		GNT_I           : in    STD_LOGIC;
		--GPMC Interface
		GPMC_CLK_I      : in    STD_LOGIC;
		GPMC_D_B        : inout STD_LOGIC_VECTOR(15 downto 0);
		GPMC_A_I        : in    STD_LOGIC_VECTOR(10 downto 1);
		GPMC_nCS_I      : in    STD_LOGIC_VECTOR(6 downto 0);
		GPMC_nADV_ALE_I : in    STD_LOGIC;
		GPMC_nWE_I      : in    STD_LOGIC;
		GPMC_nOE_I      : in    STD_LOGIC;
		GPMC_WAIT_O     : out   STD_LOGIC;
		--Debugging Signal
		DEBUG           : out   STD_LOGIC_VECTOR(31 downto 0);
		--STATUS SIGNALS
		T_COUNT_O       : out   STD_LOGIC_VECTOR(31 downto 0);
		E_COUNT_O       : out   STD_LOGIC_VECTOR(31 downto 0)
	);
end entity gpmc_wb_bridge;

architecture Behavioral of gpmc_wb_bridge is
	--Wishbone Master Lines
	signal adr_o : std_logic_vector(ADDR_WIDTH - 1 downto 0);
	signal dat_i : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal dat_o : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal we_o  : std_logic;
	signal stb_o : std_logic;
	signal ack_i : std_logic;
	signal cyc_o : std_logic;
	signal err_i : std_logic;

begin
	bus_logic : wb_m
		port map(
			CLK_I     => CLK_I,
			RST_I     => RST_I,
			WB_MS     => WB_MS,
			WB_SM     => WB_SM,
			ADR_O     => adr_o,
			DAT_I     => dat_i,
			DAT_O     => dat_o,
			WE_O      => we_o,
			STB_O     => stb_o,
			ACK_I     => ack_i,
			CYC_O     => cyc_o,
			ERR_I     => err_i,
			GNT_I     => GNT_I,
			T_COUNT_O => T_COUNT_O,
			E_COUNT_O => E_COUNT_O
		);

	GPMC_interface : gpmc_s
		generic map(
			GPMC_ADDR_WIDTH => 28
		)
		port map(
			CLK_I           => CLK_I,
			RST_I           => RST_I,
			ADR_O           => adr_o,
			DAT_I           => dat_i,
			DAT_O           => dat_o,
			WE_O            => we_o,
			STB_O           => stb_o,
			ACK_I           => ack_i,
			CYC_O           => cyc_o,
			ERR_I           => err_i,
			GPMC_CLK_I      => GPMC_CLK_I,
			GPMC_D_B        => GPMC_D_B,
			GPMC_A_I        => GPMC_A_I,
			GPMC_nCS_I      => GPMC_nCS_I,
			GPMC_nADV_ALE_I => GPMC_nADV_ALE_I,
			GPMC_nWE_I      => GPMC_nWE_I,
			GPMC_nOE_I      => GPMC_nOE_I,
			GPMC_WAIT_O     => GPMC_WAIT_O,
			DEBUG           => DEBUG
		);

end architecture Behavioral;
