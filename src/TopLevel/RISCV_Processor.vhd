library IEEE;

use IEEE.std_logic_1164.all;

use IEEE.numeric_std.all;

library work;

use work.RISCV_types.all;

entity RISC_V_Processor is

  generic(N : integer := DATA_WIDTH);

  port(

    iCLK      : in  std_logic;

    iRST      : in  std_logic;

    -- external init for instruction memory

    iInstLd   : in  std_logic;

    iInstAddr : in  std_logic_vector(N-1 downto 0);

    iInstExt  : in  std_logic_vector(N-1 downto 0);

    -- DEBUG / monitor

    oALUOut   : out std_logic_vector(N-1 downto 0);

    oPC       : out std_logic_vector(N-1 downto 0);

    oNextPC   : out std_logic_vector(N-1 downto 0);

    oInst     : out std_logic_vector(N-1 downto 0);

    oRegWrite : out std_logic;

    oRegAddr  : out std_logic_vector(4 downto 0);

    oRegData  : out std_logic_vector(N-1 downto 0)

  );

end RISC_V_Processor;

architecture structure of RISC_V_Processor is

  constant ADDR_WIDTH_C : integer := ADDR_WIDTH;

  -- IMem / DMem

  signal s_IMemAddr     : std_logic_vector(N-1 downto 0);

  signal s_NextInstAddr : std_logic_vector(N-1 downto 0);

  signal s_Inst         : std_logic_vector(N-1 downto 0);

  signal s_DMemWr       : std_logic;

  signal s_DMemAddr     : std_logic_vector(N-1 downto 0);

  signal s_DMemData     : std_logic_vector(N-1 downto 0);

  signal s_DMemOut      : std_logic_vector(N-1 downto 0);

  -- control

  signal s_ALUSrc       : std_logic;

  signal s_MemToReg     : std_logic;

  signal s_MemWrite     : std_logic;

  signal s_MemRead      : std_logic;

  signal s_Branch       : std_logic;

  signal s_Jump         : std_logic;

  signal s_Jalr         : std_logic;

  signal s_RegWrite     : std_logic;

  signal s_ALUOp        : std_logic_vector(3 downto 0); -- from CU (4-bit)

  signal s_ALUCtrl_ext  : std_logic_vector(4 downto 0); -- to datapath (0 & ALUOp)

  -- fetch

  signal s_PC_sel       : std_logic_vector(1 downto 0);

  signal s_PC_cur       : std_logic_vector(N-1 downto 0);

  signal s_PC_next      : std_logic_vector(N-1 downto 0);

  -- rs1 for JALR

  signal s_rs1          : std_logic_vector(31 downto 0);

  -- immediates from s_Inst (ImmGen in Top)

  signal s_immI, s_immB, s_immJ : std_logic_vector(31 downto 0);

  -- ★ ADD: Branch decision helpers (Zero from ALU result, effective PC select)

  signal s_branch_zero  : std_logic;                 -- ALU result == 0 ?

  signal s_is_branch    : std_logic;                 -- opcode == 1100011 ?

  signal s_beq_taken    : std_logic;

  signal s_bne_taken    : std_logic;

  signal s_branch_taken : std_logic;

  signal s_PC_sel_eff   : std_logic_vector(1 downto 0); -- final PC select to fetch

