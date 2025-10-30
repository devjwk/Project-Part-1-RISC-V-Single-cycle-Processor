library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity slt32 is
  port (
    a           : in  std_logic_vector(31 downto 0);
    b           : in  std_logic_vector(31 downto 0);
    is_unsigned : in  std_logic;  -- '0' = signed SLT, '1' = unsigned SLTU
    less        : out std_logic;  -- 1 when a < b per selected mode
    result      : out std_logic_vector(31 downto 0) -- RISC-V style: [0]=less, others 0
  );
end entity slt32;

architecture rtl of slt32 is
  signal a_s, b_s : signed(31 downto 0);
  signal a_u, b_u : unsigned(31 downto 0);
  signal lt_s, lt_u : std_logic;
  signal lt : std_logic;
begin
  a_s <= signed(a);  
  b_s <= signed(b);
  a_u <= unsigned(a); 
  b_u <= unsigned(b);

  lt_s <= '1' when a_s < b_s else '0';
  lt_u <= '1' when a_u < b_u else '0';

  lt <= lt_u when is_unsigned='1' else lt_s;
  less <= lt;

  result <= (31 downto 1 => '0') & lt;  -- bit0=lt, others zero
end architecture rtl;