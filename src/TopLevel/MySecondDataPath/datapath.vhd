library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity datapath is
    port (
        i_CLK      : in  std_logic;
        i_RST      : in  std_logic;

        -- control
        i_RegWrite : in  std_logic;                -- regfile WE
        i_ALUSrc   : in  std_logic;                -- 0: rs2, 1: imm
        i_nAdd_Sub : in  std_logic;                -- 0: add, 1: sub

        -- register addresses
        i_rs1_addr : in  std_logic_vector(4 downto 0);
        i_rs2_addr : in  std_logic_vector(4 downto 0);
        i_rd_addr  : in  std_logic_vector(4 downto 0);

        -- immediate (12-bit, I-type 스타일)
        i_imm12    : in  std_logic_vector(11 downto 0);

        -- monitor
        o_result   : out std_logic_vector(31 downto 0)  
    );
end entity;

architecture structural of datapath is
    -- 내부 배선
    signal s_rs1, s_rs2    : std_logic_vector(31 downto 0);
    signal s_imm_ext       : std_logic_vector(31 downto 0);
    signal s_B_to_alu      : std_logic_vector(31 downto 0);
    signal s_alu_result    : std_logic_vector(31 downto 0);
    signal s_wdata         : std_logic_vector(31 downto 0); 
    signal dummy_cout      : std_logic;
begin
    --------------------------------------------------------------------
    -- 12 -> 32 sign-extend
    --------------------------------------------------------------------
    s_imm_ext <= (31 downto 12 => i_imm12(11)) & i_imm12;

    --------------------------------------------------------------------
    -- Register File
    --------------------------------------------------------------------
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

    --------------------------------------------------------------------
    -- ALUSrc MUX (rs2 vs imm_ext)
    --------------------------------------------------------------------
    U_ALUSRC: entity work.mux2t1_N
        generic map ( N => 32 )
        port map (
            S  => i_ALUSrc,     -- 0: D0(rs2), 1: D1(imm)
            D0 => s_rs2,
            D1 => s_imm_ext,
            O  => s_B_to_alu
        );

    --------------------------------------------------------------------
    -- ALU (+ / -)
    --------------------------------------------------------------------
    U_ALU: entity work.addsub_N
        generic map ( N => 32 )
        port map (
            A        => s_rs1,
            B        => s_B_to_alu,
            nAdd_Sub => i_nAdd_Sub,   -- 0:add, 1:sub
            Sum      => s_alu_result,
            Cout     => dummy_cout
        );

    
    s_wdata <= s_alu_result; 

    
    o_result <= s_alu_result;

end architecture;