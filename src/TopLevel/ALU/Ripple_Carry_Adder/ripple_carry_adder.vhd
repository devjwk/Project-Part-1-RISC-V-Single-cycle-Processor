library IEEE;

use IEEE.std_logic_1164.all;

entity ripple_carry_adder is

  generic(

    N : integer := 32  

  );

  port(

    A, B  : in  std_logic_vector(N-1 downto 0);

    Cin   : in  std_logic;

    Sum   : out std_logic_vector(N-1 downto 0);

    Cout  : out std_logic

  );

end entity ripple_carry_adder;

architecture structural of ripple_carry_adder is

  

  component full_adder_1bit is

    port(

      A, B, Cin : in  std_logic;

      Sum, Cout : out std_logic

    );

  end component;

  

  signal carry : std_logic_vector(N downto 0);

begin

  

  carry(0) <= Cin;

  

  gen_adders: for i in 0 to N-1 generate

    FA: full_adder_1bit

      port map(

        A    => A(i),

        B    => B(i),

        Cin  => carry(i),

        Sum  => Sum(i),

        Cout => carry(i+1)

      );

  end generate;

  

  Cout <= carry(N);

end architecture structural;