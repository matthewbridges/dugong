---------------------------------------------------------------------------------------------------------------
--                    
--\______/\\\\\\\\\_______/\\\________/\\\____/\\\\\\\\\\\____/\\\\\_____/\\\_________/\\\\\_______\      
-- \____/\\\///////\\\____\/\\\_______\/\\\___\/////\\\///____\/\\\\\\___\/\\\_______/\\\///\\\_____\
--  \___\/\\\_____\/\\\____\/\\\_______\/\\\_______\/\\\_______\/\\\/\\\__\/\\\_____/\\\/__\///\\\___\    
--   \___\/\\\\\\\\\\\/_____\/\\\\\\\\\\\\\\\_______\/\\\_______\/\\\//\\\_\/\\\____/\\\______\//\\\__\   
--    \___\/\\\//////\\\_____\/\\\/////////\\\_______\/\\\_______\/\\\\//\\\\/\\\___\/\\\_______\/\\\__\  
--     \___\/\\\____\//\\\____\/\\\_______\/\\\_______\/\\\_______\/\\\_\//\\\/\\\___\//\\\______/\\\___\
--      \___\/\\\_____\//\\\___\/\\\_______\/\\\_______\/\\\_______\/\\\__\//\\\\\\____\///\\\__/\\\_____\
--       \___\/\\\______\//\\\__\/\\\_______\/\\\____/\\\\\\\\\\\___\/\\\___\//\\\\\______\///\\\\\/______\
--        \___\///________\///___\///________\///____\///////////____\///_____\/////_________\/////________\
--         \                                                                                                \
--          \==============  Reconfigurable Hardware Interface for computatioN and radiO  ===================\
--           \============================  http://www.rhinoplatform.org  ====================================\
--            \================================================================================================\
--
---------------------------------------------------------------------------------------------------------------
-- Company:		UNIVERSITY OF CAPE TOWN
-- Engineer: 	MATTHEW BRIDGES
--
-- Name:		GPMC_Interface_IP
-- Type:		IP CORE
-- Description: An IP core containing Shared BRAM/s which can be accessed by both the FPGA and ARM Processor	
--
-- Compliance:	DUGONG V1.0
-- ID:			x1-2-02
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library DUGONG_IP_CORE_Lib;
use DUGONG_IP_CORE_Lib.dcores.ALL;

entity gpmc_interface_ip is
	generic(
		DATA_WIDTH      : NATURAL               := 32;
		ADDR_WIDTH      : NATURAL               := 12;
		BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
		CORE_DATA_WIDTH : NATURAL               := 32;
		CORE_ADDR_WIDTH : NATURAL               := 10
	);
	port(
		--System Control Inputs
		CLK_I           : in    STD_LOGIC;
		RST_I           : in    STD_LOGIC;
		--Slave to WB
		WB_I            : in    STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
		WB_O            : out   STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
		--GPMC Interface
		GPMC_CLK_I      : in    STD_LOGIC;
		GPMC_D_B        : inout STD_LOGIC_VECTOR(15 downto 0);
		GPMC_A_I        : in    STD_LOGIC_VECTOR(1 downto 1);
		GPMC_nCS_I      : in    STD_LOGIC;
		GPMC_nWE_I      : in    STD_LOGIC;
		GPMC_nOE_I      : in    STD_LOGIC;
		GPMC_nADV_ALE_I : in    STD_LOGIC
	);
end gpmc_interface_ip;

architecture Behavioral of gpmc_interface_ip is
	signal dat_i : STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
	signal dat_o : STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
	signal adr_i : STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0);
	signal stb_i : STD_LOGIC;
	signal we_i  : STD_LOGIC;
	signal ack_o : STD_LOGIC;

	component gpmc_interface
		generic(
			DATA_WIDTH : natural := 32;
			ADDR_WIDTH : natural := 10
		);
		port(
			CLK_I           : in    STD_LOGIC;
			RST_I           : in    STD_LOGIC;
			DAT_I           : in    STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			DAT_O           : out   STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			ADR_I           : in    STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
			STB_I           : in    STD_LOGIC;
			WE_I            : in    STD_LOGIC;
			ACK_O           : out   STD_LOGIC;
			GPMC_CLK_I      : in    STD_LOGIC;
			GPMC_D_B        : inout STD_LOGIC_VECTOR(15 downto 0);
			GPMC_A_I        : in    STD_LOGIC_VECTOR(1 downto 1); --debugging
			GPMC_nCS_I      : in    STD_LOGIC;
			GPMC_nWE_I      : in    STD_LOGIC;
			GPMC_nOE_I      : in    STD_LOGIC;
			GPMC_nADV_ALE_I : in    STD_LOGIC
		);
	end component gpmc_interface;

begin
	bus_logic : wb_s
		generic map(
			DATA_WIDTH      => DATA_WIDTH,
			ADDR_WIDTH      => ADDR_WIDTH,
			BASE_ADDR       => BASE_ADDR,
			CORE_DATA_WIDTH => CORE_DATA_WIDTH,
			CORE_ADDR_WIDTH => CORE_ADDR_WIDTH
		)
		port map(
			--System Control Inputs		
			CLK_I => CLK_I,
			RST_I => RST_I,
			--Slave to WB
			WB_I  => WB_I,
			WB_O  => WB_O,
			--Wishbone Slave Lines (inverted)
			DAT_I => dat_i,
			DAT_O => dat_o,
			ADR_I => adr_i,
			STB_I => stb_i,
			WE_I  => we_i,
			CYC_I => open,
			ACK_O => ack_o
		);

	user_logic : gpmc_interface
		generic map(
			DATA_WIDTH => CORE_DATA_WIDTH,
			ADDR_WIDTH => CORE_ADDR_WIDTH
		)
		port map(
			CLK_I           => CLK_I,
			RST_I           => RST_I,
			DAT_I           => dat_i,
			DAT_O           => dat_o,
			ADR_I           => adr_i,
			STB_I           => stb_i,
			WE_I            => we_i,
			ACK_O           => ack_o,
			GPMC_CLK_I      => GPMC_CLK_I,
			GPMC_D_B        => GPMC_D_B,
			GPMC_A_I        => GPMC_A_I,
			GPMC_nCS_I      => GPMC_nCS_I,
			GPMC_nWE_I      => GPMC_nWE_I,
			GPMC_nOE_I      => GPMC_nOE_I,
			GPMC_nADV_ALE_I => GPMC_nADV_ALE_I
		);

end Behavioral;

