library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.numeric_std.ALL;

library unisim;
use unisim.vcomponents.all;

entity ads62p49_parallelizer is
	port(
		--System Control Inputs
		RST_I        : in  STD_LOGIC;
		--Signal Channel Inputs
		ADC_CLK_O    : out STD_LOGIC;
		CH_A_O       : out STD_LOGIC_VECTOR(13 downto 0);
		CH_B_O       : out STD_LOGIC_VECTOR(13 downto 0);
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

	signal adc_dclk_pll_fbout : std_logic;
	signal adc_dclk_pll_fbin  : std_logic;

	signal adc_clk   : std_logic;
	signal adc_clk_b : std_logic;

	signal ioclk0 : std_logic;
	signal ioclk1 : std_logic;

	signal adc_data_a_b : STD_LOGIC_VECTOR(6 downto 0);
	signal adc_data_b_b : STD_LOGIC_VECTOR(6 downto 0);

	signal i : std_logic_vector(13 downto 0);
	signal q : std_logic_vector(13 downto 0);

	signal i_d1 : std_logic_vector(13 downto 0);
	signal q_d1 : std_logic_vector(13 downto 0);

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

	ADC_DCLK_PLL : PLL_BASE
		generic map(
			BANDWIDTH             => "OPTIMIZED",
			CLKFBOUT_MULT         => 4,
			CLKFBOUT_PHASE        => 0.0,
			CLKIN_PERIOD          => 4.069,
			-- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for CLKOUT# clock output (1-128)
			CLKOUT0_DIVIDE        => 4,
			CLKOUT1_DIVIDE        => 1,
			CLKOUT2_DIVIDE        => 1,
			CLKOUT3_DIVIDE        => 1,
			CLKOUT4_DIVIDE        => 1,
			CLKOUT5_DIVIDE        => 1,
			-- CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for CLKOUT# clock output (0.01-0.99).
			CLKOUT0_DUTY_CYCLE    => 0.5,
			CLKOUT1_DUTY_CYCLE    => 0.5,
			CLKOUT2_DUTY_CYCLE    => 0.5,
			CLKOUT3_DUTY_CYCLE    => 0.5,
			CLKOUT4_DUTY_CYCLE    => 0.5,
			CLKOUT5_DUTY_CYCLE    => 0.5,
			-- CLKOUT0_PHASE - CLKOUT5_PHASE: Output phase relationship for CLKOUT# clock output (-360.0-360.0).
			CLKOUT0_PHASE         => 0.0,
			CLKOUT1_PHASE         => 0.0,
			CLKOUT2_PHASE         => 0.0,
			CLKOUT3_PHASE         => 0.0,
			CLKOUT4_PHASE         => 0.0,
			CLKOUT5_PHASE         => 0.0,
			CLK_FEEDBACK          => "CLKFBOUT",
			COMPENSATION          => "SYSTEM_SYNCHRONOUS",
			DIVCLK_DIVIDE         => 1,
			REF_JITTER            => 0.1,
			RESET_ON_LOSS_OF_LOCK => FALSE
		)
		port map(
			CLKFBOUT => adc_dclk_pll_fbout,
			CLKOUT0  => adc_clk,
			CLKOUT1  => open,
			CLKOUT2  => open,
			CLKOUT3  => open,
			CLKOUT4  => open,
			CLKOUT5  => open,
			LOCKED   => open,
			CLKFBIN  => adc_dclk_pll_fbin,
			CLKIN    => adc_dclk_b,
			RST      => '0'
		);

	ADC_DCLK_PLL_FB_BUFG : BUFG
		port map(
			O => adc_dclk_pll_fbin,
			I => adc_dclk_pll_fbout
		);

	ADC_CLK_BUFG : BUFG
		port map(
			O => adc_clk_b,
			I => adc_clk
		);

	ioclk0 <= adc_clk_b;
	ioclk1 <= not adc_clk_b;

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

	----------------------------Output Pipelining----------------------------

	process(adc_clk_b)
	begin
		--Perform Clock Rising Edge operations
		if (falling_edge(adc_clk_b)) then
			i_d1 <= i;
			q_d1 <= q;
		end if;

		if (rising_edge(adc_clk_b)) then
			CH_A_O <= i_d1;
			CH_B_O <= q_d1;
		end if;
	end process;

	ADC_CLK_O <= adc_clk_b;

end architecture RTL;
