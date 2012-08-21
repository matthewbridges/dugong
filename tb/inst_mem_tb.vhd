--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:35:01 08/03/2012
-- Design Name:   
-- Module Name:   /home/mbridges/Projects/project_Dugong_v0c/inst_mem_tb.vhd
-- Project Name:  project_Dugong_v0c
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: inst_mem
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
 
ENTITY inst_mem_tb IS
END inst_mem_tb;
 
ARCHITECTURE behavior OF inst_mem_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT inst_mem
    PORT(
         RSTA : IN  std_logic;
         CLKA : IN  std_logic;
         RSTB : IN  std_logic;
         CLKB : IN  std_logic;
         ADDRA : IN  std_logic_vector(13 downto 0);
         ADDRB : IN  std_logic_vector(13 downto 0);
         DIA : IN  std_logic_vector(31 downto 0);
         DIB : IN  std_logic_vector(31 downto 0);
         DOA : OUT  std_logic_vector(31 downto 0);
         DOB : OUT  std_logic_vector(31 downto 0);
         DIPA : IN  std_logic_vector(3 downto 0);
         DIPB : IN  std_logic_vector(3 downto 0);
         DOPA : OUT  std_logic_vector(3 downto 0);
         DOPB : OUT  std_logic_vector(3 downto 0);
         WEA : IN  std_logic_vector(3 downto 0);
         ENA : IN  std_logic;
         REGCEA : IN  std_logic;
         WEB : IN  std_logic_vector(3 downto 0);
         ENB : IN  std_logic;
         REGCEB : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal RSTA : std_logic := '0';
   signal CLKA : std_logic := '0';
   signal RSTB : std_logic := '0';
   signal CLKB : std_logic := '0';
   signal ADDRA : std_logic_vector(13 downto 0) := (others => '0');
   signal ADDRB : std_logic_vector(13 downto 0) := (others => '0');
   signal DIA : std_logic_vector(31 downto 0) := (others => '0');
   signal DIB : std_logic_vector(31 downto 0) := (others => '0');
   signal DIPA : std_logic_vector(3 downto 0) := (others => '0');
   signal DIPB : std_logic_vector(3 downto 0) := (others => '0');
   signal WEA : std_logic_vector(3 downto 0) := (others => '0');
   signal ENA : std_logic := '0';
   signal REGCEA : std_logic := '0';
   signal WEB : std_logic_vector(3 downto 0) := (others => '0');
   signal ENB : std_logic := '0';
   signal REGCEB : std_logic := '0';

 	--Outputs
   signal DOA : std_logic_vector(31 downto 0);
   signal DOB : std_logic_vector(31 downto 0);
   signal DOPA : std_logic_vector(3 downto 0);
   signal DOPB : std_logic_vector(3 downto 0);

   -- Clock period definitions
   constant CLKA_period : time := 10 ns;
   constant CLKB_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: inst_mem PORT MAP (
          RSTA => RSTA,
          CLKA => CLKA,
          RSTB => RSTB,
          CLKB => CLKB,
          ADDRA => ADDRA,
          ADDRB => ADDRB,
          DIA => DIA,
          DIB => DIB,
          DOA => DOA,
          DOB => DOB,
          DIPA => DIPA,
          DIPB => DIPB,
          DOPA => DOPA,
          DOPB => DOPB,
          WEA => WEA,
          ENA => ENA,
          REGCEA => REGCEA,
          WEB => WEB,
          ENB => ENB,
          REGCEB => REGCEB
        );

   -- Clock process definitions
   CLKA_process :process
   begin
		CLKA <= '0';
		wait for CLKA_period/2;
		CLKA <= '1';
		wait for CLKA_period/2;
   end process;
 
   CLKB_process :process
   begin
		CLKB <= '0';
		wait for CLKB_period/2;
		CLKB <= '1';
		wait for CLKB_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for CLKA_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
