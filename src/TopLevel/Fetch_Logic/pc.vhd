library IEEE;
use IEEE.std_logic_1164.all;

-- Simple PC register with async reset to 0
entity pc is
  port (
    i_CLK : in  std_logic;
    i_RST : in  std_logic;
    i_D   : in  std_logic_vector(31 downto 0);
    o_Q   : out std_logic_vector(31 downto 0)
  );
end entity;

architecture behavioral of pc is
  signal s_q : std_logic_vector(31 downto 0);
begin
  process(i_CLK, i_RST)
  begin
    if i_RST = '1' then
      s_q <= (others => '0');
    elsif rising_edge(i_CLK) then
      s_q <= i_D;
    end if;
  end process;

  o_Q <= s_q;
end architecture;