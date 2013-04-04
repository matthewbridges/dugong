library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package dcomponents is
	subtype dword is std_logic_vector(35 downto 0);
	type word_vector is array (natural range <>) of dword;
	--	type SLV_2D is array (natural range <>, natural range <>) of std_logic;

	component wb_s is
		generic(
			DATA_WIDTH      : NATURAL               := 32;
			ADDR_WIDTH      : NATURAL               := 12;
			BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
			CORE_DATA_WIDTH : NATURAL               := 16;
			CORE_ADDR_WIDTH : NATURAL               := 3
		);
		port(
			--System Control Inputs
			CLK_I : in  STD_LOGIC;
			RST_I : in  STD_LOGIC;
			--Slave to WB
			WB_I  : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
			WB_O  : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
			--Wishbone Slave Lines (inverted)
			DAT_I : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
			DAT_O : in  STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
			ADR_I : out STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0);
			STB_I : out STD_LOGIC;
			WE_I  : out STD_LOGIC;
			CYC_I : out STD_LOGIC;
			ACK_O : in  STD_LOGIC
		);
	end component;

	component wb_m is
		generic(
			DATA_WIDTH : natural := 32;
			ADDR_WIDTH : natural := 12
		);
		port(
			--System Control Inputs
			--			CLK_I : in  STD_LOGIC;
			--			RST_I : in  STD_LOGIC;
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
	end component;

	component system_controller
		generic(
			DATA_WIDTH      : NATURAL               := 32;
			ADDR_WIDTH      : NATURAL               := 12;
			BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
			CORE_DATA_WIDTH : NATURAL               := 32;
			CORE_ADDR_WIDTH : NATURAL               := 4
		);
		port(
			--System Clock Differential Inputs 100MHz
			SYS_CLK_P      : in  STD_LOGIC;
			SYS_CLK_N      : in  STD_LOGIC;
			--System Clock Differential Outputs 100MHz
			SYS_CLK_o      : out STD_LOGIC;
			--System Reset Input
			SYS_RST        : in  STD_LOGIC;
			--System Status
			SYS_PWR_ON     : out STD_LOGIC;
			SYS_PLL_Locked : out STD_LOGIC;
			--System Control Outputs
			CLK_123MHZ     : out STD_LOGIC;
			CLK_123MHZ_n   : out STD_LOGIC;
			CLK_246MHZ     : out STD_LOGIC;
			CLK_983MHZ     : out STD_LOGIC;
			CLK_15MHZ      : out STD_LOGIC;
			CLK_15MHZ_n    : out STD_LOGIC;
			RST_O          : out STD_LOGIC;
			--Slave to WB
			WB_I           : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
			WB_O           : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0)
		);
	end component;

	component dugong
		generic(
			DATA_WIDTH : natural := 32;
			ADDR_WIDTH : natural := 12
		);
		port(
			--System Control Inputs
			CLK_I   : in  STD_LOGIC;
			CLK_I_n : in  STD_LOGIC;
			RST_I   : in  STD_LOGIC;
			--Master to WB
			WB_I    : in  STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
			WB_O    : out STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0)
		);
	end component;

end package dcomponents;

package body dcomponents is
end package body dcomponents;
