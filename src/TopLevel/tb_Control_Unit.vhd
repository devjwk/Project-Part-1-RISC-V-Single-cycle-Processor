library IEEE;

use IEEE.std_logic_1164.all;

use IEEE.numeric_std.all;

entity tb_Control_Unit is

end entity tb_Control_Unit;

architecture sim of tb_Control_Unit is

    -- DUT Signals

    signal opcode   : std_logic_vector(6 downto 0);

    signal funct3   : std_logic_vector(2 downto 0);

    signal funct7   : std_logic_vector(6 downto 0);

    signal RegWrite : std_logic;

    signal ALUSrc   : std_logic;

    signal MemWrite : std_logic;

    signal MemToReg : std_logic;

    signal Branch   : std_logic;

    signal Jump     : std_logic;

    signal ALUOp    : std_logic_vector(1 downto 0);

    -- Record type for control vectors

    type ctrl_vec_t is record

        name       : string(1 to 16);

        opcode     : std_logic_vector(6 downto 0);

        funct3     : std_logic_vector(2 downto 0);

        funct7     : std_logic_vector(6 downto 0);

        e_RegWrite : std_logic;

        e_ALUSrc   : std_logic;

        e_MemWrite : std_logic;

        e_MemToReg : std_logic;

        e_Branch   : std_logic;

        e_Jump     : std_logic;

        e_ALUOp    : std_logic_vector(1 downto 0);

    end record;

    -- Array of test vectors

    type ctrl_vec_array is array (natural range <>) of ctrl_vec_t;

    constant test_vectors : ctrl_vec_array := (

        ( "R-type ADD      ", "0110011", "000", "0000000", '1','0','0','0','0','0',"10" ),

        ( "I-type ADDI     ", "0010011", "000", "0000000", '1','1','0','0','0','0',"00" ),

        ( "LOAD (LW)       ", "0000011", "010", "0000000", '1','1','0','1','0','0',"00" ),

        ( "STORE (SW)      ", "0100011", "010", "0000000", '0','1','1','0','0','0',"00" ),

        ( "BRANCH (BEQ)    ", "1100011", "000", "0000000", '0','0','0','0','1','0',"01" ),

        ( "JAL             ", "1101111", "000", "0000000", '1','0','0','0','0','1',"00" ),

        ( "JALR            ", "1100111", "000", "0000000", '1','1','0','0','0','1',"00" ),

        ( "LUI             ", "0110111", "000", "0000000", '1','1','0','0','0','0',"00" ),

        ( "AUIPC           ", "0010111", "000", "0000000", '1','1','0','0','0','0',"00" ),

        ( "UNKNOWN         ", "0000000", "000", "0000000", '0','0','0','0','0','0',"00" )

    );

    -- Helper functions for comparing std_logic/std_logic_vector

    function bit_matches(actual, expected: std_logic) return boolean is

    begin

        if expected = 'X' or expected = '-' then

            return true;

        else

            return actual = expected;

        end if;

    end function;

    function vec_matches(actual, expected: std_logic_vector) return boolean is

    begin

        return std_match(actual, expected);

    end function;

    function sl_to_char(s: std_logic) return character is

    begin

        case s is

            when '0' => return '0';

            when '1' => return '1';

            when others => return 'X';

        end case;

    end function;

    function slv2str(v: std_logic_vector) return string is

        variable res : string(1 to v'length);

        variable idx : integer := 1;

    begin

        for i in v'range loop

            res(idx) := sl_to_char(v(i));

            idx := idx + 1;

        end loop;

        return res;

    end function;

begin

    -- DUT Instantiation

    dut: entity work.Control_Unit

        port map (

            opcode   => opcode,

            funct3   => funct3,

            funct7   => funct7,

            RegWrite => RegWrite,

            ALUSrc   => ALUSrc,

            MemWrite => MemWrite,

            MemToReg => MemToReg,

            Branch   => Branch,

            Jump     => Jump,

            ALUOp    => ALUOp

        );

    -- Stimulus Process

    stim_proc: process

        variable passed : integer := 0;

        variable failed : integer := 0;

        variable ok     : boolean;

    begin

        report "Starting Control Unit test..." severity note;

        for i in test_vectors'range loop

            opcode <= test_vectors(i).opcode;

            funct3 <= test_vectors(i).funct3;

            funct7 <= test_vectors(i).funct7;

            wait for 10 ns;

            ok :=

                bit_matches(RegWrite, test_vectors(i).e_RegWrite) and

                bit_matches(ALUSrc,   test_vectors(i).e_ALUSrc)   and

                bit_matches(MemWrite, test_vectors(i).e_MemWrite) and

                bit_matches(MemToReg, test_vectors(i).e_MemToReg) and

                bit_matches(Branch,   test_vectors(i).e_Branch)   and

                bit_matches(Jump,     test_vectors(i).e_Jump)     and

                vec_matches(ALUOp,    test_vectors(i).e_ALUOp);

            if ok then

                report " PASS: " & test_vectors(i).name &

                       " opcode=" & slv2str(opcode) &

                       " ALUOp=" & slv2str(ALUOp)

                       severity note;

                passed := passed + 1;

            else

                report " FAIL: " & test_vectors(i).name &

                       " Expected ALUOp=" & slv2str(test_vectors(i).e_ALUOp) &

                       " Got=" & slv2str(ALUOp)

                       severity error;

                failed := failed + 1;

            end if;

        end loop;

        report "Test done. " &

               integer'image(passed) & " passed, " &

               integer'image(failed) & " failed." severity note;

        wait;

    end process;

end architecture sim;