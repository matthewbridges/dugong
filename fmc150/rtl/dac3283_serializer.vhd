library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity dac3283_serializer is
	generic(
		DATA_WIDTH : natural := 16;
		ADDR_WIDTH : natural := 5
	);
	port(
		--System Control Inputs
		CLK_I      : in  STD_LOGIC;
		RST_I      : in  STD_LOGIC;
		--Signal Channel Inputs
		CH_A_I     : in  STD_LOGIC_VECTOR(15 downto 0);
		CH_B_I     : in  STD_LOGIC_VECTOR(15 downto 0);
		-- DAC interface
		DAC_CLK_I  : in  STD_LOGIC;
		DAC_DCLK_P : out STD_LOGIC;
		DAC_DCLK_N : out STD_LOGIC;
		DAC_DATA_P : out STD_LOGIC_VECTOR(7 downto 0);
		DAC_DATA_N : out STD_LOGIC_VECTOR(7 downto 0);
		FRAME_P    : out STD_LOGIC;
		FRAME_N    : out STD_LOGIC;
		TXENABLE   : out STD_LOGIC;
		-- Debug
		DEBUG      : out STD_LOGIC_VECTOR(15 downto 0)
	);
end entity dac3283_serializer;

architecture RTL of dac3283_serializer is
	type ram_type is array (0 to (2 ** ADDR_WIDTH) - 1) of signed(DATA_WIDTH - 1 downto 0);
	constant ramp : ram_type := (
		0      => to_signed(0,
			DATA_WIDTH),
		1      => to_signed(2048,
			DATA_WIDTH),
		2      => to_signed(4096,
			DATA_WIDTH),
		3      => to_signed(6144,
			DATA_WIDTH),
		4      => to_signed(8192,
			DATA_WIDTH),
		5      => to_signed(10240,
			DATA_WIDTH),
		6      => to_signed(12288,
			DATA_WIDTH),
		7      => to_signed(14336,
			DATA_WIDTH),
		8      => to_signed(16384,
			DATA_WIDTH),
		9      => to_signed(18431,
			DATA_WIDTH),
		10     => to_signed(20479,
			DATA_WIDTH),
		11     => to_signed(22527,
			DATA_WIDTH),
		12     => to_signed(24575,
			DATA_WIDTH),
		13     => to_signed(26623,
			DATA_WIDTH),
		14     => to_signed(28671,
			DATA_WIDTH),
		15     => to_signed(30719,
			DATA_WIDTH),
		16     => to_signed(-32767,
			DATA_WIDTH),
		17     => to_signed(-30719,
			DATA_WIDTH),
		18     => to_signed(-28671,
			DATA_WIDTH),
		19     => to_signed(-26623,
			DATA_WIDTH),
		20     => to_signed(-24575,
			DATA_WIDTH),
		21     => to_signed(-22527,
			DATA_WIDTH),
		22     => to_signed(-20479,
			DATA_WIDTH),
		23     => to_signed(-18431,
			DATA_WIDTH),
		24     => to_signed(-16384,
			DATA_WIDTH),
		25     => to_signed(-14336,
			DATA_WIDTH),
		26     => to_signed(-12288,
			DATA_WIDTH),
		27     => to_signed(-10240,
			DATA_WIDTH),
		28     => to_signed(-8192,
			DATA_WIDTH),
		29     => to_signed(-6144,
			DATA_WIDTH),
		30     => to_signed(-4096,
			DATA_WIDTH),
		others => to_signed(0,
			DATA_WIDTH)
	);

	constant square : ram_type := (
		0      => to_signed(32767,
			DATA_WIDTH),
		1      => to_signed(32767,
			DATA_WIDTH),
		2      => to_signed(32767,
			DATA_WIDTH),
		3      => to_signed(32767,
			DATA_WIDTH),
		4      => to_signed(32767,
			DATA_WIDTH),
		5      => to_signed(32767,
			DATA_WIDTH),
		6      => to_signed(32767,
			DATA_WIDTH),
		7      => to_signed(32767,
			DATA_WIDTH),
		8      => to_signed(32767,
			DATA_WIDTH),
		9      => to_signed(32767,
			DATA_WIDTH),
		10     => to_signed(32767,
			DATA_WIDTH),
		11     => to_signed(32767,
			DATA_WIDTH),
		12     => to_signed(32767,
			DATA_WIDTH),
		13     => to_signed(32767,
			DATA_WIDTH),
		14     => to_signed(32767,
			DATA_WIDTH),
		15     => to_signed(32767,
			DATA_WIDTH),
		16     => to_signed(-32767,
			DATA_WIDTH),
		17     => to_signed(-32767,
			DATA_WIDTH),
		18     => to_signed(-32767,
			DATA_WIDTH),
		19     => to_signed(-32767,
			DATA_WIDTH),
		20     => to_signed(-32767,
			DATA_WIDTH),
		21     => to_signed(-32767,
			DATA_WIDTH),
		22     => to_signed(-32767,
			DATA_WIDTH),
		23     => to_signed(-32767,
			DATA_WIDTH),
		24     => to_signed(-32767,
			DATA_WIDTH),
		25     => to_signed(-32767,
			DATA_WIDTH),
		26     => to_signed(-32767,
			DATA_WIDTH),
		27     => to_signed(-32767,
			DATA_WIDTH),
		28     => to_signed(-32767,
			DATA_WIDTH),
		29     => to_signed(-32767,
			DATA_WIDTH),
		30     => to_signed(-32767,
			DATA_WIDTH),
		others => to_signed(0,
			DATA_WIDTH)
	);

	constant sine : ram_type := (
		0      => to_signed(0,
			DATA_WIDTH),
		1      => to_signed(6393,
			DATA_WIDTH),
		2      => to_signed(12539,
			DATA_WIDTH),
		3      => to_signed(18204,
			DATA_WIDTH),
		4      => to_signed(23170,
			DATA_WIDTH),
		5      => to_signed(27245,
			DATA_WIDTH),
		6      => to_signed(30273,
			DATA_WIDTH),
		7      => to_signed(32137,
			DATA_WIDTH),
		8      => to_signed(32767,
			DATA_WIDTH),
		9      => to_signed(32137,
			DATA_WIDTH),
		10     => to_signed(30273,
			DATA_WIDTH),
		11     => to_signed(27245,
			DATA_WIDTH),
		12     => to_signed(23170,
			DATA_WIDTH),
		13     => to_signed(18204,
			DATA_WIDTH),
		14     => to_signed(12539,
			DATA_WIDTH),
		15     => to_signed(6393,
			DATA_WIDTH),
		16     => to_signed(0,
			DATA_WIDTH),
		17     => to_signed(-6393,
			DATA_WIDTH),
		18     => to_signed(-12539,
			DATA_WIDTH),
		19     => to_signed(-18204,
			DATA_WIDTH),
		20     => to_signed(-23170,
			DATA_WIDTH),
		21     => to_signed(-27245,
			DATA_WIDTH),
		22     => to_signed(-30273,
			DATA_WIDTH),
		23     => to_signed(-32137,
			DATA_WIDTH),
		24     => to_signed(-32767,
			DATA_WIDTH),
		25     => to_signed(-32137,
			DATA_WIDTH),
		26     => to_signed(-30273,
			DATA_WIDTH),
		27     => to_signed(-27245,
			DATA_WIDTH),
		28     => to_signed(-23170,
			DATA_WIDTH),
		29     => to_signed(-18204,
			DATA_WIDTH),
		30     => to_signed(-12539,
			DATA_WIDTH),
		others => to_signed(0,
			DATA_WIDTH)
	);
	constant frequency_control_word : natural := 4;

	signal dac_clk_X4 : std_logic;
	signal clk_fb     : std_logic;
	signal pll_locked : std_logic;

	signal io_clk        : std_logic;
	signal serdesstrobe  : std_logic;
	signal bufpll_locked : std_logic;

	signal addr : unsigned(ADDR_WIDTH - 1 downto 0);

	signal tx_en        : std_logic;
	signal sample_count : unsigned(2 downto 0);
	signal frame        : std_logic;
	signal frame_count  : unsigned(7 downto 0);

	signal i : std_logic_vector(15 downto 0);
	signal q : std_logic_vector(15 downto 0);

	signal dac_dclk_predelay : std_logic;
	signal dac_dclk_o        : std_logic;
	signal dac_dat_o         : std_logic_vector(7 downto 0);
	signal frame_o           : std_logic;

