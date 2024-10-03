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

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
entity convert_to_binary is
	port (
		scan_code_in : in unsigned(7 downto 0);
		binary_out : out unsigned(3 downto 0)
	);
end convert_to_binary;
-- bool to determine if we have gotten F0'h. Only then we'll -> binary_out
architecture convert_to_binary_arch of convert_to_binary is
begin
	process (scan_code_in)
	begin
			if scan_code_in = "00010110" then
				binary_out <= "0001";
			elsif scan_code_in = "00011110" then
				binary_out <= "0010";
			elsif scan_code_in = "00100110" then
				binary_out <= "0011";
			elsif scan_code_in = "00100101" then
				binary_out <= "0100";
			elsif scan_code_in = "00101110" then
				binary_out <= "0101";
			elsif scan_code_in = "00110110" then
				binary_out <= "0110";
			elsif scan_code_in = "00111101" then
				binary_out <= "0111";
			elsif scan_code_in = "00111110" then
				binary_out <= "1000";
			elsif scan_code_in = "01000110" then
				binary_out <= "1001";
			elsif scan_code_in = "01000101" then
				binary_out <= "0000";
			else
			    binary_out <= "1111"; --E 
			end if;
	end process;
		-- simple combinational logic using case statements (LUT)
end convert_to_binary_arch;

