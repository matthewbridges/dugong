----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:32:38 08/30/2012 
-- Design Name: 
-- Module Name:    rhino_top - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

library RHINO_DUGONG;
use RHINO_DUGONG.dcomponents.ALL;

entity rhino_top is
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
		SYS_CLK_o      : out STD_LOGIC;
		SYS_PWR_ON     : out STD_LOGIC;
		SYS_PLL_Locked : out STD_LOGIC;
		SYS_STATUS     : out STD_LOGIC;

		--GPIO Interface
		GPIO           : out STD_LOGIC_VECTOR(15 downto 0);

		--LED Interface
		LED            : out STD_LOGIC_VECTOR(7 downto 0);

		--GMII Interface
		GTX_CLK_o      : out STD_LOGIC; --used only in GMII mode
		RX_CLK_i       : in  STD_LOGIC;
		TX_CLK_i       : in  STD_LOGIC; --used only in MII mode
		--		TX_ER          : out STD_LOGIC;
		--		TX_EN          : out STD_LOGIC;
		--		TXD            : out STD_LOGIC_VECTOR(7 downto 0);
		--		RX_ER          : in  STD_LOGIC;
		--		RX_DV          : in  STD_LOGIC;
		--		RXD            : in  STD_LOGIC_VECTOR(7 downto 0);
		--		CRS            : in  STD_LOGIC;
		--		COL            : in  STD_LOGIC;

		--GIGE Control
		GIGE_nRESET    : out STD_LOGIC

	--		--FMC150 CTRL interface
	--		FMC150_CLK     : in  STD_LOGIC;
	--		SPI_SCLK_O     : out STD_LOGIC;
	--		SPI_MOSI_O     : out STD_LOGIC;
	--		ADC_MISO_I     : in  STD_LOGIC;
	--		ADC_N_SS_O     : out STD_LOGIC;
	--		CDC_MISO_I     : in  STD_LOGIC;
	--		CDC_N_SS_O     : out STD_LOGIC;
	--		DAC_MISO_I     : in  STD_LOGIC;
	--		DAC_N_SS_O     : out STD_LOGIC;
	--		ADC_RST        : out STD_LOGIC;
	--		CDC_REF_EN     : out STD_LOGIC;
	--		CDC_N_RST      : out STD_LOGIC;
	--		CDC_N_PD       : out STD_LOGIC;
	--		CDC_PLL_STATUS : in  STD_LOGIC;
	--
	--		-- FMC150 ADC interface
	--		ADC_DCLK_P     : in  STD_LOGIC;
	--		ADC_DCLK_N     : in  STD_LOGIC;
	--		ADC_DATA_A_P   : in  STD_LOGIC_VECTOR(6 downto 0);
	--		ADC_DATA_A_N   : in  STD_LOGIC_VECTOR(6 downto 0);
	--		ADC_DATA_B_P   : in  STD_LOGIC_VECTOR(6 downto 0);
	--		ADC_DATA_B_N   : in  STD_LOGIC_VECTOR(6 downto 0);
	--
	--		-- FMC150 DAC interface		
	--		DAC_DCLK_P     : out STD_LOGIC;
	--		DAC_DCLK_N     : out STD_LOGIC;
	--		DAC_DATA_P     : out STD_LOGIC_VECTOR(7 downto 0);
	--		DAC_DATA_N     : out STD_LOGIC_VECTOR(7 downto 0);
	--		FRAME_P        : out STD_LOGIC;
	--		FRAME_N        : out STD_LOGIC;
	--		TXENABLE       : out STD_LOGIC;
	--
	-- -- Debug
	-- DEBUG          : out STD_LOGIC_VECTOR(31 downto 0)
	);
end rhino_top;

