--------------------------------------------------------------------------------
-- Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 14.2
--  \   \         Application : sch2hdl
--  /   /         Filename : prototype0.vhf
-- /___/   /\     Timestamp : 08/21/2012 17:23:19
-- \   \  /  \ 
--  \___\/\___\ 
--
--Command: sch2hdl -intstyle ise -family spartan6 -flat -suppress -vhdl /home/mbridges/Dugong/prototype0.vhf -w /home/mbridges/Dugong/src/prototype0.sch
--Design Name: prototype0
--Device: spartan6
--Purpose:
--    This vhdl netlist is translated from an ECS schematic. It can be 
--    synthesized and simulated, but it should not be modified. 
--

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity prototype0 is
   port ( RST_I     : in    std_logic; 
          sys_clk_n : in    std_logic; 
          sys_clk_p : in    std_logic; 
          Debug     : out   std_logic_vector (15 downto 0); 
          GPIO      : out   std_logic_vector (7 downto 0));
end prototype0;

architecture BEHAVIORAL of prototype0 is
   attribute BOX_TYPE   : string ;
   signal CLK_I     : std_logic;
   signal XLXN_1    : std_logic;
   signal XLXN_2    : std_logic;
   signal XLXN_3    : std_logic_vector (15 downto 0);
   signal XLXN_5    : std_logic;
   signal XLXN_6    : std_logic_vector (15 downto 0);
   signal XLXN_7    : std_logic_vector (11 downto 0);
   signal XLXN_8    : std_logic;
   signal XLXN_10   : std_logic;
   signal XLXN_11   : std_logic;
   signal XLXN_13   : std_logic;
   component dugong
      port ( CLK_I : in    std_logic; 
             RST_I : in    std_logic; 
             ACK_I : in    std_logic; 
             DAT_I : in    std_logic_vector (15 downto 0); 
             WE_O  : out   std_logic; 
             STB_O : out   std_logic; 
             CYC_O : out   std_logic; 
             DAT_O : out   std_logic_vector (15 downto 0); 
             ADR_O : out   std_logic_vector (11 downto 0));
   end component;
   
   component gpio_controller_ip
      port ( CLK_I : in    std_logic; 
             RST_I : in    std_logic; 
             WE_I  : in    std_logic; 
             STB_I : in    std_logic; 
             DAT_I : in    std_logic_vector (15 downto 0); 
             ADR_I : in    std_logic_vector (3 downto 0); 
             ACK_O : out   std_logic; 
             DAT_O : out   std_logic_vector (15 downto 0); 
             GPIO  : out   std_logic_vector (7 downto 0); 
             Debug : out   std_logic_vector (15 downto 0));
   end component;
   
   component clk_generator
      port ( clk_in1_p : in    std_logic; 
             clk_in1_n : in    std_logic; 
             reset     : in    std_logic; 
             clk_out1  : out   std_logic; 
             clk_valid : out   std_logic);
   end component;
   
   component GND
      port ( G : out   std_logic);
   end component;
   attribute BOX_TYPE of GND : component is "BLACK_BOX";
   
   component OR2
      port ( I0 : in    std_logic; 
             I1 : in    std_logic; 
             O  : out   std_logic);
   end component;
   attribute BOX_TYPE of OR2 : component is "BLACK_BOX";
   
   component INV
      port ( I : in    std_logic; 
             O : out   std_logic);
   end component;
   attribute BOX_TYPE of INV : component is "BLACK_BOX";
   
begin
   XLXI_1 : dugong
      port map (ACK_I=>XLXN_5,
                CLK_I=>CLK_I,
                DAT_I(15 downto 0)=>XLXN_6(15 downto 0),
                RST_I=>XLXN_13,
                ADR_O(11 downto 0)=>XLXN_7(11 downto 0),
                CYC_O=>open,
                DAT_O(15 downto 0)=>XLXN_3(15 downto 0),
                STB_O=>XLXN_2,
                WE_O=>XLXN_1);
   
   XLXI_2 : gpio_controller_ip
      port map (ADR_I(3 downto 0)=>XLXN_7(3 downto 0),
                CLK_I=>CLK_I,
                DAT_I(15 downto 0)=>XLXN_3(15 downto 0),
                RST_I=>XLXN_13,
                STB_I=>XLXN_2,
                WE_I=>XLXN_1,
                ACK_O=>XLXN_5,
                DAT_O(15 downto 0)=>XLXN_6(15 downto 0),
                Debug(15 downto 0)=>Debug(15 downto 0),
                GPIO(7 downto 0)=>GPIO(7 downto 0));
   
   XLXI_3 : clk_generator
      port map (clk_in1_n=>sys_clk_n,
                clk_in1_p=>sys_clk_p,
                reset=>XLXN_8,
                clk_out1=>CLK_I,
                clk_valid=>XLXN_11);
   
   XLXI_4 : GND
      port map (G=>XLXN_8);
   
   XLXI_6 : OR2
      port map (I0=>XLXN_10,
                I1=>RST_I,
                O=>XLXN_13);
   
   XLXI_7 : INV
      port map (I=>XLXN_11,
                O=>XLXN_10);
   
end BEHAVIORAL;


