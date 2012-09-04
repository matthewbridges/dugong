----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:04:58 06/20/2012 
-- Design Name: 
-- Module Name:    bram_sync_sp - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

entity da2_controller is
	generic(
		DATA_WIDTH : natural := 12;
		ADDR_WIDTH : natural := 4
	);
	port(
		--System Control Inputs
		CLK_I   : in  STD_LOGIC;
		RST_I   : in  STD_LOGIC;
		--Wishbone Slave Lines
		DAT_I   : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DAT_O   : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		ADR_I   : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		STB_I   : in  STD_LOGIC;
		WE_I    : in  STD_LOGIC;
		--		CYC_I : in   STD_LOGIC;

		ACK_O   : out STD_LOGIC;
		--DA2 Pmod interface signals
		D1      : out std_logic;
		D2      : out std_logic;
		CLK_OUT : out std_logic;
		nSYNC   : out std_logic
	);
end da2_controller;

architecture Behavioral of da2_controller is
	component DA2RefComp is
		Port(
			--General usage
			CLK     : in  std_logic;    -- System Clock (50MHz)     
			RST     : in  std_logic;
			--Pmod interface signals
			D1      : out std_logic;
			D2      : out std_logic;
			CLK_OUT : out std_logic;
			nSYNC   : out std_logic;
			--User interface signals
			DATA1   : in  std_logic_vector(11 downto 0);
			DATA2   : in  std_logic_vector(11 downto 0);
			START   : in  std_logic;
			DONE    : out std_logic
		);
	end component;

	type ram_type is array (0 to (2 ** ADDR_WIDTH) - 9) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal user_mem   : ram_type;
	signal data_valid : boolean;

	signal dac_start : std_logic;
	signal dac_done  : std_logic;

begin
	DAC : DA2RefComp
		port map(
			--General usage
			CLK     => CLK_I,
			RST     => RST_I,
			--Pmod interface signals
			D1      => D1,
			D2      => D2,
			CLK_OUT => CLK_OUT,
			nSYNC   => nSYNC,
			--User interface signals
			DATA1   => user_mem(0),
			DATA2   => user_mem(1),
			START   => dac_start,
			DONE    => dac_done
		);

	process(CLK_I)
	begin
		--Perform Clock Rising Edge operations
		if (rising_edge(CLK_I)) then
			--Check for reset
			if (RST_I = '1') then
				DAT_O       <= (others => '0');
				ACK_O       <= '0';
				user_mem(0) <= (others => '0');
				user_mem(1) <= x"7FF";
				data_valid  <= false;
				dac_start   <= '0';
			elsif (data_valid) then
				if (dac_done = '1') then
					if (dac_start = '0') then
						data_valid <= false;
					end if;
				else
					dac_start <= '0';
				end if;
				ACK_O <= '0';
			else
				--Check for strobe	
				if (STB_I = '1') then
					DAT_O <= user_mem(to_integer(unsigned(ADR_I)) - 8);
					--Check for write
					if (WE_I = '1') then
						user_mem(to_integer(unsigned(ADR_I)) - 8) <= DAT_I;
						data_valid                                <= true;
						dac_start                                 <= '1';
					end if;
					ACK_O <= '1';
				end if;
			end if;
		end if;
	end process;

end Behavioral;

