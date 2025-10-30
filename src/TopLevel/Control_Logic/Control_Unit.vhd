library IEEE;
use IEEE.std_logic_1164.all;

entity control_unit is
  port (
    i_opcode  : in  std_logic_vector(6 downto 0);
    i_funct3  : in  std_logic_vector(2 downto 0);
    i_funct7  : in  std_logic_vector(6 downto 0);

    -- 제어 신호
    o_RegWrite : out std_logic;
    o_ALUSrc   : out std_logic;
    o_MemWrite : out std_logic;
    o_MemRead  : out std_logic;
    o_MemToReg : out std_logic;
    o_Branch   : out std_logic;
    o_JAL      : out std_logic;
    o_JALR     : out std_logic;

    -- ALU Ctrl (하위 4비트 사용, 상위 1비트는 Top에서 0으로 붙여서 5비트로 전달)
    o_ALUCtrl  : out std_logic_vector(3 downto 0);

    -- PC 선택: "00"=PC+4, "01"=Branch, "10"=JAL, "11"=JALR
    o_PC_sel   : out std_logic_vector(1 downto 0)
  );
end entity;

architecture rtl of control_unit is
begin
  process(i_opcode, i_funct3, i_funct7)
  begin
    -- 기본값
    o_RegWrite <= '0';
    o_ALUSrc   <= '0';
    o_MemWrite <= '0';
    o_MemRead  <= '0';
    o_MemToReg <= '0';
    o_Branch   <= '0';
    o_JAL      <= '0';
    o_JALR     <= '0';
    o_ALUCtrl  <= "0000";    -- ADD
    o_PC_sel   <= "00";

    case i_opcode is

      ----------------------------------------------------------------
      -- R-type (0110011)
      ----------------------------------------------------------------
      when "0110011" =>
        o_RegWrite <= '1';
        o_ALUSrc   <= '0';
        case i_funct3 is
          when "000" =>                     -- ADD / SUB
            if i_funct7 = "0100000" then
              o_ALUCtrl <= "0001";          -- SUB
            else
              o_ALUCtrl <= "0000";          -- ADD
            end if;
          when "111" => o_ALUCtrl <= "0010"; -- AND
          when "110" => o_ALUCtrl <= "0011"; -- OR
          when "100" => o_ALUCtrl <= "0100"; -- XOR
          when "010" => o_ALUCtrl <= "0101"; -- SLT
          when "011" => o_ALUCtrl <= "0110"; -- SLTU
          when "001" => o_ALUCtrl <= "0111"; -- SLL
          when "101" =>
            if i_funct7 = "0100000" then
              o_ALUCtrl <= "1000";          -- SRA
            else
              o_ALUCtrl <= "1001";          -- SRL
            end if;
          when others => o_ALUCtrl <= "0000";
        end case;

      ----------------------------------------------------------------
      -- I-type ALU (0010011)
      ----------------------------------------------------------------
      when "0010011" =>
        o_RegWrite <= '1';
        o_ALUSrc   <= '1';
        case i_funct3 is
          when "000" => o_ALUCtrl <= "0000"; -- ADDI
          when "010" => o_ALUCtrl <= "0101"; -- SLTI
          when "011" => o_ALUCtrl <= "0110"; -- SLTIU
          when "111" => o_ALUCtrl <= "0010"; -- ANDI
          when "110" => o_ALUCtrl <= "0011"; -- ORI
          when "100" => o_ALUCtrl <= "0100"; -- XORI
          when "001" => o_ALUCtrl <= "0111"; -- SLLI
          when "101" =>
            if i_funct7 = "0100000" then
              o_ALUCtrl <= "1000";          -- SRAI
            else
              o_ALUCtrl <= "1001";          -- SRLI
            end if;
          when others => o_ALUCtrl <= "0000";
        end case;

      ----------------------------------------------------------------
      -- LW (0000011)
      ----------------------------------------------------------------
      when "0000011" =>
        o_RegWrite <= '1';
        o_ALUSrc   <= '1';
        o_MemRead  <= '1';
        o_MemToReg <= '1';
        o_ALUCtrl  <= "0000";               -- ADD (addr calc)

      ----------------------------------------------------------------
      -- SW (0100011)
      ----------------------------------------------------------------
      when "0100011" =>
        o_ALUSrc   <= '1';
        o_MemWrite <= '1';
        o_ALUCtrl  <= "0000";               -- ADD (addr calc)

      ----------------------------------------------------------------
      -- Branch (1100011)
      ----------------------------------------------------------------
      when "1100011" =>
        o_Branch  <= '1';
        o_ALUSrc  <= '0';
        o_PC_sel  <= "01";
        o_ALUCtrl <= "0001";                -- SUB (BEQ/BNE 비교용)

      ----------------------------------------------------------------
      -- JAL (1101111)
      ----------------------------------------------------------------
      when "1101111" =>
        o_RegWrite <= '1';
        o_JAL      <= '1';
        o_PC_sel   <= "10";
        o_ALUCtrl  <= "0000";

      ----------------------------------------------------------------
      -- JALR (1100111)
      ----------------------------------------------------------------
      when "1100111" =>
        o_RegWrite <= '1';
        o_JALR     <= '1';
        o_ALUSrc   <= '1';
        o_PC_sel   <= "11";
        o_ALUCtrl  <= "0000";

      ----------------------------------------------------------------
      -- LUI (0110111) / AUIPC (0010111) — 여기선 ALU는 ADD로 둠
      ----------------------------------------------------------------
      when "0110111" | "0010111" =>
        o_RegWrite <= '1';
        o_ALUSrc   <= '1';
        o_ALUCtrl  <= "0000";

      when others =>
        null;
    end case;
  end process;
end architecture;