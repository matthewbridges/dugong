-- TestBench Template 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fmc150_controller_ip_tb IS
END fmc150_controller_ip_tb;

ARCHITECTURE behavior OF fmc150_controller_ip_tb IS

	-- Component Declaration
	COMPONENT fmc150_controller_ip
		port(
			CLK_I      : in  STD_LOGIC;
			RST_I      : in  STD_LOGIC;
			WB_I       : in  STD_LOGIC_VECTOR(46 downto 0);
			WB_O       : out STD_LOGIC_VECTOR(32 downto 0);
			SPI_SCLK_O : out STD_LOGIC;
			SPI_MOSI_O : out STD_LOGIC;
			ADC_MISO_I : in  STD_LOGIC;
			ADC_N_SS_O : out STD_LOGIC;
			CDC_MISO_I : in  STD_LOGIC;
			CDC_N_SS_O : out STD_LOGIC;
			DAC_MISO_I : in  STD_LOGIC;
			DAC_N_SS_O : out STD_LOGIC;
			DEBUG      : out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component fmc150_controller_ip;

	--Inputs
	signal CLK_I      : std_logic                     := '0';
	signal RST_I      : std_logic                     := '1';
	signal WB_I       : STD_LOGIC_VECTOR(46 downto 0) := (others => '0');
	signal ADC_MISO_I : STD_LOGIC                     := '1';
	signal CDC_MISO_I : STD_LOGIC                     := '1';
	signal DAC_MISO_I : STD_LOGIC                     := '1';

	--Outputs
	signal WB_O       : STD_LOGIC_VECTOR(32 downto 0);
	signal SPI_SCLK_O : STD_LOGIC;
	signal SPI_MOSI_O : STD_LOGIC;
	signal ADC_N_SS_O : STD_LOGIC;
	signal CDC_N_SS_O : STD_LOGIC;
	signal DAC_N_SS_O : STD_LOGIC;
	signal DEBUG      : STD_LOGIC_VECTOR(15 downto 0);

	-- Clock period definitions
	constant CLK_I_period : time := 10 ns;

BEGIN

	-- Component Instantiation
	uut : fmc150_controller_ip
		port map(CLK_I      => CLK_I,
			     RST_I      => RST_I,
			     WB_I       => WB_I,
			     WB_O       => WB_O,
			     SPI_SCLK_O => SPI_SCLK_O,
			     SPI_MOSI_O => SPI_MOSI_O,
			     ADC_MISO_I => ADC_MISO_I,
			     ADC_N_SS_O => ADC_N_SS_O,
			     CDC_MISO_I => CDC_MISO_I,
			     CDC_N_SS_O => CDC_N_SS_O,
			     DAC_MISO_I => DAC_MISO_I,
			     DAC_N_SS_O => DAC_N_SS_O,
			     DEBUG      => DEBUG);

	-- Clock process definitions
	CLK_I_process : process
	begin
		CLK_I <= '0';
		wait for CLK_I_period / 2;
		CLK_I <= '1';
		wait for CLK_I_period / 2;
	end process;

	-- Stimulus process
	stim_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 500 ns;

		RST_I <= '0';

		wait for CLK_I_period * 10;

		-- insert stimulus here 

		wait;
	end process;
--  End Test Bench 

END;
