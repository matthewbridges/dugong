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

library DUGONG_Lib;
use DUGONG_Lib.dcomponents.ALL;

entity dugong_controller is
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
end dugong_controller;

architecture Behavioral of dugong_controller is
	--WB Master Lines
	signal dat_i : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal dat_o : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal adr_o : std_logic_vector(ADDR_WIDTH - 1 downto 0);
	signal stb_o : std_logic;
	signal we_o  : std_logic;
	signal cyc_o : std_logic;
	signal ack_i : std_logic;

	signal dat : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal adr : std_logic_vector(ADDR_WIDTH - 1 downto 0);

	signal bus_en    : std_logic;
	signal write_en  : std_logic;
	signal accum_en  : std_logic;
	signal branch_en : std_logic;
	signal wait_en   : std_logic;
	signal pc_en     : std_logic;

	signal instruction : std_logic_vector(ADDR_WIDTH + DATA_WIDTH + 3 downto 0);
	signal pc          : std_logic_vector(8 downto 0);
	signal wait_cntr   : unsigned(ADDR_WIDTH + DATA_WIDTH - 1 downto 0);
	signal accum       : std_logic_vector(DATA_WIDTH - 1 downto 0);

	signal pc_ack_i : std_logic;

	component program_counter is
		generic(
			DATA_WIDTH : natural := 9;
			PROG_SIZE  : natural := 20
		);
		port(
			--System Control Inputs
			CLK_I : in  STD_LOGIC;
			RST_I : in  STD_LOGIC;
			--Wishbone Slave Lines (inverted)
			DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
			STB_I : in  STD_LOGIC;
			WE_I  : in  STD_LOGIC;
			ACK_O : out STD_LOGIC
		);
	end component;

	COMPONENT inst_mem
		PORT(
			clka  : IN  STD_LOGIC;
			addra : IN  STD_LOGIC_VECTOR(8 DOWNTO 0);
			douta : OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
		);
	END COMPONENT;

begin
	bus_logic : wb_m
		generic map(
			DATA_WIDTH => DATA_WIDTH,
			ADDR_WIDTH => ADDR_WIDTH
		)
		port map(
			--System Control Inputs
			--			CLK_I => CLK_I,
			--			RST_I => RST_I,
			--Master to WB
			WB_MS  => WB_O,
			WB_SM  => WB_I,
			--Wishbone Master Lines (inverted)
			DAT_I => dat_i,
			DAT_O => dat_o,
			ADR_O => adr_o,
			STB_O => stb_o,
			WE_O  => we_o,
			CYC_O => cyc_o,
			ACK_I => ack_i
		);

	prog_counter : program_counter
		generic map(
			DATA_WIDTH => 9,
			PROG_SIZE  => 512
		)
		port map(
			--System Control Inputs
			CLK_I => CLK_I,
			RST_I => RST_I,
			--Wishbone Slave Lines
			DAT_I => dat(8 downto 0),
			DAT_O => pc,
			WE_I  => branch_en,
			STB_I => pc_en,
			ACK_O => pc_ack_i
		);

	instruction_mem : inst_mem
		PORT MAP(
			clka  => clk_I_n,
			addra => pc,
			douta => instruction
		);

	process(CLK_I)
	begin
		--Perform Rising Edge operations
		if (rising_edge(CLK_I)) then
			if (RST_I = '1') then
				dat_o <= (others => '0');
				adr_o <= (others => '0');
				stb_o <= '0';
				we_o  <= '0';
				cyc_o <= '0';
				accum <= (others => '0');
				pc_en <= '1';

			else
				-- Check if bus is idle
				if (stb_o = '0') then
					if (wait_en = '1') then
						if (wait_cntr = 0) then
							wait_en <= '0';
						else
							wait_cntr <= wait_cntr - 1;
						end if;
					-- Perform Instruction if valid
					elsif (pc_en = '0') then
						if (accum_en = '1') then
							dat_o <= accum;
						else
							dat_o <= dat;
						end if;
						adr_o <= adr;
						stb_o <= bus_en;
						cyc_o <= bus_en;
						we_o  <= write_en;
						pc_en <= '1';   -- Request new instruction
					end if;

				elsif (ack_i = '1') then
					if (we_o = '0') then
						accum <= dat_i;
					end if;
					stb_o <= '0';       -- Conclude bus transfer
					cyc_o <= '0';
				end if;

				if (pc_ack_i = '1') then
					dat       <= instruction(DATA_WIDTH - 1 downto 0);
					adr       <= instruction(ADDR_WIDTH + DATA_WIDTH - 1 downto DATA_WIDTH);
					wait_cntr <= unsigned(instruction(ADDR_WIDTH + DATA_WIDTH - 1 downto 0));
					bus_en    <= instruction(ADDR_WIDTH + DATA_WIDTH) or instruction(ADDR_WIDTH + DATA_WIDTH + 1);
					write_en  <= instruction(ADDR_WIDTH + DATA_WIDTH);
					accum_en  <= instruction(ADDR_WIDTH + DATA_WIDTH + 1);
					branch_en <= instruction(ADDR_WIDTH + DATA_WIDTH + 2);
					wait_en   <= instruction(ADDR_WIDTH + DATA_WIDTH + 3);
					pc_en     <= '0';
				end if;

			end if;
		end if;
	end process;

end Behavioral;

