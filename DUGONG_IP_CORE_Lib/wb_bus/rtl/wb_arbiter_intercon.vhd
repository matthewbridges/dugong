---------------------------------------------------------------------------------------------------------------
--                    
--______/\\\\\\\\\_______/\\\________/\\\____/\\\\\\\\\\\____/\\\\\_____/\\\_________/\\\\\_________     
--\ ____/\\\///////\\\____\/\\\_______\/\\\___\/////\\\///____\/\\\\\\___\/\\\_______/\\\///\\\_____\
-- \ ___\/\\\_____\/\\\____\/\\\_______\/\\\_______\/\\\_______\/\\\/\\\__\/\\\_____/\\\/__\///\\\___\    
--  \ ___\/\\\\\\\\\\\/_____\/\\\\\\\\\\\\\\\_______\/\\\_______\/\\\//\\\_\/\\\____/\\\______\//\\\__\   
--   \ ___\/\\\//////\\\_____\/\\\/////////\\\_______\/\\\_______\/\\\\//\\\\/\\\___\/\\\_______\/\\\__\  
--    \ ___\/\\\____\//\\\____\/\\\_______\/\\\_______\/\\\_______\/\\\_\//\\\/\\\___\//\\\______/\\\___\
--     \ ___\/\\\_____\//\\\___\/\\\_______\/\\\_______\/\\\_______\/\\\__\//\\\\\\____\///\\\__/\\\_____\
--      \ ___\/\\\______\//\\\__\/\\\_______\/\\\____/\\\\\\\\\\\___\/\\\___\//\\\\\______\///\\\\\/______\
--       \ ___\///________\///___\///________\///____\///////////____\///_____\/////_________\/////________\
--        \___________________________________________\          \__________________________________________\
--        |:-------------------------------------------|: DUGONG :|-----------------------------------------:|
--       / ===========================================/          /========================================= /
--      / ================================================================================================ /
--     / =================  Reconfigurable Hardware Interface for computatioN and radiO  ================ /
--    / ================================  http://www.rhinoplatform.org  ================================ /
--   / ================================================================================================ /
--
---------------------------------------------------------------------------------------------------------------
-- Company:		UNIVERSITY OF CAPE TOWN
-- Engineer: 		MATTHEW BRIDGES
--
-- Name:		WB_ARBITER_INTERCON (004)
-- Type:		PRIMITIVE (2)
-- Description:		
--
-- Compliance:		DUGONG V1.4
-- ID:			x 1-4-2-004
---------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.ALL;

library DUGONG_IP_CORE_Lib;
use DUGONG_IP_CORE_Lib.dcores.ALL;
use DUGONG_IP_CORE_Lib.dprimitives.ALL;

--NB The DATA_WIDTH and ADDR_WIDTH constants are set in the dprimitives package
entity wb_arbiter_intercon is
	generic(
		NUMBER_OF_MASTERS : NATURAL := 2;
		NUMBER_OF_SLAVES  : NATURAL := 4
	);
	port(
		--System Control Inputs
		CLK_I     : in  STD_LOGIC;
		RST_I     : in  STD_LOGIC;
		--Masters to WB
		WB_MS     : in  WB_MS_vector(NUMBER_OF_MASTERS - 1 downto 0);
		WB_MS_BUS : out WB_MS_type;
		--Slaves to WB
		WB_SM     : in  WB_SM_vector(NUMBER_OF_SLAVES - 1 downto 0);
		WB_SM_BUS : out WB_SM_type;
		--Master Arbitration
		WB_GNT_O  : out STD_LOGIC_VECTOR(NUMBER_OF_MASTERS - 1 downto 0)
	);
end wb_arbiter_intercon;

architecture Behavioral of wb_arbiter_intercon is
	signal wb_cyc     : std_logic_vector(NUMBER_OF_MASTERS - 1 downto 0);
	signal master_sel : natural;
	signal bus_busy   : std_logic;

begin
	wb_cyc   <= WB_MS(0)(2 + ADDR_WIDTH + DATA_WIDTH) & WB_MS(1)(2 + ADDR_WIDTH + DATA_WIDTH);
	bus_busy <= wb_cyc(0) or wb_cyc(1);

	process(CLK_I)
	begin
		--Perform Rising Edge operations
		if (rising_edge(CLK_I)) then
			if (RST_I = '1') then
				WB_GNT_O   <= (others => '0');
				master_sel <= 0;
			else
				if (bus_busy = '1') then
				else
					case (wb_cyc) is
						when "01" => master_sel <= 0;
							WB_GNT_O          <= "01";
						when "10" => master_sel   <= 1;
							WB_GNT_O          <= "10";
						when "11" => master_sel   <= 0;
							WB_GNT_O          <= "01";
						when others => master_sel <= NUMBER_OF_MASTERS;
							WB_GNT_O          <= "00";
					end case;
				end if;
			end if;
		end if;
	end process;

	WB_MS_BUS <= WB_MS(master_sel) when (master_sel /= NUMBER_OF_MASTERS) else (others => '0');

	WB_SM_BUS <= WB_SM(0) or WB_SM(1) or WB_SM(2) or WB_SM(3);

end Behavioral;