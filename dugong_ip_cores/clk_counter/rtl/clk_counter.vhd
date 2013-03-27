library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clk_counter is
	generic(
		DATA_WIDTH : natural                       := 32;
		ADDR_WIDTH : natural                       := 2;
		MASTER_CNT : std_logic_vector(26 downto 0) := "111" & x"530000"
	);
	port(
		--System Control Inputs
		CLK_I       : in  STD_LOGIC;
		RST_I       : in  STD_LOGIC;
		--Wishbone Slave Lines
		--DAT_I       : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DAT_O       : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		ADR_I       : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		STB_I       : in  STD_LOGIC;
		--WE_I  : in  STD_LOGIC;
		--CYC_I : in   STD_LOGIC;
		ACK_O       : out STD_LOGIC;
		--Test Clocks
		TEST_CLOCKS : in  STD_LOGIC_VECTOR((2 ** ADDR_WIDTH) - 1 downto 0)
	);
end entity clk_counter;

architecture RTL of clk_counter is
	type ram_type is array (0 to (2 ** ADDR_WIDTH) - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal user_mem : ram_type;
	signal mem_adr  : integer;

	signal master_count : unsigned(DATA_WIDTH - 6 downto 0);
	type count_mem is array (0 to (2 ** ADDR_WIDTH) - 1) of unsigned(DATA_WIDTH - 1 downto 0);
	signal count : count_mem;
	type final_count_mem is array (0 to (2 ** ADDR_WIDTH) - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal final_count : final_count_mem;

	signal read_count  : std_logic;
	signal count_valid : std_logic_vector(0 to (2 ** ADDR_WIDTH) - 1);
	signal rst_count   : std_logic;

begin
	process(CLK_I)
	begin

		--Perform Clock Rising Edge operations
		if (rising_edge(CLK_I)) then
			--Check for reset
			if (RST_I = '1') then
				DAT_O      <= (others => '0');
				ACK_O      <= '0';
				read_count <= '0';
				rst_count  <= '1';
			--Check for strobe
			else
				if (read_count = '1') then
					if (count_valid(0) = '1') then --(count_valid = x"F")
						user_mem(0) <= final_count(0);
						user_mem(1) <= final_count(1);
						user_mem(2) <= final_count(2);
						user_mem(3) <= final_count(3);
						rst_count   <= '1';
						read_count  <= '0';
					end if;
				else
					if (rst_count = '1') then
						master_count <= (others => '0');
						rst_count    <= '0';
					elsif (master_count < (unsigned(MASTER_CNT) - 1)) then --x"7530000" - '1'  --Subtract 1 to account for signal propogation
						master_count <= master_count + 1;
					else
						read_count <= '1';
					end if;

					--Check for strobe
					if (STB_I = '1') then
						DAT_O <= user_mem(mem_adr);
					end if;
					ACK_O <= STB_I;
				end if;
			end if;
		end if;
	end process;

	mem_adr <= to_integer(unsigned(ADR_I));

	-- We have multiple clocks- step over every test_clock, instantiating the required elements
	Test_CLOCKS_Processes : for clk_number in 0 to 3 generate
		process(TEST_CLOCKS(clk_number))
		begin

			--Perform Clock Rising Edge operations
			if (rising_edge(TEST_CLOCKS(clk_number))) then
				if (read_count = '1') then
					final_count(clk_number) <= std_logic_vector(count(clk_number));
					count_valid(clk_number) <= '1';
				elsif (rst_count = '1') then
					count(clk_number)       <= x"00000000";
					count_valid(clk_number) <= '0';
				else
					count(clk_number) <= count(clk_number) + 1;
				end if;
			end if;
		end process;

	end generate Test_CLOCKS_Processes;

end architecture RTL;
