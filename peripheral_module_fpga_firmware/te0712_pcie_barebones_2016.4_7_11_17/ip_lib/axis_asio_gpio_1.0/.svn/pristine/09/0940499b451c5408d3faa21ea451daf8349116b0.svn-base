----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.10.2014 18:59:57
-- Design Name: 
-- Module Name: asio_widemux - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity asio_widemux is
	generic (
    -- Users to add parameters here
    C_WIDTH : integer range 1 to 2048    := 32;
    C_SEL_BITS    : integer    := 8
);

    Port ( din : in STD_LOGIC_VECTOR(C_WIDTH-1 downto 0);
           sel : in STD_LOGIC_VECTOR(C_SEL_BITS-1 downto 0);
           q : out STD_LOGIC);
end asio_widemux;

architecture Behavioral of asio_widemux is

signal sel_integer : integer;
signal sel_unsigned : unsigned(C_SEL_BITS-1 downto 0);

begin
    sel_unsigned <= unsigned(sel);
    sel_integer <= conv_integer(sel_unsigned); 
    q <= din(sel_integer);

end Behavioral;
