-------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:40:19 09/26/2012
-- Design Name:   
-- Module Name:   /home/mbridges/Projects/Dugong/other/sim/system_controller_tb.vhd
-- Project Name:  Dugong
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: system_controller
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY rhino_top_tb IS
END rhino_top_tb;

ARCHITECTURE behavior OF rhino_top_tb IS

	-- Component Declaration for the Unit Under Test (UUT)

	component rhino_top
		generic(
			DATA_WIDTH : natural := 32;
			ADDR_WIDTH : natural := 12
		);
		port(
			--System Control Inputs
			SYS_CLK_P      : in  STD_LOGIC;
			SYS_CLK_N      : in  STD_LOGIC;
			SYS_RST        : in  STD_LOGIC;
			--System Control Outputs
			SYS_CLK_P_o    : out STD_LOGIC;
			SYS_CLK_N_o    : out STD_LOGIC;
			SYS_PWR_ON     : out STD_LOGIC;
			SYS_PLL_Locked : out STD_LOGIC;

			--GPIO Interface
			GPIO           : out STD_LOGIC_VECTOR(15 downto 0);

			--LED Interface
			LED            : out STD_LOGIC_VECTOR(7 downto 0);

			--		--DA2 Interface
			--		DA2_D1       : out STD_LOGIC;
			--		DA2_D2       : out STD_LOGIC;
			--		DA2_CLK_OUT  : out STD_LOGIC;
			--		DA2_nSYNC    : out STD_LOGIC;

			-- FMC150  interface
			--		CLK_TO_FPGA    : in  STD_LOGIC;

			-- FMC150 ADC interface
			--		CLK_AB_P       : in  STD_LOGIC;
			---		CLK_AB_N       : in  STD_LOGIC;

			--		-- FMC150 DAC interface		
			--		DAC_DCLK_P     : out STD_LOGIC;
			--		DAC_DCLK_N     : out STD_LOGIC;
			--		DAC_DATA_P     : out STD_LOGIC_VECTOR(7 downto 0);
			--		DAC_DATA_N     : out STD_LOGIC_VECTOR(7 downto 0);
			--		FRAME_P        : out STD_LOGIC;
			--		FRAME_N        : out STD_LOGIC;
			--		TXENABLE       : out STD_LOGIC;

			--FMC150 CTRL interface
			SPI_SCLK_O     : out STD_LOGIC;
			SPI_MOSI_O     : out STD_LOGIC;
			ADC_MISO_I     : in  STD_LOGIC;
			ADC_N_SS_O     : out STD_LOGIC;
			--		ADC_RESET : out STD_LOGIC;
			CDC_MISO_I     : in  STD_LOGIC;
			CDC_N_SS_O     : out STD_LOGIC;
			DAC_MISO_I     : in  STD_LOGIC;
			DAC_N_SS_O     : out STD_LOGIC;

			--Gigabit Ethernet PHY Interface
			--GMII interface for 1 Gig Ethernet PHY
			--      GIGE_GTX_CLK   : out std_logic;
			--		GIGE_TX_CLK  : in    std_logic;
			--		GIGE_TX_EN   : out   std_logic;
			--		GIGE_TX_ER   : out   std_logic;
			--		GIGE_TXD     : out   std_logic_vector(7 downto 0);
			--		GIGE_RX_CLK  : in    std_logic;
			--		GIGE_RX_DV   : in    std_logic;
			--		GIGE_RX_ER   : in    std_logic;
			--		GIGE_RXD     : in    std_logic_vector(7 downto 0);
			--		GIGE_CRS     : in    std_logic;
			--		GIGE_COL     : in    std_logic;
			--		-- Control and MDIO interface for 1 Gig Ethernet PHY
			--		GIGE_MDC     : out   std_logic;
			--		GIGE_MDIO    : inout std_logic;
			--		GIGE_nINT    : in    std_logic;
			--      GIGE_nRESET    : out std_logic;
			--      GIGE_COMA      : out std_logic;

			-- Debug
			DEBUG          : out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component rhino_top;

	--Inputs
	signal SYS_CLK_P  : std_logic := '0';
	signal SYS_CLK_N  : std_logic := '1';
	signal SYS_RST    : std_logic := '1';
	signal ADC_MISO_I : STD_LOGIC := '0';
	signal CDC_MISO_I : STD_LOGIC := '0';
	signal DAC_MISO_I : STD_LOGIC := '0';

	--Outputs
	signal SYS_CLK_P_o    : STD_LOGIC;
	signal SYS_CLK_N_o    : STD_LOGIC;
	signal SYS_PWR_ON     : STD_LOGIC;
	signal SYS_PLL_Locked : STD_LOGIC;
	signal GPIO           : STD_LOGIC_VECTOR(15 downto 0);
	signal LED            : STD_LOGIC_VECTOR(7 downto 0);
	signal SPI_SCLK_O     : STD_LOGIC;
	signal SPI_MOSI_O     : STD_LOGIC;
	signal ADC_N_SS_O     : STD_LOGIC;
	signal CDC_N_SS_O     : STD_LOGIC;
	signal DAC_N_SS_O     : STD_LOGIC;
	signal DEBUG          : STD_LOGIC_VECTOR(15 downto 0);

	-- Clock period definitions
	constant SYS_CLK_P_period : time := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : rhino_top
		generic map(
			DATA_WIDTH => 32,
			ADDR_WIDTH => 12
		)
		port map(SYS_CLK_P      => SYS_CLK_P,
			     SYS_CLK_N      => SYS_CLK_N,
			     SYS_RST        => SYS_RST,
			     SYS_CLK_P_o    => SYS_CLK_P_o,
			     SYS_CLK_N_o    => SYS_CLK_N_o,
			     SYS_PWR_ON     => SYS_PWR_ON,
			     SYS_PLL_Locked => SYS_PLL_Locked,
			     GPIO           => GPIO,
			     LED            => LED,
			     SPI_SCLK_O     => SPI_SCLK_O,
			     SPI_MOSI_O     => SPI_MOSI_O,
			     ADC_MISO_I     => ADC_MISO_I,
			     ADC_N_SS_O     => ADC_N_SS_O,
			     CDC_MISO_I     => CDC_MISO_I,
			     CDC_N_SS_O     => CDC_N_SS_O,
			     DAC_MISO_I     => DAC_MISO_I,
			     DAC_N_SS_O     => DAC_N_SS_O,
			     DEBUG          => DEBUG);

	-- Clock process definitions
	SYS_CLK_P_process : process
	begin
		SYS_CLK_P <= '0';
		SYS_CLK_N <= '1';
		wait for SYS_CLK_P_period / 2;
		SYS_CLK_P <= '1';
		SYS_CLK_N <= '0';
		wait for SYS_CLK_P_period / 2;
	end process;

	-- Stimulus process
	stim_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;

		SYS_RST <= '0';

		wait for SYS_CLK_P_period * 10;

		-- insert stimulus here 

		wait;
	end process;

END;
