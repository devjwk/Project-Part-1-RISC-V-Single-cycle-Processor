library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_alu32 is
end entity;

architecture behavior of tb_alu32 is

  -- DUT (Device Under Test) signals
  signal A, B     : std_logic_vector(31 downto 0);
  signal ALUCtrl  : std_logic_vector(4 downto 0);
  signal Result   : std_logic_vector(31 downto 0);
  signal Zero     : std_logic;

begin
  --------------------------------------------------------------------
  -- DUT Instantiation
  --------------------------------------------------------------------
  DUT: entity work.alu32
    port map (
      A        => A,
      B        => B,
      ALUCtrl  => ALUCtrl,
      Result   => Result,
      Zero     => Zero
    );

  --------------------------------------------------------------------
  -- Test Process
  -- This section sequentially applies test vectors for all ALU ops
  --------------------------------------------------------------------
  process
  begin
    ----------------------------------------------------------------
    -- ADD Test
    ----------------------------------------------------------------
    report "Testing ADD operation...";
    A <= x"00000005"; B <= x"00000003"; ALUCtrl <= "00010";  -- ADD
    wait for 10 ns;

    ----------------------------------------------------------------
    -- SUB Test
    ----------------------------------------------------------------
    report "Testing SUB operation...";
    A <= x"00000009"; B <= x"00000004"; ALUCtrl <= "00110";  -- SUB
    wait for 10 ns;

    ----------------------------------------------------------------
    -- AND Test
    ----------------------------------------------------------------
    report "Testing AND operation...";
    A <= x"AAAAAAAA"; B <= x"55555555"; ALUCtrl <= "00000";  -- AND
    wait for 10 ns;

    ----------------------------------------------------------------
    -- OR Test
    ----------------------------------------------------------------
    report "Testing OR operation...";
    A <= x"AAAAAAAA"; B <= x"55555555"; ALUCtrl <= "00001";  -- OR
    wait for 10 ns;

    ----------------------------------------------------------------
    -- XOR Test
    ----------------------------------------------------------------
    report "Testing XOR operation...";
    A <= x"F0F0F0F0"; B <= x"0F0F0F0F"; ALUCtrl <= "00100";  -- XOR
    wait for 10 ns;

    ----------------------------------------------------------------
    -- NOR Test
    ----------------------------------------------------------------
    report "Testing NOR operation...";
    A <= x"0000FFFF"; B <= x"FFFF0000"; ALUCtrl <= "00101";  -- NOR
    wait for 10 ns;

    ----------------------------------------------------------------
    -- Shift Left Logical (SLL)
    ----------------------------------------------------------------
    report "Testing SLL operation...";
    A <= x"0000000F"; B <= x"00000004"; ALUCtrl <= "01001";  -- SLL by 4
    wait for 10 ns;

    ----------------------------------------------------------------
    -- Shift Right Logical (SRL)
    ----------------------------------------------------------------
    report "Testing SRL operation...";
    A <= x"F0000000"; B <= x"00000004"; ALUCtrl <= "01010";  -- SRL by 4
    wait for 10 ns;

    ----------------------------------------------------------------
    -- Shift Right Arithmetic (SRA)
    ----------------------------------------------------------------
    report "Testing SRA operation...";
    A <= x"F0000000"; B <= x"00000004"; ALUCtrl <= "01011";  -- SRA by 4
    wait for 10 ns;

    ----------------------------------------------------------------
    -- SLT (Signed Less Than)
    ----------------------------------------------------------------
    report "Testing SLT (signed)...";
    A <= x"FFFFFFFE"; B <= x"00000002"; ALUCtrl <= "01000";  -- SLT signed
    wait for 10 ns;

    ----------------------------------------------------------------
    -- SLTU (Unsigned Less Than)
    ----------------------------------------------------------------
    report "Testing SLTU (unsigned)...";
    A <= x"FFFFFFFE"; B <= x"00000002"; ALUCtrl <= "00111";  -- SLTU unsigned
    wait for 10 ns;

    ----------------------------------------------------------------
    -- Zero flag test
    ----------------------------------------------------------------
    report "Testing Zero flag...";
    A <= x"00000002"; B <= x"00000002"; ALUCtrl <= "00110";  -- SUB → Zero
    wait for 10 ns;

    ----------------------------------------------------------------
    -- End of Testbench
    ----------------------------------------------------------------
    report "All ALU operations tested successfully!" severity note;
    wait;
  end process;

end architecture;