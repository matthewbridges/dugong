library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clk_counter is
	generic(
		DATA_WIDTH : natural                       := 32;
		ADDR_WIDTH : natural                       := 3;
		MASTER_CNT : std_logic_vector(31 downto 0) := x"07530000"
	);
	port(
		--System Control Inputs
		CLK_I       : in  STD_LOGIC;
		RST_I       : in  STD_LOGIC;
		--Wishbone Slave Lines
		DAT_I       : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DAT_O       : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		ADR_I       : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		STB_I       : in  STD_LOGIC;
		WE_I        : in  STD_LOGIC;
		--CYC_I     : in  STD_LOGIC;
		ACK_O       : out STD_LOGIC;
		--Test Clocks
		TEST_CLOCKS : in  STD_LOGIC_VECTOR((2 ** ADDR_WIDTH) - 6 downto 0)
	);
end entity clk_counter;

architecture RTL of clk_counter is
	--Core user memory architecture
	type ram_type is array (0 to (2 ** ADDR_WIDTH) - 5) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal user_mem : ram_type;
	signal mem_adr  : integer := 0;
	--Dual-port signaling
	signal mem_stb  : boolean;
	signal mem_ack  : boolean;
	--Dual-port lock
	--signal lock     : std_logic;

	signal master_count : unsigned(DATA_WIDTH - 1 downto 0);
	type count_mem is array (0 to (2 ** ADDR_WIDTH) - 6) of unsigned(DATA_WIDTH - 1 downto 0);
	signal count : count_mem;

	signal read_count  : std_logic;
	signal count_valid : std_logic_vector(0 to (2 ** ADDR_WIDTH) - 6);
	signal rst_count   : std_logic;

begin
	process(CLK_I)
	begin

		--Perform Clock Rising Edge operations
		if (rising_edge(CLK_I)) then
			--Check for reset
			if (RST_I = '1') then
				ACK_O       <= '0';
				user_mem(0) <= MASTER_CNT;
				mem_ack     <= false;
			--				lock        <= '0';

			else
				DAT_O   <= user_mem(mem_adr);
				mem_ack <= mem_stb;
				--Check for internal strobe	
				if (mem_stb) then
					user_mem(1) <= std_logic_vector(count(0));
					user_mem(2) <= std_logic_vector(count(1));
					user_mem(3) <= std_logic_vector(count(2));
				--					lock        <= '0';
				else
					--Check for external strobe
					if (STB_I = '1') then
						case mem_adr is
							--							--Lockable memory
							--							when 0 =>
							--								if (lock = '0') then
							--									--Check for write
							--									if (WE_I = '1') then
							--										user_mem(mem_adr) <= DAT_I;
							--										lock              <= '1';
							--									end if;
							--									ACK_O <= '1';
							--								end if;
							--Read-only memory
							when 1 | 2 | 3 =>
								ACK_O <= '1';
							--Not Lockable, read/write memory
							when others =>
								--Check for write
								if (WE_I = '1') then
									user_mem(mem_adr) <= DAT_I;
								end if;
								ACK_O <= '1';
						end case;
					else
						ACK_O <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;
	--Core Memory Address --> equals IP Address(core_addr_width-1:0) - 4
	mem_adr <= to_integer(unsigned(ADR_I));

	--SPI Instruction generation process
	process(CLK_I)
	begin
		if (rising_edge(CLK_I)) then
			if (RST_I = '1') then
				rst_count  <= '1';
				read_count <= '0';
			else
				-- RESET STATE
				if (rst_count = '1') then
					master_count <= unsigned(user_mem(0)) - 1; --Signal Propagation Bug
					if (count_valid = "000") then
						rst_count <= '0';
						read_count <= '0';
					end if;
				-- READING STATE
				elsif (master_count = 0) then
					read_count <= '1';
					if (mem_stb and mem_ack) then
						mem_stb   <= false;
						rst_count <= '1';
					elsif (count_valid = "111") then
						mem_stb <= true;
					end if;
				-- COUNTING STATE
				else
					master_count <= master_count - 1;
				end if;
			end if;
		end if;
	end process;

	-- We have multiple clocks- step over every test_clock, instantiating the required elements
	Test_CLOCKS_Processes : for clk_number in 0 to 2 generate
		process(TEST_CLOCKS(clk_number))
		begin

			--Perform Clock Rising Edge operations
			if (rising_edge(TEST_CLOCKS(clk_number))) then
				-- RESET STATE
				if (rst_count = '1') then
					count(clk_number)       <= x"00000000";
					count_valid(clk_number) <= '0';
				elsif (read_count = '1') then
					count_valid(clk_number) <= '1';  --WHAT IF NO CLOCK SIGNAL?
				-- COUNTING STATE
				else
					count(clk_number) <= count(clk_number) + 1;
				end if;
			end if;
		end process;

	end generate Test_CLOCKS_Processes;

end architecture RTL;
