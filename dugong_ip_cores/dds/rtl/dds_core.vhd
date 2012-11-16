----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:05:21 09/05/2012 
-- Design Name: 
-- Module Name:    dds_core - Behavioral 
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
use work.sine_lut_pkg.all;

entity dds_core is
	generic(
		DATA_WIDTH  : natural := 16;
		ADDR_WIDTH  : natural := 2;
		PHASE_WIDTH : natural := 8
	);
	port(
		--System Control Inputs
		CLK_I     : in  STD_LOGIC;
		RST_I     : in  STD_LOGIC;
		--Wishbone Slave Lines
		DAT_I     : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DAT_O     : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		ADR_I     : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		STB_I     : in  STD_LOGIC;
		WE_I      : in  STD_LOGIC;
		--		CYC_I : in   STD_LOGIC;
		ACK_O     : out STD_LOGIC;
		--Signal Channel Inputs
		DSP_CLK_I  : in  STD_LOGIC;
		CH_A_O     : out  STD_LOGIC_VECTOR(15 downto 0);
		CH_B_O     : out  STD_LOGIC_VECTOR(15 downto 0)
	);
end dds_core;

architecture Behavioral of dds_core is
	type ram_type is array (0 to (2 ** ADDR_WIDTH) - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal user_mem : ram_type;
	signal mem_adr  : integer;

	type lut_type is array (0 to (2 ** (PHASE_WIDTH - 2)) - 1) of signed(DATA_WIDTH - 1 downto 0);
	signal addr   : unsigned(PHASE_WIDTH - 1 downto 0);
	constant sine : lut_type := (
		0      => to_signed(0,
			DATA_WIDTH),
		1      => to_signed(810,
			DATA_WIDTH),
		2      => to_signed(1620,
			DATA_WIDTH),
		3      => to_signed(2429,
			DATA_WIDTH),
		4      => to_signed(3237,
			DATA_WIDTH),
		5      => to_signed(4042,
			DATA_WIDTH),
		6      => to_signed(4845,
			DATA_WIDTH),
		7      => to_signed(5646,
			DATA_WIDTH),
		8      => to_signed(6442,
			DATA_WIDTH),
		9      => to_signed(7235,
			DATA_WIDTH),
		10     => to_signed(8023,
			DATA_WIDTH),
		11     => to_signed(8806,
			DATA_WIDTH),
		12     => to_signed(9584,
			DATA_WIDTH),
		13     => to_signed(10357,
			DATA_WIDTH),
		14     => to_signed(11122,
			DATA_WIDTH),
		15     => to_signed(11881,
			DATA_WIDTH),
		16     => to_signed(12633,
			DATA_WIDTH),
		17     => to_signed(13377,
			DATA_WIDTH),
		18     => to_signed(14113,
			DATA_WIDTH),
		19     => to_signed(14840,
			DATA_WIDTH),
		20     => to_signed(15558,
			DATA_WIDTH),
		21     => to_signed(16266,
			DATA_WIDTH),
		22     => to_signed(16965,
			DATA_WIDTH),
		23     => to_signed(17653,
			DATA_WIDTH),
		24     => to_signed(18331,
			DATA_WIDTH),
		25     => to_signed(18997,
			DATA_WIDTH),
		26     => to_signed(19651,
			DATA_WIDTH),
		27     => to_signed(20294,
			DATA_WIDTH),
		28     => to_signed(20924,
			DATA_WIDTH),
		29     => to_signed(21541,
			DATA_WIDTH),
		30     => to_signed(22145,
			DATA_WIDTH),
		31     => to_signed(22736,
			DATA_WIDTH),
		32     => to_signed(23313,
			DATA_WIDTH),
		33     => to_signed(23875,
			DATA_WIDTH),
		34     => to_signed(24423,
			DATA_WIDTH),
		35     => to_signed(24956,
			DATA_WIDTH),
		36     => to_signed(25473,
			DATA_WIDTH),
		37     => to_signed(25975,
			DATA_WIDTH),
		38     => to_signed(26461,
			DATA_WIDTH),
		39     => to_signed(26931,
			DATA_WIDTH),
		40     => to_signed(27385,
			DATA_WIDTH),
		41     => to_signed(27821,
			DATA_WIDTH),
		42     => to_signed(28241,
			DATA_WIDTH),
		43     => to_signed(28643,
			DATA_WIDTH),
		44     => to_signed(29028,
			DATA_WIDTH),
		45     => to_signed(29395,
			DATA_WIDTH),
		46     => to_signed(29744,
			DATA_WIDTH),
		47     => to_signed(30075,
			DATA_WIDTH),
		48     => to_signed(30388,
			DATA_WIDTH),
		49     => to_signed(30682,
			DATA_WIDTH),
		50     => to_signed(30957,
			DATA_WIDTH),
		51     => to_signed(31213,
			DATA_WIDTH),
		52     => to_signed(31450,
			DATA_WIDTH),
		53     => to_signed(31668,
			DATA_WIDTH),
		54     => to_signed(31866,
			DATA_WIDTH),
		55     => to_signed(32045,
			DATA_WIDTH),
		56     => to_signed(32205,
			DATA_WIDTH),
		57     => to_signed(32344,
			DATA_WIDTH),
		58     => to_signed(32464,
			DATA_WIDTH),
		59     => to_signed(32564,
			DATA_WIDTH),
		60     => to_signed(32644,
			DATA_WIDTH),
		61     => to_signed(32704,
			DATA_WIDTH),
		62     => to_signed(32744,
			DATA_WIDTH),
		63     => to_signed(32764,
			DATA_WIDTH),
		others => to_signed(0,
			DATA_WIDTH)
	);

begin
	process(CLK_I)
	begin

		--Perform Clock Rising Edge operations
		if (rising_edge(CLK_I)) then
			--Check for reset
			if (RST_I = '1') then
				DAT_O       <= (others => '0');
				user_mem(0) <= x"0020";
				user_mem(1) <= (others => '0');
			--Check for strobe
			elsif (STB_I = '1') then
				DAT_O <= user_mem(mem_adr);
				--Check for write
				if (WE_I = '1') then
					case (mem_adr) is
						when 0      => user_mem(0) <= dat_i;
						when 1      => user_mem(1) <= dat_i;
						when others => null;
					end case;
				end if;
			end if;
			ACK_O <= STB_I;
		end if;
	end process;

	mem_adr <= to_integer(unsigned(ADR_I));

	process(DSP_CLK_I)
	begin
		--Perform Clock Rising Edge operations
		if (rising_edge(DSP_CLK_I)) then
			--Check for reset
			if (RST_I = '1') then
				addr        <= (others => '0');
				user_mem(2) <= (others => '0');
				user_mem(3) <= (others => '0');
			else
				case (addr(PHASE_WIDTH - 1 downto PHASE_WIDTH - 2)) is
					when "00"   => user_mem(2) <= std_logic_vector((sine(to_integer(addr(PHASE_WIDTH - 3 downto 0)))));
					when "01"   => user_mem(2) <= std_logic_vector((sine((2 ** (PHASE_WIDTH - 2) - 1) - to_integer(addr(PHASE_WIDTH - 3 downto 0)))));
					when "10"   => user_mem(2) <= std_logic_vector(-(sine(to_integer(addr(PHASE_WIDTH - 3 downto 0)))));
					when "11"   => user_mem(2) <= std_logic_vector(-(sine((2 ** (PHASE_WIDTH - 2) - 1) - to_integer(addr(PHASE_WIDTH - 3 downto 0)))));
					when others => user_mem(2) <= (others => '0');
				end case;
				--				
				case (addr(PHASE_WIDTH - 1 downto PHASE_WIDTH - 2)) is
					when "11"   => user_mem(3) <= std_logic_vector((sine(to_integer(addr(PHASE_WIDTH - 3 downto 0)))));
					when "00"   => user_mem(3) <= std_logic_vector((sine((2 ** (PHASE_WIDTH - 2) - 1) - to_integer(addr(PHASE_WIDTH - 3 downto 0)))));
					when "01"   => user_mem(3) <= std_logic_vector(-(sine(to_integer(addr(PHASE_WIDTH - 3 downto 0)))));
					when "10"   => user_mem(3) <= std_logic_vector(-(sine((2 ** (PHASE_WIDTH - 2) - 1) - to_integer(addr(PHASE_WIDTH - 3 downto 0)))));
					when others => user_mem(3) <= (others => '0');
				end case;
				--					
				--					user_mem(3) <= std_logic_vector(-sine(to_integer(addr(PHASE_WIDTH - 2 downto 0))));
				--				else
				--					
				--					user_mem(3) <= std_logic_vector(sine(to_integer(addr(PHASE_WIDTH - 2 downto 0))));
				--				end if;
				addr <= addr + unsigned(user_mem(0)(PHASE_WIDTH - 1 downto 0));
			end if;
		end if;
	end process;

	CH_A_O <= user_mem(2);
	CH_B_O <= user_mem(3);

end Behavioral;



