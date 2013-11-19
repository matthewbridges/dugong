library ieee;

use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

library unisim;
use unisim.vcomponents.all;

entity ads62p49_parallelizer is
	port(
		--System Control Inputs
		RST_I        : in  STD_LOGIC;
		--Signal Channel Inputs
		ADC_CLK_O    : out STD_LOGIC;
		CH_A_O       : out STD_LOGIC_VECTOR(15 downto 0);
		CH_B_O       : out STD_LOGIC_VECTOR(15 downto 0);
		-- FMC150 ADC interface
		ADC_DCLK_P   : in  STD_LOGIC;
		ADC_DCLK_N   : in  STD_LOGIC;
		ADC_DATA_A_P : in  STD_LOGIC_VECTOR(6 downto 0);
		ADC_DATA_A_N : in  STD_LOGIC_VECTOR(6 downto 0);
		ADC_DATA_B_P : in  STD_LOGIC_VECTOR(6 downto 0);
		ADC_DATA_B_N : in  STD_LOGIC_VECTOR(6 downto 0)
	);
end entity ads62p49_parallelizer;

architecture RTL of ads62p49_parallelizer is
	signal adc_dclk_b : std_logic;
	signal ioclk0     : std_logic;
	signal ioclk1     : std_logic;
	signal adc_clk    : std_logic;
	signal adc_clk_b  : std_logic;

	signal adc_data_a_b : STD_LOGIC_VECTOR(6 downto 0);
	signal adc_data_b_b : STD_LOGIC_VECTOR(6 downto 0);

	signal i : std_logic_vector(13 downto 0);
	signal q : std_logic_vector(13 downto 0);

	signal i_signed16 : std_logic_vector(15 downto 0);
	signal q_signed16 : std_logic_vector(15 downto 0);

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
			DIVCLK       => adc_clk,
			IOCLK        => ioclk1,
			SERDESSTROBE => open,
			I            => adc_dclk_b
		);

	ADC_CLK_BUFG : BUFG
		port map(
			O => adc_clk_b,
			I => adc_clk
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

	----------------------------O----------------------------

	process(adc_clk_b)
	begin
		--Perform Clock Rising Edge operations
		if (rising_edge(adc_clk_b)) then
			--Check for reset
			if (RST_I = '1') then
				i_signed16 <= (others => '0');
				q_signed16 <= (others => '0');
			else
				i_signed16 <= i & i(13) & i(13);
				q_signed16 <= q & q(13) & q(13);
			end if;
		end if;
	end process;

	CH_A_O    <= i_signed16;
	CH_B_O    <= q_signed16;
	ADC_CLK_O <= adc_clk_b;

end architecture RTL;
