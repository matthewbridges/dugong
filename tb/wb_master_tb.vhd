--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:30:35 08/07/2012
-- Design Name:   
-- Module Name:   /home/mbridges/Projects/project_Dugong_v0e/wb_master_tb.vhd
-- Project Name:  project_Dugong_v0e
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: wb_master
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
 
ENTITY wb_master_tb IS
END wb_master_tb;
 
ARCHITECTURE behavior OF wb_master_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT wb_master
    PORT(
         CLK_I : IN  std_logic;
         RST_I : IN  std_logic;
         DAT_O : OUT  std_logic_vector(15 downto 0);
         ADR_O : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK_I : std_logic := '0';
   signal RST_I : std_logic := '1';

 	--Outputs
   signal DAT_O : std_logic_vector(15 downto 0);
   signal ADR_O : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant CLK_I_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: wb_master PORT MAP (
          CLK_I => CLK_I,
          RST_I => RST_I,
          DAT_O => DAT_O,
          ADR_O => ADR_O
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

      wait for CLK_I_period*10;

      -- insert stimulus here 
	RST_I <= '0';
      wait;
   end process;

END;
