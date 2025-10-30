library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_fetch_logic is
end entity;

architecture sim of tb_fetch_logic is
  -- Clock period
  constant Tclk : time := 10 ns;

  -- DUT signals
  signal clk     : std_logic := '0';
  signal rst     : std_logic := '1';
  signal pc_sel  : std_logic_vector(1 downto 0) := "00";
  signal rs1     : std_logic_vector(31 downto 0) := (others => '0');
  signal immI    : std_logic_vector(31 downto 0) := (others => '0');
  signal immB    : std_logic_vector(31 downto 0) := (others => '0');
  signal immJ    : std_logic_vector(31 downto 0) := (others => '0');
  signal pc_out  : std_logic_vector(31 downto 0);
  signal instr   : std_logic_vector(31 downto 0);

begin
  --------------------------------------------------------------------
  -- Clock generation
  --------------------------------------------------------------------
  clk_process : process
  begin
    clk <= '0'; wait for Tclk/2;
    clk <= '1'; wait for Tclk/2;
  end process;

  --------------------------------------------------------------------
  -- DUT instantiation
  --------------------------------------------------------------------
  UUT : entity work.fetch_logic
    port map (
      i_CLK    => clk,
      i_RST    => rst,
      i_PC_sel => pc_sel,
      i_rs1    => rs1,
      i_immI   => immI,
      i_immB   => immB,
      i_immJ   => immJ,
      o_PC     => pc_out,
      o_instr  => instr
    );

  --------------------------------------------------------------------
  -- Test stimulus
  --------------------------------------------------------------------
  stim_proc : process
  begin
    -- Reset phase
    rst <= '1';
    wait for 3*Tclk;
    rst <= '0';
    wait for 2*Tclk;

    ------------------------------------------------------------------
    -- Case 00: Normal PC + 4
    ------------------------------------------------------------------
    pc_sel <= "00";
    wait for 6*Tclk;

    ------------------------------------------------------------------
    -- Case 01: Branch (PC + immB)
    ------------------------------------------------------------------
    immB   <= x"00000010";   -- +16
    pc_sel <= "01";
    wait for Tclk;           -- ★ 한 클럭만 유지
    pc_sel <= "00";
    wait for 6*Tclk;

    ------------------------------------------------------------------
    -- Case 10: JAL (PC + immJ)
    ------------------------------------------------------------------
    immJ   <= x"00000020";   -- +32
    pc_sel <= "10";
    wait for Tclk;           -- ★ 한 클럭만 유지
    pc_sel <= "00";
    wait for 6*Tclk;

    ------------------------------------------------------------------
    -- Case 11: JALR ((rs1 + immI) & ~1)
    ------------------------------------------------------------------
    rs1    <= x"00000100";
    immI   <= x"00000006";   -- rs1 + immI = 0x106, &~1 = 0x106
    pc_sel <= "11";
    wait for Tclk;           -- ★ 한 클럭만 유지
    pc_sel <= "00";
    wait for 6*Tclk;

    ------------------------------------------------------------------
    -- End simulation
    ------------------------------------------------------------------
    wait;
  end process;

end architecture;