
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity led_test is
    Port ( clk : in STD_LOGIC;
           led : out STD_LOGIC);
end led_test;

architecture Behavioral of led_test is
    constant max_count : natural := 48000000;
    signal count : unsigned(32 downto 0) := (others => '0');
    signal rst : std_logic;
begin
    rst <= '0';
    
    compteur : process(clk,rst)
    begin
        if rst = '1' then
            count <= (others=>'0');
        elsif rising_edge(clk) then
            count <= count + 1;
        end if;
    end process compteur;
    
led <= STD_LOGIC(count(25));


end Behavioral;
