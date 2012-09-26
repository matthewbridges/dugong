--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:40:19 09/26/2012
-- Design Name:   
-- Module Name:   /home/mbridges/Projects/Dugong/other/sim/system_controller_tb.vhd
-- Project Name:  Dugong
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: system_controller
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
 
ENTITY system_controller_tb IS
END system_controller_tb;
 
ARCHITECTURE behavior OF system_controller_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT system_controller
    PORT(
         SYS_CLK_P : IN  std_logic;
         SYS_CLK_N : IN  std_logic;
         SYS_RST : IN  std_logic;
         CLK_6MHZ : OUT  std_logic;
         CLK_100MHZ : OUT  std_logic;
         CLK_200MHZ : OUT  std_logic;
         RST_O : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal SYS_CLK_P : std_logic := '0';
   signal SYS_CLK_N : std_logic := '1';
   signal SYS_RST : std_logic := '0';

 	--Outputs
   signal CLK_6MHZ : std_logic;
   signal CLK_100MHZ : std_logic;
   signal CLK_200MHZ : std_logic;
   signal RST_O : std_logic;

   -- Clock period definitions
   constant SYS_CLK_P_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: system_controller PORT MAP (
          SYS_CLK_P => SYS_CLK_P,
          SYS_CLK_N => SYS_CLK_N,
          SYS_RST => SYS_RST,
          CLK_6MHZ => CLK_6MHZ,
          CLK_100MHZ => CLK_100MHZ,
          CLK_200MHZ => CLK_200MHZ,
          RST_O => RST_O
        );

   -- Clock process definitions
   SYS_CLK_P_process :process
   begin
		SYS_CLK_P <= '0';
		SYS_CLK_N <= '1';
		wait for SYS_CLK_P_period/2;
		SYS_CLK_P <= '1';
		SYS_CLK_N <= '0';
		wait for SYS_CLK_P_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for SYS_CLK_P_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