begin

  -- monitor outs

  oPC       <= s_PC_cur;

  oNextPC   <= s_PC_next;

  oInst     <= s_Inst;

  oALUOut   <= s_DMemAddr;   -- datapath의 ALU 결과(주소) 모니터

  oRegWrite <= s_RegWrite;

  oRegAddr  <= s_Inst(11 downto 7);      -- rd

  oRegData  <= s_DMemData;               -- write-back 데이터(간단히 모니터)

  ----------------------------------------------------------------------------

  -- Instruction Memory (외부 로드 지원)

  ----------------------------------------------------------------------------

  with iInstLd select

    s_IMemAddr <= s_NextInstAddr when '0',

                  iInstAddr      when others;

  IMem: entity work.mem

    generic map ( ADDR_WIDTH => ADDR_WIDTH_C, DATA_WIDTH => N )

    port map (

      clk  => iCLK,

      addr => s_IMemAddr(ADDR_WIDTH_C+1 downto 2),

      data => iInstExt,

      we   => iInstLd,

      q    => s_Inst

    );

  ----------------------------------------------------------------------------

  -- Data Memory

  ----------------------------------------------------------------------------

  DMem: entity work.mem

    generic map ( ADDR_WIDTH => ADDR_WIDTH_C, DATA_WIDTH => N )

    port map (

      clk  => iCLK,

      addr => s_DMemAddr(ADDR_WIDTH_C+1 downto 2),

      data => s_DMemData,

      we   => s_DMemWr,

      q    => s_DMemOut

    );

  ----------------------------------------------------------------------------

  -- Control Unit

  ----------------------------------------------------------------------------

  U_CTRL: entity work.control_unit

    port map (

      i_opcode  => s_Inst(6 downto 0),

      i_funct3  => s_Inst(14 downto 12),

      i_funct7  => s_Inst(31 downto 25),

      o_RegWrite=> s_RegWrite,

      o_ALUSrc  => s_ALUSrc,

      o_MemWrite=> s_MemWrite,

      o_MemRead => s_MemRead,

      o_MemToReg=> s_MemToReg,

      o_Branch  => s_Branch,

      o_JAL     => s_Jump,

      o_JALR    => s_Jalr,

      o_ALUCtrl => s_ALUOp,

      o_PC_sel  => s_PC_sel

    );

  -- 4→5비트 확장 (상위 1비트 0)

  s_ALUCtrl_ext <= '0' & s_ALUOp;

  ----------------------------------------------------------------------------

  -- Datapath (ALU+RegFile+DMem-port) : rs1 노출(o_rs1)

  ----------------------------------------------------------------------------

  U_DP : entity work.datapath_with_mem

    port map (

      i_CLK      => iCLK,

      i_RST      => iRST,

      i_RegWrite => s_RegWrite,

      i_ALUSrc   => s_ALUSrc,

      i_ALUCtrl  => s_ALUCtrl_ext,

      i_MemWrite => s_MemWrite,

      i_MemRead  => s_MemRead,

      i_MemToReg => s_MemToReg,

      i_rs1_addr => s_Inst(19 downto 15),

      i_rs2_addr => s_Inst(24 downto 20),

      i_rd_addr  => s_Inst(11 downto 7),

      i_imm12    => s_Inst(31 downto 20),

      o_result   => s_DMemAddr,  -- ALU result (SUB on branch)

      o_mem_data => s_DMemData,

      o_rs1      => s_rs1

    );

  ----------------------------------------------------------------------------

  -- ImmGen (Top에서 간단 생성)

  ----------------------------------------------------------------------------

  -- I-type (sign-extend)

  s_immI <= (31 downto 11 => s_Inst(31)) & s_Inst(30 downto 20);

  -- B-type: {imm[12]|imm[10:5]|imm[4:1]|0}  (<<1 반영)

  s_immB <= (31 downto 12 => s_Inst(31)) &

            s_Inst(7) & s_Inst(30 downto 25) & s_Inst(11 downto 8) & '0';

  -- J-type: {imm[20]|imm[10:1]|imm[11]|imm[19:12]|0} (<<1 반영)

  s_immJ <= (31 downto 20 => s_Inst(31)) &

            s_Inst(19 downto 12) & s_Inst(20) & s_Inst(30 downto 21) & '0';

  ----------------------------------------------------------------------------

  -- ★ ADD: Branch decision & Effective PC-select (상위에서 분기 보정)

  ----------------------------------------------------------------------------

  -- ALU 결과가 0인지 확인 (branch에서 SUB 사용 전제)

  s_branch_zero <= '1' when s_DMemAddr = (others => '0') else '0';

  -- opcode가 branch인가?

  s_is_branch   <= '1' when s_Inst(6 downto 0) = "1100011" else '0';

  -- BEQ: funct3 = 000, taken when zero=1

  s_beq_taken   <= '1' when (s_is_branch='1' and s_Inst(14 downto 12)="000" and s_branch_zero='1') else '0';

  -- BNE: funct3 = 001, taken when zero=0

  s_bne_taken   <= '1' when (s_is_branch='1' and s_Inst(14 downto 12)="001" and s_branch_zero='0') else '0';

  s_branch_taken <= s_beq_taken or s_bne_taken;

  -- 최종 PC 셀렉트 (분기는 taken 여부로 보정, JAL/JALR 등은 CU 값을 통과)

  s_PC_sel_eff <= "01" when (s_branch_taken = '1') else

                  "00" when (s_is_branch = '1' and s_branch_taken = '0') else

                  s_PC_sel;

  ----------------------------------------------------------------------------

  -- Fetch Logic (메모리 없음, PC만 업데이트)  ※ i_PC_sel에 보정값 사용!

  ----------------------------------------------------------------------------

  U_FETCH : entity work.fetch_logic

    port map (

      i_CLK     => iCLK,

      i_RST     => iRST,

      i_PC_sel  => s_PC_sel_eff,  -- ★ 수정: 보정된 PC select

      i_rs1     => s_rs1,

      i_immI    => s_immI,

      i_immB    => s_immB,

      i_immJ    => s_immJ,

      o_PC_cur  => s_PC_cur,

      o_PC_next => s_NextInstAddr

    );

end architecture;