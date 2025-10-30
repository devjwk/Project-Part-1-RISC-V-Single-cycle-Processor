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

  -- Internal signals for submodules
  signal s_addsub   : std_logic_vector(31 downto 0);
  signal s_logic    : std_logic_vector(31 downto 0);
  signal s_shift    : std_logic_vector(31 downto 0);
  signal s_slt      : std_logic_vector(31 downto 0);
  signal s_zero     : std_logic;

  signal nAdd_Sub   : std_logic;                   -- Add/Sub control signal
  signal logic_sel  : std_logic_vector(1 downto 0);
  signal shift_op   : std_logic_vector(1 downto 0); -- "00"=SRL, "01"=SRA, "10"=SLL
  signal is_unsigned: std_logic;                   -- Selects between SLT and SLTU

begin
  ------------------------------------------------------------------------------
  -- ADD / SUB Unit (addsub_N)
  -- Performs 32-bit addition or subtraction depending on nAdd_Sub
  ------------------------------------------------------------------------------
  nAdd_Sub <= '1' when (ALUCtrl = "00110") else '0'; -- '1' for SUB, '0' for ADD

  U_ADD: entity work.addsub_N
    generic map (N => 32)
    port map (
      A        => A,
      B        => B,
      nAdd_Sub => nAdd_Sub,
      Sum      => s_addsub,
      Cout     => open
    );

  ------------------------------------------------------------------------------
  -- Logic Unit (logic_unit)
  -- Implements bitwise AND, OR, XOR, NOR based on ALUCtrl
  ------------------------------------------------------------------------------
  logic_sel <= "00" when ALUCtrl="00000" else  -- AND
               "01" when ALUCtrl="00001" else  -- OR
               "10" when ALUCtrl="00100" else  -- XOR
               "11";                            -- NOR (default)

  U_LOGIC: entity work.logic_unit
    port map (
      A   => A,
      B   => B,
      Sel => logic_sel,
      Y   => s_logic
    );

  ------------------------------------------------------------------------------
  -- Barrel Shifter (barrel_shifter32)
  -- Supports SRL (logical right), SRA (arithmetic right), and SLL (logical left)
  ------------------------------------------------------------------------------
  shift_op <= "00" when ALUCtrl="01010" else  -- SRL
              "01" when ALUCtrl="01011" else  -- SRA
              "10";                            -- SLL

  U_SHIFT: entity work.barrel_shifter32
    port map (
      data_in  => A,
      shamt    => B(4 downto 0),
      op       => shift_op,
      data_out => s_shift
    );

  ------------------------------------------------------------------------------
  -- Comparator (slt32)
  -- Performs SLT (signed) or SLTU (unsigned) comparison based on ALUCtrl
  ------------------------------------------------------------------------------
  is_unsigned <= '1' when (ALUCtrl = "00111") else '0'; -- '1' for SLTU, '0' for SLT

  U_SLT: entity work.slt32
    port map (
      a           => A,
      b           => B,
      is_unsigned => is_unsigned,
      less        => open,
      result      => s_slt
    );

  ------------------------------------------------------------------------------
  -- Zero Flag
  -- Zero = 1 when the ADD/SUB result equals 0
  ------------------------------------------------------------------------------
  s_zero <= '1' when s_addsub = x"00000000" else '0';

  ------------------------------------------------------------------------------
  -- Output Multiplexer
  -- Selects final ALU output based on ALUCtrl
  ------------------------------------------------------------------------------
  process(ALUCtrl, s_addsub, s_logic, s_shift, s_slt)
  begin
    case ALUCtrl is
      when "00000" | "00001" | "00100" | "00101" =>  -- Logic operations
        Result <= s_logic;
      when "00010" | "00110" =>  -- ADD / SUB
        Result <= s_addsub;
      when "00111" | "01000" =>  -- SLT / SLTU
        Result <= s_slt;
      when "01001" | "01010" | "01011" =>  -- Shift operations
        Result <= s_shift;
      when others =>
        Result <= (others => '0');  -- Default
    end case;
  end process;

  Zero <= s_zero;

end architecture;