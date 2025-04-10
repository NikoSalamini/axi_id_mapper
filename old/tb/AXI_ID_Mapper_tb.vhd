library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.all;

entity AXI_ID_Mapper_tb is
end AXI_ID_Mapper_tb;

architecture beh of AXI_ID_Mapper_tb is

	--const def
	constant clk_period	: time := 100 ns;
	constant NBit : positive := 8;
	
	-- component AXI_ID_MAPPER
	component AXI_ID_Mapper is
    generic (
        NMaster : positive := 2;
        POOL_SIZE_LUT: positive := 8;
        AXI_ID_WIDTH : positive := 6
    );
    port ( 
           clk	: in std_logic;
		   reset: in std_logic;
           S_AWID : in STD_LOGIC_VECTOR(5 downto 0);
           S_ARID : in STD_LOGIC_VECTOR(5 downto 0);
           S_BID : in STD_LOGIC_VECTOR(5 downto 0);
           S_RID : in STD_LOGIC_VECTOR(5 downto 0);
           S_AWUSER: in STD_LOGIC_VECTOR(15 downto 0);
           S_ARUSER: in STD_LOGIC_VECTOR(15 downto 0);
           S_AWVALID: in STD_LOGIC;
           S_BVALID: in STD_LOGIC;
           S_ARVALID: in STD_LOGIC;
           S_RVALID: in STD_LOGIC;
           M_AWVALID: out STD_LOGIC;
           M_ARVALID: out STD_LOGIC;
           M_BVALID: out STD_LOGIC;
           M_RVALID: out STD_LOGIC;
           M_AWID : out STD_LOGIC_VECTOR(5 downto 0);
           M_ARID : out STD_LOGIC_VECTOR(5 downto 0);
           M_BID : out STD_LOGIC_VECTOR(5 downto 0);
           M_RID : out STD_LOGIC_VECTOR(5 downto 0);
           error : out std_logic
       );
    end component;
    
    --signal of testbench
	signal clk_ext	: std_logic := '0' ;
	signal reset_ext 	: std_logic := '0' ;
	signal S_AWID_ext : STD_LOGIC_VECTOR(5 downto 0);
    signal S_ARID_ext : STD_LOGIC_VECTOR(5 downto 0);
    signal S_BID_ext : STD_LOGIC_VECTOR(5 downto 0);
    signal S_RID_ext : STD_LOGIC_VECTOR(5 downto 0);
    signal S_AWUSER_ext: STD_LOGIC_VECTOR(15 downto 0);
    signal S_ARUSER_ext: STD_LOGIC_VECTOR(15 downto 0);
    signal S_AWVALID_ext: STD_LOGIC := '0';
    signal S_BVALID_ext: STD_LOGIC := '0';
    signal S_ARVALID_ext: STD_LOGIC := '0';
    signal S_RVALID_ext: STD_LOGIC := '0';
    signal M_AWVALID_ext: STD_LOGIC;
    signal M_ARVALID_ext: STD_LOGIC;
    signal M_BVALID_ext: STD_LOGIC;
    signal M_RVALID_ext: STD_LOGIC;
    signal M_AWID_ext : STD_LOGIC_VECTOR(5 downto 0);
    signal M_ARID_ext : STD_LOGIC_VECTOR(5 downto 0);
    signal M_BID_ext : STD_LOGIC_VECTOR(5 downto 0);
    signal M_RID_ext : STD_LOGIC_VECTOR(5 downto 0);
    signal error_ext : STD_LOGIC;
	signal testing	: boolean := true ;
	signal stage   : integer := 1;
	
	--testbench
	begin
		clk_ext <= not clk_ext after clk_period/2 when testing else '0';
		
		--component instantiation
		AXI_ID_Mapper_def: AXI_ID_Mapper
        port map( 
               clk => clk_ext,
               reset => reset_ext,
               S_AWID => S_AWID_ext,
               S_ARID => S_ARID_ext,
               S_BID => S_BID_ext,
               S_RID => S_RID_ext,
               S_AWUSER =>  S_AWUSER_ext,
               S_ARUSER =>  S_ARUSER_ext,
               S_AWVALID => S_AWVALID_ext,
               S_BVALID => S_BVALID_ext,
               S_ARVALID => S_ARVALID_ext,
               S_RVALID => S_RVALID_ext,
               M_AWVALID => M_AWVALID_ext,
               M_ARVALID => M_ARVALID_ext,
               M_BVALID => M_BVALID_ext,
               M_RVALID => M_RVALID_ext,
               M_AWID => M_AWID_ext,
               M_ARID => M_ARID_ext,
               M_BID => M_BID_ext,
               M_RID => M_RID_ext,
               error => error_ext
           );
           
        -- first test works: normal sequential remapping
