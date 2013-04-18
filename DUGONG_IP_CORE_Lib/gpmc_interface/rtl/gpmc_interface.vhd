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
		DATA_WIDTH : natural := 16;
		ADDR_WIDTH : natural := 10
	);
	port(
		--System Control Inputs
		CLK_I : in  STD_LOGIC;
		RST_I : in  STD_LOGIC;
		--Wishbone Slave Lines
		DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		ADR_I : in  STD_LOGIC_VECTOR(ADDR_WIDTH - 1 downto 0);
		STB_I : in  STD_LOGIC;
		WE_I  : in  STD_LOGIC;
		--CYC_I : in   STD_LOGIC;
		ACK_O : out STD_LOGIC
	);
end gpmc_interface;

architecture Behavioral of gpmc_interface is
	signal we : std_logic_vector(0 downto 0);

	component gpmc_bram
		port(clka  : IN  STD_LOGIC;
			 ena   : IN  STD_LOGIC;
			 wea   : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
			 addra : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
			 dina  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 douta : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
	end component gpmc_bram;

begin
	inst : gpmc_bram
		port map(
			clka  => CLK_I,
			ena   => STB_I,
			wea   => we,
			addra => ADR_I,
			dina  => DAT_I,
			douta => DAT_O
		);

	--For code syntactics
	we(0) <= WE_I;

	ACK_O <= STB_I;

end Behavioral;
	