library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity system_controller is
	port(
		--System Clock Differential Inputs 100MHz
		SYS_CLK_P      : in  STD_LOGIC;
		SYS_CLK_N      : in  STD_LOGIC;
		--System Clock Differential Outputs 100MHz
		SYS_CLK_P_o    : out STD_LOGIC;
		SYS_CLK_N_o    : out STD_LOGIC;
		--System Reset
		SYS_RST        : in  STD_LOGIC;
		--System Status
		SYS_PWR_ON     : out STD_LOGIC;
		SYS_PLL_Locked : out STD_LOGIC;
		--System Control Outputs
		CLK_100MHZ     : out STD_LOGIC;
		CLK_100MHZ_n   : out STD_LOGIC;
		CLK_125MHZ     : out STD_LOGIC;
		CLK_125MHZ_n   : out STD_LOGIC;
		CLK_200MHZ     : out STD_LOGIC;
		RST_O          : out STD_LOGIC
	);
end entity system_controller;

architecture RTL of system_controller is

	-- Input clock buffering / unused connectors
	signal sys_clk_b       : std_ulogic;
	-- Output clock buffering
	signal sys_clk_o_pb    : std_ulogic;
	signal clkout0         : std_ulogic;
	signal clkout0_b       : std_ulogic;
	signal clkout1         : std_ulogic;
	signal clkout1_b       : std_ulogic;
	signal clkout2         : std_ulogic;
	signal clkout2_b       : std_ulogic;
	signal clkout3         : std_ulogic;
	signal clkout3_b       : std_ulogic;
	signal clkout4         : std_ulogic;
	signal clkout4_b       : std_ulogic;
	signal clkfbout        : std_ulogic;
	signal locked_internal : std_logic;

begin
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

	-- PLL_BASE: Phase Locked Loop (PLL) Clock Management Component
	--           Spartan-6
	-- Xilinx HDL Libraries Guide, version 14.1

	SYS_CLK_PLL_BASE : PLL_BASE
		generic map(
			BANDWIDTH             => "HIGH", -- "HIGH", "LOW" or "OPTIMIZED"
			CLKFBOUT_MULT         => 10, -- Multiply value for all CLKOUT clock outputs (1-64)
			CLKFBOUT_PHASE        => 0.0, -- Phase offset in degrees of the clock feedback output (0.0-360.0).
			CLKIN_PERIOD          => 10.0, -- Input clock period in ns to ps resolution (i.e. 33.333 is 30MHz).
			-- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for CLKOUT# clock output (1-128)
			CLKOUT0_DIVIDE        => 10,
			CLKOUT1_DIVIDE        => 10,
			CLKOUT2_DIVIDE        => 8,
			CLKOUT3_DIVIDE        => 8,
			CLKOUT4_DIVIDE        => 5,
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
			CLKOUT3_PHASE         => 180.0,
			CLKOUT4_PHASE         => 0.0,
			CLKOUT5_PHASE         => 0.0,
			CLK_FEEDBACK          => "CLKFBOUT", -- Clock source to drive CLKFBIN ("CLKFBOUT" or "CLKOUT0")
			COMPENSATION          => "SYSTEM_SYNCHRONOUS", -- "SYSTEM_SYNCHRONOUS", "SOURCE_SYNCHRONOUS", "EXTERNAL"
			DIVCLK_DIVIDE         => 1, -- Division value for all output clocks (1-52)
			REF_JITTER            => 0.001, -- Reference Clock Jitter in UI (0.000-0.999).
			RESET_ON_LOSS_OF_LOCK => FALSE -- Must be set to FALSE
		)
		port map(
			CLKFBOUT => clkfbout,       -- 1-bit output: PLL_BASE feedback output
			-- CLKOUT0 - CLKOUT5: 1-bit (each) output: Clock outputs
			CLKOUT0  => clkout0,
			CLKOUT1  => clkout1,
			CLKOUT2  => clkout2,
			CLKOUT3  => clkout3,
			CLKOUT4  => clkout4,
			CLKOUT5  => open,
			LOCKED   => locked_internal, -- 1-bit output: PLL_BASE lock status output
			CLKFBIN  => clkfbout,       -- 1-bit input: Feedback clock input
			CLKIN    => sys_clk_b,      -- 1-bit input: Clock input
			RST      => SYS_RST         -- 1-bit input: Reset input
		);

	-- End of PLL_BASE_inst instantiation


	clkout0_buf : BUFG
		port map(
			O => clkout0_b,
			I => clkout0
		);

	CLK_100MHZ <= clkout0_b;

	clkout1_buf : BUFG
		port map(
			O => clkout1_b,
			I => clkout1
		);

	CLK_100MHZ_n <= clkout1_b;

	clkout2_buf : BUFG
		port map(
			O => clkout2_b,
			I => clkout2
		);

	CLK_125MHZ <= clkout2_b;

	clkout3_buf : BUFG
		port map(
			O => clkout3_b,
			I => clkout3
		);

	CLK_125MHZ_n <= clkout3_b;

	clkout4_buf : BUFG
		port map(
			O => clkout4_b,
			I => clkout4
		);

	CLK_200MHZ <= clkout4_b;

	RST_O          <= not locked_internal;
	SYS_PLL_Locked <= locked_internal;

	--ODDR for Clock Forwarding
	SYS_CLK_o_ODDR2 : ODDR2
		generic map(
			DDR_ALIGNMENT => "NONE",    -- Sets output alignment to "NONE", "C0", "C1"
			INIT          => '0',       -- Sets initial state of the Q output to '0' or '1'
			SRTYPE        => "SYNC")    -- Specifies "SYNC" or "ASYNC" set/reset
		port map(
			Q  => sys_clk_o_pb,         -- 1-bit output data
			C0 => clkout0_b,            -- 1-bit clock input
			C1 => clkout1_b,            -- 1-bit clock input
			CE => locked_internal,      -- 1-bit clock enable input
			D0 => '1',                  -- 1-bit data input (associated with C0)
			D1 => '0',                  -- 1-bit data input (associated with C1)
			R  => '0',                  -- 1-bit reset input
			S  => '0'                   -- 1-bit set input
		);

	-- Output buffering
	SYS_CLK_o_OBUFDS : OBUFDS
		port map(
			O  => SYS_CLK_P_o,
			OB => SYS_CLK_N_o,
			I  => sys_clk_o_pb
		);

end architecture RTL;