--        stimulus: process
--		begin
--            reset_ext <= '1';
--            wait for 200 ns;
--            reset_ext <= '0';
--            S_AWUSER_ext <= b"0000000000000000"; 
--            S_AWID_ext <= b"100000"; -- remap to 000000-000111 (this remap to 000000)
--            wait for 100 ns;
--            S_AWVALID_ext <= '1';
--            wait for 500 ns;
--            S_AWVALID_ext <= '0';
--            wait for 100 ns;
--            S_AWUSER_ext <= b"0000000000000001"; -- remap to 001000-001111 (this remap to 001000)
--            S_AWID_ext <= b"010000";
--            wait for 100 ns;
--            S_AWVALID_ext <= '1';
--            wait for 500 ns;
--            S_AWVALID_ext <= '0';
--            wait for 100 ns;
--            S_BID_ext <= b"000000"; -- remap to saved 100000 on the first awuser of all zeros
--            wait for 100 ns;
--            S_BVALID_ext <= '1';
--            wait for 100 ns;
--            S_BVALID_ext <= '0';
--            wait for 3000 ns;
--            testing <= false; 
--		end process;
		
		stimulus: process
		begin
            reset_ext <= '1';
            wait for 200 ns;
            reset_ext <= '0';
            
            -- stage 1
            stage <= 1;
            S_AWUSER_ext <= b"0000000000000000"; 
            S_AWID_ext <= b"100000"; -- remap to 000000-000111 (this remap to 000000)
            wait for 100 ns;
            S_AWVALID_ext <= '1';
            wait for 300 ns;
            S_AWVALID_ext <= '0';
            wait for 100 ns;
            
            -- stage 2
            stage <= 2;
            S_AWUSER_ext <= b"0000000000000001"; -- remap to 001000-001111 (this remap to 001000)
            S_AWID_ext <= b"010000";
            wait for 100 ns;
            S_AWVALID_ext <= '1';
            wait for 300 ns;
            S_AWVALID_ext <= '0';
            wait for 100 ns;
            
            -- stage 3
            stage <= 3;
            S_AWUSER_ext <= b"0000000000000001"; -- remap to 001000-001111 (this remap to 001000)
            S_AWID_ext <= b"010000";
            wait for 100 ns;
            S_AWVALID_EXT <= '1';
            wait for 300 ns;
            S_AWVALID_EXT <= '0';
            wait for 100 ns;
            
            --stage 4
            stage <= 4;
            S_BID_ext <= b"001000"; -- remap to saved 100000 on the first awuser of all zeros
            wait for 100 ns;
            S_BVALID_ext <= '1';
            wait for 300 ns;
            S_BVALID_ext <= '0';
            wait for 100 ns;
            
            -- stage 5
            stage <= 5;
            S_AWUSER_ext <= b"0000000000000001"; -- remap to 001000-001111 (this remap to 001000)
            S_AWID_ext <= b"010000";
            wait for 100 ns;
            S_AWVALID_EXT <= '1';
            wait for 300 ns;
            S_AWVALID_EXT <= '0';
            wait for 100 ns;
            
            -- stage 6
            stage <= 6;
            S_BID_ext <= b"001000"; -- remap to saved 000000 on the first awuser of all zeros
            wait for 100 ns;
            S_BVALID_ext <= '1';
            wait for 300 ns;
            S_BVALID_ext <= '0';
            wait for 100 ns;
            
            -- stage 7
            stage <= 7;
            S_BID_ext <= b"000000"; -- remap to saved 100000 on the first awuser of all zeros
            wait for 100 ns;
            S_BVALID_ext <= '1';
            wait for 300 ns;
            S_BVALID_ext <= '0';
             
            
            -- READ
            
            -- stage 8
            stage <= 8;
            S_ARUSER_ext <= b"0000000000000000"; 
            S_ARID_ext <= b"100000"; -- remap to 000000-000111 (this remap to 000000)
            wait for 100 ns;
            S_ARVALID_ext <= '1';
            wait for 300 ns;
            S_ARVALID_ext <= '0';
            wait for 100 ns;
            
            -- stage 9
            stage <= 9;
            S_ARUSER_ext <= b"0000000000000001"; -- remap to 001000-001111 (this remap to 001000)
            S_ARID_ext <= b"010000";
            wait for 100 ns;
            S_ARVALID_ext <= '1';
            wait for 300 ns;
            S_ARVALID_ext <= '0';
            wait for 100 ns;
            
            -- stage 10
            stage <= 10;
            S_ARUSER_ext <= b"0000000000000001"; -- remap to 001000-001111 (this remap to 001000)
            S_ARID_ext <= b"010000";
            wait for 100 ns;
            S_ARVALID_EXT <= '1';
            wait for 300 ns;
            S_ARVALID_EXT <= '0';
            wait for 100 ns;
            
            --stage 11
            stage <= 11;
            S_RID_ext <= b"001000"; -- remap to saved 100000 on the first awuser of all zeros
            wait for 100 ns;
            S_RVALID_ext <= '1';
            wait for 300 ns;
            S_RVALID_ext <= '0';
            wait for 100 ns;
            
            -- stage 12
            stage <= 12;
            S_ARUSER_ext <= b"0000000000000001"; -- remap to 001000-001111 (this remap to 001000)
            S_ARID_ext <= b"010000";
            wait for 100 ns;
            S_ARVALID_EXT <= '1';
            wait for 300 ns;
            S_ARVALID_EXT <= '0';
            wait for 100 ns;
            
            -- stage 13
            stage <= 13;
            S_RID_ext <= b"001000"; -- remap to saved 000000 on the first awuser of all zeros
            wait for 100 ns;
            S_RVALID_ext <= '1';
            wait for 300 ns;
            S_RVALID_ext <= '0';
            wait for 100 ns;
            
            -- stage 14
            stage <= 14;
            S_RID_ext <= b"000000"; -- remap to saved 100000 on the first awuser of all zeros
            wait for 100 ns;
            S_RVALID_ext <= '1';
            wait for 300 ns;
            S_RVALID_ext <= '0';
            
            wait for 3000 ns;
            testing <= false;
		end process;
    end;
