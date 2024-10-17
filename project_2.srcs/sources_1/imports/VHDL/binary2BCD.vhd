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
    SIGNAL bcd_register, next_bcd_register : unsigned(19 DOWNTO 0) := (OTHERS => '0');
    SIGNAL counter : INTEGER RANGE 0 TO 8 := 0;
    SIGNAL bcd_result : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL prev_binary_in : STD_LOGIC_VECTOR(WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL conversion_active : BOOLEAN := FALSE;
BEGIN
    -- Sequential process
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                counter <= 0;
                bcd_register <= (OTHERS => '0');
                bcd_result <= (OTHERS => '0');
                prev_binary_in <= (OTHERS => '0');
                conversion_active <= FALSE;
            ELSE
                IF NOT conversion_active AND binary_in /= prev_binary_in THEN
                    bcd_register <= (OTHERS => '0');
                    bcd_register(7 DOWNTO 0) <= unsigned(binary_in);
                    prev_binary_in <= binary_in;
                    counter <= 0;
                    conversion_active <= TRUE;
                ELSIF conversion_active THEN
                    IF counter < 8 THEN
                        bcd_register <= next_bcd_register;
                        counter <= counter + 1;
                    ELSE
                        bcd_result <= STD_LOGIC_VECTOR(bcd_register(17 DOWNTO 8));
                        conversion_active <= FALSE;
                    END IF;
                END IF;
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