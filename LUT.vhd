library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity LUT is
    generic(
		FIRST_POOL_VALUE: integer := 0; -- the first value of the pool
		POOL_SIZE: integer := 8; -- the pool size
		AXI_ID_WIDTH: integer := 6; -- value width of the output axi id
		COUNTER_WIDTH: integer := 2 -- counter of active transactions with the same axi id
	);
    port ( 
		clk	: in std_logic;
		reset: in std_logic;
        S_AXI_ID_REQ : in std_logic_vector(5 downto 0);
        S_AXI_ID_RSP : in std_logic_vector(5 downto 0);
        S_VALID_REQ: in std_logic; -- the valid signal of the request 
        S_VALID_RSP: in std_logic; -- the valid signal of the response
        M_AXI_ID_REQ: out std_logic_vector(5 downto 0);
        M_AXI_ID_RSP: out std_logic_vector(5 downto 0);
        M_AXI_VALID_REQ: out std_logic := '0';
        M_AXI_VALID_RSP: out std_logic := '0';
        error: out std_logic := '0'
    );
end entity LUT;

architecture Structural of LUT is
    component EnableMapper is 
        generic(
            FIRST_POOL_VALUE: natural := 0; -- the first value of the pool, the next depends are generated until POOL_SIZE-1
            POOL_SIZE: positive := 8; -- the pool size
            AXI_ID_WIDTH: positive := 6; -- value width of the output axi id
            COUNTER_WIDTH: positive := 2 -- counter of active transactions with the same axi id
	   );
        port ( 
            clk	: in std_logic;
            reset: in std_logic;
            -- NOTE: SAVED_MAPS must be connected to output by the wrapper
            SAVED_MAPS: in std_logic_vector(POOL_SIZE*(COUNTER_WIDTH+(2*AXI_ID_WIDTH))-1 downto 0); 
            S_AXI_ID_REQ : in std_logic_vector(AXI_ID_WIDTH-1 downto 0);
            S_AXI_ID_RSP : in std_logic_vector(AXI_ID_WIDTH-1 downto 0);
            S_VALID_REQ: in std_logic; -- the valid signal of the request 
            S_VALID_RSP: in std_logic; -- the valid signal of the response
            M_AXI_ID_REQ: out std_logic_vector(AXI_ID_WIDTH-1 downto 0);
            M_AXI_ID_RSP: out std_logic_vector(AXI_ID_WIDTH-1 downto 0);
            M_AXI_VALID_REQ: out std_logic := '0';
            M_AXI_VALID_RSP: out std_logic := '0';
            REGISTERS_CMD: out std_logic_vector(POOL_SIZE-1 downto 0);
            ACTIVATE_REGISTERS: out std_logic_vector(POOL_SIZE-1 downto 0);
            error: out std_logic := '0'
    );
    end component;
    
    component MapperRegister is
        generic (
            COUNTER_WIDTH: positive := 2;
            VALUE_WIDTH: positive := 6;
            AXI_ID_MAP: std_logic_vector(5 downto 0) -- AXI ID MAP
        );
        port (
            clk     	: in  std_logic;
            reset   	: in  std_logic;
            en          : in  std_logic;
            cmd         : in  std_logic; -- 1 inc, 0 dec
            axi_id      : in  std_logic_vector((COUNTER_WIDTH+2*VALUE_WIDTH)-1 downto 0);
            q       	: out std_logic_vector((COUNTER_WIDTH+2*VALUE_WIDTH)-1 downto 0)
        );
    end component;

-- signals
signal reg_outputs_to_enable_mapper: std_logic_vector(POOL_SIZE*(COUNTER_WIDTH+(2*AXI_ID_WIDTH))-1 downto 0);
signal activate_registers: std_logic_vector(POOL_SIZE-1 downto 0);
signal registers_cmd: std_logic_vector(POOL_SIZE-1 downto 0);

begin

    EnableMapper_def: EnableMapper
    generic map (
        FIRST_POOL_VALUE => FIRST_POOL_VALUE, 
        POOL_SIZE => POOL_SIZE, 
        AXI_ID_WIDTH => AXI_ID_WIDTH,
        COUNTER_WIDTH => COUNTER_WIDTH
    )
    port map(
        clk	=> clk,
		reset => reset,
		SAVED_MAPS => reg_outputs_to_enable_mapper,
        S_AXI_ID_REQ => S_AXI_ID_REQ,
        S_AXI_ID_RSP => S_AXI_ID_RSP,
        S_VALID_REQ => S_VALID_REQ, 
        S_VALID_RSP => S_VALID_RSP, 
        M_AXI_ID_REQ => M_AXI_ID_REQ,
        M_AXI_ID_RSP => M_AXI_ID_RSP,
        M_AXI_VALID_REQ => M_AXI_VALID_REQ,
        M_AXI_VALID_RSP => M_AXI_VALID_RSP,
        REGISTERS_CMD => registers_cmd,
        ACTIVATE_REGISTERS => activate_registers,
        error => error
    );
    
    registers_def : for i in (POOL_SIZE - 1) downto 0 generate
		single_register_def: MapperRegister
		-- AXI ID REMAPPINGS are incremental
		generic map (AXI_ID_MAP => std_logic_vector(to_unsigned(FIRST_POOL_VALUE + i, AXI_ID_WIDTH))) 
		port map ( 	clk => clk,
		            reset => reset,
		            en => activate_registers(i),
		            cmd => registers_cmd(i),
		            axi_id => S_AXI_ID_REQ,
					q => reg_outputs_to_enable_mapper
		);
	end generate registers_def;
    
end architecture Structural;