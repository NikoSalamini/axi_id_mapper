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
        REGISTERS_CMD: out std_logic_vector(POOL_SIZE-1 downto 0);
        ACTIVATE_REGISTERS: out std_logic_vector(POOL_SIZE-1 downto 0);
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

-- constants
-- placeholders to access i-th field of SAVED_MAPS
constant EntryRange: natural := COUNTER_WIDTH+(2*AXI_ID_WIDTH);
constant CounterMax: std_logic_vector(COUNTER_WIDTH-1 downto 0) := (others => '1');

begin
	-- M_AXI_VALID_REQ change to 0
	-- M_AXI_VALID_REQ is set to 1 only when the remapping is done
	process (S_VALID_REQ)
	begin
	   if falling_edge(S_VALID_REQ) then
	       M_AXI_VALID_REQ <= '0';
	   end if;
	end process;
	
	-- VALID_REQ PROCESS
    process(clk, S_VALID_REQ)
    variable FREE_CHECK : boolean;
    variable AXI_ID_CHECK : boolean;
    begin
        AXI_ID_CHECK := false; 
        FREE_CHECK := false;
        if rising_edge(S_VALID_REQ) then 
            -- used to not considering the execution of the subsequent ifs
            
            -- 1) check if there is axi id match
            -- -counter must be >= 1 to be in use
            -- -if the counter is max, all 1s, an error is raised indicating that the maximum number of transaction for an axi id
            -- has been reached
            -- entry range: COUNTER_WIDTH+(2*AXI_ID_WIDTH)
            for i in 0 to POOL_SIZE-1 loop
                if 
                SAVED_MAPS( (i+1)*EntryRange-COUNTER_WIDTH-1 downto i*EntryRange + AXI_ID_WIDTH) = S_AXI_ID_REQ and -- AXI_ID_SAVED = S_AXI_ID_REQ?
                SAVED_MAPS( (i+1)*EntryRange-1 downto i*EntryRange+2*AXI_ID_WIDTH) >= std_logic_vector(to_unsigned(1, COUNTER_WIDTH)) and -- COUNTER >= 1?
                (AXI_ID_CHECK = false) then
                    -- axi id match
				   AXI_ID_CHECK := true;
				   
				   if SAVED_MAPS( (i+1)*EntryRange-1 downto i*EntryRange+2*AXI_ID_WIDTH) = CounterMax then -- COUNTER = COUNTERMAX?
				        error <= '1';
				   else
                        -- increment counter, enable register, save the mapped AXI ID, output the remapped AXI ID     
                        -- the next clock the registers will be updated   
				        REGISTERS_CMD(i) <= '1'; 
				        ACTIVATE_REGISTERS(i) <= '1'; 
				        -- this should be cleared when the masters put it to 0
				        M_AXI_VALID_REQ <= '1';
				        -- the axi id value will be kept till the next transaction
				        M_AXI_ID_REQ <= SAVED_MAPS((i+1)*EntryRange-COUNTER_WIDTH-AXI_ID_WIDTH-1 downto i*EntryRange); --output the remapped axi_id
                   end if; 
				end if;
			end loop;   
            
            -- 2) if no AXI_ID match, check if there is a free axi id  
            -- -check for entries with counter = 0
            -- -if there are no FREE AXI IDs generate error  
			for i in 0 to POOL_SIZE-1 loop
			    if SAVED_MAPS( (i+1)*EntryRange-1 downto i*EntryRange+2*AXI_ID_WIDTH) = std_logic_vector(to_unsigned(0, COUNTER_WIDTH)) and  -- COUNTER = 0?
				(FREE_CHECK = false) and
				(AXI_ID_CHECK = false) then
				    -- free check
                    FREE_CHECK := true;                  
                    -- increment counter, enable register, save the mapped AXI ID, output the remapped AXI ID   
                    REGISTERS_CMD(i) <= '1';
                    ACTIVATE_REGISTERS(i) <= '1'; 
                    -- this should be cleared when the masters put it to 0
                    M_AXI_VALID_REQ <= '1';
                    -- the axi id value will be kept till the next transaction
                    M_AXI_ID_REQ <= SAVED_MAPS((i+1)*EntryRange-COUNTER_WIDTH-AXI_ID_WIDTH-1 downto i*EntryRange); --output the remapped axi_id
				end if;
			end loop;
			
			-- if the research indicates no axi id match neither free axi ids then error is set
			if FREE_CHECK = false and AXI_ID_CHECK = false then 
                error <= '1';
            end if;
        elsif rising_edge(clk) then
            for i in 0 to POOL_SIZE loop
                REGISTERS_CMD(i) <= '0';
                ACTIVATE_REGISTERS(i) <= '0';
            end loop;
        end if;
    end process;
    
    -- same thing for the response
    -- slaves set this signal
	process (S_VALID_RSP)
	begin
	   if falling_edge(S_VALID_RSP) then
	       M_AXI_VALID_RSP <= '0';
	   end if;
	end process;
    
    -- VALID RSP PROCESS
    process(clk, S_VALID_RSP)
    variable AXI_ID_CHECK : boolean;
    begin
        if rising_edge(S_VALID_RSP) then -- valid response transaction is ready
            AXI_ID_CHECK := false; 
            
            -- 1) find the corresponding axi id to remap
            -- counter must not be 0
            for i in 0 to POOL_SIZE-1 loop
                if SAVED_MAPS( (i+1)*EntryRange-COUNTER_WIDTH-1 downto i*EntryRange + AXI_ID_WIDTH) = S_AXI_ID_RSP and --SAVED_AXI_ID= AXI_ID_RSP?
                SAVED_MAPS( (i+1)*EntryRange-1 downto i*EntryRange+2*AXI_ID_WIDTH) /= std_logic_vector(to_unsigned(0, COUNTER_WIDTH)) and -- COUNTER /= 0?
                AXI_ID_CHECK = false then
                    -- decrement counter, output the original axi id (saved axi id)
                    REGISTERS_CMD(i) <= '0';
                    ACTIVATE_REGISTERS(i) <= '1'; 
                    -- this should be cleared when the slaves put it to 0
                    M_AXI_VALID_RSP <= '1';
                    -- the axi id value will be kept till the next transaction
                    M_AXI_ID_RSP <= SAVED_MAPS((i+1)*EntryRange-COUNTER_WIDTH-AXI_ID_WIDTH-1 downto i*EntryRange); --output the remapped axi_id
                end if;
			end loop;
			
			if AXI_ID_CHECK = false then
			     error <= '1';
			end if; 
        elsif rising_edge(clk) then
            for i in 0 to POOL_SIZE loop
                REGISTERS_CMD(i) <= '0';
                ACTIVATE_REGISTERS(i) <= '0';
            end loop;
        end if;      
    end process;

end Behavioral;
