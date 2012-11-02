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
		DATA_WIDTH : natural := 16;
		ADDR_WIDTH : natural := 2
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
		--Signal Channel Outputs
		DSP_CLK_I : in  STD_LOGIC;
		CH_A_O    : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		CH_B_O    : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0)
	);
end dds_core;

architecture Behavioral of dds_core is
	type ram_type is array (0 to (2 ** ADDR_WIDTH) - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal user_mem : ram_type;
	signal mem_adr  : integer;

	constant frequency_control_word : natural := 4;

	type lut_type is array (0 to (2 ** 5) - 1) of signed(DATA_WIDTH - 1 downto 0);
	signal addr   : unsigned(5 - 1 downto 0);
	constant ramp : lut_type := (
		0      => to_signed(0,
			DATA_WIDTH),
		1      => to_signed(2048,
			DATA_WIDTH),
		2      => to_signed(4096,
			DATA_WIDTH),
		3      => to_signed(6144,
			DATA_WIDTH),
		4      => to_signed(8192,
			DATA_WIDTH),
		5      => to_signed(10240,
			DATA_WIDTH),
		6      => to_signed(12288,
			DATA_WIDTH),
		7      => to_signed(14336,
			DATA_WIDTH),
		8      => to_signed(16384,
			DATA_WIDTH),
		9      => to_signed(18431,
			DATA_WIDTH),
		10     => to_signed(20479,
			DATA_WIDTH),
		11     => to_signed(22527,
			DATA_WIDTH),
		12     => to_signed(24575,
			DATA_WIDTH),
		13     => to_signed(26623,
			DATA_WIDTH),
		14     => to_signed(28671,
			DATA_WIDTH),
		15     => to_signed(30719,
			DATA_WIDTH),
		16     => to_signed(-32767,
			DATA_WIDTH),
		17     => to_signed(-30719,
			DATA_WIDTH),
		18     => to_signed(-28671,
			DATA_WIDTH),
		19     => to_signed(-26623,
			DATA_WIDTH),
		20     => to_signed(-24575,
			DATA_WIDTH),
		21     => to_signed(-22527,
			DATA_WIDTH),
		22     => to_signed(-20479,
			DATA_WIDTH),
		23     => to_signed(-18431,
			DATA_WIDTH),
		24     => to_signed(-16384,
			DATA_WIDTH),
		25     => to_signed(-14336,
			DATA_WIDTH),
		26     => to_signed(-12288,
			DATA_WIDTH),
		27     => to_signed(-10240,
			DATA_WIDTH),
		28     => to_signed(-8192,
			DATA_WIDTH),
		29     => to_signed(-6144,
			DATA_WIDTH),
		30     => to_signed(-4096,
			DATA_WIDTH),
		others => to_signed(0,
			DATA_WIDTH)
	);

	constant square : lut_type := (
		0      => to_signed(32767,
			DATA_WIDTH),
		1      => to_signed(32767,
			DATA_WIDTH),
		2      => to_signed(32767,
			DATA_WIDTH),
		3      => to_signed(32767,
			DATA_WIDTH),
		4      => to_signed(32767,
			DATA_WIDTH),
		5      => to_signed(32767,
			DATA_WIDTH),
		6      => to_signed(32767,
			DATA_WIDTH),
		7      => to_signed(32767,
			DATA_WIDTH),
		8      => to_signed(32767,
			DATA_WIDTH),
		9      => to_signed(32767,
			DATA_WIDTH),
		10     => to_signed(32767,
			DATA_WIDTH),
		11     => to_signed(32767,
			DATA_WIDTH),
		12     => to_signed(32767,
			DATA_WIDTH),
		13     => to_signed(32767,
			DATA_WIDTH),
		14     => to_signed(32767,
			DATA_WIDTH),
		15     => to_signed(32767,
			DATA_WIDTH),
		16     => to_signed(-32767,
			DATA_WIDTH),
		17     => to_signed(-32767,
			DATA_WIDTH),
		18     => to_signed(-32767,
			DATA_WIDTH),
		19     => to_signed(-32767,
			DATA_WIDTH),
		20     => to_signed(-32767,
			DATA_WIDTH),
		21     => to_signed(-32767,
			DATA_WIDTH),
		22     => to_signed(-32767,
			DATA_WIDTH),
		23     => to_signed(-32767,
			DATA_WIDTH),
		24     => to_signed(-32767,
			DATA_WIDTH),
		25     => to_signed(-32767,
			DATA_WIDTH),
		26     => to_signed(-32767,
			DATA_WIDTH),
		27     => to_signed(-32767,
			DATA_WIDTH),
		28     => to_signed(-32767,
			DATA_WIDTH),
		29     => to_signed(-32767,
			DATA_WIDTH),
		30     => to_signed(-32767,
			DATA_WIDTH),
		others => to_signed(0,
			DATA_WIDTH)
	);

	constant sine : lut_type := (
		0      => to_signed(0,
			DATA_WIDTH),
		1      => to_signed(6393,
			DATA_WIDTH),
		2      => to_signed(12539,
			DATA_WIDTH),
		3      => to_signed(18204,
			DATA_WIDTH),
		4      => to_signed(23170,
			DATA_WIDTH),
		5      => to_signed(27245,
			DATA_WIDTH),
		6      => to_signed(30273,
			DATA_WIDTH),
		7      => to_signed(32137,
			DATA_WIDTH),
		8      => to_signed(32767,
			DATA_WIDTH),
		9      => to_signed(32137,
			DATA_WIDTH),
		10     => to_signed(30273,
			DATA_WIDTH),
		11     => to_signed(27245,
			DATA_WIDTH),
		12     => to_signed(23170,
			DATA_WIDTH),
		13     => to_signed(18204,
			DATA_WIDTH),
		14     => to_signed(12539,
			DATA_WIDTH),
		15     => to_signed(6393,
			DATA_WIDTH),
		16     => to_signed(0,
			DATA_WIDTH),
		17     => to_signed(-6393,
			DATA_WIDTH),
		18     => to_signed(-12539,
			DATA_WIDTH),
		19     => to_signed(-18204,
			DATA_WIDTH),
		20     => to_signed(-23170,
			DATA_WIDTH),
		21     => to_signed(-27245,
			DATA_WIDTH),
		22     => to_signed(-30273,
			DATA_WIDTH),
		23     => to_signed(-32137,
			DATA_WIDTH),
		24     => to_signed(-32767,
			DATA_WIDTH),
		25     => to_signed(-32137,
			DATA_WIDTH),
		26     => to_signed(-30273,
			DATA_WIDTH),
		27     => to_signed(-27245,
			DATA_WIDTH),
		28     => to_signed(-23170,
			DATA_WIDTH),
		29     => to_signed(-18204,
			DATA_WIDTH),
		30     => to_signed(-12539,
			DATA_WIDTH),
		others => to_signed(0,
			DATA_WIDTH)
	);

--	component dds_synthesizer
--		generic(
--			ftw_width : integer
--		);
--		port(
--			clk_i   : in  std_logic;
--			rst_i   : in  std_logic;
--			ftw_i   : in  std_logic_vector(ftw_width - 1 downto 0);
--			phase_i : in  std_logic_vector(PHASE_WIDTH - 1 downto 0);
--			phase_o : out std_logic_vector(PHASE_WIDTH - 1 downto 0);
--			ampl_o  : out std_logic_vector(AMPL_WIDTH - 1 downto 0)
--		);
--	end component;
begin
	--	dds_synth : dds_synthesizer
	--		generic map(
	--			ftw_width => DATA_WIDTH
	--		)
	--		port map(
	--			clk_i   => CLK_I,
	--			rst_i   => RST_I,
	--			ftw_i   => user_mem(0),
	--			phase_i => user_mem(1),
	--			phase_o => user_mem(2),
	--			ampl_o  => user_mem(3)
	--		);

	process(CLK_I)
	begin

		--Perform Clock Rising Edge operations
		if (rising_edge(CLK_I)) then
			--Check for reset
			if (RST_I = '1') then
				DAT_O       <= (others => '0');
				user_mem(0) <= x"0FFF";
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
				addr <= (others => '0');
			else
				CH_A_O <= std_logic_vector(sine(to_integer(addr)));
				CH_B_O <= std_logic_vector(ramp(to_integer(addr)));
				addr   <= addr + frequency_control_word;
			end if;
		end if;
	end process;

end Behavioral;



