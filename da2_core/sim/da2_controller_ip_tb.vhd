--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:02:19 09/03/2012
-- Design Name:   
-- Module Name:   /home/mbridges/Projects/Dugong/da2_controller_ip_tb.vhd
-- Project Name:  Dugong
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: da2_controller_ip
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
 
ENTITY da2_controller_ip_tb IS
END da2_controller_ip_tb;
 
ARCHITECTURE behavior OF da2_controller_ip_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT da2_controller_ip
    PORT(
         CLK_I : IN  std_logic;
         RST_I : IN  std_logic;
         WB_I : IN  std_logic_vector(30 downto 0);
         WB_O : OUT  std_logic_vector(16 downto 0);
         D1 : OUT  std_logic;
         D2 : OUT  std_logic;
         CLK_OUT : OUT  std_logic;
         nSYNC : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK_I : std_logic := '0';
   signal RST_I : std_logic := '1';
   signal WB_I : std_logic_vector(30 downto 0) := (others => '0');

 	--Outputs
   signal WB_O : std_logic_vector(16 downto 0);
   signal D1 : std_logic;
   signal D2 : std_logic;
   signal CLK_OUT : std_logic;
   signal nSYNC : std_logic;

   -- Clock period definitions
   constant CLK_I_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: da2_controller_ip PORT MAP (
          CLK_I => CLK_I,
          RST_I => RST_I,
          WB_I => WB_I,
          WB_O => WB_O,
          D1 => D1,
          D2 => D2,
          CLK_OUT => CLK_OUT,
          nSYNC => nSYNC
        );

   -- Clock process definitions
   CLK_I_process :process
   begin
		CLK_I <= '0';
		wait for CLK_I_period/2;
		CLK_I <= '1';
		wait for CLK_I_period/2;
   end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

		RST_I <= '0';
		wait for CLK_I_period * 10;

		-- insert stimulus here 
		wait until rising_edge(CLK_I);
		WB_I <= "111" & x"008" & x"000F";
		wait until rising_edge(WB_O(16));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"0000";
		wait until rising_edge(CLK_I);
		WB_I <= "111" & x"008" & x"00FF";
		wait until rising_edge(WB_O(16));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"0000";
		wait until rising_edge(CLK_I);
		WB_I <= "111" & x"008" & x"0FFF";
		wait until rising_edge(WB_O(16));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"0000";

      wait;
   end process;

END;
