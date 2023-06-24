library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity NBitRegister is
    generic (
        N       : positive := 8
    );
    port (
        clk     	: in  std_logic;
        reset   	: in  std_logic;
        data_in 	: in  std_logic_vector(N-1 downto 0);
        q       	: out std_logic_vector(N-1 downto 0)
    );
end entity NBitRegister;

architecture Behavioral of NBitRegister is
    signal register_data : std_logic_vector(N-1 downto 0);
begin
    process(clk, reset)
    begin
        if reset = '1' then
            register_data <= (others => '0');  -- Reset the internal data to its predefined value
        elsif rising_edge(clk) then
                register_data <= data_in;  -- Store the input in the internal data
        end if;
    end process;

    q <= register_data;  -- Assign the internal data to the output
end architecture Behavioral;