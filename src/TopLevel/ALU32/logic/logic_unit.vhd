library IEEE;
use IEEE.std_logic_1164.all;

entity logic_unit is
  port(
    A, B  : in  std_logic_vector(31 downto 0);
    Sel   : in  std_logic_vector(1 downto 0);  -- 00=AND, 01=OR, 10=XOR, 11=NOR
    Y     : out std_logic_vector(31 downto 0)
  );
end entity;

architecture structural of logic_unit is
begin
  process(A, B, Sel)
  begin
    case Sel is
      when "00" => Y <= A and B;
      when "01" => Y <= A or B;
      when "10" => Y <= A xor B;
      when others => Y <= not (A or B);
    end case;
  end process;
end architecture;