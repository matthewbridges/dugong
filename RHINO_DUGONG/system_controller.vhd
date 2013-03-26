library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

library unisim;
use unisim.vcomponents.all;

entity system_controller is
	generic(
		DATA_WIDTH      : NATURAL               := 32;
		ADDR_WIDTH      : NATURAL               := 12;
		BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
		CORE_DATA_WIDTH : NATURAL               := 32;
		CORE_ADDR_WIDTH : NATURAL               := 3
	);
	port(
		--System Clock Differential Inputs 100MHz
		SYS_CLK_P      : in  STD_LOGIC;
		SYS_CLK_N      : in  STD_LOGIC;
		--System Clock Differential Outputs 100MHz
		SYS_CLK_o      : out STD_LOGIC;
		--System Reset Input
		SYS_RST        : in  STD_LOGIC;
		--System Status
		SYS_PWR_ON     : out STD_LOGIC;
		SYS_PLL_Locked : out STD_LOGIC;
		--System Control Outputs
		CLK_123MHZ     : out STD_LOGIC;
		CLK_123MHZ_n   : out STD_LOGIC;
		CLK_246MHZ     : out STD_LOGIC;
		CLK_983MHZ     : out STD_LOGIC;
		CLK_15MHZ      : out STD_LOGIC;
		CLK_15MHZ_n    : out STD_LOGIC;
		RST_O          : out STD_LOGIC;
		--Slave to WB
		WB_I           : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
		WB_O           : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0)
	);
end entity system_controller;

architecture RTL of system_controller is
	COMPONENT clk_counter_ip
		generic(
			DATA_WIDTH      : NATURAL               := 32;
			ADDR_WIDTH      : NATURAL               := 12;
			BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
			CORE_DATA_WIDTH : NATURAL               := 32;
			CORE_ADDR_WIDTH : NATURAL               := 3
		);
		port(
			--System Control Inputs
			CLK_I       : in  STD_LOGIC;
			RST_I       : in  STD_LOGIC;
			--Slave to WB
			WB_I        : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
			WB_O        : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
			--Test Clocks
			TEST_CLOCKS : in  STD_LOGIC_VECTOR(3 downto 0)
		);
	END COMPONENT;

	--Input Buffering
	signal sys_clk_b      : std_logic;
	--DCM Signals
	signal dcm_clkin      : std_logic;
	signal dcm_clkout     : std_logic;
	signal dcm_locked     : std_logic;
	signal dcm1_locked     : std_logic;
	--PLL Signals
	signal pll_rst        : std_logic;
	signal pll_locked     : std_logic;
	signal clkfbout       : std_logic;
	signal clkout0        : std_logic;
	signal clkout1        : std_logic;
	signal clkout2        : std_logic;
	signal clkout3        : std_logic;
	signal clkout4        : std_logic;
	signal clkout5        : std_logic;
	--Internal Clock Buffering
	signal clkout0_b      : std_logic;
	signal clkout1_b      : std_logic;
	signal clkout2_b      : std_logic;
	signal clkout3_b      : std_logic;
	signal clkout4_b      : std_logic;
	signal clkout5_b      : std_logic;
	signal sys_clk_o_pb   : std_logic;
	-- Status Signal
	signal sys_not_locked : std_logic;
	-- Clock Monitoring
	signal test_clocks    : std_logic_vector(3 downto 0);

