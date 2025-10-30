library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_control_unit is
end;

architecture sim of tb_control_unit is
  signal opcode  : std_logic_vector(6 downto 0);
  signal funct3  : std_logic_vector(2 downto 0);
  signal funct7  : std_logic_vector(6 downto 0);
  signal ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, JAL, JALR : std_logic;
  signal ALUCtrl : std_logic_vector(3 downto 0);
begin
  DUT: entity work.control_unit
    port map (
      i_opcode => opcode,
      i_funct3 => funct3,
      i_funct7 => funct7,
      o_ALUSrc => ALUSrc,
      o_MemtoReg => MemtoReg,
      o_RegWrite => RegWrite,
      o_MemRead => MemRead,
      o_MemWrite => MemWrite,
      o_Branch => Branch,
      o_JAL => JAL,
      o_JALR => JALR,
      o_ALUCtrl => ALUCtrl
    );

  process
  begin
    report "==== CONTROL UNIT TEST START ====";

    -- R-type ADD
    opcode <= "0110011"; funct3 <= "000"; funct7 <= "0000000"; wait for 10 ns;

    -- R-type SUB
    opcode <= "0110011"; funct3 <= "000"; funct7 <= "0100000"; wait for 10 ns;

    -- I-type ADDI
    opcode <= "0010011"; funct3 <= "000"; funct7 <= "0000000"; wait for 10 ns;

    -- I-type ANDI
    opcode <= "0010011"; funct3 <= "111"; funct7 <= "0000000"; wait for 10 ns;

    -- LOAD (LW)
    opcode <= "0000011"; wait for 10 ns;

    -- STORE (SW)
    opcode <= "0100011"; wait for 10 ns;

    -- BRANCH (BEQ)
    opcode <= "1100011"; funct3 <= "000"; wait for 10 ns;

    -- JAL
    opcode <= "1101111"; wait for 10 ns;

    -- JALR
    opcode <= "1100111"; wait for 10 ns;

    -- LUI
    opcode <= "0110111"; wait for 10 ns;

    wait;
  end process;
end architecture;