architecture Behavioral of rhino_top is
	signal sys_con_clk    : std_logic;
	signal sys_con_clk_n  : std_logic;
	signal dsp_clk_246MHZ : std_logic;
	signal dsp_clk_983MHZ : std_logic;
	signal clk_125MHZ     : std_logic;
	signal clk_125MHZ_n   : std_logic;
	signal sys_con_rst    : std_logic;
	signal wb_ms          : std_logic_vector(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
	signal wb_sm          : std_logic_vector(DATA_WIDTH downto 0);

	signal test_clocks : std_logic_vector(3 downto 0);

	--	signal ch_a : std_logic_vector(15 downto 0);
	--	signal ch_b : std_logic_vector(15 downto 0);

	signal tx_clk_b : std_logic;
	signal rx_clk_b : std_logic;

	component dugong
		generic(
			DATA_WIDTH : natural := 32;
			ADDR_WIDTH : natural := 12
		);
		port(
			--System Control Inputs
			CLK_I   : in  STD_LOGIC;
			CLK_I_n : in  STD_LOGIC;
			RST_I   : in  STD_LOGIC;
			--Master to WB
			WB_I    : in  STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
			WB_O    : out STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0)
		);
	end component;

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

	component gpio_controller_ip
		generic(
			DATA_WIDTH      : NATURAL               := 32;
			ADDR_WIDTH      : NATURAL               := 12;
			BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
			CORE_DATA_WIDTH : NATURAL               := 16;
			CORE_ADDR_WIDTH : NATURAL               := 4
		);
		port(
			--System Control Inputs
			CLK_I : in  STD_LOGIC;
			RST_I : in  STD_LOGIC;
			--Slave to WB
			WB_I  : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
			WB_O  : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
			--GPIO Interface
			GPIO  : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0)
		);
	end component;

	--	COMPONENT dds_core_ip
	--		generic(
	--			DATA_WIDTH      : NATURAL               := 32;
	--			ADDR_WIDTH      : NATURAL               := 12;
	--			BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
	--			CORE_DATA_WIDTH : NATURAL               := 16;
	--			CORE_ADDR_WIDTH : NATURAL               := 3
	--		);
	--		port(
	--			--System Control Inputs
	--			CLK_I     : in  STD_LOGIC;
	--			RST_I     : in  STD_LOGIC;
	--			--Slave to WB
	--			WB_I      : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
	--			WB_O      : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
	--			--Signal Channel Outputs
	--			DSP_CLK_I : in  STD_LOGIC;
	--			CH_A_O    : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
	--			CH_B_O    : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0)
	--		);
	--	END COMPONENT;
	--
	--	COMPONENT dac3283_serializer
	--		PORT(
	--			--System Control Inputs
	--			CLK_I      : in  STD_LOGIC;
	--			RST_I      : in  STD_LOGIC;
	--			--Signal Channel Inputs
	--			DSP_CLK_I  : in  STD_LOGIC;
	--			CH_A_I     : in  STD_LOGIC_VECTOR(15 downto 0);
	--			CH_B_I     : in  STD_LOGIC_VECTOR(15 downto 0);
	--			-- DAC interface
	--			DAC_DCLK_P : out STD_LOGIC;
	--			DAC_DCLK_N : out STD_LOGIC;
	--			DAC_DATA_P : out STD_LOGIC_VECTOR(7 downto 0);
	--			DAC_DATA_N : out STD_LOGIC_VECTOR(7 downto 0);
	--			FRAME_P    : out STD_LOGIC;
	--			FRAME_N    : out STD_LOGIC;
	--			TXENABLE   : out STD_LOGIC;
	--			-- Debug
	--			DEBUG      : out STD_LOGIC_VECTOR(15 downto 0)
	--		);
	--	END COMPONENT;
	--
	--	COMPONENT ads62p49_parellelizer
	--		GENERIC(
	--			DATA_WIDTH : natural := 16;
	--			ADDR_WIDTH : natural := 5
	--		);
	--		PORT(
	--			--System Control Inputs
	--			CLK_I        : in  STD_LOGIC;
	--			RST_I        : in  STD_LOGIC;
	--			--Signal Channel Inputs
	--			DSP_CLK_I    : in  STD_LOGIC;
	--			CH_A_O       : out STD_LOGIC_VECTOR(15 downto 0);
	--			CH_B_O       : out STD_LOGIC_VECTOR(15 downto 0);
	--			-- FMC150 ADC interface
	--			ADC_DCLK_P   : in  STD_LOGIC;
	--			ADC_DCLK_N   : in  STD_LOGIC;
	--			ADC_DATA_A_P : in  STD_LOGIC_VECTOR(6 downto 0);
	--			ADC_DATA_A_N : in  STD_LOGIC_VECTOR(6 downto 0);
	--			ADC_DATA_B_P : in  STD_LOGIC_VECTOR(6 downto 0);
	--			ADC_DATA_B_N : in  STD_LOGIC_VECTOR(6 downto 0);
	--			-- Debug
	--			DEBUG        : out STD_LOGIC_VECTOR(15 downto 0)
	--		);
	--	END COMPONENT;
	--
	--	component fmc150_controller_ip
	--		generic(
	--			DATA_WIDTH      : NATURAL               := 32;
	--			ADDR_WIDTH      : NATURAL               := 12;
	--			BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
	--			CORE_DATA_WIDTH : NATURAL               := 8;
	--			CORE_ADDR_WIDTH : NATURAL               := 9
	--		);
	--		port(
	--			--System Control Inputs
	--			CLK_I          : in  STD_LOGIC;
	--			RST_I          : in  STD_LOGIC;
	--			--Slave to WB
	--			WB_I           : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
	--			WB_O           : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
	--			--Serial Peripheral Interface
	--			SPI_SCLK_O     : out STD_LOGIC;
	--			SPI_MOSI_O     : out STD_LOGIC;
	--			ADC_MISO_I     : in  STD_LOGIC;
	--			ADC_N_SS_O     : out STD_LOGIC;
	--			CDC_MISO_I     : in  STD_LOGIC;
	--			CDC_N_SS_O     : out STD_LOGIC;
	--			DAC_MISO_I     : in  STD_LOGIC;
	--			DAC_N_SS_O     : out STD_LOGIC;
	--			ADC_RST        : out STD_LOGIC;
	--			CDC_REF_EN     : out STD_LOGIC;
	--			CDC_N_RST      : out STD_LOGIC;
	--			CDC_N_PD       : out STD_LOGIC;
	--			CDC_PLL_STATUS : in  STD_LOGIC;
	--			-- Debug
	--			DEBUG          : out STD_LOGIC_VECTOR(15 downto 0)
	--		);
	--	end component;

	component GIGE_TOP is
		generic(
			DATA_WIDTH : natural := 32;
			ADDR_WIDTH : natural := 12
		);
		port(
			--System Control Inputs
			CLK_I       : in  STD_LOGIC;
			CLK_I_n     : in  STD_LOGIC;
			RST_I       : in  STD_LOGIC;

			--GMII Interface
			GTX_CLK_o   : out STD_LOGIC; --used only in GMII mode
			--		RX_CLK         : in  STD_LOGIC;
			--		TX_CLK         : in  STD_LOGIC; --used only in MII mode
			--		TX_ER          : out STD_LOGIC;
			--		TX_EN          : out STD_LOGIC;
			--		TXD            : out STD_LOGIC_VECTOR(7 downto 0);
			--		RX_ER          : in  STD_LOGIC;
			--		RX_DV          : in  STD_LOGIC;
			--		RXD            : in  STD_LOGIC_VECTOR(7 downto 0);
			--		CRS            : in  STD_LOGIC;
			--		COL            : in  STD_LOGIC

			--GIGE Control
			GIGE_nRESET : out STD_LOGIC
		);
	end component;

