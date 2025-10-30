library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Generic N-bit adder (unsigned addition)
entity adder is
  generic (N : integer := 32);
  port (
    A   : in  std_logic_vector(N-1 downto 0);
    B   : in  std_logic_vector(N-1 downto 0);
    SUM : out std_logic_vector(N-1 downto 0)
  );
end entity;

architecture behavioral of adder is
begin
  SUM <= std_logic_vector(unsigned(A) + unsigned(B));
end architecture;