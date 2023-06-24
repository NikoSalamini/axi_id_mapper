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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity AXI_ID_Mapper is
    Port ( S_AWID : in STD_LOGIC_VECTOR(5 downto 0);
           S_ARID : in STD_LOGIC_VECTOR(5 downto 0);
           S_BID : in STD_LOGIC_VECTOR(5 downto 0);
           S_RID : in STD_LOGIC_VECTOR(5 downto 0);
           S_AWUSER: in STD_LOGIC_VECTOR(5 downto 0);
           S_ARUSER: in STD_LOGIC_VECTOR(5 downto 0);
           S_AWVALID: in STD_LOGIC;
           S_BVALID: in STD_LOGIC;
           S_ARVALID: in STD_LOGIC;
           S_RVALID: in STD_LOGIC;
           M_AWID : out STD_LOGIC_VECTOR(5 downto 0);
           M_ARID : out STD_LOGIC_VECTOR(5 downto 0);
           M_BID : out STD_LOGIC_VECTOR(5 downto 0);
           M_RID : out STD_LOGIC_VECTOR(5 downto 0)
           -- no need of M_AxUser cause PS-PL interface does not implement it
       );
end AXI_ID_Mapper;

architecture Behavioral of AXI_ID_Mapper is
    -- signals
    signal prev_AWID  : STD_LOGIC_VECTOR(5 downto 0);
begin
    -- WRITE CHANNEL
    process (S_AWVALID) 
    begin
        if (rising_edge (S_AWVALID)) -- new axi write transaction
            -- output the new mapping on M_AWID and update LUT
    end process;
    
    process (S_BVALID)
    begin
        if (rising_edge (S_BVALID)) -- new response write transaction
            -- output the new mapping on M_BID and update LUT
    end process;
    
    -- READ CHANNEL
    process (S_ARVALID) 
    begin
        if (rising_edge (S_ARVALID)) -- new axi read transaction
            -- output the new mapping on M_ARID and update LUT
    end process;
    
    process (S_RVALID)
    begin
        if (rising_edge (S_RVALID)) -- new response write transaction
            -- output the new mapping on M_RID and update LUT
    end process;

end Behavioral;
