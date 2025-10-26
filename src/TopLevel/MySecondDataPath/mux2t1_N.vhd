library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mux2t1_N is
    generic (N : integer := 32);
    port( 
        S : in std_logic;
        D0,D1 : in std_logic_vector(N-1 downto 0);
        O : out std_logic_vector(N-1 downto 0)
    );
end mux2t1_N;

architecture dataflow of mux2t1_N is
    begin
        O <= D0 when S = '0' else D1;
end dataflow;