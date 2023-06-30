library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- the value that will be keep represent COUNTER | AXI ID SAVED | AXI ID MAPPED
entity MapperRegister is
    generic (
        COUNTER_WIDTH: positive := 2;
        AXI_ID_WIDTH: positive := 6;
        AXI_ID_MAP: std_logic_vector(5 downto 0) -- AXI ID MAP
    );
    port (
        clk     	: in  std_logic;
        reset   	: in  std_logic;
        en          : in  std_logic;
        cmd         : in  std_logic; -- 1 inc, 0 dec
        axi_id      : in  std_logic_vector(AXI_ID_WIDTH-1 downto 0); -- axi id to save
        q       	: out std_logic_vector((COUNTER_WIDTH+2*AXI_ID_WIDTH)-1 downto 0)
    );
end entity MapperRegister;

architecture Behavioral of MapperRegister is
    signal axi_id_saved: std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    signal counter_value : std_logic_vector(COUNTER_WIDTH-1 downto 0);
    -- constants
    constant CounterMin: std_logic_vector(COUNTER_WIDTH-1 downto 0) := (others => '0');
    constant CounterMax: std_logic_vector(COUNTER_WIDTH-1 downto 0) := (others => '1');
begin
    process(clk, reset)
    begin
        if reset = '1' then
            counter_value <= (others => '0'); 
            axi_id_saved  <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                if cmd = '0' and counter_value /= CounterMin then
                    counter_value <= std_logic_vector(unsigned(counter_value) - 1);
                elsif cmd = '1'  and counter_value /= CounterMax then
                    counter_value <= std_logic_vector(unsigned(counter_value) + 1);
                end if;
                axi_id_saved <= axi_id;
            else
                counter_value <= counter_value;
            end if;
        end if;
    end process;
    
    -- output: COUNTER | AXI ID SAVED | AXI ID MAPPED
    q <= std_logic_vector(unsigned(counter_value)) & axi_id_saved & AXI_ID_MAP; 
end architecture Behavioral;