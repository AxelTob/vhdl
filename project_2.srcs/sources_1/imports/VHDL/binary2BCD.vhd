LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY work;
USE work.ALU_components_pack.ALL;

ENTITY binary2BCD IS
    GENERIC (
        WIDTH : INTEGER := 8 -- 8 bit binary to BCD
    );
    PORT (
        binary_in : IN STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0); -- binary input width
        BCD_out : OUT STD_LOGIC_VECTOR(9 DOWNTO 0); -- BCD output, 10 bits [2|4|4] to display a 3 digit BCD value when input has length 8
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC
    );
END binary2BCD;

ARCHITECTURE structural OF binary2BCD IS
    SIGNAL bcd_register, next_bcd_register, next_bcd_reg : unsigned(19 DOWNTO 0) := (OTHERS => '0');
    SIGNAL counter, next_counter_value : INTEGER RANGE 0 TO 8 := 0;
    SIGNAL bcd_result, next_bcd_result : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL prev_binary_in, next_prev_binary : STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL conversion_active, next_conversion_active: BOOLEAN := FALSE;
BEGIN
    -- Combinational Process
    PROCESS(binary_in, prev_binary_in, conversion_active, counter, bcd_register, next_bcd_register, bcd_result)
    BEGIN
        -- Default assignments (current values)
        next_counter_value <= counter;
        next_bcd_reg <= bcd_register;
        next_conversion_active <= conversion_active;
        next_prev_binary <= prev_binary_in;
        next_bcd_result <= bcd_result;
    
        IF NOT conversion_active AND binary_in /= prev_binary_in THEN
            next_bcd_reg <= (OTHERS => '0');
            next_bcd_reg(7 DOWNTO 0) <= unsigned(binary_in);
            next_prev_binary <= binary_in;
            next_counter_value <= 0;
            next_conversion_active <= TRUE;
        ELSIF conversion_active THEN
            IF counter < 8 THEN
                next_bcd_reg <= next_bcd_register;
                next_counter_value <= counter + 1;
            ELSE
                next_bcd_result <= STD_LOGIC_VECTOR(bcd_register(17 DOWNTO 8));
                next_conversion_active <= FALSE;
            END IF;
        END IF;
    END PROCESS;
    
    -- Sequential Process
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '0' THEN
                -- Reset values
                counter <= 0;
                bcd_register <= (OTHERS => '0');
                bcd_result <= (OTHERS => '0');
                prev_binary_in <= (OTHERS => '0');
                conversion_active <= FALSE;
            ELSE
                -- Register updates
                counter <= next_counter_value;
                bcd_register <= next_bcd_reg;
                bcd_result <= next_bcd_result;
                prev_binary_in <= next_prev_binary;
                conversion_active <= next_conversion_active;
            END IF;
        END IF;
    END PROCESS;
    -- Combinational process for BCD conversion
    PROCESS (bcd_register)
        VARIABLE temp : unsigned(19 DOWNTO 0);
    BEGIN
        temp := bcd_register;
        IF temp(19 DOWNTO 16) > 4 THEN
            temp(19 DOWNTO 16) := temp(19 DOWNTO 16) + 3;
        END IF;
        IF temp(15 DOWNTO 12) > 4 THEN
            temp(15 DOWNTO 12) := temp(15 DOWNTO 12) + 3;
        END IF;
        IF temp(11 DOWNTO 8) > 4 THEN
            temp(11 DOWNTO 8) := temp(11 DOWNTO 8) + 3;
        END IF;
        next_bcd_register <= temp(18 DOWNTO 0) & '0'; -- Shift left
    END PROCESS;

    -- Output assignment
    BCD_out <= bcd_result;

END structural;