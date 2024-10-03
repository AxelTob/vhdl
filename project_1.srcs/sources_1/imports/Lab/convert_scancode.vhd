-------------------------------------------------------------------------------
-- Title      : convert_scancode.vhd 
-- Project    : Keyboard VLSI Lab
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Description: 
-- 		        Implement a shift register to convert serial to parallel
-- 		        A counter to flag when the valid code is shifted in
--
-------------------------------------------------------------------------------

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity convert_scancode is
    port (
	     clk : in std_logic;
	     rst : in std_logic;
	     edge_found : in std_logic;
	     serial_data : in std_logic;
	     valid_scan_code : out std_logic;
	     scan_code_out : out unsigned(7 downto 0)
	 );
end convert_scancode;

architecture convert_scancode_arch of convert_scancode is
    signal shift_register: std_logic_vector(10 downto 0) := (others => '0');
    signal bit_counter: unsigned(3 downto 0) := (others => '0');
begin
process (edge_found, rst, serial_data)
	begin
	    if rst = '1' then
            shift_register <= (others => '0');
            bit_counter <= (others => '0');
            valid_scan_code <= '0';
            scan_code_out <= (others => '0');
        elsif rising_edge(edge_found) then
            shift_register <= serial_data & shift_register(10 downto 1);
            if bit_counter = 10 then
                scan_code_out <= unsigned(shift_register(9 downto 2)); -- if i understand that startbit should be discarded. Else 7 downto 0));
                valid_scan_code <= '1';
                bit_counter <= (others => '0');
            else
                bit_counter <= bit_counter + 1;
                valid_scan_code <= '0';  -- Default state
            end if;
        end if;
	end process;
end convert_scancode_arch;
