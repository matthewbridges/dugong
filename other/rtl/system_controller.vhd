library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

entity system_controller is
	port(
		--System Clock Differential Inputs 100MHz
		SYS_CLK_P  : in  STD_LOGIC;
		SYS_CLK_N  : in  STD_LOGIC;

		--System Reset
		SYS_RST    : in  STD_LOGIC;

		--System Control Inputs
		CLK_6MHZ   : out STD_LOGIC;
		CLK_100MHZ : out STD_LOGIC;
		CLK_200MHZ : out STD_LOGIC;
		RST_O      : out STD_LOGIC
	);
end entity system_controller;

architecture RTL of system_controller is

	-- Input clock buffering / unused connectors
	signal sys_clk_b       : std_logic;
	-- Output clock buffering
	signal clk0            : std_logic;
	signal clk0_b          : std_logic;
	signal clk2x           : std_logic;
	signal clk2x_b         : std_logic;
	signal clkdv           : std_logic;
	signal clkdv_b         : std_logic;
	signal locked_internal : std_logic;

begin
	-- Input buffering
	sys_clk_in_buf : IBUFGDS
		port map(
			O  => sys_clk_b,
			I  => SYS_CLK_P,
			IB => SYS_CLK_N
		);

	-- Clocking primitive
	--------------------------------------

	-- Instantiation of the DCM primitive
	--    * Unused inputs are tied off
	--    * Unused outputs are labelled unused
	dcm_sp_inst : DCM_SP
		generic map(
			CLKDV_DIVIDE       => 16.000,
			CLKFX_DIVIDE       => 1,
			CLKFX_MULTIPLY     => 4,
			CLKIN_DIVIDE_BY_2  => FALSE,
			CLKIN_PERIOD       => 10.0,
			CLKOUT_PHASE_SHIFT => "NONE",
			CLK_FEEDBACK       => "1X",
			DESKEW_ADJUST      => "SYSTEM_SYNCHRONOUS",
			PHASE_SHIFT        => 0,
			STARTUP_WAIT       => FALSE
		)
		port map(
			-- Input clock
			CLKIN    => sys_clk_b,
			CLKFB    => clk0_b,
			-- Output clocks
			CLK0     => clk0,
			CLK90    => open,
			CLK180   => open,
			CLK270   => open,
			CLK2X    => clk2x,
			CLK2X180 => open,
			CLKFX    => open,
			CLKFX180 => open,
			CLKDV    => clkdv,
			-- Ports for dynamic phase shift
			PSCLK    => '0',
			PSEN     => '0',
			PSINCDEC => '0',
			PSDONE   => open,
			-- Other control and status signals
			LOCKED   => locked_internal,
			STATUS   => open,
			RST      => SYS_RST,
			-- Unused pin, tie low

			DSSEN    => '0'
		);

	clk0_buf : BUFG
		port map(
			O => clk0_b,
			I => clk0
		);

	clk2x_buf : BUFG
		port map(
			O => clk2x_b,
			I => clk2x
		);

	clkdv_buf : BUFG
		port map(
			O => clkdv_b,
			I => clkdv
		);

	CLK_100MHZ <= clk0_b;
	CLK_200MHZ <= clk2x;
	CLK_6MHZ   <= clkdv_b;

	RST_O <= not locked_internal;

end architecture RTL;
