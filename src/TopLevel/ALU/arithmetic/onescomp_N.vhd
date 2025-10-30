-- onescomp_N.vhd

library ieee;

use ieee.std_logic_1164.all;

entity onescomp_N is

  generic ( N : integer := 32 );  

  port(

    i_X : in  std_logic_vector(N-1 downto 0);

    o_Y : out std_logic_vector(N-1 downto 0)

  );

end entity;

architecture structural of onescomp_N is


  component invg

    port(

      i_A : in  std_logic;

      o_F : out std_logic

    );

  end component;

begin

 

  gen_inv: for k in 0 to N-1 generate

    U_INV: invg port map(i_A => i_X(k), o_F => o_Y(k));

  end generate;

end architecture;