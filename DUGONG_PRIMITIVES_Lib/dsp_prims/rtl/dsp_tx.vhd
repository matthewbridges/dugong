--
-- _______/\\\\\\\\\_______/\\\________/\\\____/\\\\\\\\\\\____/\\\\\_____/\\\_________/\\\\\________
-- \ ____/\\\///////\\\____\/\\\_______\/\\\___\/////\\\///____\/\\\\\\___\/\\\_______/\\\///\\\_____\
--  \ ___\/\\\_____\/\\\____\/\\\_______\/\\\_______\/\\\_______\/\\\/\\\__\/\\\_____/\\\/__\///\\\___\
--   \ ___\/\\\\\\\\\\\/_____\/\\\\\\\\\\\\\\\_______\/\\\_______\/\\\//\\\_\/\\\____/\\\______\//\\\__\
--    \ ___\/\\\//////\\\_____\/\\\/////////\\\_______\/\\\_______\/\\\\//\\\\/\\\___\/\\\_______\/\\\__\
--     \ ___\/\\\____\//\\\____\/\\\_______\/\\\_______\/\\\_______\/\\\_\//\\\/\\\___\//\\\______/\\\___\
--      \ ___\/\\\_____\//\\\___\/\\\_______\/\\\_______\/\\\_______\/\\\__\//\\\\\\____\///\\\__/\\\_____\
--       \ ___\/\\\______\//\\\__\/\\\_______\/\\\____/\\\\\\\\\\\___\/\\\___\//\\\\\______\///\\\\\/______\
--        \ ___\///________\///___\///________\///____\///////////____\///_____\/////_________\/////________\
--         \ __________________________________________\          \__________________________________________\
--          |:------------------------------------------|: DUGONG :|-----------------------------------------:|
--         / ==========================================/          /========================================= /
--        / =============================================================================================== /
--       / ================  Reconfigurable Hardware Interface for computatioN and radiO  ================ /
--      / ===============================  http://www.rhinoplatform.org  ================================ /
--     / =============================================================================================== /
--
---------------------------------------------------------------------------------------------------------------
-- Company:		UNIVERSITY OF CAPE TOWN
-- Engineer: 		MATTHEW BRIDGES
--
-- Name:		
-- Type:		
-- Description:		
--
-- Compliance:		DUGONG V0.5
-- ID:			x 0-5-
--
-- Last Modified:	21-NOV-2013
-- Modified By:		MATTHEW BRIDGES
---------------------------------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity dsp_tx is
	generic(
		DATA_WIDTH        : natural := 16;
		NUMBER_OF_SAMPLES : natural := 4
	);
	port(
		--System Control Inputs
		RST_I         : in  STD_LOGIC;
		--DSP Packetizer Signals
		DSP_CLK_I     : in  STD_LOGIC;
		DSP_CLK_DIV_I : in  STD_LOGIC;
		DSP_SAMPLE_I  : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		DSP_PACKET_O  : out STD_LOGIC_VECTOR((DATA_WIDTH * NUMBER_OF_SAMPLES) - 1 downto 0)
	);
end entity dsp_tx;

architecture RTL of dsp_tx is
	type packet_type is array (0 to NUMBER_OF_SAMPLES) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal temp         : packet_type;
	signal packet       : packet_type;
	signal sample_count : unsigned(1 downto 0);

begin
	process(DSP_CLK_I)
	begin
		--Perform Clock Rising Edge operations
		if (rising_edge(DSP_CLK_I)) then
			if (RST_I = '1') then
				temp         <= (others => (others => '0'));
				sample_count <= (others => '0');
			else
				if (sample_count = 0) then
					packet <= temp;
				end if;
				temp(to_integer(sample_count)) <= DSP_SAMPLE_I;
				sample_count                   <= sample_count + 1;
			end if;
		end if;
	end process;

	--Generate Packet Registers
	packet_registers : for n in 0 to (NUMBER_OF_SAMPLES - 1) generate
	begin
		process(DSP_CLK_DIV_I)
		begin
			--Perform Clock Rising Edge operations
			if (rising_edge(DSP_CLK_DIV_I)) then
				if (RST_I = '1') then
					DSP_PACKET_O((n + 1) * DATA_WIDTH - 1 downto n * DATA_WIDTH) <= (others => '0');
				else
					DSP_PACKET_O((n + 1) * DATA_WIDTH - 1 downto n * DATA_WIDTH) <= packet(n);
				end if;
			end if;
		end process;

	end generate packet_registers;

end architecture RTL;
