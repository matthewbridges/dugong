----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:58:53 09/03/2012 
-- Design Name: 
-- Module Name:    gpmc_controller - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity gpmc_controller is
	generic(
		DATA_WIDTH : natural := 16;
		ADDR_WIDTH : natural := 12
	);
	Port(
		--System Control Inputs
		CLK_I : in  STD_LOGIC;
		RST_I : in  STD_LOGIC;
		--Master to WB
		WB_I  : in  STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
		WB_O  : out STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
		--Wishbone Master Lines (inverted)
		DAT_I : in STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DAT_O : out  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		ADR_O : out  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		STB_O : in  STD_LOGIC;
		WE_O  : in  STD_LOGIC;
		CYC_O : in  STD_LOGIC;
		ACK_I : out STD_LOGIC;
		
		GPMC_ADR_I     : in    STD_LOGIC_VECTOR(10 downto 1);
		GPMC_DAT_B     : inout STD_LOGIC_VECTOR(15 downto 0);
		GPMC_N_CS      : in    STD_LOGIC_VECTOR(7 downto 0);
		GPMC_N_ADV_ALE : in    STD_LOGIC;
		GPMC_N_OE      : in    STD_LOGIC;
		GPMC_N_WE      : in    STD_LOGIC;

		-- GPMC Clock
		GPMC_CLK_I     : in    STD_LOGIC
	);
end gpmc_controller;

architecture Behavioral of gpmc_controller is



begin

process(GPMC_N_ADV_ALE)
begin
-- if(rising_edge(GPMC_N_ADV_ALE))
 --	adr <= GPMC_ADR_I & GPMC_DAT_B
-- end if;

end process;

end Behavioral;

