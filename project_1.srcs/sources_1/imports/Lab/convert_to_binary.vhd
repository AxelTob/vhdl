-------------------------------------------------------------------------------
-- Title : convert_to_binary.vhd
-- Project : Keyboard VLSI Lab
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Description:
-- Look-up-Table
-- 
--
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_1164.ALL;
ENTITY convert_to_binary IS
	PORT (
		scan_code_in : IN unsigned(7 DOWNTO 0);
		binary_out : OUT unsigned(3 DOWNTO 0)
	);
END convert_to_binary;
-- bool to determine if we have gotten F0'h. Only then we'll -> binary_out
ARCHITECTURE convert_to_binary_arch OF convert_to_binary IS
BEGIN
	PROCESS (scan_code_in)
	BEGIN
		IF scan_code_in = "00010110" THEN
			binary_out <= "0001";
		ELSIF scan_code_in = "00011110" THEN
			binary_out <= "0010";
		ELSIF scan_code_in = "00100110" THEN
			binary_out <= "0011";
		ELSIF scan_code_in = "00100101" THEN
			binary_out <= "0100";
		ELSIF scan_code_in = "00101110" THEN
			binary_out <= "0101";
		ELSIF scan_code_in = "00110110" THEN
			binary_out <= "0110";
		ELSIF scan_code_in = "00111101" THEN
			binary_out <= "0111";
		ELSIF scan_code_in = "00111110" THEN
			binary_out <= "1000";
		ELSIF scan_code_in = "01000110" THEN
			binary_out <= "1001";
		ELSIF scan_code_in = "01000101" THEN
			binary_out <= "0000";
		ELSE
			binary_out <= "1111"; --E 
		END IF;
	END PROCESS;
END convert_to_binary_arch;