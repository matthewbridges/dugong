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
-- Name:		GPIO_CONTROLLER (002)
-- Type:		USER_LOGIC (5)
-- Description: 	Logic for controlling GPIO of differing widths. Includes an auxiliary interface
--			for streaming digital IO. This allows bypassing the WB Bus.
--
-- Compliance:		DUGONG V0.5
-- ID:			x 0-5-5-002
---------------------------------------------------------------------------------------------------------------

--  ( http://opencores.org/project,gpio ) was used for the design of this core

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity gpio is
	generic(
		GPIO_WIDTH : natural := 16
	);
	port(
		--Bus Logic Interface
		GPIO_OUT     : in    STD_LOGIC_VECTOR(GPIO_WIDTH - 1 downto 0);
		GPIO_IN      : out   STD_LOGIC_VECTOR(GPIO_WIDTH - 1 downto 0);
		OUTPUT_EN    : in    STD_LOGIC_VECTOR(GPIO_WIDTH - 1 downto 0);
		AUX_EN       : in    STD_LOGIC_VECTOR(GPIO_WIDTH - 1 downto 0);
		--GPIO Auxiliary Interface
		GPIO_AUX_IN  : out   STD_LOGIC_VECTOR(GPIO_WIDTH - 1 downto 0);
		GPIO_AUX_OUT : in    STD_LOGIC_VECTOR(GPIO_WIDTH - 1 downto 0);
		--GPIO Interface
		GPIO_B       : inout STD_LOGIC_VECTOR(GPIO_WIDTH - 1 downto 0)
	);
end gpio;

architecture Behavioral of gpio is
	signal gpio_o : std_logic_vector(GPIO_WIDTH - 1 downto 0);
	signal gpio_i : std_logic_vector(GPIO_WIDTH - 1 downto 0);

begin
	----------------------------------
	----------{ USER LOGIC }----------
	----------------------------------

	--Generate GPIO tri-state buffers and multiplexors for each GPIO pin
	gpio_control_buffers : for gpio_num in 0 to GPIO_WIDTH - 1 generate
		--Multiplexer for Auxiliary input
		gpio_o(gpio_num)      <= GPIO_AUX_OUT(gpio_num) when AUX_EN(gpio_num) = '1' else GPIO_OUT(gpio_num);
		--Auxiliary output only if Output Enable is false
		GPIO_AUX_IN(gpio_num) <= '0' when OUTPUT_EN(gpio_num) = '1' else gpio_i(gpio_num);

		--Tri-state Buffer
		GPIO_B(gpio_num) <= gpio_o(gpio_num) when OUTPUT_EN(gpio_num) = '1' else 'Z';
		gpio_i(gpio_num) <= GPIO_B(gpio_num);
	end generate gpio_control_buffers;

	GPIO_IN <= gpio_i;

end Behavioral;

