----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:12:23 06/24/2012 
-- Design Name: 
-- Module Name:    dac3283_controller_ip - Behavioral 
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

entity da2_controller_ip is
	generic(
		DATA_WIDTH      : NATURAL               := 16;
		ADDR_WIDTH      : NATURAL               := 12;
		BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
		CORE_DATA_WIDTH : NATURAL               := 12;
		CORE_ADDR_WIDTH : NATURAL               := 4
	);
	port(
		--System Control Inputs
		CLK_I   : in  STD_LOGIC;
		RST_I   : in  STD_LOGIC;
		--Slave to WB
		WB_I    : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
		WB_O    : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
		CH_A_I  : in  STD_LOGIC_VECTOR(11 downto 0);
		CH_B_I  : in  STD_LOGIC_VECTOR(11 downto 0);
		--DA2 Pmod interface signals
		D1      : out std_logic;
		D2      : out std_logic;
		CLK_OUT : out std_logic;
		nSYNC   : out std_logic
	);
end da2_controller_ip;

architecture Behavioral of da2_controller_ip is
	signal dat_i : STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
	signal dat_o : STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
	signal adr_i : STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0);
	signal stb_i : STD_LOGIC;
	signal we_i  : STD_LOGIC;
	signal ack_o : STD_LOGIC;

	component wb_s is
		generic(
			DATA_WIDTH      : NATURAL               := 16;
			ADDR_WIDTH      : NATURAL               := 12;
			BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
			CORE_DATA_WIDTH : NATURAL               := 16;
			CORE_ADDR_WIDTH : NATURAL               := 4
		);
		port(
			--System Control Inputs
			CLK_I : in  STD_LOGIC;
			RST_I : in  STD_LOGIC;
			--Wishbone Slave Lines (inverted)
			DAT_I : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
			DAT_O : in  STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
			ADR_I : out STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0);
			STB_I : out STD_LOGIC;
			WE_I  : out STD_LOGIC;
			CYC_I : out STD_LOGIC;
			ACK_O : in  STD_LOGIC;
			--Slave to WB
			WB_I  : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
			WB_O  : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0)
		);
	end component;

	component da2_controller is
		generic(
			DATA_WIDTH : natural := 12;
			ADDR_WIDTH : natural := 4
		);
		port(
			--System Control Inputs
			CLK_I   : in  STD_LOGIC;
			RST_I   : in  STD_LOGIC;
			--Wishbone Slave Lines
			DAT_I   : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			DAT_O   : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			ADR_I   : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
			STB_I   : in  STD_LOGIC;
			WE_I    : in  STD_LOGIC;
			--CYC_I : in   STD_LOGIC;

			ACK_O   : out STD_LOGIC;
			CH_A_I  : in  STD_LOGIC_VECTOR(11 downto 0);
			CH_B_I  : in  STD_LOGIC_VECTOR(11 downto 0);
			--DA2 Pmod interface signals
			D1      : out std_logic;
			D2      : out std_logic;
			CLK_OUT : out std_logic;
			nSYNC   : out std_logic
		);
	end component;

begin
	bus_logic : wb_s
		generic map(
			DATA_WIDTH      => DATA_WIDTH,
			ADDR_WIDTH      => ADDR_WIDTH,
			BASE_ADDR       => BASE_ADDR,
			CORE_DATA_WIDTH => CORE_DATA_WIDTH,
			CORE_ADDR_WIDTH => CORE_ADDR_WIDTH
		)
		port map(
			--System Control Inputs		
			CLK_I => CLK_I,
			RST_I => RST_I,
			--Slave to WB
			WB_I  => WB_I,
			WB_O  => WB_O,
			--Wishbone Slave Lines (inverted)
			DAT_I => dat_i,
			DAT_O => dat_o,
			ADR_I => adr_i,
			STB_I => stb_i,
			WE_I  => we_i,
			CYC_I => open,
			ACK_O => ack_o
		);

	user_logic : da2_controller
		generic map(
			DATA_WIDTH => CORE_DATA_WIDTH,
			ADDR_WIDTH => CORE_ADDR_WIDTH
		)
		port map(
			--System Control Inputs
			CLK_I   => CLK_I,
			RST_I   => RST_I,
			--Wishbone Slave Lines
			DAT_I   => dat_i,
			DAT_O   => dat_o,
			ADR_I   => adr_i,
			STB_I   => stb_i,
			WE_I    => we_i,
			--	CYC_I =>
			ACK_O   => ack_o,
			CH_A_I  => CH_A_I,
			CH_B_I  => CH_B_I,
			--DA2 Pmod interface signals
			D1      => D1,
			D2      => D2,
			CLK_OUT => CLK_OUT,
			nSYNC   => nSYNC
		);

end Behavioral;