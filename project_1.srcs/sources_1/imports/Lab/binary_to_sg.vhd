-------------------------------------------------------------------------------
-- Title      : binary_to_sg.vhd 
-- Project    : Keyboard VLSI Lab
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Description: 
-- 	            Simple Look-Up-Table	
-- 		
--
-------------------------------------------------------------------------------

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;


entity binary_to_sg is
    port (
	     binary_in : in unsigned(3 downto 0);
	     sev_seg   : out unsigned(7 downto 0)
	 );
end binary_to_sg;

architecture binary_to_sg_arch of binary_to_sg is
begin
process(binary_in)
begin
    sev_seg <= "10000110";
    if binary_in = "0000" then
        sev_seg <= "11000000";
    elsif binary_in = "0001" then
        sev_seg <= "11111001";
    elsif binary_in = "0010" then
        sev_seg <= "10100100";     
    elsif binary_in = "0011" then
        sev_seg <= "10110000";
    elsif binary_in = "0011" then
        sev_seg <= "10110000";
    elsif binary_in = "0100" then
        sev_seg <= "10011001";
    elsif binary_in = "0101" then
        sev_seg <= "10010010";
    elsif binary_in = "0110" then
        sev_seg <= "10000010";
    elsif binary_in = "0111" then
        sev_seg <= "11111000";
    elsif binary_in = "1000" then
        sev_seg <= "10000000";
    elsif binary_in = "1001" then
        sev_seg <= "10010000";
    elsif binary_in = "1111" then
        sev_seg <= "10000110";
    end if;
end process;
end binary_to_sg_arch;
