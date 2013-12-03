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

entity dds_core_tb is
	generic(
		CORE_DATA_WIDTH : NATURAL := 16;
		CORE_ADDR_WIDTH : NATURAL := 3
	);
end dds_core_tb;

ARCHITECTURE behavior OF dds_core_tb IS

	-- Component Declaration for the Unit Under Test (UUT)
	component dds_core
		generic(
			CORE_DATA_WIDTH : natural := 16;
			CORE_ADDR_WIDTH : natural := 3
		);
		port(
			--System Control Inputs
			CLK_I     : in  STD_LOGIC;
			RST_I     : in  STD_LOGIC;
			--Wishbone Slave Lines
			ADR_I     : in  STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0);
			DAT_I     : in  STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
			DAT_O     : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
			WE_I      : in  STD_LOGIC;
			STB_I     : in  STD_LOGIC;
			ACK_O     : out STD_LOGIC;
			CYC_I     : in  STD_LOGIC;
			--Signal Channel Inputs
			DSP_CLK_I : in  STD_LOGIC;
			CH_A_O    : out STD_LOGIC_VECTOR(15 downto 0);
			CH_B_O    : out STD_LOGIC_VECTOR(15 downto 0)
		);
	end component dds_core;

	--System Control Inputs:
	signal CLK_I : std_logic := '0';
	signal RST_I : std_logic := '1';

	--Wishbone Slave interface
	signal ADR_I : STD_LOGIC_VECTOR(CORE_ADDR_WIDTH - 1 downto 0) := (others => '0');
	signal DAT_I : STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0) := (others => '0');
	signal DAT_O : STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
	signal WE_I  : STD_LOGIC                                      := '0';
	signal STB_I : STD_LOGIC                                      := '0';
	signal ACK_O : STD_LOGIC                                      := '0';
	signal CYC_I : STD_LOGIC                                      := '0';

	--DSP Signals
	signal DSP_CLK_I : STD_LOGIC := '0';
	signal CH_A_O    : STD_LOGIC_VECTOR(15 downto 0);
	signal CH_B_O    : STD_LOGIC_VECTOR(15 downto 0);

	-- Clock period definitions
	constant CLK_I_period     : time := 10 ns;
	constant DSP_CLK_I_period : time := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : dds_core
		generic map(
			CORE_DATA_WIDTH => CORE_DATA_WIDTH,
			CORE_ADDR_WIDTH => CORE_ADDR_WIDTH
		)
		port map(
			CLK_I     => CLK_I,
			RST_I     => RST_I,
			ADR_I     => ADR_I,
			DAT_I     => DAT_I,
			DAT_O     => DAT_O,
			WE_I      => WE_I,
			STB_I     => STB_I,
			ACK_O     => ACK_O,
			CYC_I     => CYC_I,
			DSP_CLK_I => DSP_CLK_I,
			CH_A_O    => CH_A_O,
			CH_B_O    => CH_B_O
		);

	-- Clock process definitions
	CLK_I_process : process
	begin
		CLK_I <= '0';
		wait for CLK_I_period / 2;
		CLK_I <= '1';
		wait for CLK_I_period / 2;
	end process;

	-- Clock process definitions
	DSP_CLK_I_process : process
	begin
		DSP_CLK_I <= '0';
		wait for DSP_CLK_I_period / 2;
		DSP_CLK_I <= '1';
		wait for DSP_CLK_I_period / 2;
	end process;

	-- Stimulus process
	stim_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;

		RST_I <= '0';

		wait for CLK_I_period * 10;

		-- insert stimulus here
		wait until rising_edge(CLK_I);
		DAT_I <= x"0000";               --Read from PHASE_INCREMENT 
		ADR_I <= "110";                 --ADDR x3
		WE_I  <= '0';                   --Read
		STB_I <= '1';                   --Strobe
		CYC_I <= '1';
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		DAT_I <= x"0000";
		wait until rising_edge(CLK_I);
		DAT_I <= x"4000";               --Write x0001 to PHASE_INCREMENT
		ADR_I <= "110";                 --ADDR x0
		WE_I  <= '1';                   --Write
		STB_I <= '1';                   --Strobe
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		WE_I  <= '0';
		DAT_I <= x"0000";
		wait until rising_edge(CLK_I);
		DAT_I <= x"0000";               --Read from SIN_OUT 
		ADR_I <= "110";                 --ADDR x1
		WE_I  <= '0';                   --Read
		STB_I <= '1';                   --Strobe
		wait until rising_edge(ACK_O);
		wait until rising_edge(CLK_I);
		STB_I <= '0';                   --NULL
		DAT_I <= x"0000";

		wait;
	end process;

	signal_to_text : process
		file outfile_A : text is out "ch_a_o.csv"; --declare output file
		file outfile_B : text is out "ch_b_o.csv"; --declare output file
		variable outlineA : line;       --line number declaration 
		variable outlineB : line;       --line number declaration
		variable time     : integer := 0;
	begin
		wait until rising_edge(DSP_CLK_I);
		time := time + 10;
		if (RST_I = '0') then
			--write(linenumber,value(integer),justified(side),field(width),digits(natural));
			write(outlineA, to_integer(signed(CH_A_O)), left);
			write(outlineB, to_integer(signed(CH_B_O)), left);
			write(outlineA, ", ");
			write(outlineB, ", ");
			write(outlineA, time, left);
			write(outlineB, time, left);
			-- write line to external file.
			writeline(outfile_A, outlineA);
			writeline(outfile_B, outlineB);
		end if;
	end process signal_to_text;

end;
