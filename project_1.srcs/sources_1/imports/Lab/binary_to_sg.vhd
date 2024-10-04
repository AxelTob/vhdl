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

LIBRARY ieee;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_1164.ALL;
ENTITY binary_to_sg IS
    PORT (
        binary_in : IN unsigned(3 DOWNTO 0);
        sev_seg : OUT unsigned(7 DOWNTO 0)
    );
END binary_to_sg;

ARCHITECTURE binary_to_sg_arch OF binary_to_sg IS
BEGIN
    PROCESS (binary_in)
    BEGIN
        sev_seg <= "10000110";
        IF binary_in = "0000" THEN
            sev_seg <= "11000000";
        ELSIF binary_in = "0001" THEN
            sev_seg <= "11111001";
        ELSIF binary_in = "0010" THEN
            sev_seg <= "10100100";
        ELSIF binary_in = "0011" THEN
            sev_seg <= "10110000";
        ELSIF binary_in = "0011" THEN
            sev_seg <= "10110000";
        ELSIF binary_in = "0100" THEN
            sev_seg <= "10011001";
        ELSIF binary_in = "0101" THEN
            sev_seg <= "10010010";
        ELSIF binary_in = "0110" THEN
            sev_seg <= "10000010";
        ELSIF binary_in = "0111" THEN
            sev_seg <= "11111000";
        ELSIF binary_in = "1000" THEN
            sev_seg <= "10000000";
        ELSIF binary_in = "1001" THEN
            sev_seg <= "10010000";
        ELSIF binary_in = "1110" THEN
            sev_seg <= "10000110";
        ELSIF binary_in = "1111" THEN
            sev_seg <= "11111111";
        END IF;
    END PROCESS;
END binary_to_sg_arch;