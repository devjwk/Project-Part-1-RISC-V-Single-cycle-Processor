library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fetch_logic is
  generic (
    IMEM_ADDR_W : integer := 10
  );
  port (
    i_CLK     : in  std_logic;
    i_RST     : in  std_logic;

    -- Control input from control_unit
    -- "00"=PC+4, "01"=Branch, "10"=JAL, "11"=JALR
    i_PC_sel  : in  std_logic_vector(1 downto 0);

    -- operands for target calculations (already sign-extended)
    i_rs1     : in  std_logic_vector(31 downto 0); -- for JALR
    i_immI    : in  std_logic_vector(31 downto 0); -- JALR immediate
    i_immB    : in  std_logic_vector(31 downto 0); -- branch immediate (<<1)
    i_immJ    : in  std_logic_vector(31 downto 0); -- JAL immediate (<<1)

    -- output to top level
    o_PC_cur  : out std_logic_vector(31 downto 0);
    o_PC_next : out std_logic_vector(31 downto 0)
  );
end entity;

architecture structural of fetch_logic is

  -- internal signals
  signal s_pc_cur, s_pc_next : std_logic_vector(31 downto 0);
  signal s_pc_plus4          : std_logic_vector(31 downto 0);
  signal s_br_target         : std_logic_vector(31 downto 0);
  signal s_jal_target        : std_logic_vector(31 downto 0);
  signal s_jalr_sum          : std_logic_vector(31 downto 0);
  signal s_jalr_target       : std_logic_vector(31 downto 0);
  signal s_pc_sel_01         : std_logic_vector(31 downto 0);
  signal s_pc_sel_23         : std_logic_vector(31 downto 0);

begin
  ------------------------------------------------------------------------------
  -- Program Counter Register
  ------------------------------------------------------------------------------
  U_PC: entity work.pc
    port map (
      i_CLK => i_CLK,
      i_RST => i_RST,
      i_D   => s_pc_next,
      o_Q   => s_pc_cur
    );

  o_PC_cur <= s_pc_cur;

  ------------------------------------------------------------------------------
  -- PC + 4 adder
  ------------------------------------------------------------------------------
  U_ADDER_PC4: entity work.adder
    generic map ( N => 32 )
    port map (
      A   => s_pc_cur,
      B   => x"00000004",
      SUM => s_pc_plus4
    );

  ------------------------------------------------------------------------------
  -- Target address calculations
  ------------------------------------------------------------------------------
  -- branch target = PC + immB
  U_ADDER_BR: entity work.adder
    generic map ( N => 32 )
    port map (
      A   => s_pc_cur,
      B   => i_immB,
      SUM => s_br_target
    );

  -- JAL target = PC + immJ
  U_ADDER_JAL: entity work.adder
    generic map ( N => 32 )
    port map (
      A   => s_pc_cur,
      B   => i_immJ,
      SUM => s_jal_target
    );

  -- JALR target = rs1 + immI (LSB=0)
  U_ADDER_JALR: entity work.adder
    generic map ( N => 32 )
    port map (
      A   => i_rs1,
      B   => i_immI,
      SUM => s_jalr_sum
    );

  s_jalr_target <= s_jalr_sum and x"FFFFFFFE";  -- align to even address

  ------------------------------------------------------------------------------
  -- PC selection MUX (using mux2t1_N)
  ------------------------------------------------------------------------------
  -- First layer: select between PC+4 and Branch
  U_MUX_L1: entity work.mux2t1_N
    generic map ( N => 32 )
    port map (
      S  => i_PC_sel(0),   -- LSB
      D0 => s_pc_plus4,
      D1 => s_br_target,
      O  => s_pc_sel_01
    );

  -- Second layer: select between JAL and JALR
  U_MUX_L2: entity work.mux2t1_N
    generic map ( N => 32 )
    port map (
      S  => i_PC_sel(0),   -- LSB reused for "10"/"11" distinction
      D0 => s_jal_target,
      D1 => s_jalr_target,
      O  => s_pc_sel_23
    );

  -- Top-level MUX: select between {PC+4/Branch} and {JAL/JALR}
  U_MUX_FINAL: entity work.mux2t1_N
    generic map ( N => 32 )
    port map (
      S  => i_PC_sel(1),   -- MSB decides upper half
      D0 => s_pc_sel_01,
      D1 => s_pc_sel_23,
      O  => s_pc_next
    );

  ------------------------------------------------------------------------------
  -- Output
  ------------------------------------------------------------------------------
  o_PC_next <= s_pc_next;

end architecture;
