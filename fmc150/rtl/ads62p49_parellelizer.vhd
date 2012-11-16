library ieee;

use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

library unisim;
use unisim.vcomponents.all;

entity ads62p49_parellelizer is
	generic(
		DATA_WIDTH : natural := 16;
		ADDR_WIDTH : natural := 5
	);
	port(
		--System Control Inputs
		CLK_I        : in  STD_LOGIC;
		RST_I        : in  STD_LOGIC;
		--Signal Channel Inputs
		DSP_CLK_I    : in  STD_LOGIC;
		CH_A_O       : out STD_LOGIC_VECTOR(15 downto 0);
		CH_B_O       : out STD_LOGIC_VECTOR(15 downto 0);
		-- FMC150 ADC interface
		ADC_DCLK_P   : in  STD_LOGIC;
		ADC_DCLK_N   : in  STD_LOGIC;
		ADC_DATA_A_P : in  STD_LOGIC_VECTOR(6 downto 0);
		ADC_DATA_A_N : in  STD_LOGIC_VECTOR(6 downto 0);
		ADC_DATA_B_P : in  STD_LOGIC_VECTOR(6 downto 0);
		ADC_DATA_B_N : in  STD_LOGIC_VECTOR(6 downto 0);
		-- Debug
		DEBUG        : out STD_LOGIC_VECTOR(15 downto 0)
	);
end entity ads62p49_parellelizer;

architecture RTL of ads62p49_parellelizer is
	signal adc_dclk_b : std_logic;
	signal ioclk0     : std_logic;
	signal ioclk1     : std_logic;

	signal adc_data_a_b : STD_LOGIC_VECTOR(6 downto 0);
	signal adc_data_b_b : STD_LOGIC_VECTOR(6 downto 0);

	signal i : std_logic_vector(13 downto 0);
	signal q : std_logic_vector(13 downto 0);

begin

	----------------------------SET UP CLOCKING AND PLLs----------------------------

	ADC_DCLK_IBUFGDS : IBUFGDS
		generic map(
			IOSTANDARD => "LVDS_25",
			DIFF_TERM  => TRUE
		)
		port map(
			O  => adc_dclk_b,
			I  => ADC_DCLK_P,
			IB => ADC_DCLK_N
		);

	ADC_IOCLK0_BUFIO2 : BUFIO2
		generic map(
			I_INVERT    => FALSE,
			USE_DOUBLER => FALSE
		)
		port map(
			DIVCLK       => open,
			IOCLK        => ioclk0,
			SERDESSTROBE => open,
			I            => adc_dclk_b
		);

	ADC_IOCLK1_BUFIO2 : BUFIO2
		generic map(
			I_INVERT    => TRUE,
			USE_DOUBLER => FALSE
		)
		port map(
			DIVCLK       => open,
			IOCLK        => ioclk1,
			SERDESSTROBE => open,
			I            => adc_dclk_b
		);

	----------------------------DATA(6:0) IO AND BUFFERING----------------------------
	ADC_DATA_pins : for pin_count in 6 downto 0 generate
		ADC_DATA_A_IBUFDS : IBUFDS
			generic map(
				IOSTANDARD => "LVDS_25",
				DIFF_TERM  => TRUE
			)
			port map(
				O  => adc_data_a_b(pin_count),
				I  => ADC_DATA_A_P(pin_count),
				IB => ADC_DATA_A_N(pin_count)
			);

		ADC_DATA_B_IBUFDS : IBUFDS
			generic map(
				IOSTANDARD => "LVDS_25",
				DIFF_TERM  => TRUE
			)
			port map(
				O  => adc_data_b_b(pin_count),
				I  => ADC_DATA_B_P(pin_count),
				IB => ADC_DATA_B_N(pin_count)
			);

		ADC_DATA_A_IDDR2 : IDDR2
			generic map(
				DDR_ALIGNMENT => "C1",
				INIT_Q0       => '0',
				INIT_Q1       => '0',
				SRTYPE        => "SYNC"
			)
			port map(
				Q0 => i(2 * pin_count + 1),
				Q1 => i(2 * pin_count),
				C0 => ioclk0,
				C1 => ioclk1,
				CE => '1',
				D  => adc_data_a_b(pin_count),
				R  => RST_I,
				S  => '0'
			);

		ADC_DATA_B_IDDR2 : IDDR2
			generic map(
				DDR_ALIGNMENT => "C1",
				INIT_Q0       => '0',
				INIT_Q1       => '0',
				SRTYPE        => "SYNC"
			)
			port map(
				Q0 => q(2 * pin_count + 1),
				Q1 => q(2 * pin_count),
				C0 => ioclk0,
				C1 => ioclk1,
				CE => '1',
				D  => adc_data_b_b(pin_count),
				R  => RST_I,
				S  => '0'
			);
	end generate ADC_DATA_pins;

	process(DSP_CLK_I)
	begin
		--Perform Clock Rising Edge operations
		if (rising_edge(DSP_CLK_I)) then
			--Check for reset
			if (RST_I = '1') then
				CH_A_O <= (others => '0');
				CH_B_O <= (others => '0');
			else
				CH_A_O <= i & "10";
				CH_B_O <= q & "10";
			end if;
		end if;
	end process;

	--	process(adc_dclk_b)
	--		variable temp : unsigned(7 downto 0);
	--	begin
	--		--Perform Clock Rising Edge operations
	--		if (rising_edge(adc_dclk_b)) then
	--			--Check for reset
	--			if (RST_I = '1') then
	--				temp := (others => '0');
	--			else
	--				temp := temp + 1;
	--			end if;
	--			DEBUG(7 downto 0) <= std_logic_vector(temp);
	--		end if;
	--	end process;

	--Debug

	--ODDR for Clock Forwarding
	SYS_CLK_o_ODDR2 : ODDR2
		generic map(
			DDR_ALIGNMENT => "NONE",    -- Sets output alignment to "NONE", "C0", "C1"
			INIT          => '0',       -- Sets initial state of the Q output to '0' or '1'
			SRTYPE        => "SYNC"
		)                               -- Specifies "SYNC" or "ASYNC" set/reset
		port map(
			Q  => Debug(13),            -- 1-bit output data
			C0 => adc_dclk_b,             -- 1-bit clock input
			C1 => not adc_dclk_b,             -- 1-bit clock input
			CE => '1',                  -- 1-bit clock enable input
			D0 => '1',                  -- 1-bit data input (associated with C0)
			D1 => '0',                  -- 1-bit data input (associated with C1)
			R  => '0',                  -- 1-bit reset input
			S  => '0'                   -- 1-bit set input
		);

	DEBUG(12 downto 0)  <= q(12 downto 0);
	DEBUG(15 downto 14) <= adc_data_b_b(1 downto 0);

end architecture RTL;
