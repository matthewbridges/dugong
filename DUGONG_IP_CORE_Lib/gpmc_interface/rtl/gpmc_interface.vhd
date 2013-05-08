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

--library DUGONG_IP_CORES;
--use DUGONG_IP_CORES.dcores.ALL;

entity gpmc_interface is
	generic(
		DATA_WIDTH : natural := 32;
		ADDR_WIDTH : natural := 10
	);
	port(
		--System Control Inputs
		CLK_I           : in    STD_LOGIC;
		RST_I           : in    STD_LOGIC;
		--Wishbone Slave Lines
		DAT_I           : in    STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DAT_O           : out   STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		ADR_I           : in    STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		STB_I           : in    STD_LOGIC;
		WE_I            : in    STD_LOGIC;
		--CYC_I : in   STD_LOGIC;
		ACK_O           : out   STD_LOGIC;
		--GPMC Interface
		GPMC_CLK_I      : in    STD_LOGIC;
		GPMC_D_B        : inout STD_LOGIC_VECTOR(15 downto 0);
		GPMC_A_I        : in    STD_LOGIC_VECTOR(1 downto 1); -- Debugging
		GPMC_nCS_I      : in    STD_LOGIC;
		GPMC_nWE_I      : in    STD_LOGIC;
		GPMC_nOE_I      : in    STD_LOGIC;
		GPMC_nADV_ALE_I : in    STD_LOGIC
	);
end gpmc_interface;

architecture Behavioral of gpmc_interface is
	signal gpmc_din  : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal gpmc_dout : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal gpmc_addr : std_logic_vector(16 downto 0);

	component bram_sync_dp
		generic(
			DATA_WIDTH : natural := 32;
			ADDR_WIDTH : natural := 10
		);
		port(
			A_CLK_I : in  STD_LOGIC;
			A_DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			A_DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			A_ADR_I : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
			A_WE_I  : in  STD_LOGIC;
			B_CLK_I : in  STD_LOGIC;
			B_DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			B_DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			B_ADR_I : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
			B_WE_I  : in  STD_LOGIC
		);
	end component bram_sync_dp;
begin
	process(CLK_I)
	begin
		--Perform Clock Rising Edge operations
		if (rising_edge(CLK_I)) then
			--RST STATE
			if (RST_I = '1') then
				ACK_O <= '0';
			else
				ACK_O <= STB_I;
			end if;
		end if;
	end process;

	process(GPMC_CLK_I)
	begin
		--Perform Clock Rising Edge operations
		if (rising_edge(GPMC_CLK_I)) then
			--First cycle of the bus transaction record the address
			if (GPMC_nADV_ALE_I = '0') then
				gpmc_addr <= GPMC_A_I & GPMC_D_B; -- Address of 16 bit word
			end if;
		end if;
	end process;

	inst : bram_sync_dp
		generic map(
			DATA_WIDTH => DATA_WIDTH,
			ADDR_WIDTH => ADDR_WIDTH
		)
		port map(
			A_CLK_I => CLK_I,
			A_DAT_I => DAT_I,
			A_DAT_O => DAT_O,
			A_ADR_I => ADR_I,
			A_WE_I  => WE_I,
			B_CLK_I => GPMC_CLK_I,
			B_DAT_I => gpmc_din,
			B_DAT_O => gpmc_dout,
			B_ADR_I => gpmc_addr(10 downto 1),
			B_WE_I  => GPMC_nWE_I
		);

	gpmc_din <= x"0000" & GPMC_D_B;

	--GPMC tri-state buffers for GPMC Bidirectional Data Bus
	GPMC_D_B <= gpmc_dout(15 downto 0) when GPMC_nOE_I = '0' else (others => 'Z');

end Behavioral;
	