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

library DUGONG_PRIMITIVES_Lib;
use DUGONG_PRIMITIVES_Lib.dprimitives.ALL;

entity ads62p49_phy is
	generic(
		C_M_AXIS_TDATA_WIDTH : integer := 14
	);
	port(
		--System Control Inputs
		RST_I          : in  STD_LOGIC;
		-- Global ports
		AXIS_ACLK      : in  std_logic;
		AXIS_ARESETN   : in  std_logic;
		-- Master Stream Ports.
		M0_AXIS_TVALID : out std_logic;
		M0_AXIS_TDATA  : out std_logic_vector(C_M_AXIS_TDATA_WIDTH - 1 downto 0);
		M1_AXIS_TVALID : out std_logic;
		M1_AXIS_TDATA  : out std_logic_vector(C_M_AXIS_TDATA_WIDTH - 1 downto 0);
		-- FMC150 ADC interface
		ADC_DCLK_P     : in  STD_LOGIC;
		ADC_DCLK_N     : in  STD_LOGIC;
		ADC_DATA_A_P   : in  STD_LOGIC_VECTOR(6 downto 0);
		ADC_DATA_A_N   : in  STD_LOGIC_VECTOR(6 downto 0);
		ADC_DATA_B_P   : in  STD_LOGIC_VECTOR(6 downto 0);
		ADC_DATA_B_N   : in  STD_LOGIC_VECTOR(6 downto 0)
	);
end entity ads62p49_phy;

architecture RTL of ads62p49_phy is
	signal adc_clk : std_logic;

	signal adc_ch_a : std_logic_vector(13 downto 0);
	signal adc_ch_b : std_logic_vector(13 downto 0);

	signal fifo_wr_data : std_logic_vector(27 downto 0);
	signal fifo_rd_data : std_logic_vector(27 downto 0);

	signal fifo_wr_en_sr : std_logic_vector(3 downto 0) := (others => '0');

	signal fifo_wr_en    : std_logic                    := '0';
	signal fifo_rd_en    : std_logic                    := '0';
	signal fifo_empty    : std_logic;
	signal fifo_empty_sr : std_logic_vector(3 downto 0) := (others => '1');

	component ads62p49_parallelizer is
		port(
			--System Control Inputs
			RST_I        : in  STD_LOGIC;
			--Signal Channel Inputs
			ADC_CLK_O    : out STD_LOGIC;
			CH_A_O       : out STD_LOGIC_VECTOR(13 downto 0);
			CH_B_O       : out STD_LOGIC_VECTOR(13 downto 0);
			-- FMC150 ADC interface
			ADC_DCLK_P   : in  STD_LOGIC;
			ADC_DCLK_N   : in  STD_LOGIC;
			ADC_DATA_A_P : in  STD_LOGIC_VECTOR(6 downto 0);
			ADC_DATA_A_N : in  STD_LOGIC_VECTOR(6 downto 0);
			ADC_DATA_B_P : in  STD_LOGIC_VECTOR(6 downto 0);
			ADC_DATA_B_N : in  STD_LOGIC_VECTOR(6 downto 0)
		);
	end component;

begin
	adc_external_interface : ads62p49_parallelizer
		port map(
			RST_I        => RST_I,
			ADC_CLK_O    => adc_clk,
			CH_A_O       => adc_ch_a,
			CH_B_O       => adc_ch_b,
			ADC_DCLK_P   => ADC_DCLK_P,
			ADC_DCLK_N   => ADC_DCLK_N,
			ADC_DATA_A_P => ADC_DATA_A_P,
			ADC_DATA_A_N => ADC_DATA_A_N,
			ADC_DATA_B_P => ADC_DATA_B_P,
			ADC_DATA_B_N => ADC_DATA_B_N
		);

	WR_EN_SHIFT_proc : process(adc_clk) is
	begin
		if rising_edge(adc_clk) then
			fifo_wr_en_sr(0)          <= not AXIS_ARESETN;
			fifo_wr_en_sr(3 downto 1) <= fifo_wr_en_sr(2 downto 0);
			fifo_wr_en                <= fifo_wr_en_sr(3);
		end if;
	end process WR_EN_SHIFT_proc;

	fifo_wr_data <= adc_ch_b & adc_ch_a;

	fifo : fifo_sync
		generic map(
			DATA_WIDTH => 28,
			FIFO_DEPTH => 32
		)
		port map(
			RST_I    => AXIS_ARESETN,
			WR_CLK_I => adc_clk,
			WR_DAT_I => fifo_wr_data,
			WR_EN_I  => fifo_wr_en,
			RD_CLK_I => AXIS_ACLK,
			RD_DAT_O => fifo_rd_data,
			RD_EN_I  => fifo_rd_en,
			FULL     => open,
			EMPTY    => fifo_empty_sr(0)
		);

	FIFO_CTRL_proc : process(AXIS_ARESETN, AXIS_ACLK) is
	begin
		if AXIS_ARESETN = '1' then
			fifo_rd_en                <= '0';
			fifo_empty_sr(2 downto 1) <= (others => '1');
		else
			if rising_edge(AXIS_ACLK) then
				if (fifo_empty_sr(3 downto 1) = "000") then
					fifo_rd_en <= '1';
				else
					fifo_rd_en <= '0';
				end if;

				fifo_empty_sr(3 downto 1) <= fifo_empty_sr(2 downto 0);
			end if;

		end if;
	end process FIFO_CTRL_proc;

	name : process(AXIS_ACLK) is
	begin
		if rising_edge(AXIS_ACLK) then
			if AXIS_ARESETN = '1' then
				M0_AXIS_TVALID <= '0';
				M1_AXIS_TVALID <= '0';
			else
				M0_AXIS_TVALID <= fifo_rd_en;
				M1_AXIS_TVALID <= fifo_rd_en;
			end if;
			M0_AXIS_TDATA <= fifo_rd_data(C_M_AXIS_TDATA_WIDTH - 1 downto 0);
			M1_AXIS_TDATA <= fifo_rd_data(2 * C_M_AXIS_TDATA_WIDTH - 1 downto C_M_AXIS_TDATA_WIDTH);
		end if;
	end process name;

end architecture RTL;
