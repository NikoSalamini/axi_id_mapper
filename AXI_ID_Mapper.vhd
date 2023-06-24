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
        POOL_SIZE_LUT: positive := 8
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
    
    -- signals
    signal prev_AWID  : STD_LOGIC_VECTOR(5 downto 0);
begin
    -- each master has its own write and read LUT
    -- define the initial values to not overlap between the LUTs
    -- NOTE: It considers incremental masters
    lut_def: for i in (NMaster - 1) downto 0 generate
    
    -- WRITE CHANNEL
        write_lut_def: LUT
        generic map (
            AxUSER => std_logic_vector(to_unsigned(i, 16)), -- 16 is the width of the AxUser signal
            POOL_SIZE => POOL_SIZE_LUT,
            FIRST_POOL_VALUE => i*POOL_SIZE_LUT
        )
		port map (
            clk => clk,
            reset => reset,
            S_AxUSER => S_AWUSER, -- master id of the write transaction
            S_AXI_ID_REQ => S_AWID, -- incoming axi id request
            S_AXI_ID_RSP => S_BID, -- incoming axi id response
            S_VALID_REQ  => S_AWVALID, -- the valid signal of the request 
            S_VALID_RSP  => S_BVALID, -- the valid signal of the response
            M_AXI_ID_REQ => M_AWID, -- the output of the LUT with the remapped axi id for the request
            M_AXI_ID_RSP => M_BID, -- the output of the LUT with the original axi id for the response
            error => error
		);
		
    -- READ CHANNEL
        read_lut_def: LUT
        generic map (
            AxUSER => std_logic_vector(to_unsigned(i, 16)), -- 16 is the width of the AxUser signal
            POOL_SIZE => POOL_SIZE_LUT,
            FIRST_POOL_VALUE => i*POOL_SIZE_LUT
        )
		port map (
            clk => clk,
            reset => reset,
            S_AxUSER => S_ARUSER, -- master id of the write transaction
            S_AXI_ID_REQ => S_ARID, -- incoming axi id request
            S_AXI_ID_RSP => S_RID, -- incoming axi id response
            S_VALID_REQ  => S_ARVALID, -- the valid signal of the request 
            S_VALID_RSP  => S_RVALID, -- the valid signal of the response
            M_AXI_ID_REQ => M_ARID, -- the output of the LUT with the remapped axi id for the request
            M_AXI_ID_RSP => M_RID, -- the output of the LUT with the original axi id for the response
            error => error
		);
    end generate lut_def;

end Structural;
