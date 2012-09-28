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

entity rhino_top is
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
		--		DAC_DCLK_P   : out STD_LOGIC;
		--		DAC_DCLK_N   : out STD_LOGIC;
		--		DAC_DATA_P   : out STD_LOGIC_VECTOR(7 downto 0);
		--		DAC_DATA_N   : out STD_LOGIC_VECTOR(7 downto 0);
		--		FRAME_P      : out STD_LOGIC;
		--		FRAME_N      : out STD_LOGIC;
		--		TXENABLE     : out STD_LOGIC;

		--FMC150 CTRL interface
		SPI_SCLK       : out STD_LOGIC;
		SPI_SDATA      : out STD_LOGIC;
		--				ADC_N_EN     : out STD_LOGIC;
		--				ADC_SDO      : in  STD_LOGIC;
		--				ADC_RESET    : out STD_LOGIC;
		--				CDCE_N_EN    : out STD_LOGIC;
		--				CDCE_SDO     : in  STD_LOGIC;
		--				CDCE_N_RESET : out STD_LOGIC;
		--				CDCE_N_PD    : out STD_LOGIC;
		--				REF_EN       : out STD_LOGIC;
		--				PLL_STATUS   : in  STD_LOGIC;
		DAC_N_EN       : out STD_LOGIC;
		DAC_SDO        : in  STD_LOGIC;
		--			MON_N_EN     : out STD_LOGIC;
		--			MON_SDO      : in  STD_LOGIC;
		--			MON_N_RESET  : out STD_LOGIC;
		--			MON_N_INT    : in  STD_LOGIC;
		-- Debug
		DEBUG          : out STD_LOGIC_VECTOR(3 downto 0)
	);
end rhino_top;

architecture Behavioral of rhino_top is
	signal sys_con_clk : std_logic;
	signal sys_con_rst : std_logic;
	signal wb_ms       : std_logic_vector(30 downto 0);
	signal wb_sm       : std_logic_vector(16 downto 0);

	-- DEBUGGING SIGNAL
	signal temp : std_logic_vector(3 downto 0);

	--	signal clk_to_fpga_b : std_logic;

	--	signal test_clocks : std_logic_vector(3 downto 0);
	--	signal init_done : std_logic;

	--	signal ch_a : std_logic_vector(15 downto 0);
	--	signal ch_b : std_logic_vector(15 downto 0);

	COMPONENT system_controller
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
			CLK_200MHZ     : out STD_LOGIC;
			RST_O          : out STD_LOGIC
		);
	END COMPONENT;

	COMPONENT dugong
		GENERIC(
			DATA_WIDTH : natural := 16;
			ADDR_WIDTH : natural := 12
		);
		PORT(
			--System Control Inputs
			CLK_I : in  STD_LOGIC;
			RST_I : in  STD_LOGIC;
			--Master to WB
			WB_I  : in  STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
			WB_O  : out STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0)
		);
	END COMPONENT;

	--	COMPONENT clk_counter_ip
	--		GENERIC(
	--			DATA_WIDTH      : NATURAL               := 16;
	--			ADDR_WIDTH      : NATURAL               := 12;
	--			BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
	--			CORE_DATA_WIDTH : NATURAL               := 16;
	--			CORE_ADDR_WIDTH : NATURAL               := 4
	--		);
	--		PORT(
	--			--System Control Inputs
	--			CLK_I       : in  STD_LOGIC;
	--			RST_I       : in  STD_LOGIC;
	--			--Slave to WB
	--			WB_I        : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
	--			WB_O        : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
	--			--Test Clocks
	--			TEST_CLOCKS : in  STD_LOGIC_VECTOR(3 downto 0)
	--		);
	--	END COMPONENT;

	COMPONENT gpio_controller_ip
		GENERIC(
			DATA_WIDTH      : NATURAL               := 16;
			ADDR_WIDTH      : NATURAL               := 12;
			BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
			CORE_DATA_WIDTH : NATURAL               := 16;
			CORE_ADDR_WIDTH : NATURAL               := 4
		);
		PORT(
			--System Control Inputs
			CLK_I : in  STD_LOGIC;
			RST_I : in  STD_LOGIC;
			--Slave to WB
			WB_I  : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
			WB_O  : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
			--GPIO Interface
			GPIO  : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0)
		);
	END COMPONENT;

	COMPONENT spi_master_ip
		GENERIC(
			DATA_WIDTH      : NATURAL               := 16;
			ADDR_WIDTH      : NATURAL               := 12;
			BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
			CORE_DATA_WIDTH : NATURAL               := 8;
			CORE_ADDR_WIDTH : NATURAL               := 6
		);
		PORT(
			--System Control Inputs
			CLK_I    : in  STD_LOGIC;
			RST_I    : in  STD_LOGIC;
			--Slave to WB
			WB_I     : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
			WB_O     : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
			--Serial Peripheral Interface
			SCLK_O   : out  STD_LOGIC;
			SPI_CLK  : out STD_LOGIC;
			SPI_MOSI : out STD_LOGIC;
			SPI_MISO : in  STD_LOGIC;
			SPI_N_SS : out STD_LOGIC
		);
	END COMPONENT;

