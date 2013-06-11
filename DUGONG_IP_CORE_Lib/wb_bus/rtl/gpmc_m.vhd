--  
--                    
-- _____/\\\\\\\\\_______/\\\________/\\\____/\\\\\\\\\\\____/\\\\\_____/\\\_________/\\\\\_______      
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
-- Engineer:		MATTHEW BRIDGES
--
-- Name:		
-- Type:		
-- Description:		
-- 
-- Compliance:		DUGONG V1.1 (1-1)
-- ID:			x 1-1-
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--library DUGONG_IP_CORES;
--use DUGONG_IP_CORES.dcores.ALL;

entity gpmc_m is
	generic(
		DATA_WIDTH : natural := 32;
		ADDR_WIDTH : natural := 28
	);
	port(
		GPMC_CLK_I      : in    STD_LOGIC;
		--Master to WB
		WB_MS           : out   STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
		WB_SM           : in    STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		--GPMC Interface
		GPMC_D_B        : inout STD_LOGIC_VECTOR(15 downto 0);
		GPMC_A_I        : in    STD_LOGIC_VECTOR(10 downto 1);
		GPMC_nCS_I      : in    STD_LOGIC_VECTOR(6 downto 0);
		GPMC_nADV_ALE_I : in    STD_LOGIC;
		GPMC_nWE_I      : in    STD_LOGIC;
		GPMC_nOE_I      : in    STD_LOGIC
	);
end gpmc_m;

architecture Behavioral of gpmc_m is
	signal dat_ms : std_logic_vector(DATA_WIDTH - 1 downto 0);
--	alias dat_sm  : std_logic_vector(DATA_WIDTH - 1 downto 0) is WB_SM(DATA_WIDTH - 1 downto 0);
	signal adr_ms : std_logic_vector(ADDR_WIDTH - 1 downto 0);
	signal we_ms  : std_logic;
	signal stb_ms : std_logic;
	signal cyc_ms : std_logic;

	signal gpmc_dout : std_logic_vector(15 downto 0);

	signal gpmc_sel : std_logic;

	signal selected : std_logic;

begin
	selected <= '0' when (GPMC_nCS_I = "1111111") else '1';

	process(GPMC_CLK_I)
	begin
		--Perform Clock Rising Edge operations
		if (rising_edge(GPMC_CLK_I)) then
			--First cycle of the bus transaction record the address
			if (GPMC_nADV_ALE_I = '0') then
				gpmc_sel                        <= GPMC_D_B(0);
				adr_ms(ADDR_WIDTH - 4 downto 0) <= GPMC_A_I & GPMC_D_B(15 downto 1);
				case (GPMC_nCS_I) is
					when "1111110" => adr_ms(ADDR_WIDTH - 1 downto ADDR_WIDTH - 3) <= "000"; --0x00000000
					when "1111101" => adr_ms(ADDR_WIDTH - 1 downto ADDR_WIDTH - 3) <= "001"; --0x08000000
					when "1111011" => adr_ms(ADDR_WIDTH - 1 downto ADDR_WIDTH - 3) <= "010"; --0x10000000
					when "1110111" => adr_ms(ADDR_WIDTH - 1 downto ADDR_WIDTH - 3) <= "011"; --0x18000000
					when "1101111" => adr_ms(ADDR_WIDTH - 1 downto ADDR_WIDTH - 3) <= "100"; --0x20000000
					when "1011111" => adr_ms(ADDR_WIDTH - 1 downto ADDR_WIDTH - 3) <= "101"; --0x28000000
					when "0111111" => adr_ms(ADDR_WIDTH - 1 downto ADDR_WIDTH - 3) <= "111"; --0x38000000
					when others    => adr_ms(ADDR_WIDTH - 1 downto ADDR_WIDTH - 3) <= "110"; --0x30000000
				end case;
			end if;
		end if;
	end process;

	dat_ms(31 downto 16) <= GPMC_D_B when gpmc_sel = '1' else (others => '0');
	dat_ms(15 downto 0)  <= GPMC_D_B when gpmc_sel = '0' else (others => '0');

	gpmc_dout <= "00" & adr_ms(27 downto 14) when gpmc_sel = '1' else adr_ms(13 downto 0) & "00";

	we_ms <= not GPMC_nWE_I;

	WB_MS <= cyc_ms & we_ms & stb_ms & adr_ms & dat_ms;

	--GPMC tri-state buffers for GPMC Bidirectional Data Bus
	GPMC_D_B <= gpmc_dout when GPMC_nOE_I = '0' else (others => 'Z');

end Behavioral;
	