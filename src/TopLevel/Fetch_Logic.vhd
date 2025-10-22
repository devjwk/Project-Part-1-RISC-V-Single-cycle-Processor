library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Fetch_Logic is
    port(
        iCLK      : in  std_logic;
        iRST      : in  std_logic;
        Branch    : in  std_logic;
        Jump      : in  std_logic;
        Jalr      : in  std_logic;
        Zero      : in  std_logic;
        Imm       : in  std_logic_vector(31 downto 0);
        RegData   : in  std_logic_vector(31 downto 0);
        PC_out    : out std_logic_vector(31 downto 0)
    );
end Fetch_Logic;

architecture Behavioral of Fetch_Logic is
    signal PC, NextPC : std_logic_vector(31 downto 0);
begin

    process(iCLK, iRST)
    begin
        if iRST = '1' then
            PC <= (others => '0');
        elsif rising_edge(iCLK) then
            PC <= NextPC;
        end if;
    end process;

    process(Branch, Jump, Jalr, Zero, Imm, PC, RegData)
    begin
        if Jump = '1' then
            NextPC <= std_logic_vector(signed(PC) + signed(Imm));
        elsif Jalr = '1' then
            NextPC <= std_logic_vector((signed(RegData) + signed(Imm)) and x"FFFFFFFE");
        elsif Branch = '1' and Zero = '1' then
            NextPC <= std_logic_vector(signed(PC) + signed(Imm));
        else
            NextPC <= std_logic_vector(signed(PC) + 4);
        end if;
    end process;

    PC_out <= PC;

end Behavioral;