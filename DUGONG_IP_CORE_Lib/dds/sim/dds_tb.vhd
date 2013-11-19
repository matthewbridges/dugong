--
-- _______/\\\\\\\\\_______/\\\________/\\\____/\\\\\\\\\\\____/\\\\\_____/\\\_________/\\\\\________
-- \ ____/\\\///////\\\____\/\\\_______\/\\\___\/////\\\///____\/\\\\\\___\/\\\_______/\\\///\\\_____\
--  \ ___\/\\\_____\/\\\____\/\\\_______\/\\\_______\/\\\_______\/\\\/\\\__\/\\\_____/\\\/__\///\\\___\
--   \ ___\/\\\\\\\\\\\/_____\/\\\\\\\\\\\\\\\_______\/\\\_______\/\\\//\\\_\/\\\____/\\\______\//\\\__\
--    \ ___\/\\\//////\\\_____\/\\\/////////\\\_______\/\\\_______\/\\\\//\\\\/\\\___\/\\\_______\/\\\__\
--     \ ___\/\\\____\//\\\____\/\\\_______\/\\\_______\/\\\_______\/\\\_\//\\\/\\\___\//\\\______/\\\___\
--      \ ___\/\\\_____\//\\\___\/\\\_______\/\\\_______\/\\\_______\/\\\__\//\\\\\\____\///\\\__/\\\_____\
--       \ ___\/\\\______\//\\\__\/\\\_______\/\\\____/\\\\\\\\\\\___\/\\\___\//\\\\\______\///\\\\\/______\
--        \ ___\///________\///___\///________\///____\///////////____\///_____\/////_________\/////________\
--         \ __________________________________________\          \__________________________________________\
--          |:------------------------------------------|: DUGONG :|-----------------------------------------:|
--         / ==========================================/          /========================================= /
--        / =============================================================================================== /
--       / ================  Reconfigurable Hardware Interface for computatioN and radiO  ================ /
--      / ===============================  http://www.rhinoplatform.org  ================================ /
--     / =============================================================================================== /
--
---------------------------------------------------------------------------------------------------------------
-- Company:		UNIVERSITY OF CAPE TOWN
-- Engineer: 		MATTHEW BRIDGES
--
-- Name:		GPIO_CONTROLLER_TB
-- Type:		TB (15)
-- Description:
--
-- Compliance:		DUGONG V1.4
-- ID:			x 1-4-F
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

use STD.textio.ALL;

entity dds_tb is
	generic(
		AMPL_WIDTH  : natural := 16;
		PHASE_WIDTH : natural := 16
	);
end dds_tb;

ARCHITECTURE behavior OF dds_tb IS

	-- Component Declaration for the Unit Under Test (UUT)
	component dds
		generic(AMPL_WIDTH  : natural := 16;
			PHASE_WIDTH : natural := 16);
		port(
			--System Control Inputs
			CLK_I           : in  STD_LOGIC;
			RST_I           : in  STD_LOGIC;
			--Bus Logic Interface
			SIN_OUT         : out STD_LOGIC_VECTOR(AMPL_WIDTH - 1 downto 0);
			COS_OUT         : out STD_LOGIC_VECTOR(AMPL_WIDTH - 1 downto 0);
			PHASE_INCREMENT : in  STD_LOGIC_VECTOR(PHASE_WIDTH - 1 downto 0);
			PHASE_OFFSET    : in  STD_LOGIC_VECTOR(PHASE_WIDTH - 1 downto 0)
		);
	end component dds;

	--System Control Inputs:
	signal CLK_I : std_logic := '0';
	signal RST_I : std_logic := '1';

	--DSP Signals
	signal SIN_OUT         : STD_LOGIC_VECTOR(AMPL_WIDTH - 1 downto 0);
	signal COS_OUT         : STD_LOGIC_VECTOR(AMPL_WIDTH - 1 downto 0);
	signal PHASE_INCREMENT : STD_LOGIC_VECTOR(PHASE_WIDTH - 1 downto 0) := (others => '0');
	signal PHASE_OFFSET    : STD_LOGIC_VECTOR(PHASE_WIDTH - 1 downto 0) := (others => '0');

	signal n         : unsigned(PHASE_WIDTH - 1 downto 0) := (0 => '1', others => '0');
	signal recording : std_logic                          := '0';

	-- Clock period definitions
	constant CLK_I_period : time := 4069 ps;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : dds
		generic map(
			AMPL_WIDTH  => AMPL_WIDTH,
			PHASE_WIDTH => PHASE_WIDTH
		)
		port map(
			CLK_I           => CLK_I,
			RST_I           => RST_I,
			SIN_OUT         => SIN_OUT,
			COS_OUT         => COS_OUT,
			PHASE_INCREMENT => PHASE_INCREMENT,
			PHASE_OFFSET    => PHASE_OFFSET
		);

	-- Clock process definitions
	CLK_I_process : process
	begin
		CLK_I <= '0';
		wait for CLK_I_period / 2;
		CLK_I <= '1';
		wait for CLK_I_period / 2;
	end process;

	-- Stimulus process
	stim_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;

		RST_I <= '0';

		-- insert stimulus here
		wait until rising_edge(CLK_I);
		wait until rising_edge(CLK_I);
		wait until rising_edge(CLK_I);
		wait until rising_edge(CLK_I);
		wait until rising_edge(CLK_I);
		recording <= '1';

		wait;
	end process;

	counter_proc : process
	begin
		wait until rising_edge(CLK_I);
		if (RST_I = '0') then
			n <= n + 1;
		end if;
	end process;

	PHASE_INCREMENT <= x"3000";         --std_logic_vector(n);

	signal_to_text : process
		file outfile : text is out "dds/matlab/dds_simulation_out.csv"; --declare output file
		variable outline : line;        --line number declaration 
		variable time    : integer := 0;
	begin
		wait until rising_edge(CLK_I);
		if (recording = '1') then
			write(outline, to_integer(signed(SIN_OUT)), left);
			write(outline, ", ");
			write(outline, to_integer(signed(COS_OUT)), left);
			write(outline, ", ");
			write(outline, time, left);
			-- write line to external file.
			writeline(outfile, outline);
			time := time + 4069;
		end if;
	end process signal_to_text;

end;
