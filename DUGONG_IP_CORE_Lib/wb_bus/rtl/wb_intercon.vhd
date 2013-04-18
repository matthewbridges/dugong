----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:39:19 08/28/2012 
-- Design Name: 
-- Module Name:    wb_s - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

library DUGONG_IP_CORE_Lib;
use DUGONG_IP_CORE_Lib.dcores.ALL;

entity wb_intercon is
	generic(
		NUMBER_OF_CORES : NATURAL := 4
	);
	port(
		--Slave to WB
		WB_O_bus : out WB_O_type;
		WB_O     : in  WB_O_vector(NUMBER_OF_CORES - 1 downto 0)
	);
end wb_intercon;

architecture Behavioral of wb_intercon is
begin
	WB_O_bus <= WB_O(0) or WB_O(1) or WB_O(2) or WB_O(3) or WB_O(4);
end Behavioral;
