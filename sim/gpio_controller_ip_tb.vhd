--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:07:14 07/26/2012
-- Design Name:   
-- Module Name:   /home/mbridges/Projects/project_GPIO_v0a/gpio_controller_ip_tb.vhd
-- Project Name:  project_GPIO_v0a
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
--USE ieee.numeric_std.ALL;

ENTITY gpio_controller_ip_tb IS
END gpio_controller_ip_tb;

ARCHITECTURE behavior OF gpio_controller_ip_tb IS

	-- Component Declaration for the Unit Under Test (UUT)

	COMPONENT gpio_controller_ip
		PORT(
			RST_I : IN    std_logic;
			CLK_I : IN    std_logic;
			ADR_I : IN    std_logic_vector(3 downto 0);
			DAT_I : IN    std_logic_vector(15 downto 0);
			DAT_O : OUT   std_logic_vector(15 downto 0);
			WE_I  : IN    std_logic;
			STB_I : IN    std_logic;
			ACK_O : OUT   std_logic;
			GPIO  : INOUT std_logic_vector(7 downto 0);
			Debug : OUT   std_logic_vector(21 downto 0)
		);
	END COMPONENT;

	--Inputs
	signal RST_I : std_logic                     := '1';
	signal CLK_I : std_logic                     := '0';
	signal ADR_I : std_logic_vector(3 downto 0)  := (others => '0');
	signal DAT_I : std_logic_vector(15 downto 0) := (others => '0');
	signal WE_I  : std_logic                     := '0';
	signal STB_I : std_logic                     := '0';

	--BiDirs
	signal GPIO : std_logic_vector(7 downto 0);

	--Outputs
	signal DAT_O : std_logic_vector(15 downto 0);
	signal ACK_O : std_logic;
	signal Debug : std_logic_vector(21 downto 0);

	-- Clock period definitions
	constant CLK_I_period : time := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : gpio_controller_ip PORT MAP(
			RST_I => RST_I,
			CLK_I => CLK_I,
			ADR_I => ADR_I,
			DAT_I => DAT_I,
			DAT_O => DAT_O,
			WE_I  => WE_I,
			STB_I => STB_I,
			ACK_O => ACK_O,
			GPIO  => GPIO,
			Debug => Debug
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

		wait for CLK_I_period * 10;
		RST_I <= '0';

		-- insert stimulus here 
		DAT_I <= "1010101010101010";
		ADR_I <= "1000";
		WE_I <= '1';
		STB_I <= '1';
		wait;
	end process;

END;
