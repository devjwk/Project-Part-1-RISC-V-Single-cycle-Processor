library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath_with_mem is
    port (
        i_CLK       : in  std_logic;
        i_RST       : in  std_logic;

        -- control signals
        i_RegWrite  : in  std_logic;  -- Register write enable
        i_ALUSrc    : in  std_logic;  -- 0: rs2, 1: imm
        i_ALUCtrl   : in  std_logic_vector(4 downto 0); -- ALU operation control (NEW)
        i_MemWrite  : in  std_logic;  -- Memory write enable
        i_MemRead   : in  std_logic;  -- Memory read enable
        i_MemToReg  : in  std_logic;  -- 0: ALU result, 1: Mem data

        -- register addresses
        i_rs1_addr  : in  std_logic_vector(4 downto 0);
        i_rs2_addr  : in  std_logic_vector(4 downto 0);
        i_rd_addr   : in  std_logic_vector(4 downto 0);

        -- immediate (12-bit)
        i_imm12     : in  std_logic_vector(11 downto 0);

        -- monitor
        o_result    : out std_logic_vector(31 downto 0);
        o_mem_data  : out std_logic_vector(31 downto 0);
        o_rs1      : out std_logic_vector(31 downto 0)
    );
end entity;

architecture structural of datapath_with_mem is

    -- internal signals
    signal s_rs1, s_rs2    : std_logic_vector(31 downto 0);
    signal s_imm_ext       : std_logic_vector(31 downto 0);
    signal s_B_to_alu      : std_logic_vector(31 downto 0);
    signal s_alu_result    : std_logic_vector(31 downto 0);
    signal s_mem_data      : std_logic_vector(31 downto 0);
    signal s_wdata         : std_logic_vector(31 downto 0);
    signal s_zero          : std_logic;  -- from ALU
begin
    -----------------------------------------------------------------------------
    -- Immediate Sign-Extend (12 -> 32)
    -----------------------------------------------------------------------------
    s_imm_ext <= (31 downto 12 => i_imm12(11)) & i_imm12;

    -----------------------------------------------------------------------------
    -- Register File
    -----------------------------------------------------------------------------
    U_RF: entity work.reg_file
        port map (
            i_CLK    => i_CLK,
            i_RST    => i_RST,
            i_WE     => i_RegWrite,
            i_WADDR  => i_rd_addr,
            i_WDATA  => s_wdata,
            i_RADDR1 => i_rs1_addr,
            i_RADDR2 => i_rs2_addr,
            o_RDATA1 => s_rs1,
            o_RDATA2 => s_rs2
        );

    -----------------------------------------------------------------------------
    -- ALUSrc MUX (rs2 vs immediate)
    -----------------------------------------------------------------------------
    U_ALUSRC: entity work.mux2t1_N
        generic map ( N => 32 )
        port map (
            S  => i_ALUSrc,
            D0 => s_rs2,
            D1 => s_imm_ext,
            O  => s_B_to_alu
        );

    -----------------------------------------------------------------------------
    -- ALU (Integrated 32-bit RISC-V ALU)
    -----------------------------------------------------------------------------
    U_ALU: entity work.alu32
        port map (
            A       => s_rs1,
            B       => s_B_to_alu,
            ALUCtrl => i_ALUCtrl,
            Result  => s_alu_result,
            Zero    => s_zero
        );

    -----------------------------------------------------------------------------
    -- Data Memory
    -----------------------------------------------------------------------------
    U_MEM: entity work.mem
        generic map (
            DATA_WIDTH => 32,
            ADDR_WIDTH => 10
        )
        port map (
            clk  => i_CLK,
            addr => s_alu_result(9 downto 0),  -- ALU result as address
            data => s_rs2,
            we   => i_MemWrite,                -- write enable
            q    => s_mem_data                 -- read value
        );

    -----------------------------------------------------------------------------
    -- Write-back MUX (ALU result vs Memory data)
    -----------------------------------------------------------------------------
    s_wdata <= s_alu_result when i_MemToReg = '0' else s_mem_data;

    -----------------------------------------------------------------------------
    -- Monitor Outputs
    -----------------------------------------------------------------------------
    o_result   <= s_alu_result;
    o_mem_data <= s_mem_data;
    o_rs1      <= s_rs1; 
end architecture;