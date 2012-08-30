----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:13:09 08/28/2012 
-- Design Name: 
-- Module Name:    test_WB - Behavioral 
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

entity test_WB is
	generic(
		DATA_WIDTH : natural := 16;
		ADDR_WIDTH : natural := 12
	);
	port(
		--Wishbone Master Lines (inverted)
		CLK_I   : in STD_LOGIC;
		RST_I   : in STD_LOGIC;
		DAT_I   : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DAT_O   : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		ADR_O   : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		WE_O    : in  STD_LOGIC;
		STB_O   : in  STD_LOGIC;
		ACK_I   : out STD_LOGIC;
		CYC_O   : in  STD_LOGIC;
		--Wishbone Slave Lines (inverted)
		s_DAT_I : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		s_DAT_O : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		ADR_I   : out STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		WE_I    : out STD_LOGIC;
		STB_I   : out STD_LOGIC;
		ACK_O   : in  STD_LOGIC;
		CYC_I   : out STD_LOGIC
	);
end test_WB;

architecture Behavioral of test_WB is
	signal wb_ms : std_logic_vector(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
	signal wb_sm : std_logic_vector(DATA_WIDTH downto 0);

	COMPONENT wb_m
		PORT(
			--Wishbone Master Lines (inverted)
			CLK_I : in STD_LOGIC;
			RST_I : in STD_LOGIC;
			DAT_I : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			DAT_O : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			ADR_O : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
			WE_O  : in  STD_LOGIC;
			STB_O : in  STD_LOGIC;
			ACK_I : out STD_LOGIC;
			CYC_O : in  STD_LOGIC;
			--Master to WB
			WB_I  : in  STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
			WB_O  : out STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0)
		);
	END COMPONENT;

	COMPONENT wb_s
		PORT(
			--Wishbone Slave Lines (inverted)
			CLK_I : in STD_LOGIC;
			RST_I : in STD_LOGIC;
			DAT_I : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			DAT_O : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			ADR_I : out STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
			WE_I  : out STD_LOGIC;
			STB_I : out STD_LOGIC;
			ACK_O : in  STD_LOGIC;
			CYC_I : out STD_LOGIC;
			--Master to WB
			WB_I  : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
			WB_O  : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0)
		);
	END COMPONENT;
begin
	Inst_wb_m : wb_m PORT MAP(
			CLK_I => CLK_I,
			RST_I => RST_I,
			DAT_I => DAT_I,
			DAT_O => DAT_O,
			ADR_O => ADR_O,
			WE_O  => WE_O,
			STB_O => STB_O,
			ACK_I => ACK_I,
			CYC_O => CYC_O,
			WB_I  => wb_sm,
			WB_O  => wb_ms);

	Inst_wb_s : wb_s PORT MAP(
			CLK_I => CLK_I,
			RST_I => RST_I,
			DAT_I => s_DAT_I,
			DAT_O => s_DAT_O,
			ADR_I => ADR_I,
			WE_I  => WE_I,
			STB_I => STB_I,
			ACK_O => ACK_O,
			CYC_I => CYC_I,
			WB_I  => wb_ms,
			WB_O  => wb_sm);
end Behavioral;

