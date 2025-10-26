library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mux2t1 is
    port(
        D0,D1 : in std_logic;
        S : in std_logic;
        O : out std_logic
    ); 
end mux2t1;

architecture structural of mux2t1 is
    component andg2
        port(
            i_A, i_B: in std_logic;
            o_F :out std_logic
        );
    end component;
    component org2
        port(
            i_A, i_B: in std_logic;
            o_F :out std_logic
        );
    end component;
    component invg
        port(
            i_A: in std_logic;
            o_F: out std_logic
        );
    end component;

    --internal signal
    signal nsel, S1,S2 : std_logic;

    begin
        U0: invg port map(i_A => S, o_F => nsel);
        U1: andg2 port map(i_A => D0, i_B => nsel, o_F => S1);
        U2: andg2 port map(i_A => D1, i_B => S, o_F => S2);
        U3: org2 port map(i_A => S1,i_B => S2,o_F=> O);
end structural;