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
		DATA_WIDTH : natural := 16;
		ADDR_WIDTH : natural := 4;
		GPIO_WIDTH : natural := 8
	);
	port(
		--Wishbone Slave Lines
		CLK_I : in  STD_LOGIC;
		RST_I : in  STD_LOGIC;
		DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		ADR_I : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		WE_I  : in  STD_LOGIC;
		STB_I : in  STD_LOGIC;
		ACK_O : out STD_LOGIC;
		--CYC_I : in    STD_LOGIC
		--GPIO Interface
		GPIO  : out STD_LOGIC_VECTOR(GPIO_WIDTH - 1 downto 0);
		--Debug
		Debug : out STD_LOGIC_VECTOR(ADDR_WIDTH + DATA_WIDTH +1 downto 0)
	);
end gpio_controller_ip;

architecture Behavioral of gpio_controller_ip is
	alias ram_adr_i : std_logic_vector(ADDR_WIDTH - 2 downto 0) is ADR_I(ADDR_WIDTH - 2 downto 0);
	alias ram_sel   : std_logic is ADR_I(ADDR_WIDTH - 1);
	--Local Registers
	--	constant base_addr : std_logic_vector (32 downto 0); -- Base + 0x0
	--	constant high_addr : std_logic_vector (32 downto 0); -- BASE + 0x2
	--	constant core_info : std_logic_vector (32 downto 0); -- BASE + 0x4	
	--	signal status_reg : std_logic_vector (DATA_WIDTH-1 downto 0) := (others => '1'); -- BASE + 0x6
--	signal control_reg : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '1'); -- BASE + 0x7

	type ram_type is array (0 to (2 ** (ADDR_WIDTH-1)) - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal core_mem : ram_type;

	signal u_dat_o : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal u_stb_i : std_logic;
	signal u_ack_o : std_logic;

	signal c_dat_o : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal c_stb_i : std_logic;
	signal c_ack_o : std_logic;

	component gpio_controller is
		generic(
			DATA_WIDTH : natural := DATA_WIDTH;
			ADDR_WIDTH : natural := ADDR_WIDTH - 1;
			GPIO_WIDTH : natural := 8
		);
		port(
			--Wishbone Slave Lines
			CLK_I : in  STD_LOGIC;
			RST_I : in  STD_LOGIC;
			DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			ADR_I : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
			WE_I  : in  STD_LOGIC;
			STB_I : in  STD_LOGIC;
			ACK_O : out STD_LOGIC;
			--		CYC_I : in    STD_LOGIC

			--GPIO Interface
			GPIO  : out STD_LOGIC_VECTOR(GPIO_WIDTH - 1 downto 0)
		);
	end component;

begin
	user_logic : gpio_controller
		generic map(
			DATA_WIDTH => DATA_WIDTH,
			ADDR_WIDTH => 3,
			GPIO_WIDTH => 8
		)
		port map(
			--Wishbone Master Lines
			RST_I => RST_I,--core_mem(7)(0),
			CLK_I => CLK_I,
			ADR_I => ram_adr_i,
			DAT_I => DAT_I,
			DAT_O => u_dat_o,
			WE_I  => WE_I,
			STB_I => u_stb_i,
			ACK_O => u_ack_o,
			--		CYC_I : in   STD_LOGIC
			--Serial Peripheral Interface
			GPIO  => GPIO
		);

	process(CLK_I)
	begin

		--Perform Clock Rising Edge operations
		if (rising_edge(CLK_I)) then
			--Reset the interface
			if (RST_I = '1') then
				core_mem(7) <= (others => '0');
				c_dat_o     <= (others => '0');
				c_ack_o     <= '0';

			--Check for strobe
			elsif (c_stb_i = '1') then
				c_dat_o <= core_mem(to_integer(unsigned(ram_adr_i)));
				--Check for write
				if (WE_I <= '1' and ram_adr_i = "111") then
					core_mem(7) <= DAT_I;
				end if;
			end if;
		end if;
	end process;

	DAT_O <= u_dat_o when (ram_sel = '1') else
		c_dat_o;
	ACK_O <= u_ack_o when (ram_sel = '1') else
		c_ack_o;
	u_stb_i <= STB_I and ram_sel;
	c_stb_i <= STB_I and not ram_sel;
	Debug   <= DAT_I & ADR_I & STB_I  & WE_I;
end Behavioral;

