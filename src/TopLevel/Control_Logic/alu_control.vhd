library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu_control is
  port (
    i_ALUOp  : in  std_logic_vector(1 downto 0);
    i_funct3 : in  std_logic_vector(2 downto 0);
    i_funct7 : in  std_logic_vector(6 downto 0);
    o_ALUCtrl: out std_logic_vector(3 downto 0)
  );
end entity;

architecture behavioral of alu_control is
begin
  process(i_ALUOp, i_funct3, i_funct7)
  begin
    case i_ALUOp is
      when "00" => o_ALUCtrl <= "0010"; -- add (for lw/sw)
      when "01" => o_ALUCtrl <= "0110"; -- sub (for branch)
      when "10" =>  -- R-type
        case i_funct3 is
          when "000" =>
            if i_funct7 = "0100000" then
              o_ALUCtrl <= "0110"; -- sub
            else
              o_ALUCtrl <= "0010"; -- add
            end if;
          when "111" => o_ALUCtrl <= "0000"; -- and
          when "110" => o_ALUCtrl <= "0001"; -- or
          when "010" => o_ALUCtrl <= "0111"; -- slt
          when others => o_ALUCtrl <= "1111";
        end case;

      when "11" =>  -- I-type arithmetic
        case i_funct3 is
          when "000" => o_ALUCtrl <= "0010"; -- addi
          when "111" => o_ALUCtrl <= "0000"; -- andi
          when "110" => o_ALUCtrl <= "0001"; -- ori
          when others => o_ALUCtrl <= "1111";
        end case;

      when others =>
        o_ALUCtrl <= "1111";
    end case;
  end process;
end architecture;