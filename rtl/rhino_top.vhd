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
--library UNISIM;
--use UNISIM.VComponents.all;

entity rhino_top is
	port(
		--System Control Inputs
		SYS_CLK_P   : in  STD_LOGIC;
		SYS_CLK_N   : in  STD_LOGIC;
		SYS_RST     : in  STD_LOGIC;
		--GPIO Interface
		GPIO        : out STD_LOGIC_VECTOR(15 downto 0);
		--LED Interface
		LED         : out STD_LOGIC_VECTOR(7 downto 0);
		--DA2 Interface
		DA2_D1      : out STD_LOGIC;
		DA2_D2      : out STD_LOGIC;
		DA2_CLK_OUT : out STD_LOGIC;
		DA2_nSYNC   : out STD_LOGIC
	);
end rhino_top;

architecture Behavioral of rhino_top is
	signal wb_ms       : std_logic_vector(30 downto 0);
	signal wb_sm       : std_logic_vector(16 downto 0);
	signal sys_con_clk : std_logic;
	signal sys_con_rst : std_logic;

--	signal ch_a      : std_logic_vector(11 downto 0);
--	signal ch_b      : std_logic_vector(11 downto 0);

	COMPONENT system_controller
		PORT(
			--System Clock Differential Inputs 100MHz
			SYS_CLK_P  : in  STD_LOGIC;
			SYS_CLK_N  : in  STD_LOGIC;
			--System Reset
			SYS_RST    : in  STD_LOGIC;
			--System Control Inputs
			CLK_100MHz : out STD_LOGIC;
			CLK_200Mhz : out STD_LOGIC;
			RST_O      : out STD_LOGIC
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
--			CH_A_O : out STD_LOGIC_VECTOR(11 downto 0);
--			CH_B_O : out STD_LOGIC_VECTOR(11 downto 0)
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

begin
	Sys_Con : system_controller
	PORT MAP(
		SYS_CLK_P  => SYS_CLK_P,
		SYS_CLK_N  => SYS_CLK_N,
		SYS_RST    => SYS_RST,
		CLK_100MHz => sys_con_clk,
		CLK_200Mhz => open,
		RST_O     => sys_con_rst
	);

	Central_Control_Unit : dugong
		PORT MAP(
			CLK_I => sys_con_clk,
			RST_I => sys_con_rst,
			WB_I  => wb_sm,
			WB_O  => wb_ms
		);

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

--	DDS : dds_core_ip
--		GENERIC MAP(
--			BASE_ADDR       => x"700",
--			CORE_DATA_WIDTH => 12
--		)
--		PORT MAP(
--			CLK_I  => sys_con_clk,
--			RST_I  => sys_con_rst,
--			WB_I   => wb_ms,
--			WB_O   => wb_sm,
--			CH_A_O => ch_a,
--			CH_B_O => ch_b
--		);

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
--			CH_A_I  => ch_a,
--			CH_B_I  => ch_b,
--			D1      => DA2_D1,
--			D2      => DA2_D2,
--			CLK_OUT => DA2_CLK_OUT,
--			nSYNC   => DA2_nSYNC
--		);

end Behavioral;

