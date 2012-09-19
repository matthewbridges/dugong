--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:31:00 09/18/2012
-- Design Name:   
-- Module Name:   /home/mbridges/Projects/Dugong/spi_master_core/sim/spi_master_tb.vhd
-- Project Name:  Dugong
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: spi_master
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
 
ENTITY spi_master_tb IS
END spi_master_tb;
 
ARCHITECTURE behavior OF spi_master_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT spi_master
    PORT(
         CLK_I : IN  std_logic;
         RST_I : IN  std_logic;
         DAT_I : IN  std_logic_vector(7 downto 0);
         DAT_O : OUT  std_logic_vector(7 downto 0);
         ADR_I : IN  std_logic_vector(4 downto 0);
         STB_I : IN  std_logic;
         WE_I : IN  std_logic;
         ACK_O : OUT  std_logic;
         SPI_CLK : OUT  std_logic;
         SPI_MOSI : OUT  std_logic;
         SPI_MISO : IN  std_logic;
         SPI_N_SS : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK_I : std_logic := '0';
   signal RST_I : std_logic := '1';
   signal DAT_I : std_logic_vector(7 downto 0) := (others => '0');
   signal ADR_I : std_logic_vector(4 downto 0) := (others => '0');
   signal STB_I : std_logic := '0';
   signal WE_I : std_logic := '0';
   signal SPI_MISO : std_logic := '1';

 	--Outputs
   signal DAT_O : std_logic_vector(7 downto 0);
   signal ACK_O : std_logic;
   signal SPI_CLK : std_logic;
   signal SPI_MOSI : std_logic;
   signal SPI_N_SS : std_logic;

   -- Clock period definitions
   constant CLK_I_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: spi_master PORT MAP (
          CLK_I => CLK_I,
          RST_I => RST_I,
          DAT_I => DAT_I,
          DAT_O => DAT_O,
          ADR_I => ADR_I,
          STB_I => STB_I,
          WE_I => WE_I,
          ACK_O => ACK_O,
          SPI_CLK => SPI_CLK,
          SPI_MOSI => SPI_MOSI,
          SPI_MISO => SPI_MISO,
          SPI_N_SS => SPI_N_SS
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

      wait for CLK_I_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
