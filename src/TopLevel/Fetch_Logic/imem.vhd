library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Instruction Memory (ROM)
-- Depth: 2^ADDR_W words (each 32-bit)
-- Replace INIT block with your program, or switch to file-based init if needed.
entity imem is
  generic (
    ADDR_W : integer := 10   -- 1024 words (4 KB)
  );
  port (
    addr : in  std_logic_vector(ADDR_W-1 downto 0);  -- word index
    dout : out std_logic_vector(31 downto 0)
  );
end entity;

architecture rtl of imem is
  type mem_t is array (0 to (2**ADDR_W)-1) of std_logic_vector(31 downto 0);
  signal rom : mem_t := (others => (others => '0'));
begin
  dout <= rom(to_integer(unsigned(addr)));
end architecture;