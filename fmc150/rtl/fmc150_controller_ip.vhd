library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library unisim;
use unisim.vcomponents.all;

library RHINO_DUGONG;
use RHINO_DUGONG.dcomponents.all;

entity fmc150_controller_ip is
	generic(
		DATA_WIDTH      : NATURAL               := 32;
		ADDR_WIDTH      : NATURAL               := 12;
		BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
		CORE_DATA_WIDTH : NATURAL               := 16;
		CORE_ADDR_WIDTH : NATURAL               := 9
	);
	port(
		--System Control Inputs
		CLK_I          : in  STD_LOGIC;
		RST_I          : in  STD_LOGIC;
		--Slave to WB
		WB_I           : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
		WB_O           : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
		--Serial Peripheral Interface
		SPI_SCLK_O     : out STD_LOGIC;
		SPI_MOSI_O     : out STD_LOGIC;
		ADC_MISO_I     : in  STD_LOGIC;
		ADC_N_SS_O     : out STD_LOGIC;
		CDC_MISO_I     : in  STD_LOGIC;
		CDC_N_SS_O     : out STD_LOGIC;
		DAC_MISO_I     : in  STD_LOGIC;
		DAC_N_SS_O     : out STD_LOGIC;
		ADC_RST        : out STD_LOGIC;
		CDC_REF_EN     : out STD_LOGIC;
		CDC_N_RST      : out STD_LOGIC;
		CDC_N_PD       : out STD_LOGIC;
		CDC_PLL_STATUS : in  STD_LOGIC;
		-- Debug
		DEBUG          : out STD_LOGIC_VECTOR(15 downto 0)
	);
end entity fmc150_controller_ip;

architecture RTL of fmc150_controller_ip is
	signal clkout0         : std_ulogic;
	signal clkout0_b       : std_ulogic;
	signal clkout1         : std_ulogic;
	signal clkout1_b       : std_ulogic;
	signal clkfbout        : std_ulogic;
	signal locked_internal : std_logic;
	signal rst             : std_logic;

	signal adc_spi_ce : STD_LOGIC;
	signal adc_mosi   : STD_LOGIC := '0';
	signal adc_miso   : STD_LOGIC;
	signal adc_n_ss   : STD_LOGIC := '1';
	signal cdc_spi_ce : STD_LOGIC;
	signal cdc_mosi   : STD_LOGIC;
	signal cdc_miso   : STD_LOGIC;
	signal cdc_n_ss   : STD_LOGIC;
	signal dac_spi_ce : STD_LOGIC;
	signal dac_mosi   : STD_LOGIC;
	signal dac_miso   : STD_LOGIC;
	signal dac_n_ss   : STD_LOGIC;

	signal n_ss           : std_logic;
	signal transfer_count : unsigned(6 downto 0);

	COMPONENT spi_master_ip
		generic(
			DATA_WIDTH      : NATURAL               := 32;
			ADDR_WIDTH      : NATURAL               := 12;
			BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
			CORE_DATA_WIDTH : NATURAL               := 16;
			CORE_ADDR_WIDTH : NATURAL               := 3;
			SPI_DATA_WIDTH  : natural               := 8;
			DEFAULT_DATA    : word_vector(0 to 128) := (others => x"000010000");
			REVERSE_BITS    : boolean               := false
		);
		port(
			--System Control Inputs
			CLK_I     : in  STD_LOGIC;
			RST_I     : in  STD_LOGIC;
			--Slave to WB
			WB_I      : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
			WB_O      : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
			--Serial Peripheral Interface
			SPI_CLK_I : in  STD_LOGIC;
			SPI_CE    : in  STD_LOGIC;
			SPI_MOSI  : out STD_LOGIC;
			SPI_MISO  : in  STD_LOGIC;
			SPI_N_SS  : out STD_LOGIC
		);
	END COMPONENT;

