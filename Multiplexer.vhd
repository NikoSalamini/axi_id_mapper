library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Multiplexer is
  generic (
    Q : natural;     -- Number of bits in each input signal
    N : natural      -- Number of input signals
  );
  port (
    Sel : in std_logic_vector(N-1 downto 0);  -- Selection signal
    Inputs : in std_logic_vector((Q*N)-1 downto 0);  -- Input signals
    Output : out std_logic_vector(Q downto 0)  -- Output signal
  );
end entity Multiplexer;

architecture Behavioral of Multiplexer is
begin
  process (Sel, Inputs)
  begin
    Output <= Inputs((to_integer(unsigned(Sel))+1)*Q-1 downto to_integer(unsigned(Sel))*Q);
  end process;
end architecture Behavioral;
