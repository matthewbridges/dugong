-- TestBench Template 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY dds_core_ip_tb IS
END dds_core_ip_tb;

ARCHITECTURE behavior OF dds_core_ip_tb IS
	component sink_file
		generic(
			stim_file : string := "file_io.out"
		);
		port(
			clk  : in STD_LOGIC;
			data : in STD_LOGIC_VECTOR(15 downto 0)
		);
	end component sink_file;

	-- Component Declaration
	component dds_core_ip
		generic(
			DATA_WIDTH      : NATURAL               := 32;
			ADDR_WIDTH      : NATURAL               := 12;
			BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
			CORE_DATA_WIDTH : NATURAL               := 16;
			CORE_ADDR_WIDTH : NATURAL               := 3);
		port(
			CLK_I  : in  STD_LOGIC;
			RST_I  : in  STD_LOGIC;
			WB_I   : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
			WB_O   : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
			DSP_CLK_I : in  STD_LOGIC;
			CH_A_O : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0);
			CH_B_O : out STD_LOGIC_VECTOR(CORE_DATA_WIDTH - 1 downto 0)
		);
	end component dds_core_ip;

	signal CLK_I  : STD_LOGIC;
	signal RST_I  : STD_LOGIC := '1';
	signal WB_I   : STD_LOGIC_VECTOR(46 downto 0);
	signal WB_O   : STD_LOGIC_VECTOR(32 downto 0);
	signal DSP_CLK_I : STD_LOGIC;
	signal CH_A_O : STD_LOGIC_VECTOR(15 downto 0);
	signal CH_B_O : STD_LOGIC_VECTOR(15 downto 0);

	-- Clock period definitions
	constant CLK_I_period : time := 8 ns;

BEGIN

	-- Component Instantiation
	uut : dds_core_ip
		port map(
			CLK_I  => CLK_I,
			RST_I  => RST_I,
			WB_I   => WB_I,
			WB_O   => WB_O,
			DSP_CLK_I => DSP_CLK_I,
			CH_A_O => CH_A_O,
			CH_B_O => CH_B_O
		);

	sampler : sink_file
		port map(
			clk  => clk_I,
			data => CH_A_O
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
		wait for CLK_I_period / 2;
		DSP_CLK_I <= '1';
		wait for CLK_I_period / 2;
	end process;

	-- Stimulus process
	stim_proc : process
	begin
		-- hold reset state for 100 ns.
		wait for 100 ns;

		RST_I <= '0';
		wait for CLK_I_period * 10;

	end process;

END;
