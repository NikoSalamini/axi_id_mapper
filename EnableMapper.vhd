----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/23/2021 02:07:42 PM
-- Design Name: 
-- Module Name: LUT - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

-- LUT_FWD: this LUT takes in input the AXI ID and output another one, taken from a pool of values, to M_AXI_ID. 
-- The LUT is enabled only if the AxUSER input signal is the correct one, specified by a generic parameter
-- A counter is incremented to know how many active transaction are using that Axi ID.
-- When a response is received, the entry of the mapped AXI Id is updated: the counter is decremented.
-- If there are no free Axi ID mapping, neither already active ones, an error is raised.
entity EnableMapper is
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
        error: out std_logic := '0'
    );
end EnableMapper;

architecture Behavioral of EnableMapper is

-- MappeRegister component
-- It will hold: USED_COUNTER [13:12] | ORIGINAL_AXI_ID [11:6] | REMAPPED_AXI_ID [5:0]
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
-- array of signals to the registers keeping the mappings
type t_signal_array is array (0 to POOL_SIZE-1) of std_logic_vector(COUNTER_WIDTH+(2*AXI_ID_WIDTH)-1 downto 0);
signal registers_input  : t_signal_array;
signal registers_output  : t_signal_array;
signal reset_input  : t_signal_array;
signal en_input : std_logic_vector(POOL_SIZE-1 downto 0) := (others => '0');
signal activate_register: std_logic_vector(POOL_SIZE-1 downto 0);
signal register_cmd: std_logic_vector(POOL_SIZE-1 downto 0);

-- constants
-- placeholders to access i-th field of SAVED_MAPS
constant EntryRange: natural := COUNTER_WIDTH+(2*AXI_ID_WIDTH);
constant CounterMax: std_logic_vector(COUNTER_WIDTH-1 downto 0) := (others => '1');

begin
    -- MapperRegisters definition
	registers_def : for i in (POOL_SIZE - 1) downto 0 generate
		single_register_def: MapperRegister
		-- AXI ID REMAPPINGS are incremental
		generic map (AXI_ID_MAP => std_logic_vector(to_unsigned(FIRST_POOL_VALUE + i, AXI_ID_WIDTH))) 
		port map ( 	clk => clk,
		            reset => reset,
		            en => activate_register(i),
		            cmd => register_cmd(i),
		            axi_id => S_AXI_ID_REQ,
					q => registers_output(i)
		);
	end generate registers_def;
	
	-- VALID_REQ PROCESS
    process(clk, S_VALID_REQ)
    variable FREE_CHECK : boolean;
    variable AXI_ID_CHECK : boolean;
    begin
        AXI_ID_CHECK := false; 
        FREE_CHECK := false;
        if S_VALID_REQ = '1' then 
            -- used to not considering the execution of the subsequent ifs
            
            -- 1) check if there is axi id match
            -- -counter must be >= 1 to be in use
            -- -if the counter is max, all one, an error is raised indicating that the maximum number of transaction for an axi id
            -- has been reached
            -- entry range: COUNTER_WIDTH+(2*AXI_ID_WIDTH)
            for i in 0 to POOL_SIZE-1 loop
                if 
                SAVED_MAPS( (i+1)*EntryRange-COUNTER_WIDTH-1 downto i*EntryRange + AXI_ID_WIDTH) = S_AXI_ID_REQ and
                SAVED_MAPS( (i+1)*EntryRange-1 downto i*EntryRange+2*AXI_ID_WIDTH) >= std_logic_vector(to_unsigned(1, COUNTER_WIDTH)) and
                (AXI_ID_CHECK = false) then
                    -- axi id match
				   AXI_ID_CHECK := true;
				   
				   if SAVED_MAPS( (i+1)*EntryRange-1 downto i*EntryRange+2*AXI_ID_WIDTH) = CounterMax then
				        error <= '1';
				   else
                        -- increment counter, save the mapped AXI ID, output the remapped AXI ID        
				        -- enable register
				        register_cmd(i) <= '1';
				        activate_register(i) <= '1'; 
				        M_AXI_ID_REQ <= SAVED_MAPS((i+1)*EntryRange-COUNTER_WIDTH-AXI_ID_WIDTH-1 downto i*EntryRange); --output the remapped axi_id
                   end if; 
				end if;
			end loop;
            
            -- 2) if no AXI_ID match, check if there is a free axi id  
            -- -check for entries with counter = 0
            -- -if there are no FREE AXI IDs generate error  
			for i in 0 to POOL_SIZE-1 loop
			    if SAVED_MAPS( (i+1)*EntryRange-1 downto i*EntryRange+2*AXI_ID_WIDTH) = std_logic_vector(to_unsigned(0, COUNTER_WIDTH)) and 
				(FREE_CHECK = false) and
				(AXI_ID_CHECK = false) then
                    FREE_CHECK := true;                  
					-- increment counter, save the mapped AXI ID, output the remapped AXI ID
					-- enable register
				        register_cmd(i) <= '1';
				        activate_register(i) <= '1'; 
					    M_AXI_ID_REQ <= SAVED_MAPS((i+1)*EntryRange-COUNTER_WIDTH-AXI_ID_WIDTH-1 downto i*EntryRange); --output the remapped axi_id
				end if;
			end loop;
			
			-- if the research indicates no axi id match neither free axi ids then error is set
			if FREE_CHECK = false and AXI_ID_CHECK = false then 
                error <= '1';
            end if;
        elsif rising_edge(clk) then
            for i in 0 to POOL_SIZE loop
                register_cmd(i) <= '0';
                activate_register(i) <= '0';
            end loop;
        end if;
        
        
        
    end process;
    
    -- VALID RSP PROCESS
    process(S_VALID_RSP)
    variable AXI_ID_CHECK : boolean;
    begin
        if rising_edge(S_VALID_RSP) then -- valid response transaction is ready
            -- used to not considering the execution of the subsequent ifs
            AXI_ID_CHECK := false; 
            
            -- 1) find the corresponding axi id to remap
            -- counter must not be 0
            for i in 0 to POOL_SIZE-1 loop
                if SAVED_MAPS( (i+1)*EntryRange-COUNTER_WIDTH-1 downto i*EntryRange + AXI_ID_WIDTH) = S_AXI_ID_RSP and
                SAVED_MAPS( (i+1)*EntryRange-1 downto i*EntryRange+2*AXI_ID_WIDTH) /= std_logic_vector(to_unsigned(0, COUNTER_WIDTH)) and -- counter /= 0 
                AXI_ID_CHECK = false then
                    -- decrement counter, output the original axi id (saved axi id)
                    register_cmd(i) <= '0';
                    activate_register(i) <= '1'; 
                    M_AXI_ID_RSP <= SAVED_MAPS((i+1)*EntryRange-COUNTER_WIDTH-AXI_ID_WIDTH-1 downto i*EntryRange); --output the remapped axi_id
                end if;
			end loop;
			
			if AXI_ID_CHECK = false then
			     error <= '1';
			end if;
        end if;        
    end process;

end Behavioral;
