library IEEE;

use IEEE.std_logic_1164.all;

use IEEE.numeric_std.all;

entity tb_Fetch_Logic is

end entity;

architecture sim of tb_Fetch_Logic is

  signal clk, reset, branch, jump, jalr, zero : std_logic := '0';

  signal imm, rs1_data, next_pc, pc_out : std_logic_vector(31 downto 0);

begin

  dut: entity work.Fetch_Logic

    port map(

      clk      => clk,

      reset    => reset,

      branch   => branch,

      jump     => jump,

      jalr     => jalr,

      zero     => zero,

      imm      => imm,

      rs1_data => rs1_data,

      next_pc  => next_pc,

      pc_out   => pc_out

    );

  -- Clock generation

  clk_process : process

  begin

    clk <= '0';

    wait for 5 ns;

    clk <= '1';

    wait for 5 ns;

  end process;

  -- Stimulus

  stim: process

  begin

    reset <= '1';

    wait for 10 ns;

    reset <= '0';

    imm <= x"00000008";

    rs1_data <= x"00000010";

    -- Normal increment

    wait for 10 ns;

    -- Branch taken

    branch <= '1';

    zero <= '1';

    wait for 10 ns;

    -- Jump

    branch <= '0';

    jump <= '1';

    wait for 10 ns;

    -- JALR

    jump <= '0';

    jalr <= '1';

    wait for 10 ns;

    -- Return to normal

    jalr <= '0';

    wait for 20 ns;

    wait;

  end process;

end architecture sim;