----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:25:01 08/07/2012 
-- Design Name: 
-- Module Name:    wb_m - Behavioral 
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

entity wb_m is
	generic(
		DATA_WIDTH : natural := 16;
		ADDR_WIDTH : natural := 12
	);
	port(
		--System Control Inputs
		CLK_I : in  STD_LOGIC;
		RST_I : in  STD_LOGIC;
		--Master to WB
		WB_I  : in  STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
		WB_O  : out STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
		--Wishbone Master Lines (inverted)
		DAT_I : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DAT_O : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		ADR_O : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		STB_O : in  STD_LOGIC;
		WE_O  : in  STD_LOGIC;
		CYC_O : in  STD_LOGIC;
		ACK_I : out STD_LOGIC
	);
end wb_m;

architecture Behavioral of wb_m is
	alias dat_sm : std_logic_vector(DATA_WIDTH - 1 downto 0) is WB_I(DATA_WIDTH - 1 downto 0);
	alias ack_sm : std_logic is WB_I(DATA_WIDTH);

begin
	--WB Output Ports
	WB_O <= (CYC_O & WE_O & STB_O & ADR_O & DAT_O);
	--WB Input Ports
	DAT_I <= dat_sm;
	ACK_I <= ack_sm;

end Behavioral;

