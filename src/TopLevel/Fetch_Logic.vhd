library IEEE;

use IEEE.std_logic_1164.all;

use IEEE.numeric_std.all;

entity Fetch_Logic is

  port(

    clk       : in  std_logic;

    reset     : in  std_logic;

    branch    : in  std_logic;

    jump      : in  std_logic;

    jalr      : in  std_logic;

    zero      : in  std_logic;

    imm       : in  std_logic_vector(31 downto 0);

    rs1_data  : in  std_logic_vector(31 downto 0);

    next_pc   : out std_logic_vector(31 downto 0);

    pc_out    : out std_logic_vector(31 downto 0)

  );

end entity Fetch_Logic;

architecture Behavioral of Fetch_Logic is

  signal pc, pc_plus4, pc_branch, pc_jalr, next_pc_sig : std_logic_vector(31 downto 0);

  signal branch_taken : std_logic;

begin

  -- Branch 판단

  branch_taken <= branch and zero;

  -- PC + 4

  pc_plus4 <= std_logic_vector(unsigned(pc) + 4);

  -- PC + Immediate (Branch, JAL)

  pc_branch <= std_logic_vector(unsigned(pc) + unsigned(imm));

  -- JALR target (rs1 + imm)

  pc_jalr <= std_logic_vector(unsigned(rs1_data) + unsigned(imm));

  -- 최종 PC 선택 (Branch → Jump → JALR 순)

  process(branch_taken, jump, jalr, pc_plus4, pc_branch, pc_jalr)

  begin

    if jalr = '1' then

      next_pc_sig <= pc_jalr;

    elsif jump = '1' then

      next_pc_sig <= pc_branch;

    elsif branch_taken = '1' then

      next_pc_sig <= pc_branch;

    else

      next_pc_sig <= pc_plus4;

    end if;

  end process;

  -- PC register (동기 업데이트)

  process(clk, reset)

  begin

    if reset = '1' then

      pc <= (others => '0');

    elsif rising_edge(clk) then

      pc <= next_pc_sig;

    end if;

  end process;

  -- 출력

  pc_out <= pc;
  next_pc <= next_pc_sig;

end architecture Behavioral;