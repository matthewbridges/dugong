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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity wb_s is
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
end wb_s;

architecture Behavioral of wb_s is
	--WB Inputs
	alias dat_ms  : std_logic_vector(DATA_WIDTH - 1 downto 0) is WB_I(DATA_WIDTH - 1 downto 0);
	alias adr_ms  : std_logic_vector(ADDR_WIDTH - 1 downto 0) is WB_I(ADDR_WIDTH + DATA_WIDTH - 1 downto DATA_WIDTH);
	alias stb_ms  : std_logic is WB_I(ADDR_WIDTH + DATA_WIDTH);
	alias we_ms   : std_logic is WB_I(ADDR_WIDTH + DATA_WIDTH + 1);
	alias cyc_ms  : std_logic is WB_I(ADDR_WIDTH + DATA_WIDTH + 2);
	--WB Outputs
	signal dat_sm : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal ack_sm : std_logic;

	signal core_sel     : std_logic;
	signal core_mem_sel : std_logic;
	signal core_adr     : unsigned(CORE_ADDR_WIDTH - 1 downto 0);

	type ram_type is array (0 to 3) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal core_mem : ram_type;

begin
	------------------------------------
	--------- Recode this entire process
	------------------------------------
	process(CLK_I)
	begin

		--Perform Clock Rising Edge operations
		if (rising_edge(CLK_I)) then
			--Check for reset
			if (RST_I = '1') then
				dat_sm                               <= (others => '0');
				ack_sm                               <= '0';
				core_mem(0)(ADDR_WIDTH - 1 downto 0) <= std_logic_vector(BASE_ADDR); --For 12 bit addressing
				core_mem(0)(31 downto ADDR_WIDTH)    <= (others => '0');
				core_mem(1)(ADDR_WIDTH - 1 downto 0) <= std_logic_vector(BASE_ADDR + (2 ** CORE_ADDR_WIDTH) - 1); --For 12 bit addressing
				core_mem(1)(31 downto ADDR_WIDTH)    <= (others => '0');
				core_mem(2)                          <= "10101010101010101010101010101010"; --Test Signal
				core_mem(3)                          <= "01010101010101010101010101010101"; --Test Signal

			elsif ((core_sel and core_mem_sel) = '1') then
				--Check for strobe
				if (stb_ms = '1') then
					dat_sm <= core_mem(to_integer(core_adr));
					ack_sm <= '1';
					--Check for write
					if (we_ms = '1') then
						core_mem(to_integer(core_adr)) <= dat_ms;
					end if;
				else
					ack_sm <= '0';
				end if;
			end if;
		end if;
	end process;

	core_sel     <= '1' when (adr_ms(ADDR_WIDTH - 1 downto CORE_ADDR_WIDTH) = std_logic_vector(BASE_ADDR(ADDR_WIDTH - 1 downto CORE_ADDR_WIDTH))) else '0';
	core_adr     <= unsigned(adr_ms(CORE_ADDR_WIDTH - 1 downto 0));
	core_mem_sel <= '1' when (core_adr < 4) else '0';

	process(core_sel, core_mem_sel, DAT_O, ACK_O, dat_sm, ack_sm)
	begin
		if (core_sel = '1') then
			if (core_mem_sel = '1') then
				--WB Output Ports
				WB_O <= (ack_sm & dat_sm);
			else
				--WB Output Ports
				WB_O(DATA_WIDTH downto CORE_DATA_WIDTH) <= (DATA_WIDTH => ACK_O, others => '0');
				WB_O(CORE_DATA_WIDTH - 1 downto 0)      <= DAT_O;
			end if;
		else
			--WB Output Ports
			WB_O <= (others => 'Z');
		end if;
	end process;

	--WB Input Ports
	DAT_I <= dat_ms(CORE_DATA_WIDTH - 1 downto 0);
	ADR_I <= std_logic_vector(core_adr - 4) when core_mem_sel = '0' else (others => '0');
	WE_I  <= we_ms;
	STB_I <= stb_ms and (core_sel and not core_mem_sel);
	cyc_I <= cyc_ms and (core_sel and not core_mem_sel);
end Behavioral;
