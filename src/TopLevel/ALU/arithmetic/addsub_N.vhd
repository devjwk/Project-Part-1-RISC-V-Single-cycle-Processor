library ieee;

use ieee.std_logic_1164.all;

entity addsub_N is

  generic ( N : integer := 32 );

  port (

    A        : in  std_logic_vector(N-1 downto 0);

    B        : in  std_logic_vector(N-1 downto 0);

    nAdd_Sub : in  std_logic;                       -- 0: A+B, 1: A-B

    Sum      : out std_logic_vector(N-1 downto 0);

    Cout     : out std_logic

  );

end entity addsub_N;

architecture structural of addsub_N is

  --------------------------------------------------------------------

  -- Reuse your existing blocks as-is (interfaces must match yours!)

  --------------------------------------------------------------------

  component onescomp_N is

    generic ( N : integer := 32 );

    port(

      i_X : in  std_logic_vector(N-1 downto 0);

      o_Y : out std_logic_vector(N-1 downto 0)

    );

  end component;

  component mux2t1_N is

    generic ( N : integer := 32 );

    port(

      S   : in  std_logic;                               

      D0  : in  std_logic_vector(N-1 downto 0);

      D1  : in  std_logic_vector(N-1 downto 0);

      O   : out std_logic_vector(N-1 downto 0)

    );

  end component;

  component ripple_carry_adder is

    generic ( N : integer := 32 );

    port(

      A, B  : in  std_logic_vector(N-1 downto 0);

      Cin   : in  std_logic;

      Sum   : out std_logic_vector(N-1 downto 0);

      Cout  : out std_logic

    );

  end component;

  -- internal signals

  signal B_not : std_logic_vector(N-1 downto 0);

  signal B_sel : std_logic_vector(N-1 downto 0);

begin

  --------------------------------------------------------------------

  -- 1) ~B (ones complementation)

  --------------------------------------------------------------------

  U_INV: onescomp_N

    generic map ( N => N )

    port map (

      i_X => B,

      o_Y => B_not

    );

  --------------------------------------------------------------------

  -- 2) nAdd_Sub --> choose B'  (add: B, sub: ~B)

  --------------------------------------------------------------------

  U_MUX: mux2t1_N

    generic map ( N => N )

    port map (

      S  => nAdd_Sub,   

      D0 => B,          -- nAdd_Sub=0 → D0  → B

      D1 => B_not,      -- nAdd_Sub=1 → D1 → ~B

      O  => B_sel

    );

  --------------------------------------------------------------------

  -- 3) A + B_sel + Cin(nAdd_Sub)  →> Sum, Cout

  --------------------------------------------------------------------

  U_ADD: ripple_carry_adder

    generic map ( N => N )

    port map (

      A    => A,

      B    => B_sel,

      Cin  => nAdd_Sub,   -- add:0, sub:1 (+1)

      Sum  => Sum,

      Cout => Cout

    );

end architecture structural;