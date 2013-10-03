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
-- Name:		DPRIMITIVES (002)
-- Type:		PACKAGE (1)
-- Description:		A package containing primitives that are used by the DUGONG IP Cores	
--
-- Compliance:		DUGONG V0.3
-- ID:			x 0-3-1-002
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package dprimitives is
	constant DATA_WIDTH : natural := 32;
	constant ADDR_WIDTH : natural := 28;

	subtype WB_MS_type is std_logic_vector(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
	type WB_MS_vector is array (natural range <>) of WB_MS_type;

	subtype WB_SM_type is std_logic_vector(DATA_WIDTH downto 0);
	type WB_SM_vector is array (natural range <>) of WB_SM_type;

	subtype WORD is std_logic_vector(15 downto 0);
	subtype DWORD is std_logic_vector(31 downto 0);
	subtype QWORD is std_logic_vector(63 downto 0);

	type WORD_vector is array (natural range <>) of WORD;
	type DWORD_vector is array (natural range <>) of DWORD;
	type QWORD_vector is array (natural range <>) of QWORD;

	subtype ADDR_type is unsigned(ADDR_WIDTH - 1 downto 0);

	constant DEFAULT_ADDR : ADDR_TYPE := (others => '0');

	function min_num_of_bits(highest_number : natural) return natural;

	component sys_con is
		port(
			--System Clock Differential Inputs 100MHz
			SYS_CLK_P      : in  STD_LOGIC;
			SYS_CLK_N      : in  STD_LOGIC;
			--System Clock Differential Outputs 100MHz
			SYS_CLK_o      : out STD_LOGIC;
			--System Reset Input
			SYS_RST        : in  STD_LOGIC;
			--System Status
			SYS_PWR_ON     : out STD_LOGIC;
			SYS_PLL_Locked : out STD_LOGIC;
			--System Control Outputs
			CLK_100MHz_P   : out STD_LOGIC;
			CLK_100MHz_N   : out STD_LOGIC;
			RST_O          : out STD_LOGIC;
			--SPI Clock Outputs
			CLK_10MHz_P    : out STD_LOGIC;
			CLK_10MHz_N    : out STD_LOGIC
		);
	end component sys_con;

	------------------------------
	---- ARM SIDE INTERFACING ----
	------------------------------ 

	component gpmc_s is
		generic(
			GPMC_ADDR_WIDTH : natural := 28
		);
		port(
			--System Control Inputs
			CLK_I           : in    STD_LOGIC;
			RST_I           : in    STD_LOGIC;
			--Wishbone Master Interface
			ADR_O           : out   STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
			DAT_I           : in    STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			DAT_O           : out   STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			WE_O            : out   STD_LOGIC;
			STB_O           : out   STD_LOGIC;
			ACK_I           : in    STD_LOGIC;
			CYC_O           : out   STD_LOGIC;
			ERR_I           : in    STD_LOGIC;
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
			DEBUG           : out   STD_LOGIC_VECTOR(31 downto 0)
		);
	end component gpmc_s;

	-----------------------------
	---- WB SIDE INTERFACING ----
	-----------------------------

	component wb_m is
		port(
			--System Control Inputs
			CLK_I     : in  STD_LOGIC;
			RST_I     : in  STD_LOGIC;
			--Master to WB
			WB_MS     : out WB_MS_type;
			WB_SM     : in  WB_SM_type;
			--Wishbone Master Interface (inverted)
			ADR_O     : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
			DAT_I     : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			DAT_O     : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			WE_O      : in  STD_LOGIC;
			STB_O     : in  STD_LOGIC;
			ACK_I     : out STD_LOGIC;
			CYC_O     : in  STD_LOGIC;
			--Wishbone Error Signal
			ERR_I     : out STD_LOGIC;
			--Wishbone Arbitration Signal
			GNT_I     : in  STD_LOGIC;
			--STATUS SIGNALS
			T_COUNT_O : out STD_LOGIC_VECTOR(31 downto 0);
			E_COUNT_O : out STD_LOGIC_VECTOR(31 downto 0)
		);
	end component;

	component wb_s is
		generic(
			BASE_ADDR       : UNSIGNED(ADDR_WIDTH + 3 downto 0) := x"00000000";
			CORE_ID         : UNSIGNED(31 downto 0)             := x"00032002"; -- SEE HEADER
			CORE_DATA_WIDTH : NATURAL                           := 16;
			CORE_ADDR_WIDTH : NATURAL                           := 3
		);
		port(
			--System Control Inputs
			CLK_I : in  STD_LOGIC;
			RST_I : in  STD_LOGIC;
			--Slave to WB
			WB_MS : in  WB_MS_type;
			WB_SM : out WB_SM_type;
			--Wishbone Slave Interface (inverted)
			ADR_I : out STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0);
			DAT_I : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
			DAT_O : in  STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
			WE_I  : out STD_LOGIC;
			STB_I : out STD_LOGIC;
			ACK_O : in  STD_LOGIC;
			CYC_I : out STD_LOGIC
		);
	end component;

	component wb_arbiter_intercon is
		generic(
			NUMBER_OF_MASTERS : NATURAL := 2;
			NUMBER_OF_SLAVES  : NATURAL := 5
		);
		port(
			--System Control Inputs
			CLK_I     : in  STD_LOGIC;
			RST_I     : in  STD_LOGIC;
			--Masters to WB
			WB_MS     : in  WB_MS_vector(NUMBER_OF_MASTERS - 1 downto 0);
			WB_MS_BUS : out WB_MS_type;
			--Slaves to WB
			WB_SM     : in  WB_SM_vector(NUMBER_OF_SLAVES - 1 downto 0);
			WB_SM_BUS : out WB_SM_type;
			--Master Arbitration
			WB_GNT_O  : out STD_LOGIC_VECTOR(NUMBER_OF_MASTERS - 1 downto 0)
		);
	end component;

	----------------------------------------
	---- Wishbone Slave Memory Elements ----
	----------------------------------------

	component wb_register is
		generic(
			DATA_WIDTH   : NATURAL                       := 32;
			DEFAULT_DATA : STD_LOGIC_VECTOR(31 downto 0) := x"00000000"
		);
		port(
			--System Control Inputs:
			CLK_I : in  STD_LOGIC;
			RST_I : in  STD_LOGIC;
			--WISHBONE SLAVE interface
			DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			WE_I  : in  STD_LOGIC;
			STB_I : in  STD_LOGIC;
			ACK_O : out STD_LOGIC
		);
	end component;

	component wb_fifo is
		generic(
			DATA_WIDTH : NATURAL := 32;
			FIFO_DEPTH : NATURAL := 4
		);
		port(
			--System Control Inputs:
			RST_I    : in  STD_LOGIC;
			--WRITE PORT
			--WISHBONE SLAVE interface (WRITE-ONLY)
			WR_CLK_I : in  STD_LOGIC;
			WR_DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			WR_WE_I  : in  STD_LOGIC;
			WR_STB_I : in  STD_LOGIC;
			WR_ACK_O : out STD_LOGIC;
			--READ PORT
			--WISHBONE SLAVE interface (READ-ONLY)
			RD_CLK_I : in  STD_LOGIC;
			RD_DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			RD_STB_I : in  STD_LOGIC;
			RD_ACK_O : out STD_LOGIC;
			--STATUS SIGNALS
			FULL     : out STD_LOGIC;
			EMPTY    : out STD_LOGIC
		);
	end component;

	component wb_latch is
		generic(
			DATA_WIDTH : NATURAL := 32
		);
		port(
			--System Control Inputs:
			CLK_I : in  STD_LOGIC;
			RST_I : in  STD_LOGIC;
			--WISHBONE SLAVE interface
			DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			STB_I : in  STD_LOGIC;
			ACK_O : out STD_LOGIC
		);
	end component;

	component wb_const is
		generic(
			DATA_WIDTH   : NATURAL                       := 32;
			DEFAULT_DATA : STD_LOGIC_VECTOR(31 downto 0) := x"00000000"
		);
		port(
			--System Control Inputs:
			CLK_I : in  STD_LOGIC;
			RST_I : in  STD_LOGIC;
			--WISHBONE SLAVE interface
			DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			STB_I : in  STD_LOGIC;
			ACK_O : out STD_LOGIC
		);
	end component;

	-------------------------
	---- Memory Elements ----
	-------------------------

	component bram_sync_sp is
		generic(
			DATA_WIDTH : natural := 32;
			ADDR_WIDTH : natural := 10
		);
		port(
			--System Control Inputs:
			CLK_I : in  STD_LOGIC;
			RST_I : in  STD_LOGIC;
			--PORT
			ADR_I : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
			DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			STB_I : in  STD_LOGIC;
			ACK_O : out STD_LOGIC;
			WE_I  : in  STD_LOGIC
		);
	end component;

	component wb_bram_sync_dp_simple is
		generic(
			DATA_WIDTH : natural := 32;
			ADDR_WIDTH : natural := 10
		);
		port(
			--System Control Inputs:
			RST_I   : in  STD_LOGIC;
			--PORT A
			A_CLK_I : in  STD_LOGIC;
			A_DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			A_ADR_I : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
			A_WE_I  : in  STD_LOGIC;
			A_STB_I : in  STD_LOGIC;
			A_ACK_O : out STD_LOGIC;
			--PORT B
			B_CLK_I : in  STD_LOGIC;
			B_DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			B_ADR_I : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
			B_STB_I : in  STD_LOGIC;
			B_ACK_O : out STD_LOGIC
		);
	end component wb_bram_sync_dp_simple;

	component bram_sync_dp_true is
		generic(
			DATA_WIDTH : natural := 32;
			ADDR_WIDTH : natural := 10
		);
		port(
			--PORT A
			A_CLK_I : in  STD_LOGIC;
			A_DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			A_DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			A_ADR_I : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
			A_WE_I  : in  STD_LOGIC;
			--PORT B
			B_CLK_I : in  STD_LOGIC;
			B_DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			B_DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			B_ADR_I : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
			B_WE_I  : in  STD_LOGIC
		);
	end component bram_sync_dp_true;

end package dprimitives;

package body dprimitives is
	function min_num_of_bits(highest_number : natural) return natural is
		variable num       : natural := 0;
		variable remainder : natural := highest_number;
	begin
		while (remainder >= 1) loop
			remainder := remainder / 2;
			num       := num + 1;
		end loop;

		return num;
	end function;
end package body dprimitives;