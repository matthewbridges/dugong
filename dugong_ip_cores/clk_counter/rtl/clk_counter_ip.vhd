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

library dugong_ip_cores;
use dugong_ip_cores.dcores.ALL;

entity clk_counter_ip is
	generic(
		DATA_WIDTH      : NATURAL                       := 32;
		ADDR_WIDTH      : NATURAL                       := 12;
		BASE_ADDR       : UNSIGNED(11 downto 0)         := x"000";
		CORE_DATA_WIDTH : NATURAL                       := 32;
		CORE_ADDR_WIDTH : NATURAL                       := 3;
		MASTER_CNT      : std_logic_vector(31 downto 0) := x"07530000"
	);
	port(
		--System Control Inputs
		CLK_I       : in  STD_LOGIC;
		RST_I       : in  STD_LOGIC;
		--Slave to WB
		WB_I        : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
		WB_O        : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
		--Test Clocks
		TEST_CLOCKS : in  STD_LOGIC_VECTOR((2 ** CORE_ADDR_WIDTH) - 6 downto 0)
	);
end clk_counter_ip;

architecture Behavioral of clk_counter_ip is
	signal dat_i : STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
	signal dat_o : STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
	signal adr_i : STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0);
	signal stb_i : STD_LOGIC;
	signal we_i  : STD_LOGIC;
	signal ack_o : STD_LOGIC;

	component clk_counter
		generic(
			DATA_WIDTH : natural                       := 32;
			ADDR_WIDTH : natural                       := 3;
			MASTER_CNT : std_logic_vector(31 downto 0) := x"07530000"
		);
		port(
			CLK_I       : in  STD_LOGIC;
			RST_I       : in  STD_LOGIC;
			DAT_I       : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			DAT_O       : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			ADR_I       : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
			STB_I       : in  STD_LOGIC;
			WE_I        : in  STD_LOGIC;
			ACK_O       : out STD_LOGIC;
			TEST_CLOCKS : in  STD_LOGIC_VECTOR((2 ** ADDR_WIDTH) - 6 downto 0)
		);
	end component clk_counter;

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

	user_logic : clk_counter
		generic map(
			DATA_WIDTH => CORE_DATA_WIDTH,
			ADDR_WIDTH => CORE_ADDR_WIDTH,
			MASTER_CNT => MASTER_CNT
		)
		port map(
			--System Control Inputs
			CLK_I       => CLK_I,
			RST_I       => RST_I,
			--Wishbone Slave Lines
			DAT_I       => dat_i,
			DAT_O       => dat_o,
			ADR_I       => adr_i,
			STB_I       => stb_i,
			WE_I        => we_i,
			--	CYC_I =>
			ACK_O       => ack_o,
			--Test Clock Signals
			TEST_CLOCKS => TEST_CLOCKS
		);
end Behavioral;

