-- Vhdl test bench created from schematic /home/mbridges/Projects/project_Dugong_v1a/prototype0.sch - Fri Aug 10 17:54:03 2012
--
-- Notes: 
-- 1) This testbench template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the unit under test.
-- Xilinx recommends that these types always be used for the top-level
-- I/O of a design in order to guarantee that the testbench will bind
-- correctly to the timing (post-route) simulation model.
-- 2) To use this template as your testbench, change the filename to any
-- name of your choice with the extension .vhd, and use the "Source->Add"
-- menu in Project Navigator to import the testbench. Then
-- edit the user defined section below, adding code to generate the 
-- stimulus for your design.
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY UNISIM;
USE UNISIM.Vcomponents.ALL;
ENTITY prototype0_prototype0_sch_tb IS
END prototype0_prototype0_sch_tb;
ARCHITECTURE behavioral OF prototype0_prototype0_sch_tb IS
	COMPONENT prototype0
		PORT(sys_clk_p : IN  STD_LOGIC;
			 sys_clk_n : IN  STD_LOGIC;
			 RST_I     : IN  STD_LOGIC;
			 GPIO      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			 Debug     : OUT STD_LOGIC_VECTOR(21 DOWNTO 0));
	END COMPONENT;

	SIGNAL sys_clk_p : STD_LOGIC := '0';
	SIGNAL sys_clk_n : STD_LOGIC := '0';
	SIGNAL RST_I : STD_LOGIC := '1';
	SIGNAL GPIO  : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL Debug : STD_LOGIC_VECTOR(21 DOWNTO 0);

	-- Clock period definitions
	constant CLK_I_period : time := 10 ns;

BEGIN
	UUT : prototype0 PORT MAP(
			SYS_CLK_P => SYS_CLK_P,
			SYS_CLK_N => SYS_CLK_N,
			RST_I => RST_I,
			GPIO  => GPIO,
			Debug => Debug
		);

	-- Clock process definitions
	CLK_I_process : process
	begin
		SYS_CLK_P <= '0';
		SYS_CLK_N <= '1';
		wait for CLK_I_period / 2;
		SYS_CLK_P <= '1';
		SYS_CLK_N <= '0';
		wait for CLK_I_period / 2;
	end process;

	-- *** Test Bench - User Defined Section ***
	tb : PROCESS
	BEGIN

		-- hold reset state for 100 ns.
		wait for 100 ns;

		wait for CLK_I_period * 10;
		RST_I <= '0';
		WAIT;                           -- will wait forever
	END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;