--	COMPONENT dds_core_ip
--		GENERIC(
--			DATA_WIDTH      : NATURAL               := 16;
--			ADDR_WIDTH      : NATURAL               := 12;
--			BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
--			CORE_DATA_WIDTH : NATURAL               := 16;
--			CORE_ADDR_WIDTH : NATURAL               := 4
--		);
--		PORT(
--			--System Control Inputs
--			CLK_I  : in  STD_LOGIC;
--			RST_I  : in  STD_LOGIC;
--			--Slave to WB
--			WB_I   : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
--			WB_O   : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
--			CH_A_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
--			CH_B_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0)
--		);
--	END COMPONENT;

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
--
--	COMPONENT dac3283_serializer
--		PORT(
--			--System Control Inputs
--			CLK_I      : in  STD_LOGIC;
--			RST_I      : in  STD_LOGIC;
--
--			CH_A_I     : in  STD_LOGIC_VECTOR(15 downto 0);
--			CH_B_I     : in  STD_LOGIC_VECTOR(15 downto 0);
--
--			-- DAC interface
--			DAC_DCLK_P : out STD_LOGIC;
--			DAC_DCLK_N : out STD_LOGIC;
--			DAC_DATA_P : out STD_LOGIC_VECTOR(7 downto 0);
--			DAC_DATA_N : out STD_LOGIC_VECTOR(7 downto 0);
--			FRAME_P    : out STD_LOGIC;
--			FRAME_N    : out STD_LOGIC;
--			TXENABLE   : out STD_LOGIC
--		);
--	END COMPONENT;

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
--
--	signal SPI_SCLK_a  : STD_LOGIC;
--	--	signal spi_sclk_b : std_logic;
--	signal SPI_SDATA_a : STD_LOGIC;
--	--	signal spi_sdata_b : std_logic;
--	signal DAC_N_EN_a  : STD_LOGIC;
--	signal temp        : std_logic := '0';
----	signal dac_n_en_b : std_logic;


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
			CLK_100MHZ     => sys_con_clk,
			CLK_100MHZ_n   => open,
			CLK_200MHZ     => open,
			RST_O          => sys_con_rst
		);

	Central_Control_Unit : dugong
		PORT MAP(
			CLK_I => sys_con_clk,
			RST_I => sys_con_rst,
			WB_I  => wb_sm,
			WB_O  => wb_ms
		);

	--	Clock_Counter : clk_counter_ip
	--		GENERIC MAP(
	--			BASE_ADDR => x"100"
	--		)
	--		PORT MAP(
	--			CLK_I       => sys_con_clk,
	--			RST_I       => sys_con_rst,
	--			WB_I        => wb_ms,
	--			WB_O        => wb_sm,
	--			TEST_CLOCKS => test_clocks
	--		);

	GPIOs_16 : gpio_controller_ip
		GENERIC MAP(
			BASE_ADDR       => x"E00",
			CORE_DATA_WIDTH => 16
		)
		PORT MAP(
			CLK_I => sys_con_clk,
			RST_I => sys_con_rst,
			WB_I  => wb_ms,
			WB_O  => wb_sm,
			GPIO  => GPIO
		);

	LEDs_8 : gpio_controller_ip
		GENERIC MAP(
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

	DAC3283_ctrl : spi_master_ip
		GENERIC MAP(
			BASE_ADDR => x"A00"
		)
		PORT MAP(
			CLK_I    => sys_con_clk,
			RST_I    => sys_con_rst,
			WB_I     => wb_ms,
			WB_O     => wb_sm,
			SCLK_O   => temp(0),
			SPI_CLK  => SPI_SCLK,
			SPI_MOSI => temp(1),        --SPI_SDATA,
			SPI_MISO => temp(2),        --DAC_SDO,
			SPI_N_SS => temp(3)         --DAC_N_EN
		);

	SPI_SDATA <= temp(1);
	temp(2)   <= DAC_SDO;
	DAC_N_EN  <= temp(3);

	DEBUG <= temp;

--	DDS : dds_core_ip
--		GENERIC MAP(
--			BASE_ADDR       => x"700",
--			CORE_DATA_WIDTH => 16
--		)
--		PORT MAP(
--			CLK_I  => sys_con_clk,
--			RST_I  => sys_con_rst,
--			WB_I   => wb_ms,
--			WB_O   => wb_sm,
--			CH_A_O => ch_a,
--			CH_B_O => ch_b
--		);
--
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

--	FMC150 : dac3283_serializer
--		PORT MAP(
--			--System Control Inputs
--			CLK_I      => sys_con_clk,
--			RST_I      => sys_con_rst,
--			CH_A_I     => ch_a,
--			CH_B_I     => x"0000",
--
--			-- DAC interface
--			DAC_DCLK_P => DAC_DCLK_P,
--			DAC_DCLK_N => DAC_DCLK_N,
--			DAC_DATA_P => DAC_DATA_P,
--			DAC_DATA_N => DAC_DATA_N,
--			FRAME_P    => FRAME_P,
--			FRAME_N    => FRAME_N,
--			TXENABLE   => TXENABLE
--		);

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

--	name : process(clk_6mhz) is
--	begin
--		temp <= not clk_6mhz;
--	end process name;
--
--	DEBUG(0)  <= SPI_SCLK_a;
--	DEBUG(1)  <= temp;
--	--	DEBUG(1) <= SPI_SDATA_a;
--	DEBUG(2)  <= DAC_N_EN_a;
--	DEBUG(3)  <= DAC_SDO;
--	SPI_SCLK  <= SPI_SCLK_a;            -- when(init_done = '1') else spi_sclk_b;
--	SPI_SDATA <= SPI_SDATA_a;           -- when(init_done = '1') else spi_sdata_b;
--	DAC_N_EN  <= DAC_N_EN_a;            -- when(init_done = '1') else dac_n_en_b;
--
--	test_clocks(0) <= sys_con_clk;
--	test_clocks(2) <= clk_to_fpga_b;
--
--	CLK_TO_FPGA_IBUFG : IBUFG
--		generic map(
--			IBUF_LOW_PWR => TRUE,       -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
--			IOSTANDARD   => "DEFAULT")
--		port map(
--			O => clk_to_fpga_b,         -- Clock buffer output
--			I => CLK_TO_FPGA            -- Clock buffer input (connect directly to top-level port)
--		);
--
--	CLK_AB_P_IBUFGDS : IBUFGDS
--		generic map(
--			DIFF_TERM    => FALSE,      -- Differential Termination 
--			IBUF_LOW_PWR => TRUE,       -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
--			IOSTANDARD   => "DEFAULT")
--		port map(
--			O  => test_clocks(3),       -- Clock buffer output
--			I  => CLK_AB_P,             -- Diff_p clock buffer input (connect directly to top-level port)
--			IB => CLK_AB_N              -- Diff_n clock buffer input (connect directly to top-level port)
--		);

end Behavioral;

