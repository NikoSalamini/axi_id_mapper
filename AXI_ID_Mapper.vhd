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
end AXI_ID_Mapper;

architecture Structural of AXI_ID_Mapper is
    -- components
    -- LUT
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
    
    -- Multiplexer
    component Multiplexer is
        generic (
            Q : natural;     -- Number of bits in each input signal
            N : natural      -- Number of input signals
        );
        port (
            Sel : in std_logic_vector(N-1 downto 0);  -- Selection signal
            Inputs : in std_logic_vector((Q*N)-1 downto 0);  -- Input signals
            Output : out std_logic_vector(Q downto 0)  -- Output signal
        );
    end component;
    
    -- valid signals
    -- each one is connected to the VALID REQ input port of a LUT
    -- only one lut is activated depending on awuser
    -- those signals are the valid signal connected to the each write and read LUT for request/response. 
    -- One signal at time will be set to 1 to trigger the corresponding remapping
    signal valids_req_write: std_logic_vector(NMaster-1 downto 0) := (others => '0'); 
    signal valids_req_read: std_logic_vector(NMaster-1 downto 0) := (others => '0');
    signal valids_rsp_write: std_logic_vector(NMaster-1 downto 0) := (others => '0'); 
    signal valids_rsp_read: std_logic_vector(NMaster-1 downto 0) := (others => '0'); 
    
    -- each one is connected to the valid signals of the VALID REQ output port of a LUT
    -- those are the output valid signals of the LUT indicating that the remapping is ready
    signal valid_req_write_out: std_logic_vector(NMaster-1 downto 0) := (others => '0'); 
    signal valid_rsp_write_out: std_logic_vector(NMaster-1 downto 0) := (others => '0'); 
    signal valid_req_read_out: std_logic_vector(NMaster-1 downto 0) := (others => '0'); 
    signal valid_rsp_read_out: std_logic_vector(NMaster-1 downto 0) := (others => '0'); 
    
    -- each AXI_ID_WIDTH bits are connected to the M_AXI_ID port of the LUT. Those indicating the remapping for the write/read request/response.
    signal axi_ids_req_write: std_logic_vector( (NMaster*AXI_ID_WIDTH)-1 downto 0) := (others => '0'); 
    signal axi_ids_req_read: std_logic_vector( (NMaster*AXI_ID_WIDTH)-1 downto 0) := (others => '0');
    signal axi_ids_rsp_write: std_logic_vector( (NMaster*AXI_ID_WIDTH)-1 downto 0) := (others => '0');
    signal axi_ids_rsp_read: std_logic_vector( (NMaster*AXI_ID_WIDTH)-1 downto 0) := (others => '0');
    
    -- master axi valid signals
    -- write
    signal m_axi_awvalid: std_logic := '0';
    signal m_axi_bvalid: std_logic := '0';
    signal m_axi_awid: std_logic_vector(AXI_ID_WIDTH-1 downto 0) := (others => '0');
    signal m_axi_bid: std_logic_vector(AXI_ID_WIDTH-1 downto 0) := (others => '0');
    -- read
    signal m_axi_arvalid: std_logic := '0';
    signal m_axi_rvalid: std_logic := '0';
    signal m_axi_arid: std_logic_vector(AXI_ID_WIDTH-1 downto 0) := (others => '0');
    signal m_axi_rid: std_logic_vector(AXI_ID_WIDTH-1 downto 0) := (others => '0');
    
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
            M_AXI_VALID_REQ => valid_req_write_out(i),
            M_AXI_VALID_RSP => valid_rsp_write_out(i),
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
            M_AXI_VALID_REQ => valid_req_read_out(i),
            M_AXI_VALID_RSP => valid_rsp_read_out(i),
            error => error
		);
    end generate lut_def;
    
    -- At each moment, there can be at most 1 active request transaction and 1 response transaction for the write and read channel.
    -- This unit activate the correct lut when the valid response signal goes high, it shows it only to the LUT selected by AxUser.
    -- The output of AWID, ARID, BID and RID should be set only after the mapping is correctly done. When one of the luts output 1 to the valid signal, the 
    -- corresponding AxID, xID is set too and the output is mapped to the one of the activated lut.
    -- So the valid signal coming from the LUTs works like a ready signal to indicates that the mapping has been done and it is ready.
   
    -- --------------------------------------WRITE CHANNEL--------------------------------------------------------
    -- awvalid to '1' --> activate the register --> at rising of clock the enabler output the axi id and 
    -- set the ith valid output to 1 -->
    -- this unit see this change in valid_req_write_out, set awid and awvalid, put the valid signal to 0 so
    -- at the next clock no registers will be enabled
    
    -- AWUSER is not set in the sensitivity list because is certainly set when AWVALID is high 
    process(S_AWVALID, valid_req_write_out, axi_ids_req_write)
    begin
        -- if rising_edge (clk)
        if S_AWVALID = '1' and m_axi_awvalid = '0' then
            -- which to connect for mapping? Depend to AWUSER
            valids_req_write(natural(to_integer(unsigned(S_AWUSER)))) <= '1';
            -- check for new valid_req_write from the LUT
            for i in (NMaster-1) downto 0 loop
                if valid_req_write_out(i) = '1' then
                    m_axi_awid <= axi_ids_req_write((to_integer(unsigned(S_AWUSER)) + 1) * AXI_ID_WIDTH - 1 downto to_integer(unsigned(S_AWUSER)) * AXI_ID_WIDTH);
                    m_axi_awvalid <= '1';
                    valids_req_write <= (others => '0');
                end if;
            end loop;
        elsif S_AWVALID = '0' then
             m_axi_awvalid <= '0';
        end if;
     end process;
     
    -- response channel
    -- when the signal indicating a valid response id goes high then the correct lut is activated
    -- valid_rsp_write activate a LUT --> when the LUT is ready for the remapping it sets valid_rsp_write_out
    -- the axi id mapper see which one has been set and perform remapping
    -- when one of the luts set his valid signal, M_BID is updated
    process(S_BVALID, valid_rsp_write_out, axi_ids_rsp_write)
    begin
        if S_BVALID = '1' and m_axi_bvalid = '0' then
            -- which to connect for inverse mapping?
            for i in (NMaster - 1) downto 0 loop
                -- the match is based on the range
                -- i*POOL_SIZE_LUT is the first map assigned to the i-th LUT and FIRST_POOL_VALUE + POOL_SIZE -1 is the last
                if (to_unsigned(i*POOL_SIZE_LUT + POOL_SIZE_LUT - 1, AXI_ID_WIDTH) >= unsigned(S_BID)) 
                and (unsigned(S_BID)) >= (to_unsigned(i*POOL_SIZE_LUT, AXI_ID_WIDTH)) then
                    valids_rsp_write(i) <= '1';
                end if;
            end loop;
            -- check if the response is ready
            for i in (NMaster-1) downto 0 loop
            if valid_rsp_write_out(i) = '1' then
                m_axi_bid <= axi_ids_rsp_write((i+1)*AXI_ID_WIDTH -1 downto i*AXI_ID_WIDTH);
                m_axi_bvalid <= '1';
                valids_rsp_write <= (others => '0');
            end if;
            end loop;
        elsif S_BVALID = '0' then
             m_axi_bvalid <= '0';
        end if;
     end process;
     
     M_AWVALID <= m_axi_awvalid;
     M_AWID <= m_axi_awid;
     M_BVALID <= m_axi_bvalid;
     M_BID <= m_axi_bid;

    
    -- --------------------------------------WRITE CHANNEL--------------------------------------------------------
    
    -- --------------------------------------READ CHANNEL---------------------------------------------------------
    process(S_ARVALID, valid_req_read_out, axi_ids_req_read)
    begin
        if S_ARVALID = '1' and m_axi_arvalid = '0' then
            -- which to connect for mapping? Depend to AWUSER
            valids_req_read(natural(to_integer(unsigned(S_ARUSER)))) <= '1';
            for i in (NMaster-1) downto 0 loop
                if valid_req_read_out(i) = '1' then
                    m_axi_arid <= axi_ids_req_read((to_integer(unsigned(S_ARUSER)) + 1) * AXI_ID_WIDTH - 1 downto to_integer(unsigned(S_ARUSER)) * AXI_ID_WIDTH);
                    m_axi_arvalid <= '1';
                    valids_req_read <= (others => '0');
                end if;
            end loop;
        elsif S_ARVALID = '0' then
             m_axi_arvalid <= '0';
        end if;
     end process;
    
    -- when one of the luts set his valid signal, M_ARID is updated
    process(S_RVALID, valid_rsp_read_out, axi_ids_rsp_read)
    begin
        if S_RVALID = '1' and m_axi_rvalid = '0' then
            -- which to connect for inverse mapping?
            for i in (NMaster - 1) downto 0 loop
                -- the match is based on the range
                -- i*POOL_SIZE_LUT is the first map assigned to the i-th LUT and FIRST_POOL_VALUE + POOL_SIZE -1 is the last
                if (to_unsigned(i*POOL_SIZE_LUT + POOL_SIZE_LUT - 1, AXI_ID_WIDTH) >= unsigned(S_RID)) 
                and (unsigned(S_RID)) >= (to_unsigned(i*POOL_SIZE_LUT, AXI_ID_WIDTH)) then
                    valids_rsp_read(i) <= '1';
                end if;
            end loop;
            for i in (NMaster-1) downto 0 loop
                if valid_rsp_read_out(i) = '1' then
                    m_axi_rid <= axi_ids_rsp_read((i+1)*AXI_ID_WIDTH -1 downto i*AXI_ID_WIDTH);
                    m_axi_rvalid <= '1';
                    valids_rsp_read <= (others => '0');
                end if;
            end loop;
        elsif S_RVALID = '0' then
             m_axi_rvalid <= '0';
        end if;
     end process;
     
     M_ARVALID <= m_axi_arvalid;
     M_ARID <= m_axi_arid;
     M_RVALID <= m_axi_rvalid;
     M_RID <= m_axi_rid;
    
    
    
    -- --------------------------------------READ CHANNEL---------------------------------------------------------

end Structural;
