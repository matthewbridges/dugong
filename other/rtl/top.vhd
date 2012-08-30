----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:32:23 08/07/2012 
-- Design Name: 
-- Module Name:    top - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity wb_master is
	generic(
		DATA_WIDTH : natural := 16;
		ADDR_WIDTH : natural := 10
	);
	port(
		--Wishbone Master Lines (inverted)
		CLK_I : in  STD_LOGIC;
		RST_I : in  STD_LOGIC;
		--		DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);

		DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		ADR_O : out STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		WE_O  : out STD_LOGIC;
		STB_O : out STD_LOGIC;
		ACK_I : in  STD_LOGIC
	--		CYC_O : out STD_LOGIC
	);
end wb_master;

architecture Behavioral of wb_master is
	type wb_state is (idle, reading, writing);
	signal bus_state         : wb_state := idle;
	signal instruction       : std_logic_vector(31 downto 0);
	signal instruction_valid : boolean  := true;
	signal pc                : std_logic_vector(8 downto 0);

--	component program_counter is
--		generic(
--			DATA_WIDTH : natural := 9;
--			PROG_SIZE  : natural := 20
--		);
--		port(
--			-- Wishbone Master Lines
--			CLK_I : in  STD_LOGIC;
--			RST_I : in  STD_LOGIC;
--			DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
--			DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
--			WE_I  : in  STD_LOGIC;
--			STB_I : in  STD_LOGIC
--		);
--	end component;
--
--	component inst_mem is
--		generic(
--			DATA_WIDTH : natural := 32;
--			ADDR_WIDTH : natural := 9
--		);
--		port(
--			--Wishbone Slave Lines
--			CLK_I : in  STD_LOGIC;
--			RST_I : in  STD_LOGIC;
--			DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
--			DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
--			ADR_I : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
--			WE_I  : in  STD_LOGIC;
--			STB_I : in  STD_LOGIC
--		--		CYC_I : in   STD_LOGIC;
--
--		);
--	end component;

begin
	--	Inst_program_counter : program_counter PORT MAP(
	--			CLK_I => CLK_I,
	--			RST_I => RST_I,
	--			DAT_I => (others => '0'),
	--			DAT_O => pc,
	--			WE_I  => '0',
	--			STB_I => '1'
	--		);
	--
	--	Inst_inst_mem : inst_mem PORT MAP(
	--			CLK_I => CLK_I,
	--			RST_I => RST_I,
	--			DAT_I => (others => '0'),
	--			DAT_O => instruction,
	--			ADR_I => pc,
	--			WE_I  => '0',
	--			STB_I => '1'
	--		);

	process(CLK_I)
	begin
		--Perform Rising Edge operations
		if (rising_edge(CLK_I)) then
			if (RST_I = '1') then
				STB_O <= '0';
				WE_O  <= '0';

				bus_state <= idle;

				instruction_valid <= false;

			else
				-- Check if bus is idle
				if (bus_state = idle) then
					-- Perform Instruction if valid
					if (instruction_valid) then
						WE_O              <= instruction(16);
						STB_O             <= '1';
						bus_state         <= writing;
						instruction_valid <= false;
					-- Collect new Instruction
					else
						instruction_valid <= true;
					end if;
				end if;

				if (ACK_I = '1') then
					STB_O     <= '0';
					bus_state <= idle;
				end if;
			end if;
		end if;
	end process;

	DAT_O <= instruction(15 downto 0);
	ADR_O <= instruction(25 downto 16);

end Behavioral;

