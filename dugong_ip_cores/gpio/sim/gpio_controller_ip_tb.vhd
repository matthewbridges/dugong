--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:49:26 08/29/2012
-- Design Name:   
-- Module Name:   /home/mbridges/Projects/Dugong/sim/gpio_controller_ip_tb.vhd
-- Project Name:  Dugong
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: gpio_controller_ip
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
USE ieee.numeric_std.ALL;

ENTITY gpio_controller_ip_tb IS
END gpio_controller_ip_tb;

ARCHITECTURE behavior OF gpio_controller_ip_tb IS

	-- Component Declaration for the Unit Under Test (UUT)

	COMPONENT gpio_controller_ip
		generic(
			DATA_WIDTH      : NATURAL               := 16;
			ADDR_WIDTH      : NATURAL               := 12;
			BASE_ADDR       : UNSIGNED(11 downto 0) := x"F00";
			CORE_ADDR_WIDTH : NATURAL               := 4;
			GPIO_WIDTH      : natural               := 8
		);
		port(
			--System Control Inputs
			CLK_I : in  STD_LOGIC;
			RST_I : in  STD_LOGIC;
			--Slave to WB
			WB_I  : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
			WB_O  : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
			--GPIO Interface
			GPIO  : out STD_LOGIC_VECTOR(GPIO_WIDTH - 1 downto 0)
		);
	END COMPONENT;

	--Inputs
	signal CLK_I : std_logic                     := '0';
	signal RST_I : std_logic                     := '1';
	signal WB_I  : std_logic_vector(30 downto 0) := (others => '0');

	--Outputs
	signal WB_O : std_logic_vector(16 downto 0);
	signal GPIO : std_logic_vector(7 downto 0);

	-- Clock period definitions
	constant CLK_I_period : time := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : gpio_controller_ip PORT MAP(
			CLK_I => CLK_I,
			RST_I => RST_I,
			WB_I  => WB_I,
			WB_O  => WB_O,
			GPIO  => GPIO
		);

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
		wait for 100 ns;
		RST_I <= '0';
		wait for CLK_I_period * 10;

		-- insert stimulus here 
		wait until rising_edge(CLK_I);
		WB_I <= "111" & x"F08" & x"000F";
		wait until rising_edge(WB_O(16));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"0000";
		wait until rising_edge(CLK_I);
		WB_I <= "101" & x"F08" & x"00FF";
		wait until rising_edge(WB_O(16));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"0000";
		wait until rising_edge(CLK_I);
		WB_I <= "101" & x"F03" & x"000F";
		wait until rising_edge(WB_O(16));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"0000";
		wait until rising_edge(CLK_I);
		WB_I <= "111" & x"E08" & x"000F";
		wait until rising_edge(WB_O(16));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"0000";
		wait;
	end process;

END;
