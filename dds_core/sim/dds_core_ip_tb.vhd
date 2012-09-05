LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;

ENTITY dds_core_ip_tb IS
END dds_core_ip_tb;

ARCHITECTURE behavior OF dds_core_ip_tb IS

	-- Component Declaration for the Unit Under Test (UUT)

	component dds_core_ip
		generic(DATA_WIDTH      : NATURAL               := 16;
			    ADDR_WIDTH      : NATURAL               := 12;
			    BASE_ADDR       : UNSIGNED(11 downto 0) := x"000";
			    CORE_DATA_WIDTH : NATURAL               := 12;
			    CORE_ADDR_WIDTH : NATURAL               := 4);
		port(CLK_I : in  STD_LOGIC;
			 RST_I : in  STD_LOGIC;
			 WB_I  : in  STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0);
			 WB_O  : out STD_LOGIC_VECTOR(DATA_WIDTH downto 0));
	end component dds_core_ip;

	--Inputs
	signal CLK_I : std_logic                     := '0';
	signal RST_I : std_logic                     := '1';
	signal WB_I  : std_logic_vector(30 downto 0) := (others => '0');

	--Outputs
	signal WB_O : std_logic_vector(16 downto 0);

	-- Clock period definitions
	constant CLK_I_period : time := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut : dds_core_ip PORT MAP(
			CLK_I => CLK_I,
			RST_I => RST_I,
			WB_I  => WB_I,
			WB_O  => WB_O
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
		wait for CLK_I_period * 10;

		-- insert stimulus here 
		wait until rising_edge(CLK_I);
		WB_I <= "111" & x"008" & x"000F";
		wait until rising_edge(WB_O(16));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"0000";
		wait until rising_edge(CLK_I);
		WB_I <= "101" & x"00B" & x"00FF";
		wait until rising_edge(WB_O(16));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"0000";
		wait until rising_edge(CLK_I);
		WB_I <= "101" & x"00C" & x"000F";
		wait until rising_edge(WB_O(16));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"0000";
		wait until rising_edge(CLK_I);
		WB_I <= "111" & x"008" & x"000F";
		wait until rising_edge(WB_O(16));
		wait until rising_edge(CLK_I);
		WB_I <= "000" & x"000" & x"0000";
		wait;
	end process;

END;
