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
-- Name:		WB_FIFO (010)
-- Type:		PRIMITIVE (2)
-- Description:		A FIFO primitive with one read port and one write port which
--			can take on generic data widths.
--
-- Compliance:		DUGONG V0.3
-- ID:			x 0-3-2-00A
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity wb_fifo is
	generic(
		DATA_WIDTH : NATURAL := 32;
		ADDR_WIDTH : NATURAL := 4       --FIFO DEPTH = ADDR_WIDTH^2
	);
	port(
		--System Control Inputs:
		RST_I    : in  STD_LOGIC;
		--WRITE PORT
		WR_CLK_I : in  STD_LOGIC;
		WR_DAT_I : in  STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		WR_WE_I  : in  std_logic;
		WR_STB_I : in  STD_LOGIC;
		WR_ACK_O : out STD_LOGIC;
		--READ PORT
		RD_CLK_I : in  STD_LOGIC;
		RD_DAT_O : out STD_LOGIC_VECTOR(DATA_WIDTH - 1 downto 0);
		RD_STB_I : in  STD_LOGIC;
		RD_ACK_O : out STD_LOGIC;
		--STATUS SIGNALS
		FULL     : out STD_LOGIC;
		EMPTY    : out STD_LOGIC
	);
end wb_fifo;

architecture Behavioral of wb_fifo is
	-- Shared memory
	type ram_type is array (0 to (2 ** ADDR_WIDTH) - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal mem : ram_type;

	signal wr_ack : std_logic;
	signal rd_Q   : std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal rd_ack : std_logic;

	subtype fifo_ptr_type is unsigned(ADDR_WIDTH downto 0);
	signal WR_ptr : fifo_ptr_type := (others => '0');
	signal RD_ptr : fifo_ptr_type := (others => '0');

	signal collision_flag : std_logic;
	signal full_flag      : std_logic;
	signal empty_flag     : std_logic;

begin

	--WRITE Port
	process(WR_CLK_I, RST_I, WR_STB_I)
	begin
		--RESET STATE
		if (RST_I = '1') then
			WR_ptr <= (others => '0');
			wr_ack <= '0';
		else
			if (WR_STB_I = '0') then
				wr_ack <= '0';
			else
				--Perform Clock Rising Edge operations
				if (rising_edge(WR_CLK_I)) then
					if (wr_ack = '0') then
						if (full_flag = '0') then
							--WRITING STATE
							if ((WR_STB_I and WR_WE_I) = '1') then
								mem(to_integer(WR_ptr(ADDR_WIDTH - 1 downto 0))) <= WR_DAT_I;
								WR_ptr                                           <= WR_ptr + 1;
							end if;
						end if;
						wr_ack <= WR_STB_I;
					end if;
				end if;
			end if;
		end if;
	end process;

	WR_ACK_O <= wr_ack;

	--READ Port
	process(RD_CLK_I, RST_I, RD_STB_I)
	begin
		--RESET STATE
		if (RST_I = '1') then
			RD_ptr <= (others => '0');
			rd_ack <= '0';
		else
			if (RD_STB_I = '0') then
				rd_ack <= '0';
			else
				--Perform Clock Rising Edge operations
				if (rising_edge(RD_CLK_I)) then
					if (rd_ack = '0') then
						if (empty_flag = '0') then
							rd_Q <= mem(to_integer(RD_ptr(ADDR_WIDTH - 1 downto 0)));
							--READING STATE
							if (RD_STB_I = '1') then
								RD_ptr <= RD_ptr + 1;
							end if;
						end if;
						rd_ack <= RD_STB_I;
					end if;
				end if;
			end if;
		end if;
	end process;

	RD_DAT_O <= rd_Q;
	RD_ACK_O <= rd_ack;

	collision_flag <= '1' when (RD_ptr(ADDR_WIDTH - 1 downto 0) = WR_ptr(ADDR_WIDTH - 1 downto 0)) else '0';
	empty_flag     <= collision_flag when (RD_ptr(ADDR_WIDTH) = WR_ptr(ADDR_WIDTH)) else '0';
	full_flag      <= collision_flag when (RD_ptr(ADDR_WIDTH) /= WR_ptr(ADDR_WIDTH)) else '0';

	FULL  <= full_flag;
	EMPTY <= empty_flag;

end Behavioral;