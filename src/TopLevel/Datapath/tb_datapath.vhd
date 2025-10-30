library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_datapath is
end entity;

architecture sim of tb_datapath is
    -- Component under test
    component datapath_with_mem is
        port (
            i_CLK       : in std_logic;
            i_RST       : in std_logic;
            i_RegWrite  : in std_logic;
            i_ALUSrc    : in std_logic;
            i_nAdd_Sub  : in std_logic;
            i_MemWrite  : in std_logic;
            i_MemRead   : in std_logic;
            i_MemToReg  : in std_logic;
            i_ALUCtrl   : in std_logic_vector(4 downto 0);
            i_rs1_addr  : in std_logic_vector(4 downto 0);
            i_rs2_addr  : in std_logic_vector(4 downto 0);
            i_rd_addr   : in std_logic_vector(4 downto 0);
            i_imm12     : in std_logic_vector(11 downto 0);
            o_result    : out std_logic_vector(31 downto 0);
            o_mem_data  : out std_logic_vector(31 downto 0)
        );
    end component;

    -- signals
    signal CLK, RST, RegWrite, ALUSrc, nAdd_Sub, MemWrite, MemRead, MemToReg : std_logic := '0';
    signal ALUCtrl  : std_logic_vector(4 downto 0) := (others => '0');
    signal rs1_addr, rs2_addr, rd_addr : std_logic_vector(4 downto 0) := (others => '0');
    signal imm12 : std_logic_vector(11 downto 0) := (others => '0');
    signal result, mem_data : std_logic_vector(31 downto 0);

    constant CLK_PERIOD : time := 10 ns;
begin
    -- DUT instance
    DUT: datapath_with_mem
        port map (
            i_CLK => CLK,
            i_RST => RST,
            i_RegWrite => RegWrite,
            i_ALUSrc => ALUSrc,
            i_nAdd_Sub => nAdd_Sub,
            i_MemWrite => MemWrite,
            i_MemRead => MemRead,
            i_MemToReg => MemToReg,
            i_ALUCtrl => ALUCtrl,
            i_rs1_addr => rs1_addr,
            i_rs2_addr => rs2_addr,
            i_rd_addr => rd_addr,
            i_imm12 => imm12,
            o_result => result,
            o_mem_data => mem_data
        );

    -- Clock process
    clk_process : process
    begin
        CLK <= '0';
        wait for CLK_PERIOD/2;
        CLK <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Test sequence
    stim_proc: process
    begin
        -- Reset
        RST <= '1';
        wait for 20 ns;
        RST <= '0';
        wait for 10 ns;

        ----------------------------------------------------------------
        -- 1. ADD: r3 = r1 + r2
        ----------------------------------------------------------------
        RegWrite <= '1'; ALUSrc <= '0'; nAdd_Sub <= '0';
        MemWrite <= '0'; MemRead <= '0'; MemToReg <= '0';
        ALUCtrl <= "00000"; -- ADD
        rs1_addr <= "00001";
        rs2_addr <= "00010";
        rd_addr <= "00011";
        wait for 40 ns;

        ----------------------------------------------------------------
        -- 2. SUB: r4 = r1 - r2
        ----------------------------------------------------------------
        ALUCtrl <= "00001"; -- SUB
        rd_addr <= "00100";
        nAdd_Sub <= '1';
        wait for 40 ns;

        ----------------------------------------------------------------
        -- 3. SLT: r5 = (r1 < r2) ? 1 : 0
        ----------------------------------------------------------------
        ALUCtrl <= "00100"; -- SLT
        rd_addr <= "00101";
        wait for 40 ns;

        ----------------------------------------------------------------
        -- 4. AND
        ----------------------------------------------------------------
        ALUCtrl <= "00110"; -- AND
        rd_addr <= "00110";
        wait for 40 ns;

        ----------------------------------------------------------------
        -- 5. OR
        ----------------------------------------------------------------
        ALUCtrl <= "00111"; -- OR
        rd_addr <= "00111";
        wait for 40 ns;

        ----------------------------------------------------------------
        -- 6. Memory Write / Read Test (SW/LW)
        ----------------------------------------------------------------
        ALUSrc <= '1';
        MemWrite <= '1';
        MemRead <= '0';
        MemToReg <= '0';
        imm12 <= x"010";
        wait for 40 ns;

        MemWrite <= '0';
        MemRead <= '1';
        MemToReg <= '1';
        wait for 40 ns;

        wait;
    end process;
end architecture;