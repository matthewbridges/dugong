----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:22:16 08/07/2012 
-- Design Name: 
-- Module Name:    dugong - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dugong is
	generic(
		DATA_WIDTH : natural := 16;
		ADDR_WIDTH : natural := 12
	);
	port(
		--Wishbone Master Lines
		CLK_I : in  STD_LOGIC;
		RST_I : in  STD_LOGIC;
		DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		ADR_O : out STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		WE_O  : out STD_LOGIC;
		STB_O : out STD_LOGIC;
		ACK_I : in  STD_LOGIC;
		CYC_O : out STD_LOGIC
	);
end dugong;

architecture Behavioral of dugong is
	signal mem_dat_o   : std_logic_vector(31 downto 0);
	signal instruction : std_logic_vector(31 downto 0);
	signal pc          : std_logic_vector(8 downto 0);
	signal wait_cntr   : unsigned(ADDR_WIDTH + DATA_WIDTH - 1 downto 0);

	signal pc_ack_i : std_logic;

	signal bus_en    : std_logic;
	signal write_en  : std_logic;
	signal branch_en : std_logic;
	signal wait_en   : std_logic;
	signal pc_en     : std_logic;

	component program_counter is
		generic(
			DATA_WIDTH : natural := 9;
			PROG_SIZE  : natural := 511
		);
		port(
			-- Wishbone Master Lines
			CLK_I : in  STD_LOGIC;
			RST_I : in  STD_LOGIC;
			DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			WE_I  : in  STD_LOGIC;
			STB_I : in  STD_LOGIC;
			ACK_O : out STD_LOGIC
		);
	end component;

	component inst_mem is
		generic(
			DATA_WIDTH : natural := 32;
			ADDR_WIDTH : natural := 9
		);
		port(
			--Wishbone Slave Lines
			CLK_I : in  STD_LOGIC;
			RST_I : in  STD_LOGIC;
			DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			ADR_I : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
			WE_I  : in  STD_LOGIC;
			STB_I : in  STD_LOGIC
		--	CYC_I : in   STD_LOGIC;

		);
	end component;

begin
	prog_counter : program_counter PORT MAP(
			CLK_I => CLK_I,
			RST_I => RST_I,
			DAT_I => instruction(8 downto 0),
			DAT_O => pc,
			WE_I  => branch_en,
			STB_I => pc_en,
			ACK_O => pc_ack_i
		);

	instruction_mem : inst_mem PORT MAP(
			CLK_I => not CLK_I,
			RST_I => RST_I,
			DAT_I => (others => '0'),
			DAT_O => mem_dat_o,
			ADR_I => pc,
			WE_I  => '0',
			STB_I => '1'
		);

	process(CLK_I)
	begin
		--Perform Rising Edge operations
		if (rising_edge(CLK_I)) then
			if (RST_I = '1') then
				DAT_O       <= (others => '0');
				ADR_O       <= (others => '0');
				bus_en      <= '0';
				write_en    <= '0';
				branch_en   <= '0';
				pc_en       <= '0';
				instruction <= (others => '0');

			else
				-- Check if bus is idle
				if (bus_en = '0') then
					if (wait_en = '1') then
						if (wait_cntr = "000000000000000") then
							wait_en <= '0';
						else
							wait_cntr <= wait_cntr - 1;
						end if;
					-- Perform Instruction if valid
					elsif (pc_en = '0') then
						DAT_O     <= instruction(15 downto 0);
						ADR_O     <= instruction(27 downto 16);
						bus_en    <= instruction(28);
						write_en  <= instruction(29);
						branch_en <= instruction(30);
						wait_en   <= instruction(31);
						wait_cntr <= unsigned(instruction(27 downto 0));
						pc_en     <= '1'; -- Request new instruction
					end if;
				elsif (ACK_I = '1') then
					bus_en <= '0';      -- Conclude bus transfer
				end if;

				if (pc_ack_i = '1') then
					instruction <= mem_dat_o; -- Store new instruction
					pc_en       <= '0';
				end if;

			end if;
		end if;
	end process;

	STB_O <= bus_en;
	WE_O  <= write_en;

	CYC_O <= branch_en;                 -- Debug

--	DAT_O <= mem_dat_o(15 downto 0);
--	ADR_O <= "000" & pc;

end Behavioral;

