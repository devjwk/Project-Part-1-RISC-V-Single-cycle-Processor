library ieee;

use ieee.std_logic_1164.all;

entity full_adder_1bit is

  port(

    A, B, Cin : in  std_logic;

    Sum, Cout : out std_logic

  );

end entity;

architecture structural of full_adder_1bit is

  component xorg2 port(i_A, i_B: in std_logic; o_F: out std_logic); end component;

  component andg2 port(i_A, i_B: in std_logic; o_F: out std_logic); end component;

  component org2  port(i_A, i_B: in std_logic; o_F: out std_logic); end component;

  signal X1, P1, P2, P3, T1 : std_logic;

begin

  -- Sum

  Ux1: xorg2 port map(A, B, X1);

  Us : xorg2 port map(X1, Cin, Sum);

  -- Cout

  Ua1: andg2 port map(A, B,   P1);

  Ua2: andg2 port map(B, Cin, P2);

  Ua3: andg2 port map(A, Cin, P3);

  Uo1: org2  port map(P1, P2, T1);

  Uo2: org2  port map(T1, P3, Cout);

end architecture;