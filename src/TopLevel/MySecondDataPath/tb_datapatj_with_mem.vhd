library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_datapath_with_mem is
end tb_datapath_with_mem;

architecture behavior of tb_datapath_with_mem is

    
    signal clk       : std_logic := '0';
    signal rst       : std_logic := '0';
    signal RegWrite  : std_logic := '0';
    signal ALUSrc    : std_logic := '0';
    signal nAdd_Sub  : std_logic := '0';
    signal MemWrite  : std_logic := '0';
    signal MemRead   : std_logic := '0';
    signal MemToReg  : std_logic := '0';

    signal rs1       : std_logic_vector(4 downto 0) := (others => '0');
    signal rs2       : std_logic_vector(4 downto 0) := (others => '0');
    signal rd        : std_logic_vector(4 downto 0) := (others => '0');
    signal imm12     : std_logic_vector(11 downto 0) := (others => '0');

    signal result    : std_logic_vector(31 downto 0);
    signal mem_data  : std_logic_vector(31 downto 0);

begin
    ----------------------------------------------------------------
    -- DUT instance
    ----------------------------------------------------------------
    uut: entity work.datapath_with_mem
        port map (
            i_CLK      => clk,
            i_RST      => rst,
            i_RegWrite => RegWrite,
            i_ALUSrc   => ALUSrc,
            i_nAdd_Sub => nAdd_Sub,
            i_MemWrite => MemWrite,
            i_MemRead  => MemRead,
            i_MemToReg => MemToReg,
            i_rs1_addr => rs1,
            i_rs2_addr => rs2,
            i_rd_addr  => rd,
            i_imm12    => imm12,
            o_result   => result,
            o_mem_data => mem_data   
        );

    ----------------------------------------------------------------
    -- Clock process (10 ns period)
    ----------------------------------------------------------------
    clk_process : process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;

    ----------------------------------------------------------------
    -- Stimulus process 
    ----------------------------------------------------------------
    stim_proc : process
    begin
        ----------------------------------------------------------------
        -- Reset
        ----------------------------------------------------------------
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 20 ns;

        ----------------------------------------------------------------
        -- addi 25, zero, 0   # Load &A base address
        ----------------------------------------------------------------
        rs1 <= "00000"; rd <= "11001";
        imm12 <= std_logic_vector(to_unsigned(0, 12));
        ALUSrc <= '1'; nAdd_Sub <= '0';
        RegWrite <= '1'; MemWrite <= '0'; MemRead <= '0'; MemToReg <= '0';
        wait for 40 ns;

        -- addi 26, zero, 256   # Load &B base address
        rd <= "11010";
        imm12 <= std_logic_vector(to_unsigned(256, 12));
        RegWrite <= '1'; wait for 40 ns;

        -- lw 1, 0(25)
        rs1 <= "11001"; rd <= "00001";
        imm12 <= std_logic_vector(to_unsigned(0, 12));
        ALUSrc <= '1'; RegWrite <= '1';
        MemRead <= '1'; MemToReg <= '1'; MemWrite <= '0';
        wait for 40 ns;

        -- lw 2, 4(25)
        rd <= "00010";
        imm12 <= std_logic_vector(to_unsigned(4, 12));
        wait for 40 ns;

        -- add 1, 1, 2
        rs1 <= "00001"; rs2 <= "00010"; rd <= "00001";
        ALUSrc <= '0'; nAdd_Sub <= '0';
        RegWrite <= '1'; MemRead <= '0'; MemToReg <= '0'; MemWrite <= '0';
        wait for 40 ns;

        -- sw 1, 0(26)
        rs1 <= "11010"; rs2 <= "00001";
        imm12 <= std_logic_vector(to_unsigned(0, 12));
        RegWrite <= '0'; MemWrite <= '1'; MemRead <= '0';
        wait for 40 ns;

        -- lw 2, 8(25)
        rs1 <= "11001"; rd <= "00010";
        imm12 <= std_logic_vector(to_unsigned(8, 12));
        RegWrite <= '1'; MemRead <= '1'; MemToReg <= '1'; MemWrite <= '0';
        wait for 40 ns;

        -- add 1, 1, 2
        rs1 <= "00001"; rs2 <= "00010"; rd <= "00001";
        ALUSrc <= '0'; RegWrite <= '1'; wait for 40 ns;

        -- sw 1, 4(26)
        rs1 <= "11010"; rs2 <= "00001";
        imm12 <= std_logic_vector(to_unsigned(4, 12));
        RegWrite <= '0'; MemWrite <= '1'; wait for 40 ns;

        -- lw 2, 12(25)
        rs1 <= "11001"; rd <= "00010";
        imm12 <= std_logic_vector(to_unsigned(12, 12));
        RegWrite <= '1'; MemRead <= '1'; MemToReg <= '1'; wait for 40 ns;

        -- add 1, 1, 2
        rs1 <= "00001"; rs2 <= "00010"; rd <= "00001";
        ALUSrc <= '0'; RegWrite <= '1'; wait for 40 ns;

        -- sw 1, 8(26)
        rs1 <= "11010"; rs2 <= "00001";
        imm12 <= std_logic_vector(to_unsigned(8, 12));
        RegWrite <= '0'; MemWrite <= '1'; wait for 40 ns;

        -- lw 2, 16(25)
        rs1 <= "11001"; rd <= "00010";
        imm12 <= std_logic_vector(to_unsigned(16, 12));
        RegWrite <= '1'; MemRead <= '1'; MemToReg <= '1'; wait for 40 ns;

        -- add 1, 1, 2
        rs1 <= "00001"; rs2 <= "00010"; rd <= "00001";
        ALUSrc <= '0'; RegWrite <= '1'; wait for 40 ns;

        -- sw 1, 12(26)
        rs1 <= "11010"; rs2 <= "00001";
        imm12 <= std_logic_vector(to_unsigned(12, 12));
        RegWrite <= '0'; MemWrite <= '1'; wait for 40 ns;

        -- lw 2, 20(25)
        rs1 <= "11001"; rd <= "00010";
        imm12 <= std_logic_vector(to_unsigned(20, 12));
        RegWrite <= '1'; MemRead <= '1'; MemToReg <= '1'; wait for 40 ns;

        -- add 1, 1, 2
        rs1 <= "00001"; rs2 <= "00010"; rd <= "00001";
        ALUSrc <= '0'; RegWrite <= '1'; wait for 40 ns;

        -- sw 1, 16(26)
        rs1 <= "11010"; rs2 <= "00001";
        imm12 <= std_logic_vector(to_unsigned(16, 12));
        RegWrite <= '0'; MemWrite <= '1'; wait for 40 ns;

        -- lw 2, 24(25)
        rs1 <= "11001"; rd <= "00010";
        imm12 <= std_logic_vector(to_unsigned(24, 12));
        RegWrite <= '1'; MemRead <= '1'; MemToReg <= '1'; wait for 40 ns;

        -- add 1, 1, 2
        rs1 <= "00001"; rs2 <= "00010"; rd <= "00001";
        ALUSrc <= '0'; RegWrite <= '1'; wait for 40 ns;

        -- addi 27, zero, 512
        rs1 <= "00000"; rd <= "11011";
        imm12 <= std_logic_vector(to_unsigned(512, 12));
        ALUSrc <= '1'; RegWrite <= '1';
        MemWrite <= '0'; MemRead <= '0'; MemToReg <= '0'; wait for 40 ns;

        -- sw 1, -4(27)
        rs1 <= "11011"; rs2 <= "00001";
        imm12 <= std_logic_vector(to_unsigned(4092, 12)); -- -4 in 12-bit 2's complement
        RegWrite <= '0'; MemWrite <= '1'; MemRead <= '0';
        wait for 40 ns;

        ----------------------------------------------------------------
        wait;
    end process;

end architecture;