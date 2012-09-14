library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity dac3283_serializer is
	port(
		--System Control Inputs
		CLK_I      : in  STD_LOGIC;
		RST_I      : in  STD_LOGIC;

		CH_A_I     : in  STD_LOGIC_VECTOR(15 downto 0);
		CH_B_I     : in  STD_LOGIC_VECTOR(15 downto 0);

		-- DAC interface
		DAC_DCLK_P : out STD_LOGIC;
		DAC_DCLK_N : out STD_LOGIC;
		DAC_DATA_P : out STD_LOGIC_VECTOR(7 downto 0);
		DAC_DATA_N : out STD_LOGIC_VECTOR(7 downto 0);
		FRAME_P    : out STD_LOGIC;
		FRAME_N    : out STD_LOGIC;
		TXENABLE   : out STD_LOGIC
	);
end entity dac3283_serializer;

architecture RTL of dac3283_serializer is
	signal clk_i_X1     : std_logic;
	signal clk_i_X1_b   : std_logic;
	signal clk_i_X4     : std_logic;
--	signal n_io_clk     : std_logic;	
	signal dac_dclk     : std_logic;
	signal dac_dclk_b   : std_logic;
	signal n_dac_dclk   : std_logic;
	signal n_dac_dclk_b : std_logic;
	signal dac_dclk_o   : std_logic;
	signal frame        : std_logic;
	signal frame_b      : std_logic;
	signal n_frame      : std_logic;
	signal n_frame_b    : std_logic;
	signal frame_o      : std_logic;
	signal io_clk       : std_logic;
--	signal n_io_clk     : std_logic;
	signal serdesstrobe : std_logic;
--	signal clk_div      : std_logic;
--	signal clk_div_b    : std_logic;
	signal clk_fb       : std_logic;
	signal pll_locked   : std_logic;
	signal bufpll_locked : std_logic;
	signal temp         : std_logic_vector(7 downto 0);

