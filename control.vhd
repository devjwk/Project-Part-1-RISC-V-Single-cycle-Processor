library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Control_Unit is
    port(
        opcode   : in  std_logic_vector(6 downto 0);
        funct3   : in  std_logic_vector(2 downto 0);
        funct7   : in  std_logic_vector(6 downto 0);
        RegWrite : out std_logic;
        ALUSrc   : out std_logic;
        MemWrite : out std_logic;
        MemToReg : out std_logic;
        Branch   : out std_logic;
        Jump     : out std_logic;
        ALUOp    : out std_logic_vector(1 downto 0)
    );
end entity Control_Unit;

architecture Behavioral of Control_Unit is
begin
    process(opcode, funct3, funct7)
    begin
        -- Default values (safe defaults)
        RegWrite <= '0';
        ALUSrc   <= '0';
        MemWrite <= '0';
        MemToReg <= '0';
        Branch   <= '0';
        Jump     <= '0';
        ALUOp    <= "00";

        -- Main control logic
        case opcode is
            -- R-type (add, sub, and, slt, etc.)
            when "0110011" =>
                RegWrite <= '1';
                ALUSrc   <= '0';
                MemWrite <= '0';
                MemToReg <= '0';
                Branch   <= '0';
                Jump     <= '0';
                ALUOp    <= "10";

            -- I-type (addi, andi, ori, slti, jalr)
            when "0010011" =>
                RegWrite <= '1';
                ALUSrc   <= '1';
                MemWrite <= '0';
                MemToReg <= '0';
                Branch   <= '0';
                Jump     <= '0';
                ALUOp    <= "00";

            -- Load Word (lw)
            when "0000011" =>
                RegWrite <= '1';
                ALUSrc   <= '1';
                MemWrite <= '0';
                MemToReg <= '1';
                Branch   <= '0';
                Jump     <= '0';
                ALUOp    <= "00";

            -- Store Word (sw)
            when "0100011" =>
                RegWrite <= '0';
                ALUSrc   <= '1';
                MemWrite <= '1';
                MemToReg <= '0';
                Branch   <= '0';
                Jump     <= '0';
                ALUOp    <= "00";

            -- Branch Equal / Not Equal
            when "1100011" =>
                RegWrite <= '0';
                ALUSrc   <= '0';
                MemWrite <= '0';
                MemToReg <= '0';
                Branch   <= '1';
                Jump     <= '0';
                ALUOp    <= "01";

            -- Jump and Link (jal)
            when "1101111" =>
                RegWrite <= '1';
                ALUSrc   <= 'X';
                MemWrite <= '0';
                MemToReg <= '0';
                Branch   <= '0';
                Jump     <= '1';
                ALUOp    <= "XX";

            -- Jump and Link Register (jalr)
            when "1100111" =>
                RegWrite <= '1';
                ALUSrc   <= '1';
                MemWrite <= '0';
                MemToReg <= '0';
                Branch   <= '0';
                Jump     <= '1';
                ALUOp    <= "XX";

            -- Load Upper Immediate (lui)
            when "0110111" =>
                RegWrite <= '1';
                ALUSrc   <= '1';
                MemWrite <= '0';
                MemToReg <= '0';
                Branch   <= '0';
                Jump     <= '0';
                ALUOp    <= "00";

            -- Add Upper Immediate to PC (auipc)
            when "0010111" =>
                RegWrite <= '1';
                ALUSrc   <= '1';
                MemWrite <= '0';
                MemToReg <= '0';
                Branch   <= '0';
                Jump     <= '0';
                ALUOp    <= "00";

            when others =>
                -- Default NOP (no operation)
                RegWrite <= '0';
                ALUSrc   <= '0';
                MemWrite <= '0';
                MemToReg <= '0';
                Branch   <= '0';
                Jump     <= '0';
                ALUOp    <= "00";
        end case;
    end process;
end architecture Behavioral;
