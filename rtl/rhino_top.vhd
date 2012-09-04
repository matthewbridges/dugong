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

	signal clk_valid : std_logic;

	COMPONENT clk_generator
		PORT(CLK_IN1_P : IN  std_logic;
			 CLK_IN1_N : IN  std_logic;
			 RESET     : IN  std_logic;
			 CLK_OUT1  : OUT std_logic;
			 CLK_VALID : OUT std_logic);
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

	COMPONENT da2_controller_ip
		GENERIC(
			DATA_WIDTH      : NATURAL               := 16;
			ADDR_WIDTH      : NATURAL               := 12;
			BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
			CORE_DATA_WIDTH : NATURAL               := 16;
			CORE_ADDR_WIDTH : NATURAL               := 4
		);
		PORT(
			--System Control Inputs
			CLK_I   : in  STD_LOGIC;
			RST_I   : in  STD_LOGIC;
			--Slave to WB
			WB_I    : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
			WB_O    : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
			--DA2 Pmod interface signals
			D1      : out std_logic;
			D2      : out std_logic;
			CLK_OUT : out std_logic;
			nSYNC   : out std_logic
		);
	END COMPONENT;

begin
	Sys_Clk_Gen : clk_generator
		PORT MAP(
			CLK_IN1_P => SYS_CLK_P,
			CLK_IN1_N => SYS_CLK_N,
			CLK_OUT1  => sys_con_clk,
			RESET     => '0',
			CLK_VALID => clk_valid
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

	DAC : da2_controller_ip
		GENERIC MAP(
			BASE_ADDR       => x"800",
			CORE_DATA_WIDTH => 12
		)
		PORT MAP(
			CLK_I   => sys_con_clk,
			RST_I   => sys_con_rst,
			WB_I    => wb_ms,
			WB_O    => wb_sm,
			D1      => DA2_D1,
			D2      => DA2_D2,
			CLK_OUT => DA2_CLK_OUT,
			nSYNC   => DA2_nSYNC
		);

	sys_con_rst <= SYS_RST or not clk_valid;
end Behavioral;