begin
	process(n_ss, rst)
	begin
		--Check for reset asynchronous
		if (rst = '1') then
			transfer_count <= (others => '0');
		--Perform Clock Rising Edge operations
		elsif (rising_edge(n_ss)) then
			transfer_count <= transfer_count + 1;
		end if;
	end process;

	cdc_spi_ce <= '1' when (transfer_count(6) = '0') else '0';
	adc_spi_ce <= '1' when (transfer_count(6 downto 5) = "11") else '0';
	dac_spi_ce <= '1' when (transfer_count(6 downto 5) = "10") else '0';

	FMC150_SPI_CLK_PLL_BASE : PLL_BASE
		generic map(
			BANDWIDTH             => "OPTIMIZED", -- "HIGH", "LOW" or "OPTIMIZED"
			CLKFBOUT_MULT         => 4, -- Multiply value for all CLKOUT clock outputs (1-64)
			CLKFBOUT_PHASE        => 0.0, -- Phase offset in degrees of the clock feedback output (0.0-360.0).
			CLKIN_PERIOD          => 10.0, -- Input clock period in ns to ps resolution (i.e. 33.333 is 30MHz).
			-- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for CLKOUT# clock output (1-128)
			CLKOUT0_DIVIDE        => 80,
			CLKOUT1_DIVIDE        => 80,
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
			CLKOUT1_PHASE         => 180.0,
			CLKOUT2_PHASE         => 0.0,
			CLKOUT3_PHASE         => 0.0,
			CLKOUT4_PHASE         => 0.0,
			CLKOUT5_PHASE         => 0.0,
			CLK_FEEDBACK          => "CLKFBOUT", -- Clock source to drive CLKFBIN ("CLKFBOUT" or "CLKOUT0")
			COMPENSATION          => "SYSTEM_SYNCHRONOUS", -- "SYSTEM_SYNCHRONOUS", "SOURCE_SYNCHRONOUS", "EXTERNAL"
			DIVCLK_DIVIDE         => 1, -- Division value for all output clocks (1-52)
			REF_JITTER            => 0.100, -- Reference Clock Jitter in UI (0.000-0.999).
			RESET_ON_LOSS_OF_LOCK => FALSE -- Must be set to FALSE
		)
		port map(
			CLKFBOUT => clkfbout,       -- 1-bit output: PLL_BASE feedback output
			-- CLKOUT0 - CLKOUT5: 1-bit (each) output: Clock outputs
			CLKOUT0  => clkout0,
			CLKOUT1  => clkout1,
			CLKOUT2  => open,
			CLKOUT3  => open,
			CLKOUT4  => open,
			CLKOUT5  => open,
			LOCKED   => locked_internal, -- 1-bit output: PLL_BASE lock status output
			CLKFBIN  => clkfbout,       -- 1-bit input: Feedback clock input
			CLKIN    => CLK_I,          -- 1-bit input: Clock input
			RST      => RST_I           -- 1-bit input: Reset input
		);

	clkout0_buf : BUFG
		port map(
			O => clkout0_b,
			I => clkout0
		);

	clkout1_buf : BUFG
		port map(
			O => clkout1_b,
			I => clkout1
		);

	rst <= RST_I or (not locked_internal);

	--ODDR for Clock Forwarding
	SPI_CLK_ODDR2 : ODDR2
		generic map(
			DDR_ALIGNMENT => "NONE",    -- Sets output alignment to "NONE", "C0", "C1"
			INIT          => '0',       -- Sets initial state of the Q output to '0' or '1'
			SRTYPE        => "SYNC")    -- Specifies "SYNC" or "ASYNC" set/reset
		port map(
			Q  => SPI_SCLK_O,           -- 1-bit output data
			C0 => clkout0_b,            -- 1-bit clock input
			C1 => clkout1_b,            -- 1-bit clock input
			CE => locked_internal,      -- 1-bit clock enable input
			D0 => '0',                  -- 1-bit data input (associated with C0)
			D1 => '1',                  -- 1-bit data input (associated with C1)
			R  => n_ss,                 -- 1-bit reset input
			S  => '0'                   -- 1-bit set input
		);

	--ODDR for Clock Forwarding
	DEBUG_SPI_CLK_ODDR2 : ODDR2
		generic map(
			DDR_ALIGNMENT => "NONE",    -- Sets output alignment to "NONE", "C0", "C1"
			INIT          => '0',       -- Sets initial state of the Q output to '0' or '1'
			SRTYPE        => "SYNC")    -- Specifies "SYNC" or "ASYNC" set/reset
		port map(
			Q  => DEBUG(0),             -- 1-bit output data
			C0 => clkout0_b,            -- 1-bit clock input
			C1 => clkout1_b,            -- 1-bit clock input
			CE => locked_internal,      -- 1-bit clock enable input
			D0 => '0',                  -- 1-bit data input (associated with C0)
			D1 => '1',                  -- 1-bit data input (associated with C1)
			R  => n_ss,                 -- 1-bit reset input
			S  => '0'                   -- 1-bit set input
		);

	ADS62P49_ctrl : spi_master_ip
		GENERIC MAP(
			DATA_WIDTH      => DATA_WIDTH,
			ADDR_WIDTH      => ADDR_WIDTH,
			BASE_ADDR       => x"A00",
			CORE_ADDR_WIDTH => 5,
			DEFAULT_DATA    => (
				0 => x"000012000",      --0xXXX & XXPV & 0xAADD
				1 => x"000013F20",
				2 => x"000014008",
				3 => x"000014180",
				--	4 => x"000014400",

				4 => x"000015044",
				5 => x"00001517F",
				6 => x"000015200",
				7 => x"000015340",
				8 => x"000015500",
				9 => x"000015700",
				10 => x"000016204",
				11 => x"000016300",
				12 => x"000016640",
				13 => x"000016800",
				14 => x"000016A00",
				15 => x"000017504",
				--				17 => x"000017600",

				128 => X"000000000",
				others => x"000000000"
			)
		)
		PORT MAP(
			CLK_I     => CLK_I,
			RST_I     => rst,
			WB_I      => WB_I,
			WB_O      => WB_O,
			SPI_CLK_I => clkout0_b,
			SPI_CE    => adc_spi_ce,
			SPI_MOSI  => adc_mosi,
			SPI_MISO  => adc_miso,
			SPI_N_SS  => adc_n_ss
		);

	CDCE72010_ctrl : spi_master_ip
		GENERIC MAP(
			DATA_WIDTH      => DATA_WIDTH,
			ADDR_WIDTH      => ADDR_WIDTH,
			BASE_ADDR       => x"B00",
			CORE_DATA_WIDTH => 32,
			CORE_ADDR_WIDTH => 5,
			SPI_DATA_WIDTH  => 32,
			DEFAULT_DATA    => (
				0 => x"1002C0050",      --XXPV & 0xDDDDDDD & 0xA
				1 => x"168840051",
				2 => x"183800002",      --"001110000011010000000000000000000010",
				3 => x"168840003",
				4 => x"1E9800004",
				5 => x"168840005",
				6 => x"168840006",
				7 => x"183400317",
				8 => x"168840158",
				9 => x"101000049",
				10 => x"10C0007DA",     --x"30BFC07CA",--"001100000000000000000000000000001010",
				11 => x"1C000840B",     --"001111000000000000000000000110001011",
				12 => x"161E09B0C",
				13 => x"000000000",
				14 => x"000000000",
				15 => x"000000000",
				128 => X"00000000E",
				others => x"000000000"
			),
			REVERSE_BITS    => TRUE
		)
		PORT MAP(
			CLK_I     => CLK_I,
			RST_I     => rst,
			WB_I      => WB_I,
			WB_O      => WB_O,
			SPI_CLK_I => clkout0_b,
			SPI_CE    => cdc_spi_ce,
			SPI_MOSI  => cdc_mosi,
			SPI_MISO  => cdc_miso,
			SPI_N_SS  => cdc_n_ss
		);

	DAC3283_ctrl : spi_master_ip
		GENERIC MAP(
			DATA_WIDTH      => DATA_WIDTH,
			ADDR_WIDTH      => ADDR_WIDTH,
			BASE_ADDR       => x"C00",
			CORE_ADDR_WIDTH => 6,
			DEFAULT_DATA    => (
				0 => x"000010070",      --0xXXX & XXPV & 0xAADD
				1 => x"000010121",
				2 => x"000000200",
				3 => x"000010310",
				4 => x"0000104FF",
				5 => x"000000500",
				6 => x"000000600",
				7 => x"000000700",
				8 => x"000010800",
				9 => x"000010980",
				10 => x"000010A00",
				11 => x"000010B80",
				12 => x"000010C00",
				13 => x"000010D80",
				14 => x"000010E00",
				15 => x"000010F80",
				16 => x"000011000",
				17 => x"000011124",
				18 => x"000011202",
				19 => x"000001300",
				20 => x"000001400",
				21 => x"000001500",
				22 => x"000001600",
				23 => x"000011704",
				24 => x"000011883",
				25 => x"000001900",
				26 => x"000001A00",
				27 => x"000001B00",
				28 => x"000001C00",
				29 => x"000001D00",
				30 => x"000011E24",
				31 => x"000011F12",
				128 => x"000000080",
				others => x"000000000"
			)
		)
		PORT MAP(
			CLK_I     => CLK_I,
			RST_I     => rst,
			WB_I      => WB_I,
			WB_O      => WB_O,
			SPI_CLK_I => clkout0_b,
			SPI_CE    => dac_spi_ce,
			SPI_MOSI  => dac_mosi,
			SPI_MISO  => dac_miso,
			SPI_N_SS  => dac_n_ss
		);

	adc_miso   <= ADC_MISO_I;
	cdc_miso   <= CDC_MISO_I;
	dac_miso   <= DAC_MISO_I;
	SPI_MOSI_O <= (adc_mosi and (not adc_n_ss)) or (cdc_mosi and (not cdc_n_ss)) or (dac_mosi and (not dac_n_ss));

	ADC_N_SS_O <= adc_n_ss;
	CDC_N_SS_O <= cdc_n_ss;
	DAC_N_SS_O <= dac_n_ss;
	n_ss       <= (adc_n_ss xnor cdc_n_ss xnor dac_n_ss);

	ADC_RST    <= RST_I;
	CDC_REF_EN <= '1';
	CDC_N_RST  <= not RST_I;
	CDC_N_PD   <= not RST_I;

	DEBUG(1)            <= n_ss;
	DEBUG(2)            <= cdc_spi_ce;
	DEBUG(3)            <= cdc_n_ss;
	DEBUG(4)            <= cdc_mosi;
	DEBUG(5)            <= cdc_miso;
	DEBUG(6)            <= adc_spi_ce;
	DEBUG(7)            <= adc_n_ss;
	DEBUG(8)            <= adc_mosi;
	DEBUG(9)            <= adc_miso;
	DEBUG(10)           <= dac_spi_ce;
	DEBUG(11)           <= dac_n_ss;
	DEBUG(12)           <= dac_mosi;
	DEBUG(13)           <= dac_miso;
	DEBUG(15 downto 14) <= std_logic_vector(transfer_count(6 downto 5));

end architecture RTL;
