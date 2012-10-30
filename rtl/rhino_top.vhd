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
		SYS_CLK_P_o    : out STD_LOGIC;
		SYS_CLK_N_o    : out STD_LOGIC;
		FMC150_CLK     : out STD_LOGIC;
		FMC150_ADC_CLK : out STD_LOGIC;
		SYS_PWR_ON     : out STD_LOGIC;
		SYS_PLL_Locked : out STD_LOGIC;
		SYS_STATUS     : out STD_LOGIC;

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
		CLK_TO_FPGA    : in  STD_LOGIC;

		--FMC150 CTRL interface
		SPI_SCLK_O     : out STD_LOGIC;
		SPI_MOSI_O     : out STD_LOGIC;
		ADC_MISO_I     : in  STD_LOGIC;
		ADC_N_SS_O     : out STD_LOGIC;
		--		ADC_RESET : out STD_LOGIC;
		CDC_MISO_I     : in  STD_LOGIC;
		CDC_N_SS_O     : out STD_LOGIC;
		CDC_REF_EN     : out STD_LOGIC;
		CDC_N_RST      : out STD_LOGIC;
		CDC_N_PD       : out STD_LOGIC;
		CDC_PLL_STATUS : in  STD_LOGIC;
		DAC_MISO_I     : in  STD_LOGIC;
		DAC_N_SS_O     : out STD_LOGIC;

		-- FMC150 ADC interface
		CLK_AB_P       : in  STD_LOGIC;
		CLK_AB_N       : in  STD_LOGIC;

		-- FMC150 DAC interface		
		DAC_DCLK_P     : out STD_LOGIC;
		DAC_DCLK_N     : out STD_LOGIC;
		DAC_DATA_P     : out STD_LOGIC_VECTOR(7 downto 0);
		DAC_DATA_N     : out STD_LOGIC_VECTOR(7 downto 0);
		FRAME_P        : out STD_LOGIC;
		FRAME_N        : out STD_LOGIC;
		TXENABLE       : out STD_LOGIC;

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
		DEBUG          : out STD_LOGIC_VECTOR(31 downto 0)
	);
end rhino_top;

