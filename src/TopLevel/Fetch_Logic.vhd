library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- ==============================================================
-- Fetch_Logic.vhd
-- 
-- Description:
--   Instruction Fetch logic for a single-cycle RISC-V processor.
--   Determines the next PC value based on control-flow instructions.
--
-- Supported control flow types:
--   - Sequential (PC + 4)
--   - Conditional branch (PC + B-imm)
--   - Unconditional jump (JAL)
--   - Register-based jump (JALR)
--
-- Priority: JALR > JAL > Branch (taken) > PC + 4
--
-- Author: JongwooKim 2025-10-22
-- ==============================================================

entity Fetch_Logic is
  generic (
    WIDTH : integer := 32
  );
  port (
    -- Clock & Reset
    iCLK          : in  std_logic;
    iRST          : in  std_logic;

    -- Control signals from the Control Unit
    iBranch       : in  std_logic;                           -- Branch instruction active
    iJump         : in  std_logic;                           -- JAL instruction active
    iJalr         : in  std_logic;                           -- JALR instruction active
    iALUZero      : in  std_logic;                           -- Condition flag (e.g., BEQ)

    -- Pre-computed target addresses from datapath
    iBranchTarget : in  std_logic_vector(WIDTH-1 downto 0);  -- Target: PC + B-imm << 1
    iJumpTarget   : in  std_logic_vector(WIDTH-1 downto 0);  -- Target: PC + J-imm
    iJalrTarget   : in  std_logic_vector(WIDTH-1 downto 0);  -- Target: RS1 + I-imm (JALR)

    -- Outputs to instruction memory
    oNextInstAddr : out std_logic_vector(WIDTH-1 downto 0);  -- Next PC value
    oIMemAddr     : out std_logic_vector(WIDTH-1 downto 0)   -- Current instruction address
  );
end entity Fetch_Logic;

architecture Behavioral of Fetch_Logic is
  signal s_PC       : std_logic_vector(WIDTH-1 downto 0);
  signal s_PCNext   : std_logic_vector(WIDTH-1 downto 0);
  signal s_PCPlus4  : std_logic_vector(WIDTH-1 downto 0);

  -- Function to ensure LSB(0) = 0 for JALR target alignment
  function mask_lsb0(v : std_logic_vector) return std_logic_vector is
    variable r : std_logic_vector(v'range) := v;
  begin
    r(0) := '0';
    return r;
  end function;
begin
  -- Compute PC + 4 for sequential execution
  s_PCPlus4 <= std_logic_vector(unsigned(s_PC) + to_unsigned(4, WIDTH));

  -- Determine next PC value
  process(iBranch, iJump, iJalr, iALUZero, iBranchTarget, iJumpTarget, iJalrTarget, s_PCPlus4)
    variable v_JalrMasked : std_logic_vector(WIDTH-1 downto 0);
  begin
    v_JalrMasked := mask_lsb0(iJalrTarget);

    if (iJalr = '1') then
      s_PCNext <= v_JalrMasked;            -- JALR (RS1 + Imm)
    elsif (iJump = '1') then
      s_PCNext <= iJumpTarget;             -- JAL (PC + J-Imm)
    elsif (iBranch = '1' and iALUZero = '1') then
      s_PCNext <= iBranchTarget;           -- Conditional branch
    else
      s_PCNext <= s_PCPlus4;               -- Sequential execution
    end if;
  end process;

  -- PC register with asynchronous reset
  process(iCLK, iRST)
  begin
    if (iRST = '1') then
      s_PC <= (others => '0');
    elsif rising_edge(iCLK) then
      s_PC <= s_PCNext;
    end if;
  end process;

  -- Outputs
  oIMemAddr     <= s_PC;       -- Address of current instruction
  oNextInstAddr <= s_PCNext;   -- Address of next instruction
end architecture Behavioral;