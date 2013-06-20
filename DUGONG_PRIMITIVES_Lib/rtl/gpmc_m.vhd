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
-- Name:		
-- Type:		
-- Description:		
-- 
-- Compliance:		DUGONG V1.1
-- ID:			x 1-1-
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library DUGONG_IP_CORE_Lib;
use DUGONG_IP_CORE_Lib.dprimitives.ALL;

--NB The DATA_WIDTH and ADDR_WIDTH constants are set in the dprimitives package
entity gpmc_m is
	generic(
		GPMC_ADDR_WIDTH : natural := 28
	);
	port(
		--System Control Inputs
		CLK_I           : in    STD_LOGIC;
		RST_I           : in    STD_LOGIC;
		--Wishbone Master Lines
		ADR_O           : out   STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		DAT_I           : in    STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DAT_O           : out   STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		WE_O            : out   STD_LOGIC;
		STB_O           : out   STD_LOGIC;
		ACK_I           : in    STD_LOGIC;
		CYC_O           : out   STD_LOGIC;
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
end gpmc_m;

architecture Behavioral of gpmc_m is
	--WB Master Lines
	signal adr_ms : std_logic_vector(GPMC_ADDR_WIDTH - 1 downto 0);
	signal dat_sm : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal dat_ms : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal we_ms  : std_logic;
	--signal sel_ms : stb_logic_vector(? downto 0);
	signal stb_ms : std_logic;
	signal cyc_ms : std_logic;

	signal gpmc_dout : std_logic_vector(15 downto 0);

	signal word_sel : std_logic;
	signal gpmc_stb : std_logic;
	signal gpmc_ack : std_logic;

begin
	process(CLK_I, RST_I, gpmc_stb, gpmc_ack)
	begin
		--RST STATE
		if (RST_I = '1') then
			dat_sm   <= (others => '0');
			we_ms    <= '0';
			stb_ms   <= '0';
			cyc_ms   <= '0';
			gpmc_ack <= '0';
		else
			if ((gpmc_stb = '0') and (gpmc_ack = '1')) then
				gpmc_ack <= '0';
			else
				--Perform Clock Rising Edge operations
				if (rising_edge(CLK_I)) then
					if (stb_ms = '1') then
						if (ACK_I = '1') then
							dat_sm   <= DAT_I;
							we_ms    <= '0';
							stb_ms   <= '0';
							cyc_ms   <= '0';
							gpmc_ack <= '1';
						end if;
					elsif (gpmc_stb = '1') then
						stb_ms <= '1';
						cyc_ms <= '1';
						we_ms  <= word_sel;
					end if;
				end if;
			end if;
		end if;

	end process;

	process(GPMC_CLK_I, RST_I, gpmc_stb, gpmc_ack)
	begin
		--RST STATE
		if (RST_I = '1') then
			gpmc_stb <= '0';
			word_sel <= '0';
			adr_ms   <= (others => '0');
			dat_ms   <= (others => '0');
		else
			if ((gpmc_stb = '1') and (gpmc_ack = '1')) then
				gpmc_stb <= '0';
			else
				--Perform Clock Rising Edge operations
				if (rising_edge(GPMC_CLK_I)) then
					if (GPMC_nCS_I /= "1111111") then
						--First cycle of the bus transaction record the address
						if (GPMC_nADV_ALE_I = '0') then
							word_sel                             <= GPMC_D_B(0);
							adr_ms(GPMC_ADDR_WIDTH - 4 downto 0) <= GPMC_A_I & GPMC_D_B(15 downto 1);
							case (GPMC_nCS_I) is
								when "1111110" => adr_ms(GPMC_ADDR_WIDTH - 1 downto GPMC_ADDR_WIDTH - 3) <= "000"; --0x00000000
								when "1111101" => adr_ms(GPMC_ADDR_WIDTH - 1 downto GPMC_ADDR_WIDTH - 3) <= "001"; --0x08000000
								when "1111011" => adr_ms(GPMC_ADDR_WIDTH - 1 downto GPMC_ADDR_WIDTH - 3) <= "010"; --0x10000000
								when "1110111" => adr_ms(GPMC_ADDR_WIDTH - 1 downto GPMC_ADDR_WIDTH - 3) <= "011"; --0x18000000
								when "1101111" => adr_ms(GPMC_ADDR_WIDTH - 1 downto GPMC_ADDR_WIDTH - 3) <= "100"; --0x20000000
								when "1011111" => adr_ms(GPMC_ADDR_WIDTH - 1 downto GPMC_ADDR_WIDTH - 3) <= "101"; --0x28000000
								when "0111111" => adr_ms(GPMC_ADDR_WIDTH - 1 downto GPMC_ADDR_WIDTH - 3) <= "111"; --0x38000000
								when others    => adr_ms(GPMC_ADDR_WIDTH - 1 downto GPMC_ADDR_WIDTH - 3) <= "110"; --0x30000000
							end case;
							gpmc_stb <= not GPMC_D_B(0);
						elsif (GPMC_nWE_I = '0') then
							if (word_sel = '1') then
								dat_ms(31 downto 16) <= GPMC_D_B;
								gpmc_stb             <= '1';
							else
								dat_ms(15 downto 0) <= GPMC_D_B;
							end if;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;

	ADR_O <= adr_ms(ADDR_WIDTH - 1 downto 0);
	DAT_O <= dat_ms;
	WE_O  <= we_ms;
	STB_O <= stb_ms;
	CYC_O <= cyc_ms;

	--gpmc_dout <= x"0" & adr_ms(GPMC_ADDR_WIDTH - 1 downto 16) when word_sel = '1' else adr_ms(15 downto 0);
	gpmc_dout <= dat_sm(31 downto 16) when word_sel = '1' else dat_sm(15 downto 0);

	GPMC_WAIT_O <= not gpmc_stb;

	--GPMC tri-state buffers for GPMC Bidirectional Data Bus
	GPMC_D_B <= gpmc_dout when GPMC_nOE_I = '0' else (others => 'Z');
	--GPMC_D_B <= x"FEDC" when GPMC_nOE_I = '0' else (others => 'Z');

	DEBUG <= "0000000000" & GPMC_CLK_I & GPMC_A_I & GPMC_nCS_I & GPMC_nADV_ALE_I & GPMC_nWE_I & GPMC_nOE_I & gpmc_stb;

end Behavioral;
	