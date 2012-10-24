--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:11:21 08/30/2012
-- Design Name:   
-- Module Name:   /home/mbridges/Projects/Dugong/sim/dugong_tb.vhd
-- Project Name:  Dugong
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: dugong
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY dugong_tb IS
	generic(
		DATA_WIDTH : natural := 32;
		ADDR_WIDTH : natural := 12
	);
END dugong_tb;

ARCHITECTURE behavior OF dugong_tb IS

	-- Component Declaration for the Unit Under Test (UUT)

	COMPONENT dugong
		generic(
			DATA_WIDTH : natural := 32;
			ADDR_WIDTH : natural := 12
		);
		port(
			--System Control Inputs
			CLK_I   : in  STD_LOGIC;
			CLK_I_n : in  STD_LOGIC;
			RST_I   : in  STD_LOGIC;
			--Master to WB
			WB_I    : in  STD_LOGIC_VECTOR(DATA_WIDTH downto 0);
			WB_O    : out STD_LOGIC_VECTOR(2 + ADDR_WIDTH + DATA_WIDTH downto 0)
		);
	END COMPONENT;

	--Inputs
	signal CLK_I   : std_logic                             := '0';
	signal CLK_I_n : std_logic                             := '1';
	signal RST_I   : std_logic                             := '1';
	signal WB_I    : std_logic_vector(DATA_WIDTH downto 0) := (others => '0');

	--Outputs
	signal WB_O : std_logic_vector(2 + ADDR_WIDTH + DATA_WIDTH downto 0);

	signal temp    : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
	signal dat_out : std_logic_vector(15 downto 0);
	signal adr_out : std_logic_vector(11 downto 0);
	signal stb     : std_logic;
	signal we      : std_logic;
	signal ack     : std_logic;

	-- Clock period definitions
	constant CLK_I_period : time := 10 ns;

BEGIN
	dat_out <= WB_O(15 downto 0);
	adr_out <= WB_O(27 downto 16);
	stb     <= WB_O(28);
	we      <= WB_O(29);
	ack     <= WB_I(16);

	-- Instantiate the Unit Under Test (UUT)
	uut : dugong
		generic map(
			DATA_WIDTH => DATA_WIDTH,
			ADDR_WIDTH => ADDR_WIDTH
		)
		port map(
			CLK_I   => CLK_I,
			CLK_I_n => CLK_I_n,
			RST_I   => RST_I,
			WB_I    => WB_I,
			WB_O    => WB_O
		);

	-- Clock process definitions
	CLK_I_process : process
	begin
		CLK_I   <= '0';
		CLK_I_n <= '1';
		wait for CLK_I_period / 2;
		CLK_I   <= '1';
		CLK_I_n <= '0';
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


		wait;
	end process;

--	ACK_proc : process
--	begin
--		wait until (rising_edge(WB_O(28)));
--		wait until (rising_edge(CLK_I));
--		WB_I(15 downto 0) <= temp;
--		temp              <= WB_O(15 downto 0);
--		WB_I(16)          <= '1';
--		wait until (rising_edge(CLK_I));
--		--wait until (falling_edge(WB_O(28)));
--		WB_I(16)          <= '0';
--		WB_I(15 downto 0) <= x"0000";
--	end process;

END;
