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
-- Name:		GPMC_M (011) -- Should technically be GPMC_S, since it is a slave on the GPMC bus
-- Type:		PRIMITIVE (2)
-- Description:		This primitive performs all the task required to convert the signals from the ARM's GPMC
--			into Wishbone Master signals. Performance is not optimal, however, the system is able to
--			perform succesful read and writes to wb_register primitives.
-- 
-- Compliance:		DUGONG V0.3
-- ID:			x 0-3-2-00B
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

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

	--Signal to hold data ready to send out to GPMC
	signal gpmc_dout : std_logic_vector(15 downto 0);

	--Internal Control Signals
	signal word_sel            : std_logic;
	signal read_stb            : std_logic;
	signal read_ack            : std_logic;
	signal write_stb           : std_logic;
	signal write_ack           : std_logic;
	signal gpmc_data_not_valid : std_logic;

begin
	process(CLK_I, RST_I, ACK_I, cyc_ms, read_stb, read_ack, write_stb, write_ack)
	begin
		--RST STATE
		if (RST_I = '1') then
			dat_sm    <= (others => '0');
			we_ms     <= '0';
			stb_ms    <= '0';
			cyc_ms    <= '0';
			read_ack  <= '0';
			write_ack <= '0';
		else
			--Perform Clock Rising Edge operations
			if (rising_edge(CLK_I)) then
				if (stb_ms = '1') then
					if (ACK_I = '1') then
						dat_sm    <= DAT_I;
						we_ms     <= '0';
						stb_ms    <= '0';
						read_ack  <= not we_ms;
						write_ack <= we_ms;
					elsif (ERR_I = '1') then
						dat_sm    <= "00" & adr_ms & "00";
						we_ms     <= '0';
						stb_ms    <= '0';
						read_ack  <= not we_ms;
						write_ack <= we_ms;
					end if;
				elsif ((read_stb or write_stb) = '1') then
					if ((read_ack and write_ack) = '0') then
						cyc_ms <= '1';
						stb_ms <= '1';
						we_ms  <= write_stb;
					end if;
				else
					cyc_ms <= '0';
				end if;

				if (read_ack = '1') then
					read_ack <= read_stb;
				end if;

				if (write_ack = '1') then
					write_ack <= write_stb;
				end if;
			end if;
		end if;
	end process;

	process(GPMC_CLK_I, RST_I, read_stb, read_ack, write_stb, write_ack)
	begin
		--RST STATE
		if (RST_I = '1') then
			read_stb            <= '0';
			write_stb           <= '0';
			gpmc_data_not_valid <= '0';
			word_sel            <= '0';
			adr_ms              <= (others => '0');
			dat_ms              <= (others => '0');
		else
			if ((read_stb = '1') and (read_ack = '1')) then
				read_stb <= '0';
			elsif ((write_stb = '1') and (write_ack = '1')) then
				write_stb <= '0';
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
							read_stb            <= not GPMC_D_B(0); --Read on first cycle
							gpmc_data_not_valid <= '1';
						elsif (GPMC_nWE_I = '0') then
							if (word_sel = '1') then
								dat_ms(31 downto 16) <= GPMC_D_B;
								write_stb            <= '1'; --Write on second cycle
							else
								dat_ms(15 downto 0) <= GPMC_D_B;
							end if;
							gpmc_data_not_valid <= '0';
						elsif (GPMC_nOE_I = '0') then
							gpmc_data_not_valid <= read_stb;
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

	gpmc_dout <= dat_sm(31 downto 16) when word_sel = '1' else dat_sm(15 downto 0);

	GPMC_WAIT_O <= not gpmc_data_not_valid;

	--GPMC tri-state buffers for GPMC Bidirectional Data Bus
	GPMC_D_B <= gpmc_dout when GPMC_nOE_I = '0' else (others => 'Z');

	DEBUG <= word_sel & read_stb & read_ack & write_stb & write_ack & we_ms & stb_ms & ACK_I & cyc_ms & ERR_I & GPMC_CLK_I & GPMC_A_I & GPMC_nCS_I & GPMC_nADV_ALE_I & GPMC_nWE_I & GPMC_nOE_I & not gpmc_data_not_valid;

end Behavioral;