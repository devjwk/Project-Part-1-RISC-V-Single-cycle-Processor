library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu32 is
  port (
    A, B      : in  std_logic_vector(31 downto 0);
    ALUCtrl   : in  std_logic_vector(4 downto 0);
    Result    : out std_logic_vector(31 downto 0);
    Zero      : out std_logic
  );
end entity;

architecture structural of alu32 is
  -- Internal signals
  signal s_addsub, s_logic, s_shift, s_slt : std_logic_vector(31 downto 0);
  signal s_zero, nAdd_Sub, is_unsigned : std_logic;
  signal logic_sel, shift_op : std_logic_vector(1 downto 0);

begin
  -----------------------------------------------------------------------------
  -- ADD / SUB
  -----------------------------------------------------------------------------
  nAdd_Sub <= '1' when (ALUCtrl = "00001") else '0'; -- SUB=1, ADD=0

  U_ADD: entity work.addsub_N
    generic map (N => 32)
    port map (
      A => A,
      B => B,
      nAdd_Sub => nAdd_Sub,
      Sum => s_addsub,
      Cout => open
    );

  -----------------------------------------------------------------------------
  -- LOGIC
  -----------------------------------------------------------------------------
  logic_sel <= "00" when ALUCtrl = "00010" else -- AND
               "01" when ALUCtrl = "00011" else -- OR
               "10" when ALUCtrl = "00100" else -- XOR
               "11";                           -- NOR

  U_LOGIC: entity work.logic_unit
    port map (
      A => A,
      B => B,
      Sel => logic_sel,
      Y => s_logic
    );

  -----------------------------------------------------------------------------
  -- SHIFT
  -----------------------------------------------------------------------------
  shift_op <= "10" when ALUCtrl = "01000" else  -- SLL
              "00" when ALUCtrl = "01001" else  -- SRL
              "01";                             -- SRA

  U_SHIFT: entity work.barrel_shifter32
    port map (
      data_in  => A,
      shamt    => B(4 downto 0),
      op       => shift_op,
      data_out => s_shift
    );

  -----------------------------------------------------------------------------
  -- SLT / SLTU
  -----------------------------------------------------------------------------
  is_unsigned <= '1' when (ALUCtrl = "00111") else '0';

  U_SLT: entity work.slt32
    port map (
      a => A,
      b => B,
      is_unsigned => is_unsigned,
      less => open,
      result => s_slt
    );

  -----------------------------------------------------------------------------
  -- ZERO flag
  -----------------------------------------------------------------------------
  s_zero <= '1' when s_addsub = x"00000000" else '0';

  -----------------------------------------------------------------------------
  -- OUTPUT MUX (모든 명령어 커버)
  -----------------------------------------------------------------------------
  process(ALUCtrl, s_addsub, s_logic, s_shift, s_slt)
  begin
    case ALUCtrl is
      when "00010" => Result <= s_addsub;  -- ADD
      when "00110" => Result <= s_addsub;  -- SUB
      when "00010" => Result <= s_logic;   -- AND
      when "00011" => Result <= s_logic;   -- OR
      when "00100" => Result <= s_logic;   -- XOR
      when "00101" => Result <= s_logic;   -- NOR
      when "00110" => Result <= s_slt;     -- SLT
      when "00111" => Result <= s_slt;     -- SLTU
      when "01000" => Result <= s_shift;   -- SLL
      when "01001" => Result <= s_shift;   -- SRL
      when "01010" => Result <= s_shift;   -- SRA
      when others  => Result <= (others => '0');
    end case;
  end process;

  Zero <= s_zero;
end architecture;