begin
	Sys_Con : system_controller
		generic map(
			DATA_WIDTH => DATA_WIDTH,
			ADDR_WIDTH => ADDR_WIDTH,
			BASE_ADDR  => x"E08"
		)
		port map(
			--System Clock Differential Inputs 100MHz			
			SYS_CLK_P      => SYS_CLK_P,
			SYS_CLK_N      => SYS_CLK_N,
			--System Clock Differential Outputs 100MHz			
			SYS_CLK_o      => SYS_CLK_o,
			--System Reset	
			SYS_RST        => SYS_RST,
			--System Status	
			SYS_PWR_ON     => SYS_PWR_ON,
			SYS_PLL_Locked => SYS_PLL_Locked,
			--System Control Outputs
			CLK_123MHZ     => sys_con_clk,
			CLK_123MHZ_n   => sys_con_clk_n,
			CLK_246MHZ     => dsp_clk_246MHZ,
			CLK_983MHZ     => dsp_clk_983MHZ,
			CLK_15MHZ      => clk_125MHZ,
			CLK_15MHZ_n    => clk_125MHZ_n,
			RST_O          => sys_con_rst,
			--Slave to WB
			WB_I           => wb_ms,
			WB_O           => wb_sm
		);

	Central_Control_Unit : dugong
		GENERIC MAP(
			DATA_WIDTH => DATA_WIDTH,
			ADDR_WIDTH => ADDR_WIDTH
		)
		PORT MAP(
			CLK_I   => sys_con_clk,
			CLK_I_n => sys_con_clk_n,
			RST_I   => sys_con_rst,
			WB_I    => wb_sm,
			WB_O    => wb_ms
		);

	Clock_Counter : clk_counter_ip
		generic map(
			DATA_WIDTH => DATA_WIDTH,
			ADDR_WIDTH => ADDR_WIDTH,
			BASE_ADDR  => x"E00"
		)
		port map(
			CLK_I       => sys_con_clk,
			RST_I       => sys_con_rst,
			WB_I        => wb_ms,
			WB_O        => wb_sm,
			TEST_CLOCKS => test_clocks
		);

	test_clocks(3 downto 0) <= rx_clk_b & tx_clk_b & clk_125MHZ & sys_con_clk;

	LEDs_8 : gpio_controller_ip
		GENERIC MAP(
			DATA_WIDTH      => DATA_WIDTH,
			ADDR_WIDTH      => ADDR_WIDTH,
			BASE_ADDR       => x"F00",
			CORE_DATA_WIDTH => 8
		)
		PORT MAP(
			CLK_I => sys_con_clk,
			RST_I => sys_con_rst,
			WB_I  => wb_ms,
			WB_O  => wb_sm,
			GPIO  => LED
		);

	GPIOs_16 : gpio_controller_ip
		GENERIC MAP(
			DATA_WIDTH      => DATA_WIDTH,
			ADDR_WIDTH      => ADDR_WIDTH,
			BASE_ADDR       => x"F08",
			CORE_DATA_WIDTH => 16
		)
		PORT MAP(
			CLK_I => sys_con_clk,
			RST_I => sys_con_rst,
			WB_I  => wb_ms,
			WB_O  => wb_sm,
			GPIO  => GPIO
		);

	--	DDS : dds_core_ip
	--		GENERIC MAP(
	--			BASE_ADDR       => x"700",
	--			CORE_DATA_WIDTH => 16
	--		)
	--		PORT MAP(
	--			CLK_I     => sys_con_clk,
	--			RST_I     => sys_con_rst,
	--			WB_I      => wb_ms,
	--			WB_O      => wb_sm,
	--			DSP_CLK_I => dsp_clk_246MHZ,
	--			CH_A_O    => ch_a,
	--			CH_B_O    => open
	--		);
	--
	--	FMC150_CTRL : fmc150_controller_ip
	--		generic map(
	--			DATA_WIDTH      => DATA_WIDTH,
	--			ADDR_WIDTH      => ADDR_WIDTH,
	--			BASE_ADDR       => x"A00",
	--			CORE_DATA_WIDTH => 8
	--		)
	--		port map(
	--			--System Control Inputs
	--			CLK_I          => sys_con_clk,
	--			RST_I          => sys_con_rst,
	--			WB_I           => wb_ms,
	--			WB_O           => wb_sm,
	--			--Serial Peripheral Interface
	--			SPI_SCLK_O     => SPI_SCLK_O,
	--			SPI_MOSI_O     => SPI_MOSI_O,
	--			ADC_MISO_I     => ADC_MISO_I,
	--			ADC_N_SS_O     => ADC_N_SS_O,
	--			CDC_MISO_I     => CDC_MISO_I,
	--			CDC_N_SS_O     => CDC_N_SS_O,
	--			DAC_MISO_I     => DAC_MISO_I,
	--			DAC_N_SS_O     => DAC_N_SS_O,
	--			ADC_RST        => ADC_RST,
	--			CDC_REF_EN     => CDC_REF_EN,
	--			CDC_N_RST      => CDC_N_RST,
	--			CDC_N_PD       => CDC_N_PD,
	--			CDC_PLL_STATUS => CDC_PLL_STATUS,
	--			DEBUG          => DEBUG(15 downto 0)
	--		);
	--
	--	FMC150_DAC : dac3283_serializer
	--		PORT MAP(
	--			--System Control Inputs
	--			CLK_I      => sys_con_clk,
	--			RST_I      => sys_con_rst,
	--			--Signal Channel Inputs
	--			DSP_CLK_I  => dsp_clk_246MHZ,
	--			CH_A_I     => ch_a,
	--			CH_B_I     => ch_b,
	--			-- DAC interface
	--			DAC_DCLK_P => DAC_DCLK_P,
	--			DAC_DCLK_N => DAC_DCLK_N,
	--			DAC_DATA_P => DAC_DATA_P,
	--			DAC_DATA_N => DAC_DATA_N,
	--			FRAME_P    => FRAME_P,
	--			FRAME_N    => FRAME_N,
	--			TXENABLE   => TXENABLE,
	--			-- Debug
	--			DEBUG      => open          --DEBUG(15 downto 0)
	--		);
	--
	--	FMC150_ADC : ads62p49_parellelizer
	--		generic map(
	--			DATA_WIDTH => DATA_WIDTH,
	--			ADDR_WIDTH => ADDR_WIDTH
	--		)
	--		port map(
	--			--System Control Inputs
	--			CLK_I        => sys_con_clk,
	--			RST_I        => sys_con_rst,
	--			--Signal Channel Inputs
	--			DSP_CLK_I    => dsp_clk_246MHZ,
	--			CH_A_O       => open,
	--			CH_B_O       => ch_b,
	--			-- FMC150 ADC interface
	--			ADC_DCLK_P   => ADC_DCLK_P,
	--			ADC_DCLK_N   => ADC_DCLK_N,
	--			ADC_DATA_A_P => ADC_DATA_A_P,
	--			ADC_DATA_A_N => ADC_DATA_A_N,
	--			ADC_DATA_B_P => ADC_DATA_B_P,
	--			ADC_DATA_B_N => ADC_DATA_B_N,
	--			-- Debug
	--			DEBUG        => DEBUG(31 downto 16)
	--		);

	Gbe_MAC : GIGE_TOP
		port map(
			CLK_I       => clk_125MHZ,
			CLK_I_n     => clk_125MHZ_n,
			RST_I       => sys_con_rst,
			GTX_CLK_o   => GTX_CLK_o,
			GIGE_nRESET => GIGE_nRESET
		);

	inst1 : IBUFG
		port map(
			O => tx_clk_b,
			I => TX_CLK_i
		);

	inst2 : IBUFG
		port map(
			O => rx_clk_b,
			I => RX_CLK_i
		);

	SYS_STATUS <= '1';

end Behavioral;

