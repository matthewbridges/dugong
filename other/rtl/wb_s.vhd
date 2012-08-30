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
		DATA_WIDTH      : NATURAL               := 16;
		ADDR_WIDTH      : NATURAL               := 12;
		BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
		CORE_ADDR_WIDTH : NATURAL               := 4
	);
	port(
		--System Control Inputs
		CLK_I : in  STD_LOGIC;
		RST_I : in  STD_LOGIC;
		--Slave to WB
		WB_I  : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
		WB_O  : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
		--Wishbone Slave Lines (inverted)
		DAT_I : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DAT_O : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		ADR_I : out STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0);
		STB_I : out STD_LOGIC;
		WE_I  : out STD_LOGIC;
		CYC_I : out STD_LOGIC;
		ACK_O : in  STD_LOGIC
	);
end wb_s;

architecture Behavioral of wb_s is
	--WB Inputs
	alias dat_ms : std_logic_vector(DATA_WIDTH - 1 downto 0) is WB_I(DATA_WIDTH - 1 downto 0);
	alias adr_ms : std_logic_vector(ADDR_WIDTH - 1 downto 0) is WB_I(ADDR_WIDTH + DATA_WIDTH - 1 downto DATA_WIDTH);
	alias stb_ms : std_logic is WB_I(ADDR_WIDTH + DATA_WIDTH);
	alias we_ms  : std_logic is WB_I(ADDR_WIDTH + DATA_WIDTH + 1);
	alias cyc_ms : std_logic is WB_I(ADDR_WIDTH + DATA_WIDTH + 2);
	--WB Outputs
	signal dat_sm : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal ack_sm : std_logic;

	signal core_sel     : boolean;
	signal core_mem_sel : boolean;

	type ram_type is array (0 to 7) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal core_mem : ram_type;

begin
	process(CLK_I)
	begin

		--Perform Clock Rising Edge operations
		if (rising_edge(CLK_I)) then
			--Check for reset
			if (RST_I = '1') then
				dat_sm      <= (others => '0');
				ack_sm      <= '0';
				core_mem(0) <= x"0000"; --For 32 bit addressing
				core_mem(1) <= x"0" & std_logic_vector(BASE_ADDR);
				core_mem(2) <= x"0000"; --For 32 bit addressing
				core_mem(3) <= x"0" & std_logic_vector(BASE_ADDR + (2 ** CORE_ADDR_WIDTH) - 1);
				if (core_sel and core_mem_sel) then
				--Check for strobe
				elsif (stb_ms = '1') then
					dat_sm <= core_mem(to_integer(unsigned(adr_ms(2 downto 0))));
					ack_sm <= '1';
					--Check for write
					if (we_ms = '1') then
						core_mem(to_integer(unsigned(adr_ms(2 downto 0)))) <= dat_ms;
					end if;
				else
					ack_sm <= '0';
				end if;
			end if;
		end if;
	end process;

	core_sel     <= (adr_ms(ADDR_WIDTH - 1 downto CORE_ADDR_WIDTH) = std_logic_vector(BASE_ADDR(ADDR_WIDTH - 1 downto CORE_ADDR_WIDTH)));
	core_mem_sel <= (adr_ms(CORE_ADDR_WIDTH - 1 downto 3) = "0"); --ISSUE here

	process(core_sel, core_mem_sel, DAT_O, ACK_O, dat_sm, ack_sm, stb_ms, cyc_ms)
	begin
		if (core_sel) then
			if (core_mem_sel) then
				--WB Output Ports
				WB_O <= (ack_sm & dat_sm);
				--WB Input Ports
				STB_I <= '0';
				CYC_I <= '0';
			else
				--WB Output Ports
				WB_O <= (ACK_O & DAT_O);
				--WB Input Ports
				STB_I <= stb_ms;
				CYC_I <= cyc_ms;
			end if;
		else
			--WB Output Ports
			WB_O <= (others => 'Z');
			--WB Input Ports
			CYC_I <= '0';
			STB_I <= '0';
		end if;
	end process;

	--WB Input Ports
	DAT_I <= dat_ms;
	ADR_I <= adr_ms(CORE_ADDR_WIDTH - 1 downto 0);
	WE_I  <= we_ms;
end Behavioral;

