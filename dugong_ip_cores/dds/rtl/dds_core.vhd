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
		CLK_I  : in  STD_LOGIC;
		RST_I  : in  STD_LOGIC;
		--Wishbone Slave Lines
		DAT_I  : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DAT_O  : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		ADR_I  : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		STB_I  : in  STD_LOGIC;
		WE_I   : in  STD_LOGIC;
		--		CYC_I : in   STD_LOGIC;
		ACK_O  : out STD_LOGIC;
		--Signal Channel Outputs
		CH_A_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		CH_B_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0)
	);
end dds_core;

architecture Behavioral of dds_core is
	type ram_type is array (0 to (2 ** ADDR_WIDTH) - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal user_mem : ram_type;
	signal mem_adr  : integer;

	component dds_synthesizer
		generic(
			ftw_width : integer
		);
		port(
			clk_i   : in  std_logic;
			rst_i   : in  std_logic;
			ftw_i   : in  std_logic_vector(ftw_width - 1 downto 0);
			phase_i : in  std_logic_vector(PHASE_WIDTH - 1 downto 0);
			phase_o : out std_logic_vector(PHASE_WIDTH - 1 downto 0);
			ampl_o  : out std_logic_vector(AMPL_WIDTH - 1 downto 0)
		);
	end component;
begin
	dds_synth : dds_synthesizer
		generic map(
			ftw_width => DATA_WIDTH
		)
		port map(
			clk_i   => CLK_I,
			rst_i   => RST_I,
			ftw_i   => user_mem(0),
			phase_i => user_mem(1)(15 downto 8),
			phase_o => user_mem(2)(15 downto 8),
			ampl_o  => user_mem(3)(15 downto 8)
		);

	process(CLK_I)
	begin

		--Perform Clock Rising Edge operations
		if (rising_edge(CLK_I)) then
			--Check for reset
			if (RST_I = '1') then
				DAT_O       <= (others => '0');
				user_mem(0) <= (others => '0');
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

--	user_mem(3) <= not (user_mem(2)(DATA_WIDTH - 1)) & user_mem(2)(DATA_WIDTH - 2 downto 0);
--	user_mem(5) <= not (user_mem(4)(DATA_WIDTH - 1)) & user_mem(4)(DATA_WIDTH - 2 downto 0);

	CH_A_O <= user_mem(2);
	CH_B_O <= user_mem(3);

end Behavioral;