begin

	----------------------------SET UP CLOCKING AND PLLs----------------------------

	process(DAC_CLK_I)
	begin
		--Perform Clock Rising Edge operations
		if (rising_edge(DAC_CLK_I)) then
			--Check for reset
			if (RST_I = '1') then
				sample_count <= (others => '0');
				frame_count  <= (others => '0');
				addr         <= (others => '0');
				frame        <= '0';
				tx_en        <= '0';
			elsif (bufpll_locked = '1') then
				i    <= std_logic_vector(sine(to_integer(addr)));
				q    <= CH_A_I; --std_logic_vector(ramp(to_integer(addr)));
				addr <= addr + frequency_control_word;

				if (sample_count = 7) then
					frame       <= '1';
					tx_en       <= '1';
					frame_count <= frame_count + 1;
				else
					frame <= '0';
				end if;
				sample_count <= sample_count + 1;
			end if;
		end if;
	end process;

	----------------------------SET UP CLOCKING AND PLLs----------------------------

	PLL_BASE_inst : PLL_BASE
		generic map(
			BANDWIDTH             => "OPTIMIZED", -- "HIGH", "LOW" or "OPTIMIZED"
			CLKFBOUT_MULT         => 4, -- Multiply value for all CLKOUT clock outputs (1-64)
			CLKFBOUT_PHASE        => 0.0, -- Phase offset in degrees of the clock feedback output (0.0-360.0).
			CLKIN_PERIOD          => 4.069, -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
			-- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for CLKOUT# clock output (1-128)
			CLKOUT0_DIVIDE        => 1,
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
			CLK_FEEDBACK          => "CLKFBOUT", -- Clock source to drive CLKFBIN ("CLKFBOUT" or "CLKOUT0")
			COMPENSATION          => "SYSTEM_SYNCHRONOUS", -- "SYSTEM_SYNCHRONOUS", "SOURCE_SYNCHRONOUS", "EXTERNAL"
			DIVCLK_DIVIDE         => 1, -- Division value for all output clocks (1-52)
			REF_JITTER            => 0.1, -- Reference Clock Jitter in UI (0.000-0.999).
			RESET_ON_LOSS_OF_LOCK => FALSE -- Must be set to FALSE
		)
		port map(
			CLKFBOUT => clk_fb,         -- 1-bit output: PLL_BASE feedback output
			-- CLKOUT0 - CLKOUT5: 1-bit (each) output: Clock outputs
			CLKOUT0  => DAC_CLK_X4,
			CLKOUT1  => open,
			CLKOUT2  => open,
			CLKOUT3  => open,
			CLKOUT4  => open,
			CLKOUT5  => open,
			LOCKED   => pll_locked,     -- 1-bit output: PLL_BASE lock status output
			CLKFBIN  => clk_fb,         -- 1-bit input: Feedback clock input
			CLKIN    => DAC_CLK_I,      -- 1-bit input: Clock input
			RST      => RST_I           -- 1-bit input: Reset input
		);

	io_BUFPLL : BUFPLL
		generic map(
			DIVIDE      => 4,           -- DIVCLK divider (1-8)
			ENABLE_SYNC => TRUE         -- Enable synchrnonization between PLL and GCLK (TRUE/FALSE)
		)
		port map(
			IOCLK        => io_clk,     -- 1-bit output: Output I/O clock
			LOCK         => bufpll_locked, -- 1-bit output: Synchronized LOCK output
			SERDESSTROBE => serdesstrobe, -- 1-bit output: Output SERDES strobe (connect to ISERDES2/OSERDES2)
			GCLK         => DAC_CLK_I,  -- 1-bit input: BUFG clock input
			LOCKED       => pll_locked, -- 1-bit input: LOCKED input from PLL
			PLLIN        => DAC_CLK_X4  -- 1-bit input: Clock input from PLL
		);

	----------------------------DATA CLOCK IO, DELAY AND BUFFERING----------------------------

	DAC_DCLK_OSERDES2 : OSERDES2
		generic map(
			BYPASS_GCLK_FF => FALSE,    -- Bypass CLKDIV syncronization registers (TRUE/FALSE)
			DATA_RATE_OQ   => "SDR",    -- Output Data Rate ("SDR" or "DDR")
			DATA_RATE_OT   => "SDR",    -- 3-state Data Rate ("SDR" or "DDR")
			DATA_WIDTH     => 4,        -- Parallel data width (2-8)
			OUTPUT_MODE    => "SINGLE_ENDED", -- "SINGLE_ENDED" or "DIFFERENTIAL"
			SERDES_MODE    => "NONE",   -- "NONE", "MASTER" or "SLAVE"
			TRAIN_PATTERN  => 0         -- Training Pattern (0-15)
		)
		port map(
			OQ        => dac_dclk_predelay, -- 1-bit output: Data output to pad or IODELAY2
			SHIFTOUT1 => open,          -- 1-bit output: Cascade data output
			SHIFTOUT2 => open,          -- 1-bit output: Cascade 3-state output
			SHIFTOUT3 => open,          -- 1-bit output: Cascade differential data output
			SHIFTOUT4 => open,          -- 1-bit output: Cascade differential 3-state output
			TQ        => open,          -- 1-bit output: 3-state output to pad or IODELAY2
			CLK0      => io_clk,        -- 1-bit input: I/O clock input
			CLK1      => '0',           -- 1-bit input: Secondary I/O clock input
			CLKDIV    => DAC_CLK_I,     -- 1-bit input: Logic domain clock input
			-- D1 - D4: 1-bit (each) input: Parallel data inputs
			D1        => '1',
			D2        => '0',
			D3        => '1',
			D4        => '0',
			IOCE      => serdesstrobe,  -- 1-bit input: Data strobe input
			OCE       => tx_en,         -- 1-bit input: Clock enable input
			RST       => '0',           -- 1-bit input: Asynchrnous reset input
			SHIFTIN1  => '0',           -- 1-bit input: Cascade data input
			SHIFTIN2  => '0',           -- 1-bit input: Cascade 3-state input
			SHIFTIN3  => '0',           -- 1-bit input: Cascade differential data input
			SHIFTIN4  => '0',           -- 1-bit input: Cascade differential 3-state input
			-- T1 - T4: 1-bit (each) input: 3-state control inputs
			T1        => '0',
			T2        => '0',
			T3        => '0',
			T4        => '0',
			TCE       => '0',           -- 1-bit input: 3-state clock enable input
			TRAIN     => '0'            -- 1-bit input: Training pattern enable input
		);

	--	DAC_DCLK_IODELAY2 : IODELAY2
	--		generic map(
	--			COUNTER_WRAPAROUND => "WRAPAROUND", -- "STAY_AT_LIMIT" or "WRAPAROUND"
	--			DATA_RATE          => "SDR", -- "SDR" or "DDR"
	--			DELAY_SRC          => "ODATAIN", -- "IO", "ODATAIN" or "IDATAIN"
	--			IDELAY2_VALUE      => 0,    -- Delay value when IDELAY_MODE="PCI" (0-255)
	--			IDELAY_MODE        => "NORMAL", -- "NORMAL" or "PCI"
	--			IDELAY_TYPE        => "FIXED", -- "FIXED", "DEFAULT", "VARIABLE_FROM_ZERO", "VARIABLE_FROM_HALF_MAX"
	--			-- or "DIFF_PHASE_DETECTOR"
	--			IDELAY_VALUE       => 0,    -- Amount of taps for fixed input delay (0-255)
	--			ODELAY_VALUE       => 0,   -- Amount of taps fixed output delay (0-255)
	--			SERDES_MODE        => "NONE", -- "NONE", "MASTER" or "SLAVE"
	--			SIM_TAPDELAY_VALUE => 50    -- Per tap delay used for simulation in ps
	--		)
	--		port map(
	--			BUSY     => open,           -- 1-bit output: Busy output after CAL
	--			DATAOUT  => open,           -- 1-bit output: Delayed data output to ISERDES/input register
	--			DATAOUT2 => open,           -- 1-bit output: Delayed data output to general FPGA fabric
	--			DOUT     => dac_dclk_o,     -- 1-bit output: Delayed data output
	--			TOUT     => open,           -- 1-bit output: Delayed 3-state output
	--			CAL      => '0',            -- 1-bit input: Initiate calibration input
	--			CE       => '0',            -- 1-bit input: Enable INC input
	--			CLK      => '0',            -- 1-bit input: Clock input
	--			IDATAIN  => '0',            -- 1-bit input: Data input (connect to top-level port or I/O buffer)
	--			INC      => '0',            -- 1-bit input: Increment / decrement input
	--			IOCLK0   => '0',            -- 1-bit input: Input from the I/O clock network
	--			IOCLK1   => '0',            -- 1-bit input: Input from the I/O clock network
	--			ODATAIN  => dac_dclk_predelay, -- 1-bit input: Output data input from output register or OSERDES2.
	--			RST      => '0',            -- 1-bit input: Reset to zero or 1/2 of total delay period
	--			T        => '0'             -- 1-bit input: 3-state input signal
	--		);

	dac_dclk_o <= dac_dclk_predelay;

	DAC_DCLK_OBUFDS : OBUFDS
		generic map(
			IOSTANDARD => "LVDS_25"
		)
		port map(
			O  => DAC_DCLK_P,
			OB => DAC_DCLK_N,
			I  => dac_dclk_o
		);

	--		DEBUG9_OBUF : OBUF
	--			port map(
	--				O => DEBUG(9),
	--				I => dac_dclk_o
	--			);

	----------------------------DATA(7:0) IO AND BUFFERING----------------------------

	DAC_DATA_pins : for pin_count in 7 downto 0 generate
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
				OQ        => dac_dat_o(pin_count), -- 1-bit output: Data output to pad or IODELAY2
				SHIFTOUT1 => open,      -- 1-bit output: Cascade data output
				SHIFTOUT2 => open,      -- 1-bit output: Cascade 3-state output
				SHIFTOUT3 => open,      -- 1-bit output: Cascade differential data output
				SHIFTOUT4 => open,      -- 1-bit output: Cascade differential 3-state output
				TQ        => open,      -- 1-bit output: 3-state output to pad or IODELAY2
				CLK0      => io_clk,    -- 1-bit input: I/O clock input
				CLK1      => '0',       -- 1-bit input: Secondary I/O clock input
				CLKDIV    => DAC_CLK_I, -- 1-bit input: Logic domain clock input
				-- D1 - D4: 1-bit (each) input: Parallel data inputs
				D1        => i(pin_count + 8),
				D2        => i(pin_count),
				D3        => q(pin_count + 8),
				D4        => q(pin_count),
				IOCE      => serdesstrobe, -- 1-bit input: Data strobe input
				OCE       => tx_en,     -- 1-bit input: Clock enable input
				RST       => '0',       -- 1-bit input: Asynchrnous reset input
				SHIFTIN1  => '0',       -- 1-bit input: Cascade data input
				SHIFTIN2  => '0',       -- 1-bit input: Cascade 3-state input
				SHIFTIN3  => '0',       -- 1-bit input: Cascade differential data input
				SHIFTIN4  => '0',       -- 1-bit input: Cascade differential 3-state input
				-- T1 - T4: 1-bit (each) input: 3-state control inputs
				T1        => '0',
				T2        => '0',
				T3        => '0',
				T4        => '0',
				TCE       => '0',       -- 1-bit input: 3-state clock enable input
				TRAIN     => '0'        -- 1-bit input: Training pattern enable input
			);

		DAC_DATA_OBUFDS : OBUFDS
			generic map(
				IOSTANDARD => "LVDS_25"
			)
			port map(
				O  => DAC_DATA_P(pin_count),
				OB => DAC_DATA_N(pin_count),
				I  => dac_dat_o(pin_count)
			);

	--		DEBUG_OBUF : OBUF
	--			port map(
	--				O => DEBUG(pin_count),
	--				I => dac_dat_o(pin_count)
	--			);

	end generate DAC_DATA_pins;

	----------------------------FRAME IO AND BUFFERING----------------------------

	FRAME_OSERDES2 : OSERDES2
		generic map(
			BYPASS_GCLK_FF => FALSE,    -- Bypass CLKDIV syncronization registers (TRUE/FALSE)
			DATA_RATE_OQ   => "SDR",    -- Output Data Rate ("SDR" or "DDR")
			DATA_RATE_OT   => "SDR",    -- 3-state Data Rate ("SDR" or "DDR")
			DATA_WIDTH     => 4,        -- Parallel data width (2-8)
			OUTPUT_MODE    => "SINGLE_ENDED", -- "SINGLE_ENDED" or "DIFFERENTIAL"
			SERDES_MODE    => "NONE",   -- "NONE", "MASTER" or "SLAVE"
			TRAIN_PATTERN  => 0         -- Training Pattern (0-15)
		)
		port map(
			OQ        => frame_o,       -- 1-bit output: Data output to pad or IODELAY2
			SHIFTOUT1 => open,          -- 1-bit output: Cascade data output
			SHIFTOUT2 => open,          -- 1-bit output: Cascade 3-state output
			SHIFTOUT3 => open,          -- 1-bit output: Cascade differential data output
			SHIFTOUT4 => open,          -- 1-bit output: Cascade differential 3-state output
			TQ        => open,          -- 1-bit output: 3-state output to pad or IODELAY2
			CLK0      => io_clk,        -- 1-bit input: I/O clock input
			CLK1      => '0',           -- 1-bit input: Secondary I/O clock input
			CLKDIV    => DAC_CLK_I,     -- 1-bit input: Logic domain clock input
			-- D1 - D4: 1-bit (each) input: Parallel data inputs
			D1        => frame,
			D2        => frame,
			D3        => '0',
			D4        => '0',
			IOCE      => serdesstrobe,  -- 1-bit input: Data strobe input
			OCE       => tx_en,         -- 1-bit input: Clock enable input
			RST       => '0',           -- 1-bit input: Asynchrnous reset input
			SHIFTIN1  => '0',           -- 1-bit input: Cascade data input
			SHIFTIN2  => '0',           -- 1-bit input: Cascade 3-state input
			SHIFTIN3  => '0',           -- 1-bit input: Cascade differential data input
			SHIFTIN4  => '0',           -- 1-bit input: Cascade differential 3-state input
			-- T1 - T4: 1-bit (each) input: 3-state control inputs
			T1        => '0',
			T2        => '0',
			T3        => '0',
			T4        => '0',
			TCE       => '0',           -- 1-bit input: 3-state clock enable input
			TRAIN     => '0'            -- 1-bit input: Training pattern enable input
		);

	FRAME_OBUFDS : OBUFDS
		generic map(
			IOSTANDARD => "LVDS_25"
		)
		port map(
			O  => FRAME_P,
			OB => FRAME_N,
			I  => frame_o
		);

	--	DEBUG8_OBUF : OBUF
	--		port map(
	--			O => DEBUG(8),
	--			I => frame_o
	--		);

	----------------------------OTHER SIGNAL ASSIGNMENT AND DEBUGING----------------------------

	TXENABLE <= tx_en;

	--	DEBUG <= std_logic_vector(test_signal);

	DEBUG(7 downto 0)   <= std_logic_vector(frame_count);
	DEBUG(10)           <= frame;
	DEBUG(11)           <= tx_en;
	DEBUG(14 downto 12) <= std_logic_vector(sample_count);
	DEBUG(15)           <= pll_locked;

end architecture RTL;