architecture Behavioral of rhino_top is
	signal sys_con_clk   : std_logic;
	signal sys_con_clk_n : std_logic;
	signal sys_con_rst   : std_logic;
	signal wb_ms         : std_logic_vector(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
	signal wb_sm         : std_logic_vector(DATA_WIDTH downto 0);

	signal ch_a : std_logic_vector(15 downto 0);
	signal ch_b : std_logic_vector(15 downto 0);

	signal clk_to_fpga_b : std_logic;
	signal clk_ab_b      : std_logic;

	--	signal init_done : std_logic;

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

	COMPONENT dds_core_ip
		generic(
			DATA_WIDTH      : NATURAL               := 32;
			ADDR_WIDTH      : NATURAL               := 12;
			BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
			CORE_DATA_WIDTH : NATURAL               := 16;
			CORE_ADDR_WIDTH : NATURAL               := 3
		);
		port(
			--System Control Inputs
			CLK_I  : in  STD_LOGIC;
			RST_I  : in  STD_LOGIC;
			--Slave to WB
			WB_I   : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
			WB_O   : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
			--Signal Channel Outputs
			CH_A_O : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
			CH_B_O : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0)
		);
	END COMPONENT;

	--	COMPONENT da2_controller_ip
	--		GENERIC(
	--			DATA_WIDTH      : NATURAL               := 16;
	--			ADDR_WIDTH      : NATURAL               := 12;
	--			BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
	--			CORE_DATA_WIDTH : NATURAL               := 16;
	--			CORE_ADDR_WIDTH : NATURAL               := 4
	--		);
	--		PORT(
	--			--System Control Inputs
	--			CLK_I   : in  STD_LOGIC;
	--			RST_I   : in  STD_LOGIC;
	--			--Slave to WB
	--			WB_I    : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
	--			WB_O    : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
	--			CH_A_I  : in  STD_LOGIC_VECTOR(11 downto 0);
	--			CH_B_I  : in  STD_LOGIC_VECTOR(11 downto 0);
	--			--DA2 Pmod interface signals
	--			D1      : out std_logic;
	--			D2      : out std_logic;
	--			CLK_OUT : out std_logic;
	--			nSYNC   : out std_logic
	--		);
	--	END COMPONENT;

	COMPONENT dac3283_serializer
		PORT(
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
	END COMPONENT;

	component fmc150_controller_ip
		generic(
			DATA_WIDTH      : NATURAL               := 32;
			ADDR_WIDTH      : NATURAL               := 12;
			BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
			CORE_DATA_WIDTH : NATURAL               := 8;
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
			--		ADC_RESET : out STD_LOGIC;
			CDC_MISO_I     : in  STD_LOGIC;
			CDC_N_SS_O     : out STD_LOGIC;
			CDC_REF_EN     : out STD_LOGIC;
			CDC_N_RST      : out STD_LOGIC;
			CDC_N_PD       : out STD_LOGIC;
			CDC_PLL_STATUS : in  STD_LOGIC;
			DAC_MISO_I     : in  STD_LOGIC;
			DAC_N_SS_O     : out STD_LOGIC;
			-- Debug
			DEBUG          : out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component;

--	COMPONENT fmc150_if
--		generic(
--			START_ADDR : std_logic_vector(27 downto 0) := x"0000000";
--			STOP_ADDR  : std_logic_vector(27 downto 0) := x"00000FF"
--		);
--		port(
--			-- Global signals
--			rst          : in  std_logic;
--			clk          : in  std_logic;
--
--			spi_sclk     : out std_logic;
--			spi_sdata    : out std_logic;
--			adc_n_en     : out std_logic;
--			adc_sdo      : in  std_logic;
--			adc_reset    : out std_logic;
--			cdce_n_en    : out std_logic;
--			cdce_sdo     : in  std_logic;
--			cdce_n_reset : out std_logic;
--			cdce_n_pd    : out std_logic;
--			ref_en       : out std_logic;
--			pll_status   : in  std_logic;
--			dac_n_en     : out std_logic;
--			dac_sdo      : in  std_logic;
--			mon_n_en     : out std_logic;
--			mon_sdo      : in  std_logic;
--			mon_n_reset  : out std_logic;
--			mon_n_int    : in  std_logic;
--			init_done    : out std_logic
--		);
--	END COMPONENT;

begin
	Sys_Con : system_controller
		port map(
			--System Clock Differential Inputs 100MHz			
			SYS_CLK_P      => SYS_CLK_P,
			SYS_CLK_N      => SYS_CLK_N,
			--System Clock Differential Outputs 100MHz			
			SYS_CLK_P_o    => SYS_CLK_P_o,
			SYS_CLK_N_o    => SYS_CLK_N_o,
			--System Reset	
			SYS_RST        => SYS_RST,
			--System Status	
			SYS_PWR_ON     => SYS_PWR_ON,
			SYS_PLL_Locked => SYS_PLL_Locked,
			--System Control Outputs	
			CLK_100MHZ     => open,
			CLK_100MHZ_n   => open,
			CLK_125MHZ     => sys_con_clk,
			CLK_125MHZ_n   => sys_con_clk_n,
			CLK_200MHZ     => open,
			RST_O          => sys_con_rst
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
			TEST_CLOCKS => clk_ab_b & clk_to_fpga_b & sys_con_clk_n & sys_con_clk
		);

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

		DDS : dds_core_ip
			GENERIC MAP(
				BASE_ADDR       => x"700",
				CORE_DATA_WIDTH => 16
			)
			PORT MAP(
				CLK_I  => sys_con_clk,
				RST_I  => sys_con_rst,
				WB_I   => wb_ms,
				WB_O   => wb_sm,
				CH_A_O => ch_a,
				CH_B_O => ch_b
			);
	
	--	DAC : da2_controller_ip
	--		GENERIC MAP(
	--			BASE_ADDR       => x"800",
	--			CORE_DATA_WIDTH => 12
	--		)
	--		PORT MAP(
	--			CLK_I   => sys_con_clk,
	--			RST_I   => sys_con_rst,
	--			WB_I    => wb_ms,
	--			WB_O    => wb_sm,
	--			CH_A_I  => ch_a(15 downto 4),
	--			CH_B_I  => ch_b(15 downto 4),
	--			D1      => DA2_D1,
	--			D2      => DA2_D2,
	--			CLK_OUT => DA2_CLK_OUT,
	--			nSYNC   => DA2_nSYNC
	--		);

	FMC150_CTRL : fmc150_controller_ip
		generic map(
			DATA_WIDTH      => DATA_WIDTH,
			ADDR_WIDTH      => ADDR_WIDTH,
			BASE_ADDR       => x"A00",
			CORE_DATA_WIDTH => 8
		)
		port map(
			CLK_I          => sys_con_clk,
			RST_I          => sys_con_rst,
			WB_I           => wb_ms,
			WB_O           => wb_sm,
			SPI_SCLK_O     => SPI_SCLK_O,
			SPI_MOSI_O     => SPI_MOSI_O,
			ADC_MISO_I     => ADC_MISO_I,
			ADC_N_SS_O     => ADC_N_SS_O,
			CDC_MISO_I     => CDC_MISO_I,
			CDC_N_SS_O     => CDC_N_SS_O,
			CDC_REF_EN     => CDC_REF_EN,
			CDC_N_RST      => CDC_N_RST,
			CDC_N_PD       => CDC_N_PD,
			CDC_PLL_STATUS => CDC_PLL_STATUS,
			DAC_MISO_I     => DAC_MISO_I,
			DAC_N_SS_O     => DAC_N_SS_O,
			DEBUG          => DEBUG(15 downto 0)
		);

	FMC150 : dac3283_serializer
		PORT MAP(
			--System Control Inputs
			CLK_I      => sys_con_clk,
			RST_I      => sys_con_rst,
			--Signal Channel Inputs
			CH_A_I     => ch_a,
			CH_B_I     => ch_b,
			-- DAC interface
			DAC_CLK_I  => clk_to_fpga_b,
			DAC_DCLK_P => DAC_DCLK_P,
			DAC_DCLK_N => DAC_DCLK_N,
			DAC_DATA_P => DAC_DATA_P,
			DAC_DATA_N => DAC_DATA_N,
			FRAME_P    => FRAME_P,
			FRAME_N    => FRAME_N,
			TXENABLE   => TXENABLE,
			DEBUG      => DEBUG(31 downto 16)
		);

	--		FMC150_CTRL : fmc150_if
	--			PORT MAP(
	--				-- Global signals
	--				rst          => sys_con_rst,
	--				clk          => sys_con_clk,
	--				spi_sclk     => spi_sclk_b,
	--				spi_sdata    => spi_sdata_b,
	--				adc_n_en     => adc_n_en,
	--				adc_sdo      => adc_sdo,
	--				adc_reset    => adc_reset,
	--				cdce_n_en    => cdce_n_en,
	--				cdce_sdo     => cdce_sdo,
	--				cdce_n_reset => cdce_n_reset,
	--				cdce_n_pd    => cdce_n_pd,
	--				ref_en       => ref_en,
	--				pll_status   => pll_status,
	--				dac_n_en     => dac_n_en_b,
	--				dac_sdo      => dac_sdo,
	--				mon_n_en     => mon_n_en,
	--				mon_sdo      => mon_sdo,
	--				mon_n_reset  => mon_n_reset,
	--				mon_n_int    => mon_n_int,
	--				init_done => init_done
	--			);

	SYS_STATUS <= CDC_PLL_STATUS;

	CLK_TO_FPGA_IBUFG : IBUFG
		generic map(
			IBUF_LOW_PWR => TRUE,       -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
			IOSTANDARD   => "DEFAULT")
		port map(
			O => clk_to_fpga_b,         -- Clock buffer output
			I => CLK_TO_FPGA            -- Clock buffer input (connect directly to top-level port)
		);

	CLK_AB_P_IBUFGDS : IBUFGDS
		generic map(
			DIFF_TERM    => FALSE,      -- Differential Termination 
			IBUF_LOW_PWR => TRUE,       -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
			IOSTANDARD   => "DEFAULT")
		port map(
			O  => clk_ab_b,             -- Clock buffer output
			I  => CLK_AB_P,             -- Diff_p clock buffer input (connect directly to top-level port)
			IB => CLK_AB_N              -- Diff_n clock buffer input (connect directly to top-level port)
		);

	--ODDR for Clock Forwarding
	DAC_CLK_ODDR2 : ODDR2
		generic map(
			DDR_ALIGNMENT => "NONE",    -- Sets output alignment to "NONE", "C0", "C1"
			INIT          => '0',       -- Sets initial state of the Q output to '0' or '1'
			SRTYPE        => "SYNC")    -- Specifies "SYNC" or "ASYNC" set/reset
		port map(
			Q  => FMC150_CLK,           -- 1-bit output data
			C0 => clk_to_fpga_b,        -- 1-bit clock input
			C1 => not clk_to_fpga_b,    -- 1-bit clock input
			CE => '1',                  -- 1-bit clock enable input
			D0 => '0',                  -- 1-bit data input (associated with C0)
			D1 => '1',                  -- 1-bit data input (associated with C1)
			R  => '0',                  -- 1-bit reset input
			S  => '0'                   -- 1-bit set input
		);

	--ODDR for Clock Forwarding
	ADC_CLK_ODDR2 : ODDR2
		generic map(
			DDR_ALIGNMENT => "NONE",    -- Sets output alignment to "NONE", "C0", "C1"
			INIT          => '0',       -- Sets initial state of the Q output to '0' or '1'
			SRTYPE        => "SYNC")    -- Specifies "SYNC" or "ASYNC" set/reset
		port map(
			Q  => FMC150_ADC_CLK,       -- 1-bit output data
			C0 => clk_ab_b,             -- 1-bit clock input
			C1 => not clk_ab_b,         -- 1-bit clock input
			CE => '1',                  -- 1-bit clock enable input
			D0 => '0',                  -- 1-bit data input (associated with C0)
			D1 => '1',                  -- 1-bit data input (associated with C1)
			R  => '0',                  -- 1-bit reset input
			S  => '0'                   -- 1-bit set input
		);

end Behavioral;

