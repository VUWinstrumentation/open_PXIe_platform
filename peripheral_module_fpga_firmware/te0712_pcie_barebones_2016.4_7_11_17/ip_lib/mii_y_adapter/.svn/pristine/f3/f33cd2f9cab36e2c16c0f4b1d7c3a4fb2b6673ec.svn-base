-------------------------------------------------------------------------------
-- Company: 		Trenz Electronic
-- Engineer: 		Oleksandr Kiyenko
-------------------------------------------------------------------------------
library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
-------------------------------------------------------------------------------
entity mii_y_adapater is
port (
	-- Slave Interface
	s_mii_col					: out STD_LOGIC;
	s_mii_crs					: out STD_LOGIC;
	s_mii_rx_clk				: out STD_LOGIC;
	s_mii_rx_dv					: out STD_LOGIC;
	s_mii_rx_er					: out STD_LOGIC;
	s_mii_rxd					: out STD_LOGIC_VECTOR(3 downto 0);
	s_mii_tx_clk				: out STD_LOGIC;
	s_mii_tx_en					: in  STD_LOGIC;
	s_mii_tx_er					: in  STD_LOGIC;
	s_mii_txd					: in  STD_LOGIC_VECTOR(3 downto 0);
	s_mii_rst_n					: in  STD_LOGIC;
	-- Master Interface
	m_mii_col					: in  STD_LOGIC;
	m_mii_crs					: in  STD_LOGIC;
	m_mii_rx_clk				: in  STD_LOGIC;
	m_mii_rx_dv					: in  STD_LOGIC;
	m_mii_rx_er					: in  STD_LOGIC;
	m_mii_rxd					: in  STD_LOGIC_VECTOR(3 downto 0);
	m_mii_tx_clk				: in  STD_LOGIC;
	m_mii_tx_en					: out STD_LOGIC;
	m_mii_tx_er					: out STD_LOGIC;
	m_mii_txd					: out STD_LOGIC_VECTOR(3 downto 0);
	m_mii_rst_n					: out STD_LOGIC;
	-- Reset out
	phy_rst_n					: out STD_LOGIC
);
end mii_y_adapater;
-------------------------------------------------------------------------------
architecture rtl of mii_y_adapater is
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
begin
-------------------------------------------------------------------------------
s_mii_col		<= m_mii_col;
s_mii_crs		<= m_mii_crs;
s_mii_rx_clk	<= m_mii_rx_clk;
s_mii_rx_dv		<= m_mii_rx_dv;
s_mii_rx_er		<= m_mii_rx_er;
s_mii_rxd		<= m_mii_rxd;
s_mii_tx_clk	<= m_mii_tx_clk;
m_mii_tx_en		<= s_mii_tx_en;
m_mii_tx_er		<= s_mii_tx_er;
m_mii_txd		<= s_mii_txd;
m_mii_rst_n		<= s_mii_rst_n;

phy_rst_n		<= s_mii_rst_n;
-------------------------------------------------------------------------------
end rtl;