begin
	-- Initial Test Signal
	SYS_PWR_ON <= '1';

	-- Input buffering
	SYS_CLK_IBUFGDS : IBUFGDS
		generic map(
			DIFF_TERM  => FALSE,
			IOSTANDARD => "LVPECL_33"
		)
		port map(
			O  => sys_clk_b,
			I  => SYS_CLK_P,
			IB => SYS_CLK_N
		);
		
	-- Input divider
	SYS_CLK_BUFIO2 : BUFIO2
		generic map(
			DIVIDE        => 5,
			DIVIDE_BYPASS => FALSE,
			I_INVERT      => FALSE,
			USE_DOUBLER   => FALSE
		)
		port map(
			DIVCLK       => dcm_clkin,
			IOCLK        => open,
			SERDESSTROBE => open,
			I            => sys_clk_b
		);

	-- System  Clock Generator
	SYS_CLK_DCM_CLKGEN : DCM_CLKGEN
		generic map(
			CLKFXDV_DIVIDE  => 2,
			CLKFX_DIVIDE    => 125,
			CLKFX_MD_MAX    => 0.0,
			CLKFX_MULTIPLY  => 256,
			CLKIN_PERIOD    => 50.00,
			SPREAD_SPECTRUM => "NONE",
			STARTUP_WAIT    => FALSE
		)
		port map(
			CLKFX     => dcm_clkout,
			CLKFX180  => open,
			CLKFXDV   => open,
			LOCKED    => dcm_locked,
			PROGDONE  => open,
			STATUS    => open,
			CLKIN     => dcm_clkin,
			FREEZEDCM => '0',
			PROGCLK   => '0',
			PROGDATA  => '0',
			PROGEN    => '0',
			RST       => SYS_RST
		);

	pll_rst <= SYS_RST and not dcm_locked;

	-- System PLL 
	SYS_CLK_PLL_BASE : PLL_BASE
		generic map(
			BANDWIDTH             => "HIGH", -- "HIGH", "LOW" or "OPTIMIZED"
			CLKFBOUT_MULT         => 24, -- Multiply value for all CLKOUT clock outputs (1-64)
			CLKFBOUT_PHASE        => 0.0, -- Phase offset in degrees of the clock feedback output (0.0-360.0).
			CLKIN_PERIOD          => 24.4140625, -- Input clock period in ns to ps resolution (i.e. 33.333 is 30MHz).
			-- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for CLKOUT# clock output (1-128)
			CLKOUT0_DIVIDE        => 8,
			CLKOUT1_DIVIDE        => 8,
			CLKOUT2_DIVIDE        => 4,
			CLKOUT3_DIVIDE        => 1,
			CLKOUT4_DIVIDE        => 64,
			CLKOUT5_DIVIDE        => 64,
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
			CLKOUT5_PHASE         => 180.0,
			CLK_FEEDBACK          => "CLKFBOUT", -- Clock source to drive CLKFBIN ("CLKFBOUT" or "CLKOUT0")
			COMPENSATION          => "SYSTEM_SYNCHRONOUS", -- "SYSTEM_SYNCHRONOUS", "SOURCE_SYNCHRONOUS", "EXTERNAL"
			DIVCLK_DIVIDE         => 1, -- Division value for all output clocks (1-52)
			REF_JITTER            => 0.001, -- Reference Clock Jitter in UI (0.000-0.999).
			RESET_ON_LOSS_OF_LOCK => FALSE -- Must be set to FALSE
		)
		port map(
			CLKFBOUT => clkfbout,
			CLKOUT0  => clkout0,
			CLKOUT1  => clkout1,
			CLKOUT2  => clkout2,
			CLKOUT3  => clkout3,
			CLKOUT4  => open,--clkout4,
			CLKOUT5  => open, --clkout5,
			LOCKED   => pll_locked,
			CLKFBIN  => clkfbout,
			CLKIN    => dcm_clkout,
			RST      => pll_rst
		);

	-- Internal Global Buffers
	clkout0_buf : BUFG
		port map(
			O => clkout0_b,
			I => clkout0
		);

	CLK_123MHZ <= clkout0_b;

	clkout1_buf : BUFG
		port map(
			O => clkout1_b,
			I => clkout1
		);

	CLK_123MHZ_n <= clkout1_b;

	clkout2_buf : BUFG
		port map(
			O => clkout2_b,
			I => clkout2
		);

	CLK_246MHZ <= clkout2_b;

	clkout3_buf : BUFG
		port map(
			O => clkout3_b,
			I => clkout3
		);

	CLK_983MHZ <= clkout3_b;


	-- GIGE GTX  Clock Generator
	GTX_CLK_DCM_CLKGEN : DCM_CLKGEN
		generic map(
			CLKFXDV_DIVIDE  => 2,
			CLKFX_DIVIDE    => 4,
			CLKFX_MD_MAX    => 0.0,
			CLKFX_MULTIPLY  => 25,
			CLKIN_PERIOD    => 10.00,
			SPREAD_SPECTRUM => "NONE",
			STARTUP_WAIT    => FALSE
		)
		port map(
			CLKFX     => clkout4,
			CLKFX180  => clkout5,
			CLKFXDV   => open,
			LOCKED    => dcm1_locked,
			PROGDONE  => open,
			STATUS    => open,
			CLKIN     => dcm_clkin,
			FREEZEDCM => '0',
			PROGCLK   => '0',
			PROGDATA  => '0',
			PROGEN    => '0',
			RST       => SYS_RST
		);

	clkout4_buf : BUFG
		port map(
			O => clkout4_b,
			I => clkout4
		);

	CLK_15MHZ <= clkout4_b;

	clkout5_buf : BUFG
		port map(
			O => clkout5_b,
			I => clkout5
		);

	CLK_15MHZ_n <= clkout5_b;

	sys_not_locked <= not (dcm_locked and pll_locked);
	RST_O          <= sys_not_locked;
	SYS_PLL_Locked <= dcm_locked and pll_locked;

	--ODDR for Clock Forwarding
	SYS_CLK_o_ODDR2 : ODDR2
		generic map(
			DDR_ALIGNMENT => "NONE",    -- Sets output alignment to "NONE", "C0", "C1"
			INIT          => '0',       -- Sets initial state of the Q output to '0' or '1'
			SRTYPE        => "SYNC"
		)                               -- Specifies "SYNC" or "ASYNC" set/reset
		port map(
			Q  => sys_clk_o_pb,         -- 1-bit output data
			C0 => clkout0_b,            -- 1-bit clock input
			C1 => clkout1_b,            -- 1-bit clock input
			CE => pll_locked,           -- 1-bit clock enable input
			D0 => '1',                  -- 1-bit data input (associated with C0)
			D1 => '0',                  -- 1-bit data input (associated with C1)
			R  => '0',                  -- 1-bit reset input
			S  => '0'                   -- 1-bit set input
		);

	-- Output buffering
	SYS_CLK_o_OBUFDS : OBUF
		port map(
			O => SYS_CLK_o,
			I => sys_clk_o_pb
		);

	-- Clock Counter for Debugging
	Clock_Counter : clk_counter_ip
		generic map(
			DATA_WIDTH => DATA_WIDTH,
			ADDR_WIDTH => ADDR_WIDTH,
			BASE_ADDR  => BASE_ADDR
		)
		port map(
			CLK_I       => clkout0_b,
			RST_I       => sys_not_locked,
			WB_I        => WB_I,
			WB_O        => WB_O,
			TEST_CLOCKS => test_clocks
		);

	test_clocks(0) <= sys_clk_b;
	test_clocks(1) <= clkout2_b;
	test_clocks(2) <= clkout3_b;
	test_clocks(3) <= clkout4_b;

end architecture RTL;
