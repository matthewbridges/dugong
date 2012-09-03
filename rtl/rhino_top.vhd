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
		SYS_CLK_P : in  STD_LOGIC;
		SYS_CLK_N : in  STD_LOGIC;
		SYS_RST   : in  STD_LOGIC;
		--GPIO Interface
		GPIO      : out STD_LOGIC_VECTOR(7 downto 0)
	);
end rhino_top;

architecture Behavioral of rhino_top is
	signal wb_ms   : std_logic_vector(30 downto 0);
	signal wb_sm   : std_logic_vector(16 downto 0);
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
		PORT(CLK_I : IN  std_logic;
			 RST_I : IN  std_logic;
			 WB_I  : IN  std_logic_vector(16 downto 0);
			 WB_O  : OUT std_logic_vector(30 downto 0));
	END COMPONENT;

	COMPONENT gpio_controller_ip
		GENERIC(
			BASE_ADDR : UNSIGNED(11 downto 0) := x"000"
		);
		PORT(
			CLK_I : IN  std_logic;
			RST_I : IN  std_logic;
			WB_I  : IN  std_logic_vector(30 downto 0);
			WB_O  : OUT std_logic_vector(16 downto 0);
			GPIO  : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

begin
	Inst_clk_generator : clk_generator
		PORT MAP(
			CLK_IN1_P => SYS_CLK_P,
			CLK_IN1_N => SYS_CLK_N,
			CLK_OUT1  => sys_con_clk,
			RESET     => '0',
			CLK_VALID => clk_valid
		);
	Inst_dugong : dugong
		PORT MAP(
			CLK_I => sys_con_clk,
			RST_I => sys_con_rst,
			WB_I  => wb_sm,
			WB_O  => wb_ms
		);
	Inst_gpio_controller_ip_1 : gpio_controller_ip
		GENERIC MAP(
			BASE_ADDR => x"E00"
		)
		PORT MAP(
			CLK_I => sys_con_clk,
			RST_I => sys_con_rst,
			WB_I  => wb_ms,
			WB_O  => wb_sm,
			GPIO  => open
		);
			Inst_gpio_controller_ip_2 : gpio_controller_ip
		GENERIC MAP(
			BASE_ADDR => x"F00"
		)
		PORT MAP(
			CLK_I => sys_con_clk,
			RST_I => sys_con_rst,
			WB_I  => wb_ms,
			WB_O  => wb_sm,
			GPIO  => GPIO
		);

	sys_con_rst <= SYS_RST or not clk_valid;
end Behavioral;

