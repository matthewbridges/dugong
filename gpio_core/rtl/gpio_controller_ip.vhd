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

entity gpio_controller_ip is
	generic(
		DATA_WIDTH      : NATURAL               := 16;
		ADDR_WIDTH      : NATURAL               := 12;
		BASE_ADDR       : UNSIGNED(11 downto 0) := x"F00";
		CORE_ADDR_WIDTH : NATURAL               := 4;
		GPIO_WIDTH      : natural               := 8
	);
	port(
		--System Control Inputs
		CLK_I : in  STD_LOGIC;
		RST_I : in  STD_LOGIC;
		--Slave to WB
		WB_I  : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
		WB_O  : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
		--GPIO Interface
		GPIO  : out STD_LOGIC_VECTOR(GPIO_WIDTH - 1 downto 0)
	);
end gpio_controller_ip;

architecture Behavioral of gpio_controller_ip is
	signal DAT_I : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
	signal DAT_O : STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
	signal ADR_I : STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0);
	signal WE_I  : STD_LOGIC;
	signal STB_I : STD_LOGIC;
	signal ACK_O : STD_LOGIC;

	component wb_s is
		generic(
			DATA_WIDTH      : NATURAL               := 16;
			ADDR_WIDTH      : NATURAL               := 12;
			BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
			CORE_ADDR_WIDTH : NATURAL               := 4
		);
		port(
			--System Control Inputs
			CLK_I : in  STD_LOGIC;
			RST_I : in  STD_LOGIC;
			--Wishbone Slave Lines (inverted)
			DAT_I : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			DAT_O : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			ADR_I : out STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0);
			WE_I  : out STD_LOGIC;
			STB_I : out STD_LOGIC;
			ACK_O : in  STD_LOGIC;
			CYC_I : out STD_LOGIC;
			--Slave to WB
			WB_I  : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
			WB_O  : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0)
		);
	end component;

	component gpio_controller is
		generic(
			DATA_WIDTH : natural := 16;
			ADDR_WIDTH : natural := 4;
			GPIO_WIDTH : natural := 8
		);
		port(
			--System Control Inputs
			CLK_I : in  STD_LOGIC;
			RST_I : in  STD_LOGIC;
			--Wishbone Slave Lines
			DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			ADR_I : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
			WE_I  : in  STD_LOGIC;
			STB_I : in  STD_LOGIC;
			ACK_O : out STD_LOGIC;
			--		CYC_I : in   STD_LOGIC;
			--GPIO Interface
			GPIO  : out STD_LOGIC_VECTOR(GPIO_WIDTH - 1 downto 0)
		);
	end component;

begin
	core_logic : wb_s
		generic map(
			DATA_WIDTH      => DATA_WIDTH,
			ADDR_WIDTH      => ADDR_WIDTH,
			BASE_ADDR       => BASE_ADDR,
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
			WE_I  => we_i,
			STB_I => stb_i,
			ACK_O => ack_o,
			CYC_I => open
		);

	user_logic : gpio_controller
		generic map(
			DATA_WIDTH => DATA_WIDTH,
			ADDR_WIDTH => CORE_ADDR_WIDTH,
			GPIO_WIDTH => GPIO_WIDTH
		)
		port map(
			--System Control Inputs
			CLK_I => CLK_I,
			RST_I => RST_I,
			--Wishbone Slave Lines
			DAT_I => dat_i,
			DAT_O => dat_o,
			ADR_I => adr_i,
			WE_I  => we_i,
			STB_I => stb_i,
			ACK_O => ack_o,
			--	CYC_I =>
			--GPIO Interface
			GPIO  => GPIO
		);

end Behavioral;