begin

	-- PLL_BASE: Phase Locked Loop (PLL) Clock Management Component
	--           Spartan-6
	-- Xilinx HDL Libraries Guide, version 14.1

	PLL_BASE_inst : PLL_BASE
		generic map(
			BANDWIDTH             => "OPTIMIZED", -- "HIGH", "LOW" or "OPTIMIZED"
			CLKFBOUT_MULT         => 4, -- Multiply value for all CLKOUT clock outputs (1-64)
			CLKFBOUT_PHASE        => 0.0, -- Phase offset in degrees of the clock feedback output
			-- (0.0-360.0).
			CLKIN_PERIOD          => 5.0, -- Input clock period in ns to ps resolution (i.e. 33.333 is 30
			-- MHz).
			-- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for CLKOUT# clock output (1-128)
			CLKOUT0_DIVIDE        => 4,
			CLKOUT1_DIVIDE        => 1,
			CLKOUT2_DIVIDE        => 2,
			CLKOUT3_DIVIDE        => 2,
			CLKOUT4_DIVIDE        => 8,
			CLKOUT5_DIVIDE        => 8,
			-- CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for CLKOUT# clock output (0.01-0.99).
			CLKOUT0_DUTY_CYCLE    => 0.5,
			CLKOUT1_DUTY_CYCLE    => 0.5,
			CLKOUT2_DUTY_CYCLE    => 0.5,
			CLKOUT3_DUTY_CYCLE    => 0.5,
			CLKOUT4_DUTY_CYCLE    => 0.5,
			CLKOUT5_DUTY_CYCLE    => 0.5,
			-- CLKOUT0_PHASE - CLKOUT5_PHASE: Output phase relationship for CLKOUT# clock output (-360.0-360.0).
			CLKOUT0_PHASE         => 180.0,
			CLKOUT1_PHASE         => 0.0,
			CLKOUT2_PHASE         => 90.0,
			CLKOUT3_PHASE         => 270.0,
			CLKOUT4_PHASE         => 0.0,
			CLKOUT5_PHASE         => 180.0,
			CLK_FEEDBACK          => "CLKFBOUT", -- Clock source to drive CLKFBIN ("CLKFBOUT" or "CLKOUT0")
			COMPENSATION          => "SYSTEM_SYNCHRONOUS", -- "SYSTEM_SYNCHRONOUS", "SOURCE_SYNCHRONOUS", "EXTERNAL"
			DIVCLK_DIVIDE         => 1, -- Division value for all output clocks (1-52)
			REF_JITTER            => 0.1, -- Reference Clock Jitter in UI (0.000-0.999).
			RESET_ON_LOSS_OF_LOCK => FALSE -- Must be set to FALSE
		)
		port map(
			CLKFBOUT => clk_fb,         -- 1-bit output: PLL_BASE feedback output
			-- CLKOUT0 - CLKOUT5: 1-bit (each) output: Clock outputs
			CLKOUT0  => clk_i_X1,
			CLKOUT1  => clk_i_X4,
			CLKOUT2  => dac_dclk,
			CLKOUT3  => n_dac_dclk,
			CLKOUT4  => frame,
			CLKOUT5  => n_frame,
			LOCKED   => pll_locked,     -- 1-bit output: PLL_BASE lock status output
			CLKFBIN  => clk_fb,         -- 1-bit input: Feedback clock input
			CLKIN    => CLK_I,          -- 1-bit input: Clock input
			RST      => RST_I           -- 1-bit input: Reset input
		);

	-- End of PLL_BASE_inst instantiation

	dac_dclk_BUFG : BUFG
		port map(
			O => dac_dclk_b,            -- 1-bit output: Clock buffer output
			I => dac_dclk               -- 1-bit input: Clock buffer input
		);
	n_dac_dclk_BUFG : BUFG
		port map(
			O => n_dac_dclk_b,          -- 1-bit output: Clock buffer output
			I => n_dac_dclk             -- 1-bit input: Clock buffer input
		);
	frame_BUFG : BUFG
		port map(
			O => frame_b,               -- 1-bit output: Clock buffer output
			I => frame                  -- 1-bit input: Clock buffer input
		);
	n_frame_BUFG : BUFG
		port map(
			O => n_frame_b,             -- 1-bit output: Clock buffer output
			I => n_frame                -- 1-bit input: Clock buffer input
		);

	clk_i_2x_BUFG : BUFG
		port map(
			O => clk_i_X1_b,            -- 1-bit output: Clock buffer output
			I => clk_i_X1               -- 1-bit input: Clock buffer input
		);

	-- BUFPLL: High-speed I/O PLL clock buffer
	--         Spartan-6
	-- Xilinx HDL Libraries Guide, version 14.1

	io_BUFPLL : BUFPLL
		generic map(
			DIVIDE      => 1,           -- DIVCLK divider (1-8)
			ENABLE_SYNC => TRUE         -- Enable synchrnonization between PLL and GCLK (TRUE/FALSE)
		)
		port map(
			IOCLK        => io_clk,     -- 1-bit output: Output I/O clock
			LOCK         => bufpll_locked, -- 1-bit output: Synchronized LOCK output
			SERDESSTROBE => serdesstrobe, -- 1-bit output: Output SERDES strobe (connect to ISERDES2/OSERDES2)
			GCLK         => clk_i_X1_b, -- 1-bit input: BUFG clock input
			LOCKED       => pll_locked, -- 1-bit input: LOCKED input from PLL
			PLLIN        => clk_i_X4    -- 1-bit input: Clock input from PLL
		);

	-- End of BUFPLL_inst instantiation

