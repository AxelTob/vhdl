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
        BCD_out : OUT unsigned(9 DOWNTO 0); -- BCD output, 10 bits [2|4|4] to display a 3 digit BCD value when input has length 8
        clk : IN STD_LOGIC; --changed port
        reset : IN STD_LOGIC --changed port
    );
END binary2BCD;

ARCHITECTURE structural OF binary2BCD IS
    SIGNAL bcd_register, next_bcd_register : unsigned(19 DOWNTO 0) := (OTHERS => '0');
    SIGNAL counter : INTEGER RANGE 0 TO 10 := 0;
    --SIGNAL number : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
BEGIN
    -- Sequential process
    PROCESS (clk, reset)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                counter <= 0;
                bcd_register <= (OTHERS => '0');
            ELSE
                IF counter = 0 THEN
                    bcd_register(7 DOWNTO 0) <= unsigned(binary_in);
                    counter <= counter + 1;
                ELSIF counter < 9 THEN
                    bcd_register <= next_bcd_register;
                    counter <= counter + 1;
                ELSIF counter = 9 THEN
                    counter <= 0;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- Combinational process for BCD conversion
    PROCESS (bcd_register)
        VARIABLE temp : unsigned(19 DOWNTO 0);
    BEGIN
        temp := bcd_register;
        IF temp(19 DOWNTO 16) > "0100" THEN
            temp(19 DOWNTO 16) := temp(19 DOWNTO 16) + 3;
        END IF;
        IF temp(15 DOWNTO 12) > "0100" THEN
            temp(15 DOWNTO 12) := temp(15 DOWNTO 12) + 3;
        END IF;
        IF temp(11 DOWNTO 8) > "0100" THEN
            temp(11 DOWNTO 8) := temp(11 DOWNTO 8) + 3;
        END IF;
        next_bcd_register <= temp(18 DOWNTO 0) & '0'; -- Shift left
    END PROCESS;

    -- Output assignment
    BCD_out <= bcd_register(17 DOWNTO 8) WHEN counter = 9 ELSE
        (OTHERS => '0');

END structural;