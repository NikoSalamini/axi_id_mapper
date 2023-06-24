
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.all;

entity LUT_tb is
end LUT_tb;

architecture beh of LUT_tb is

	--const def
	constant clk_period	: time := 100 ns;
	constant new_transaction_period : time := 500 ns; -- the period between a new valid transaction
	constant NBit : positive := 8;

	--component dut
	component LUT is
	generic(
	    AxUSER: std_logic_vector(15 downto 0);
		FIRST_POOL_VALUE: integer := 0; -- the first value of the pool
		POOL_SIZE: integer := 8; -- the pool size
		VALUE_WIDTH: integer := 6; -- value width of the output axi id
		COUNTER_WIDTH: integer := 2 -- counter of active transactions with the same axi id
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
    end component;
    

	--signal of testbench
	signal clk_ext	: std_logic := '0' ;
	signal reset_ext 	: std_logic := '0' ;
	signal S_AxUSER_ext	: std_logic_vector(15 downto 0);
	signal S_AXI_ID_REQ_ext : std_logic_vector(5 downto 0);
	signal S_AXI_ID_RSP_ext : std_logic_vector(5 downto 0);
	signal S_VALID_REQ_ext  : std_logic := '0';
	signal S_VALID_RSP_ext  : std_logic := '0';
	signal M_AXI_ID_REQ_ext : std_logic_vector(5 downto 0);
	signal M_AXI_ID_RSP_ext : std_logic_vector(5 downto 0);
	signal error_ext : std_logic;
	signal testing	: boolean := true ;
	
	--testbench
	begin
		clk_ext <= not clk_ext after clk_period/2 when testing else '0';
		
		--component instantiation
        write_lut_def: LUT
        generic map (
            AxUSER => (others => '0'), -- 16 is the width of the AxUser signal
            POOL_SIZE => 8,
            FIRST_POOL_VALUE => 0
        )
        port map (
            clk => clk_ext,
            reset => reset_ext,
            S_AxUSER => S_AxUSER_ext, -- master id of the write transaction
            S_AXI_ID_REQ => S_AXI_ID_REQ_ext, -- incoming axi id request
            S_AXI_ID_RSP => S_AXI_ID_RSP_ext, -- incoming axi id response
            S_VALID_REQ  => S_VALID_REQ_ext, -- the valid signal of the request 
            S_VALID_RSP  => S_VALID_RSP_ext, -- the valid signal of the response
            M_AXI_ID_REQ => M_AXI_ID_REQ_ext, -- the output of the LUT with the remapped axi id for the request
            M_AXI_ID_RSP => M_AXI_ID_RSP_ext, -- the output of the LUT with the original axi id for the response
            error => error_ext
        );
		
		stimulus: process
		begin
			reset_ext <= '1';
			wait for 30 ns;
			reset_ext <= '0';
			S_AXI_ID_REQ_ext <= b"1000000";
			S_AxUSER_ext <= (others => '0');
			wait for 100 ns;
			S_VALID_REQ_ext <= '1';
			wait for 100 ns;
			S_VALID_REQ_ext <= '0';
			wait for 500 ns;
			
			wait until rising_edge(transaction_ext);
			d_ext <= b"00001000";
			wait until rising_edge(clk_ext);
			d_ext <= b"00001010";
			wait until rising_edge(clk_ext);
			d_ext <= b"00001001";
			wait until rising_edge(clk_ext);
			rst_ext <= '0';
			wait until rising_edge(clk_ext);
			testing <= false; 
		end process;
end beh;
	
	
	
