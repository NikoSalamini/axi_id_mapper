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
		FIRST_POOL_VALUE: integer := 0; -- the first value of the pool
		POOL_SIZE: integer := 8; -- the pool size
		VALUE_WIDTH: integer := 8; -- value width of the output axi id
		COUNTER_WIDTH: integer := 2 -- counter of active transactions with the same axi id
	);
    port ( 
		clk	: in std_logic;
		reset: in std_logic;
        S_AXI_ID : in std_logic_vector(5 downto 0);
        S_VALID_REQ: in std_logic; -- the valid signal of the request 
        S_VALID_RSP: in std_logic; -- the valid signal of the response
        M_AXI_ID: out std_logic_vector(5 downto 0)
    );
end LUT;

architecture Behavioral of LUT is

-- NBitRegister component
-- It will hold: USED_COUNTER | ORIGINAL_AXI_ID | REMAPPED_AXI_ID
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
constant CounterMax : std_logic_vector(COUNTER_WIDTH-1 downto 0) := (others => '1');

begin
    initialize_registers: process
    begin
        for i in 0 to POOL_SIZE-1 loop
          registers_input(i) <= InitCounter & InitMappedAxiId & std_logic_vector(to_unsigned(FIRST_POOL_VALUE + i, VALUE_WIDTH));
        end loop;
    end process initialize_registers;
    
	registers_def : for i in (POOL_SIZE - 1) downto 0 generate
		single_register_def: NBitRegister
		generic map (N => VALUE_WIDTH)
		port map ( 	clk => clk,
		            data_in => registers_input(i),
					reset => reset,
					q => registers_output(i)
		);
	end generate registers_def;
	
    process(S_VALID_REQ)
    variable FREE_CHECK : boolean;
    begin
        if rising_edge(S_VALID_REQ) then -- valid request transaction is ready
            FREE_CHECK := false;
            -- check which value of the pool is free and assign to output, update the original AXI ID
            if registers_output(0)(VALUE_WIDTH+COUNTER_WIDTH-1 downto VALUE_WIDTH+1) = CounterMax  then
                -- save the input AXI ID
                
                -- new mapped AXI ID
                registers_input(0) <= std_logic_vector( unsigned(registers_output(0)) + 1);
                M_AXI_ID <= std_logic_vector(registers_output(0)(VALUE_WIDTH-1 downto 0));
                FREE_CHECK := true;
            end if;
            
			for i in 1 to POOL_SIZE-1 loop
				if (registers_output(i)(VALUE_WIDTH+COUNTER_WIDTH-1 downto VALUE_WIDTH+1) = CounterMax) and (FREE_CHECK = false) then
					registers_input(0) <= std_logic_vector( unsigned(registers_output(0)) + 1);
					M_AXI_ID <= std_logic_vector(registers_output(i)(VALUE_WIDTH-1 downto 0));
					FREE_CHECK := true;
				end if;
			end loop;
        end if;
        
    end process;
    
    process(S_VALID_RSP)
        if rising_edge(S_VALID_RSP)) then -- valid response transaction is ready
            
        end if;
        
    end 

end Behavioral;
