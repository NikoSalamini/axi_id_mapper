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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- LUT_FWD: this LUT takes in input the AXI ID and output another one, taken from a pool of values, to M_AXI_ID 
-- It marks the AXI IDs already in use of the pool and remember the original one. The marks consists in setting to 1 the MSB bit of the AXI_ID (could be implemented as counter!) 
	--for example [7:6] is counter and [5:0] is axi id, if the MSB are more than 0 it is in use
-- An entry is cleaned when valid_clean is asserted and 
entity LUT is
	generic(
	    AxUSER: std_logic_vector(15 downto 0); -- work as an enable for the LUT
		FIRST_POOL_VALUE: natural := 0; -- the first value of the pool, the next depends are generated until POOL_SIZE-1
		POOL_SIZE: positive := 8; -- the pool size
		VALUE_WIDTH: positive := 6; -- value width of the output axi id
		COUNTER_WIDTH: positive := 2 -- counter of active transactions with the same axi id
	);
    port ( 
		clk	: in std_logic;
		reset: in std_logic;
		S_AxUSER: in std_logic_vector(15 downto 0);
        S_AXI_ID_REQ : in std_logic_vector(5 downto 0);
        S_AXI_ID_RSP : in std_logic_vector(5 downto 0);
        S_VALID_REQ: in std_logic; -- the valid signal of the request 
        S_VALID_RSP: in std_logic; -- the valid signal of the response
        M_AXI_ID_REQ: out std_logic_vector(5 downto 0);
        M_AXI_ID_RSP: out std_logic_vector(5 downto 0);
        error: out std_logic := '0'
    );
end LUT;

architecture Behavioral of LUT is

-- NBitRegister component
-- It will hold: USED_COUNTER [13:12] | ORIGINAL_AXI_ID [11:6] | REMAPPED_AXI_ID [5:0]
component NBitRegister is
	generic (
		N       : positive := 8
	);
    port (
		clk     : in  std_logic := '0';
        reset   : in  std_logic := '0';
        data_in : in  std_logic_vector(N-1 downto 0);
        q       : out std_logic_vector(N-1 downto 0)
	);
end component;

-- signals
type t_signal_array is array (0 to POOL_SIZE-1) of std_logic_vector(COUNTER_WIDTH+(2*VALUE_WIDTH)-1 downto 0);
signal registers_input  : t_signal_array;
signal registers_output  : t_signal_array;

-- constant
constant InitCounter : std_logic_vector(COUNTER_WIDTH-1 downto 0) := (others => '0');
constant InitMappedAxiId : std_logic_vector(VALUE_WIDTH-1 downto 0) := (others => '0');
constant CounterMax: std_logic_vector(COUNTER_WIDTH-1 downto 0) := (others => '1');

