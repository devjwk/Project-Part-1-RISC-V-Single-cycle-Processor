library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity barrel_shifter32 is
    port (
        data_in  : in  std_logic_vector(31 downto 0);
        shamt    : in  std_logic_vector(4 downto 0);  -- shift amount
        op       : in  std_logic_vector(1 downto 0);  -- "00"=SRL, "01"=SRA, "10"=SLL
        data_out : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of barrel_shifter32 is

    -- Reverse bits helper (used for SLL)
    function bit_reverse(x : std_logic_vector(31 downto 0)) return std_logic_vector is
        variable r : std_logic_vector(31 downto 0);
    begin
        for i in 0 to 31 loop
            r(i) := x(31 - i);
        end loop;
        return r;
    end function;

    signal in_R        : std_logic_vector(31 downto 0);
    signal s0, s1, s2, s3, s4 : std_logic_vector(31 downto 0);
    signal signbit     : std_logic;
    signal right_result: std_logic_vector(31 downto 0);
    signal left_result : std_logic_vector(31 downto 0);

begin

    ----------------------------------------------------------
    -- Input Preprocessing
    -- SLL("10") → bit_reverse(data_in)
    ----------------------------------------------------------
    in_R    <= bit_reverse(data_in) when op = "10" else data_in;
    signbit <= in_R(31);  -- MSB (sign bit) used for SRA

    ----------------------------------------------------------
    -- Shift stages (5 levels, covering 2^0 ~ 2^4)
    ----------------------------------------------------------

    stage0: for i in 0 to 31 generate
        s0(i) <= in_R(i+1) when (shamt(0)='1' and i<=30) else
                 (signbit)  when (shamt(0)='1' and i=31 and op="01") else
                 ('0')      when (shamt(0)='1' and i=31 and op/="01") else
                 in_R(i);
    end generate;

    stage1: for i in 0 to 31 generate
        s1(i) <= s0(i+2) when (shamt(1)='1' and i<=29) else
                 (signbit) when (shamt(1)='1' and i>=30 and op="01") else
                 ('0')     when (shamt(1)='1' and i>=30 and op/="01") else
                 s0(i);
    end generate;

    stage2: for i in 0 to 31 generate
        s2(i) <= s1(i+4) when (shamt(2)='1' and i<=27) else
                 (signbit) when (shamt(2)='1' and i>=28 and op="01") else
                 ('0')     when (shamt(2)='1' and i>=28 and op/="01") else
                 s1(i);
    end generate;

    stage3: for i in 0 to 31 generate
        s3(i) <= s2(i+8) when (shamt(3)='1' and i<=23) else
                 (signbit) when (shamt(3)='1' and i>=24 and op="01") else
                 ('0')     when (shamt(3)='1' and i>=24 and op/="01") else
                 s2(i);
    end generate;

    stage4: for i in 0 to 31 generate
        s4(i) <= s3(i+16) when (shamt(4)='1' and i<=15) else
                 (signbit) when (shamt(4)='1' and i>=16 and op="01") else
                 ('0')     when (shamt(4)='1' and i>=16 and op/="01") else
                 s3(i);
    end generate;

    ----------------------------------------------------------
    -- Output Selection
    -- Right result = SRL / SRA
    -- Left result = bit-reversed SRL (for SLL)
    ----------------------------------------------------------
    right_result <= s4;
    left_result  <= bit_reverse(right_result);

    ----------------------------------------------------------
    -- Final output
    ----------------------------------------------------------
    data_out <= left_result when op = "10" else right_result;

end architecture;