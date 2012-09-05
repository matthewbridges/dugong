-- Testbench of DDS Frequency Synthesizer
--
-- Copyright (C) 2009 Martin Kumm
-- 
-- This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License along with this program; 
-- if not, see <http://www.gnu.org/licenses/>.

-- Package Definition

library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;
--use work.dds_synthesizer_pkg.all;
use work.sine_lut_pkg.all;

entity dds_synthesizer_tb is
	generic(
		clk_period : time    := 10 ns;
		ftw_width  : integer := 12
	);
end dds_synthesizer_tb;
architecture dds_synthesizer_tb_arch of dds_synthesizer_tb is
	component sink_file
		generic(stim_file : string := "file_io.out");
		port(clk  : in STD_LOGIC;
			 data : in STD_LOGIC_VECTOR(11 downto 0));
	end component sink_file;

	component dds_synthesizer
		generic(ftw_width : integer := 32);
		port(clk_i   : in  std_logic;
			 rst_i   : in  std_logic;
			 ftw_i   : in  std_logic_vector(ftw_width - 1 downto 0);
			 phase_i : in  std_logic_vector(PHASE_WIDTH - 1 downto 0);
			 phase_o : out std_logic_vector(PHASE_WIDTH - 1 downto 0);
			 ampl_o  : out std_logic_vector(AMPL_WIDTH - 1 downto 0));
	end component dds_synthesizer;

	signal clk, rst   : std_logic := '0';
	signal ftw        : std_logic_vector(ftw_width - 1 downto 0);
	signal init_phase : std_logic_vector(phase_width - 1 downto 0);
	signal phase_out  : std_logic_vector(phase_width - 1 downto 0);
	signal ampl_out   : std_logic_vector(ampl_width - 1 downto 0);

begin
	dds_synth : dds_synthesizer
		generic map(
			ftw_width => ftw_width
		)
		port map(
			clk_i   => clk,
			rst_i   => rst,
			ftw_i   => ftw,
			phase_i => init_phase,
			phase_o => phase_out,
			ampl_o  => ampl_out
		);

	sink : sink_file
		port map(
			clk  => clk,
			data => ampl_out
		);

	init_phase <= (others => '0');
	ftw        <= conv_std_logic_vector(80, ftw_width); --20us period @ 100MHz, ftw_width=32

	clk <= not clk after clk_period / 2;
	rst <= '1', '0' after 2 * clk_period;

end dds_synthesizer_tb_arch;