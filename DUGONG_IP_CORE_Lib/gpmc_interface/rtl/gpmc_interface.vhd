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

--library DUGONG_IP_CORES;
--use DUGONG_IP_CORES.dcores.ALL;

entity gpmc_interface is
	generic(
		DATA_WIDTH : natural := 32;
		ADDR_WIDTH : natural := 10
	);
	port(
		--System Control Inputs
		CLK_I         : in    STD_LOGIC;
		RST_I         : in    STD_LOGIC;
		--Wishbone Slave Lines
		DAT_I         : in    STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DAT_O         : out   STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		ADR_I         : in    STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		STB_I         : in    STD_LOGIC;
		WE_I          : in    STD_LOGIC;
		--CYC_I : in   STD_LOGIC;
		ACK_O         : out   STD_LOGIC;
		--GPMC Interface
		GPMC_CLK      : in    STD_LOGIC;
		GPMC_D        : inout STD_LOGIC_VECTOR(15 downto 0);
		--		GPMC_A        : in    STD_LOGIC_VECTOR(10 downto 1);
		GPMC_nCS      : in    STD_LOGIC;
		GPMC_nWE      : in    STD_LOGIC;
		GPMC_nOE      : in    STD_LOGIC;
		GPMC_nADV_ALE : in    STD_LOGIC
	);
end gpmc_interface;

architecture Behavioral of gpmc_interface is
	signal gpmc_dout : std_logic_vector(15 downto 0);
	signal gpmc_addr : std_logic_vector(10 downto 0); --(25 downto 0);

	signal ena : std_logic;
	signal enb : std_logic;

	signal wea : std_logic_vector(0 downto 0);
	signal web : std_logic_vector(0 downto 0);

	component gpmc_bram
		port(
			clka  : IN  STD_LOGIC;
			rsta  : IN  STD_LOGIC;
			ena   : IN  STD_LOGIC;
			wea   : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
			addra : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
			dina  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			clkb  : IN  STD_LOGIC;
			enb   : IN  STD_LOGIC;
			web   : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
			addrb : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
			dinb  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			doutb : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
		);
	end component gpmc_bram;
begin
	--For code syntactics
	wea(0) <= WE_I;
	web(0) <= not GPMC_nWE;

	process(CLK_I)
	begin
		--Perform Clock Rising Edge operations
		if (rising_edge(CLK_I)) then
			--Check for reset
			if (RST_I = '1') then
				ena <= '0';
			elsif (GPMC_nCS = '0') then
				ena <= '0';
			else
				ena <= STB_I;
			end if;
		end if;
	end process;

	ACK_O <= ena;

	process(GPMC_CLK)
	begin
		--Perform Clock Rising Edge operations
		if (rising_edge(GPMC_CLK)) then
			--First cycle of the bus transaction record the address
			if (GPMC_nADV_ALE = '0') then
				gpmc_addr <= GPMC_D(10 downto 0); --GPMC_A & GPMC_D; -- Address of 16 bit word
			end if;
		end if;
	end process;

	enb <= not (GPMC_nCS and GPMC_nOE);

	inst : gpmc_bram
		port map(
			clka  => CLK_I,
			rsta  => RST_I,
			ena   => ena,
			wea   => wea,
			addra => ADR_I,
			dina  => DAT_I,
			douta => DAT_O,
			clkb  => GPMC_CLK,
			enb   => enb,
			web   => web,
			addrb => gpmc_addr(10 downto 0),
			dinb  => GPMC_D,
			doutb => gpmc_dout
		);

	--GPMC tri-state buffers for GPMC Bidirectional Data Bus
	GPMC_D <= gpmc_dout when GPMC_nOE = '1' else (others => 'Z');
end Behavioral;
	