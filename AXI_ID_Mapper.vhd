----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.06.2023 16:30:36
-- Design Name: 
-- Module Name: AXI_ID_Mapper - Behavioral
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
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- NOTE: Use incremental master for AxUser signals!
entity AXI_ID_Mapper is
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
           M_AWID : out STD_LOGIC_VECTOR(5 downto 0);
           M_ARID : out STD_LOGIC_VECTOR(5 downto 0);
           M_BID : out STD_LOGIC_VECTOR(5 downto 0);
           M_RID : out STD_LOGIC_VECTOR(5 downto 0);
           error : out std_logic
       );
end AXI_ID_Mapper;

architecture Structural of AXI_ID_Mapper is
    -- components
    component LUT is
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
    end component;
    
    -- valid signals
    -- each one is connected to the VALID REQ input port of a LUT
    -- only one lut is activated depending on awuser
    signal valids_req_write: std_logic_vector(NMaster-1 downto 0) := (others => '0'); 
    signal valids_req_read: std_logic_vector(NMaster-1 downto 0) := (others => '0');
    -- each one is connected to the VALID RSP input port of a LUT
    signal valids_rsp_write: std_logic_vector(NMaster-1 downto 0) := (others => '0'); 
    signal valids_rsp_read: std_logic_vector(NMaster-1 downto 0) := (others => '0'); 
    -- each AXI_ID_WIDTH bits are connected to the M_AXI_ID port of the LUT
    signal axi_ids_req_write: std_logic_vector( (NMaster*AXI_ID_WIDTH)-1 downto 0) := (others => '0'); 
    signal axi_ids_req_read: std_logic_vector( (NMaster*AXI_ID_WIDTH)-1 downto 0) := (others => '0');
    signal axi_ids_rsp_write: std_logic_vector( (NMaster*AXI_ID_WIDTH)-1 downto 0) := (others => '0');
    signal axi_ids_rsp_read: std_logic_vector( (NMaster*AXI_ID_WIDTH)-1 downto 0) := (others => '0');
begin
    -- each master has its own write and read LUT
    -- define the initial values to not overlap between the LUTs
    -- NOTE: It considers incremental masters
    lut_def: for i in (NMaster - 1) downto 0 generate
    
    -- WRITE CHANNEL
    write_lut_def: LUT
        generic map (
            POOL_SIZE => POOL_SIZE_LUT,
            FIRST_POOL_VALUE => i*POOL_SIZE_LUT,
            AXI_ID_WIDTH => AXI_ID_WIDTH
        )
		port map (
            clk => clk,
            reset => reset,
            S_AXI_ID_REQ => S_AWID, -- incoming axi id request
            S_AXI_ID_RSP => S_BID, -- incoming axi id response
            S_VALID_REQ  => valids_req_write(i), -- the valid signal of the request 
            S_VALID_RSP  => valids_rsp_write(i), -- the valid signal of the response
            M_AXI_ID_REQ => axi_ids_req_write( ((i+1)*AXI_ID_WIDTH-1) downto (i)*AXI_ID_WIDTH ), -- the output of the LUT with the remapped axi id for the request
            M_AXI_ID_RSP => axi_ids_rsp_write( ((i+1)*AXI_ID_WIDTH-1) downto (i)*AXI_ID_WIDTH ), -- the output of the LUT with the original axi id for the response
            error => error
		);
	
		
    -- READ CHANNEL
    read_lut_def: LUT
        generic map (
            POOL_SIZE => POOL_SIZE_LUT,
            FIRST_POOL_VALUE => i*POOL_SIZE_LUT,
            AXI_ID_WIDTH => AXI_ID_WIDTH
        )
		port map (
            clk => clk,
            reset => reset,
            S_AXI_ID_REQ => S_ARID, -- incoming axi id request
            S_AXI_ID_RSP => S_RID, -- incoming axi id response
            S_VALID_REQ  => valids_req_read(i), -- the valid signal of the request 
            S_VALID_RSP  => valids_rsp_read(i), -- the valid signal of the response
            M_AXI_ID_REQ => axi_ids_req_read( ((i+1)*AXI_ID_WIDTH-1) downto (i)*AXI_ID_WIDTH ), -- the output of the LUT with the remapped axi id for the request
            M_AXI_ID_RSP => axi_ids_rsp_read( ((i+1)*AXI_ID_WIDTH-1) downto (i)*AXI_ID_WIDTH ), -- the output of the LUT with the original axi id for the response
            error => error
		);
    end generate lut_def;
    
    --NEED A MULTIPLEXER TO CONNECT ONE OF THE OUTPUT OF THE LUT TO THE OUTPUT
    -- M_AXI_ID_REQ <= 
    -- M_AXI_ID_RSP <= 
    
    -- WRITE CHANNEL
    process(S_AWVALID)
    begin
        -- which to connect for mapping? Depend to AWUSER
        valids_req_write(natural(to_integer(unsigned(S_AWUSER)))) <= S_AWVALID;
    end process;
    
    -- response channel
    process(S_BID)
    begin
        -- which to connect for inverse mapping?
        for i in (NMaster - 1) downto 0 loop
            if (to_unsigned(i*POOL_SIZE_LUT + POOL_SIZE_LUT - 1, AXI_ID_WIDTH) >= unsigned(S_BID)) 
            and (unsigned(S_BID)) >= (to_unsigned(i*POOL_SIZE_LUT, AXI_ID_WIDTH)) then
                valids_rsp_write(i) <= S_BVALID;
            end if;
        end loop;
    end process;
    
    -- READ CHANNEL
        -- request channel
    process(S_ARVALID)
    begin
        -- which to connect for mapping? Depend to ARUSER
        valids_req_read(natural(to_integer(unsigned(S_ARUSER)))) <= S_ARVALID;
    end process;
    
    -- response channel
    process(S_RID)
    begin
        -- which to connect for inverse mapping?
        for i in (NMaster - 1) downto 0 loop
            if (to_unsigned(i*POOL_SIZE_LUT + POOL_SIZE_LUT - 1, AXI_ID_WIDTH) >= unsigned(S_RID)) 
            and (unsigned(S_RID)) >= (to_unsigned(i*POOL_SIZE_LUT, AXI_ID_WIDTH)) then
                valids_rsp_read(i) <= S_RVALID;
            end if;
        end loop;
    end process;

end Structural;