begin
    process
    begin
        for i in 0 to POOL_SIZE-1 loop
          registers_input(i) <= InitCounter & InitMappedAxiId & std_logic_vector(to_unsigned(FIRST_POOL_VALUE + i, VALUE_WIDTH));
        end loop;
	   wait;
	end process;
    
	registers_def : for i in (POOL_SIZE - 1) downto 0 generate
		single_register_def: NBitRegister
		generic map (N => VALUE_WIDTH)
		port map ( 	clk => clk,
		            data_in => registers_input(i),
					reset => reset,
					q => registers_output(i)
		);
	end generate registers_def;
	
	-- VALID_REQ PROCESS
    process(S_VALID_REQ)
    variable FREE_CHECK : boolean;
    variable AXI_ID_CHECK : boolean;
    begin
        -- the write channel of the lut is activated on a valid transaction only if there is a match 
        -- with the predefined AxUSER
        if rising_edge(S_VALID_REQ) and S_AxUSER = AxUSER then 
            -- used to not considering the execution of the subsequent ifs
            AXI_ID_CHECK := false; 
            FREE_CHECK := false;
            
            -- 1) check if there is axi id match
            -- -counter must be >= 1 to be in use
            -- -if the counter is max, all one, an error is raised indicating that the maximum number of transaction for an axi id
            -- has neem reached
            for i in 0 to POOL_SIZE-1 loop
				if (registers_output(i)(2*VALUE_WIDTH-1 downto VALUE_WIDTH) = S_AXI_ID_REQ) -- saved AXI ID match
				   and (registers_output(i)(2*VALUE_WIDTH+COUNTER_WIDTH-1 downto 2*VALUE_WIDTH) >= std_logic_vector(to_unsigned(1, COUNTER_WIDTH))) -- counter at least 1
				   and (AXI_ID_CHECK = false)  then
				   
				   -- axi id match
				    AXI_ID_CHECK := true;
				    
				    -- the entry reached counter_max? y/n
                    if registers_output(i)(2*VALUE_WIDTH+COUNTER_WIDTH -1 downto 2*VALUE_WIDTH) = CounterMax then 
                        error <= '1';
                    else
                        -- increment counter, save the mapped AXI ID, output the remapped AXI ID
                        registers_input(i) <= 
                            std_logic_vector(unsigned(registers_output(i)(2*VALUE_WIDTH+COUNTER_WIDTH -1 downto 2*VALUE_WIDTH) + 1)) -- COUNTER + 1
                            & S_AXI_ID_REQ -- AXI_ID in input to be saved
                            & registers_output(i) (VALUE_WIDTH-1 downto 0); -- AXI_ID_REMAPPED to the output (constant for each entry)
                        M_AXI_ID_REQ <= std_logic_vector(registers_output(i)(VALUE_WIDTH-1 downto 0)); -- output
                    end if;
                end if;
			end loop;
            
            -- 2) if no AXI_ID match, check if there is a free axi id  
            -- -check for entries with counter = 0
            -- -if there are no FREE AXI IDs generate error  
			for i in 0 to POOL_SIZE-1 loop
				if (registers_output(i)(2*VALUE_WIDTH+COUNTER_WIDTH-1 downto VALUE_WIDTH+1) = std_logic_vector(to_unsigned(0, COUNTER_WIDTH))) 
				and (FREE_CHECK = false) 
				and (AXI_ID_CHECK = false) then
                    FREE_CHECK := true;                  
					-- increment counter, save the mapped AXI ID, output the remapped AXI ID
                    registers_input(i) <= 
                        std_logic_vector(unsigned(registers_output(i)(2*VALUE_WIDTH+COUNTER_WIDTH -1 downto 2*VALUE_WIDTH) + 1)) -- COUNTER + 1
                        & S_AXI_ID_REQ -- AXI_ID in input to be saved
                        & registers_output(i) (VALUE_WIDTH-1 downto 0); -- AXI_ID_REMAPPED
					M_AXI_ID_REQ <= std_logic_vector(registers_output(i)(VALUE_WIDTH-1 downto 0)); --output the remapped axi_id
				end if;
			end loop;
			
			-- if the research indicates no axi id match neither free axi ids then error is set
			if FREE_CHECK = false and AXI_ID_CHECK = FALSE then 
                error <= '1';
            end if;
        end if;
        
    end process;
    
    -- VALID RSP PROCESS
    process(S_VALID_RSP)
    variable FREE_CHECK : boolean;
    variable AXI_ID_CHECK : boolean;
    begin
        -- the read channel of the lut is activated on a valid transaction only if there is a match 
        -- with the predefined AxUSER
        if rising_edge(S_VALID_RSP) and S_AxUSER = AxUSER then -- valid response transaction is ready
            -- used to not considering the execution of the subsequent ifs
            AXI_ID_CHECK := false; 
            
            -- 1) find the corresponding axi id to remap
            -- counter must not be 0
            for i in 0 to POOL_SIZE-1 loop
				if (registers_output(i)(VALUE_WIDTH-1 downto 0) = S_AXI_ID_RSP) -- REMAPPED AXI ID MATCH
				and (registers_output(i)(2*VALUE_WIDTH+COUNTER_WIDTH-1 downto 2*VALUE_WIDTH) /= std_logic_vector(to_unsigned(0, COUNTER_WIDTH))) -- counter /= 0
				and (AXI_ID_CHECK = false)  then
				    AXI_ID_CHECK := true;
                    -- decrement counter, remove saved axi id, output the original axi id (saved axi id)
                    registers_input(i) <= 
                        std_logic_vector(to_unsigned(0, COUNTER_WIDTH)) -- COUNTER = 0
                        & std_logic_vector(to_unsigned(0, VALUE_WIDTH)) -- REMOVE SAVED_AXI_ID
                        & registers_output(i) (VALUE_WIDTH-1 downto 0); -- AXI_ID_REMAPPED
                    M_AXI_ID_RSP <= std_logic_vector(registers_output(i)(2*VALUE_WIDTH-1 downto VALUE_WIDTH)); -- output the original AXI ID
                end if;
			end loop;
			
			if AXI_ID_CHECK = false then
			     error <= '1';
			end if;
        end if;        
    end process;

end Behavioral;