--	-- Set up the clock for use in the serdes
--	io_BUFIO2 : BUFIO2
--		generic map(
--			DIVIDE_BYPASS => FALSE,
--			I_INVERT      => FALSE,
--			USE_DOUBLER   => TRUE,
--			DIVIDE        => 4
--		)
--		port map(
--			DIVCLK       => clk_div,
--			IOCLK        => io_clk,
--			SERDESSTROBE => serdesstrobe,
--			I            => clk_i_2x_b
--		);
--
--	-- also generated the inverted clock
--	n_io_BUFIO2 : BUFIO2
--		generic map(
--			DIVIDE_BYPASS => FALSE,
--			I_INVERT      => TRUE,
--			USE_DOUBLER   => FALSE,
--			DIVIDE        => 4
--		)
--		port map(
--			DIVCLK       => open,
--			IOCLK        => n_io_clk,
--			SERDESSTROBE => open,
--			I            => clk_i_2x_b
--		);
--
--	-- Buffer up the divided clock
--	clk_div_BUFG : BUFG
--		port map(
--			O => clk_div_b,
--			I => clk_div);
--
	-- We have multiple bits- step over every bit, instantiating the required elements
	DAC_DATA_pins : for pin_count in 0 to 7 generate
	begin
		DAC_DATA_OSERDES2 : OSERDES2
			generic map(
				BYPASS_GCLK_FF => FALSE, -- Bypass CLKDIV syncronization registers (TRUE/FALSE)
				DATA_RATE_OQ   => "SDR", -- Output Data Rate ("SDR" or "DDR")
				DATA_RATE_OT   => "SDR", -- 3-state Data Rate ("SDR" or "DDR")
				DATA_WIDTH     => 4,    -- Parallel data width (2-8)
				OUTPUT_MODE    => "SINGLE_ENDED", -- "SINGLE_ENDED" or "DIFFERENTIAL"
				SERDES_MODE    => "NONE", -- "NONE", "MASTER" or "SLAVE"
				TRAIN_PATTERN  => 0     -- Training Pattern (0-15)
			)
			port map(
				D1        => CH_A_I(pin_count + 8),
				D2        => CH_A_I(pin_count),
				D3        => CH_B_I(pin_count + 8),
				D4        => CH_B_I(pin_count),
				T1        => '0',
				T2        => '0',
				T3        => '0',
				T4        => '0',
				SHIFTIN1  => '1',
				SHIFTIN2  => '1',
				SHIFTIN3  => '1',
				SHIFTIN4  => '1',
				SHIFTOUT1 => open,
				SHIFTOUT2 => open,
				SHIFTOUT3 => open,
				SHIFTOUT4 => open,
				TRAIN     => '0',
				OCE       => bufpll_locked,
				CLK0      => io_clk,
				CLK1      => '0',
				CLKDIV    => clk_i_X1_b,
				OQ        => temp(pin_count),
				TQ        => open,
				IOCE      => serdesstrobe,
				TCE       => '0',
				RST       => RST_I
			);

		DAC_DATA_OBUFDS : OBUFDS
			generic map(
				IOSTANDARD => "LVDS_25"
			)
			port map(
				O  => DAC_DATA_P(pin_count),
				OB => DAC_DATA_N(pin_count),
				I  => temp(pin_count)
			);

	end generate DAC_DATA_pins;

	-- ODDR2: Output Double Data Rate Output Register with Set, Reset
	--        and Clock Enable. 
	--        Spartan-6
	-- Xilinx HDL Libraries Guide, version 14.1

	frame_ODDR2 : ODDR2
	generic map(
		DDR_ALIGNMENT => "NONE",        -- Sets output alignment to "NONE", "C0", "C1"
		INIT          => '0',           -- Sets initial state of the Q output to '0' or '1'
		SRTYPE        => "SYNC")        -- Specifies "SYNC" or "ASYNC" set/reset
	port map(
		Q  => frame_o,                  -- 1-bit output data
		C0 => frame_b,                  -- 1-bit clock input
		C1 => n_frame_b,                -- 1-bit clock input
		CE => pll_locked,               -- 1-bit clock enable input
		D0 => '1',                      -- 1-bit data input (associated with C0)
		D1 => '0',                      -- 1-bit data input (associated with C1)
		R  => RST_I,                    -- 1-bit reset input
		S  => '0'                       -- 1-bit set input
	);

-- End of ODDR2_inst instantiation

FRAME_OBUFDS : OBUFDS
	generic map(
		IOSTANDARD => "LVDS_25"
	)
	port map(
		O  => FRAME_P,
		OB => FRAME_N,
		I  => frame_o
	);

--FRAME_N <= io_clk;
--FRAME_P <= serdesstrobe;

	-- ODDR2: Output Double Data Rate Output Register with Set, Reset
	--        and Clock Enable. 
	--        Spartan-6
	-- Xilinx HDL Libraries Guide, version 14.1

	dac_dclk_ODDR2 : ODDR2
		generic map(
			DDR_ALIGNMENT => "NONE",    -- Sets output alignment to "NONE", "C0", "C1"
			INIT          => '0',       -- Sets initial state of the Q output to '0' or '1'
			SRTYPE        => "SYNC")    -- Specifies "SYNC" or "ASYNC" set/reset
		port map(
			Q  => dac_dclk_o,           -- 1-bit output data
			C0 => dac_dclk_b,           -- 1-bit clock input
			C1 => n_dac_dclk_b,         -- 1-bit clock input
			CE => pll_locked,           -- 1-bit clock enable input
			D0 => '1',                  -- 1-bit data input (associated with C0)
			D1 => '0',                  -- 1-bit data input (associated with C1)
			R  => RST_I,                -- 1-bit reset input
			S  => '0'                   -- 1-bit set input
		);

	-- End of ODDR2_inst instantiation

	DAC_DCLK_OBUFDS : OBUFDS
		generic map(
			IOSTANDARD => "LVDS_25"
		)
		port map(
			O  => DAC_DCLK_P,
			OB => DAC_DCLK_N,
			I  => dac_dclk_o
		);

	TXENABLE <= bufpll_locked;

end architecture RTL;
