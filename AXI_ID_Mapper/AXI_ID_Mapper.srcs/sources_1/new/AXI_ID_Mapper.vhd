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
           M_AWID : out STD_LOGIC_VECTOR(5 downto 0);
           M_ARID : out STD_LOGIC_VECTOR(5 downto 0);
           M_BID : out STD_LOGIC_VECTOR(5 downto 0);
           M_RID : out STD_LOGIC_VECTOR(5 downto 0)
           -- no need of M_AxUser cause PS-PL interface does not implement it
       );
end AXI_ID_Mapper;

architecture Behavioral of AXI_ID_Mapper is
    signal prev_AWID  : STD_LOGIC_VECTOR(5 downto 0);
    signal prev_AWUSER: STD_LOGIC_VECTOR(5 downto 0);
    signal counter1   : STD_LOGIC_VECTOR(7 downto 0);
    signal counter2   : STD_LOGIC_VECTOR(7 downto 0);
    signal 
begin
    process (S_AWID, S_AWUSER) -- actually is when
    begin
        if S_AWID /= prev_AWID then
            if prev_AWUSER = "000001" then
                counter1 <= counter1 + 1;
            elsif prev_AWUSER = "000010" then
                counter2 <= counter2 + 1;
            end if;
        end if;
        prev_AWID   <= S_AWID;
        prev_AWUSER <= S_AWUSER;
    end process;

end Behavioral;
