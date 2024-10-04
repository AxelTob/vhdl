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

LIBRARY ieee;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_1164.ALL;

ENTITY convert_scancode IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        edge_found : IN STD_LOGIC;
        serial_data : IN STD_LOGIC;
        valid_scan_code : OUT STD_LOGIC;
        scan_code_out : OUT unsigned(7 DOWNTO 0)
    );
END ENTITY convert_scancode;

ARCHITECTURE convert_scancode_arch OF convert_scancode IS
    SIGNAL shift_register : STD_LOGIC_VECTOR(10 DOWNTO 0) := (OTHERS => '0');
    SIGNAL bit_counter : unsigned(3 DOWNTO 0) := (OTHERS => '0');

    SIGNAL internal_scan_code : unsigned(7 DOWNTO 0);

    -- Signals for next state
    SIGNAL next_shift_register : STD_LOGIC_VECTOR(10 DOWNTO 0);
    SIGNAL next_bit_counter : unsigned(3 DOWNTO 0);
    SIGNAL next_valid_scan_code : STD_LOGIC;
    SIGNAL next_internal_scan_code : unsigned(7 DOWNTO 0);
BEGIN
    -- Sequential Process
    seq_process : PROCESS (clk, rst)
    BEGIN
        IF rising_edge(clk) THEN
            IF rst = '1' THEN
                shift_register <= (OTHERS => '0');
                bit_counter <= (OTHERS => '0');
                valid_scan_code <= '0';
                internal_scan_code <= (OTHERS => '0');
            END IF;
            shift_register <= next_shift_register;
            bit_counter <= next_bit_counter;
            valid_scan_code <= next_valid_scan_code;
            internal_scan_code <= next_internal_scan_code;
        END IF;
    END PROCESS seq_process;
    -- Combinational Process
    comb_process : PROCESS (serial_data, edge_found, shift_register, bit_counter, internal_scan_code)
    BEGIN
        next_valid_scan_code <= '0'; -- Default state
        next_internal_scan_code <= internal_scan_code;
        next_shift_register <= shift_register;
        next_bit_counter <= bit_counter;
        IF edge_found = '1' THEN
            next_shift_register <= serial_data & shift_register(10 DOWNTO 1);
            IF bit_counter = 10 THEN
                next_internal_scan_code <= unsigned(shift_register(9 DOWNTO 2));
                next_valid_scan_code <= '1';
                next_bit_counter <= (OTHERS => '0');
            ELSE
                next_bit_counter <= bit_counter + 1;
            END IF;
       END IF;
    END PROCESS comb_process;

    -- Continuous assignment to output
    scan_code_out <= internal_scan_code;
END ARCHITECTURE convert_scancode_arch;