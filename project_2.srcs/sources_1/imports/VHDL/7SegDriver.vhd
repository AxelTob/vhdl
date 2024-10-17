LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY seven_seg_driver IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        BCD_digit : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        sign : IN STD_LOGIC;
        overflow : IN STD_LOGIC;
        DIGIT_ANODE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SEGMENT : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END seven_seg_driver;

ARCHITECTURE behavioral OF seven_seg_driver IS
    SIGNAL next_bit_counter : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL bit_counter : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL binary_in : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL sev_seg : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL clk_counter : unsigned(13 DOWNTO 0);
    SIGNAL soo : STD_LOGIC_VECTOR(3 DOWNTO 0); --signed or overflow
    SIGNAL display : STD_LOGIC_VECTOR(15 DOWNTO 0); --to control the 4-bit led light
BEGIN
    PROCESS (clk_counter, bit_counter, display) --change  the showed number slowly
    BEGIN
        -- Default assignment
        -- FIX if needed
        binary_in <= "1111";
        next_bit_counter <= bit_counter;
        IF clk_counter = 9999 THEN
            CASE bit_counter IS
                WHEN "1110" =>
                    binary_in <= display(3 DOWNTO 0);
                    next_bit_counter <= "1101";
                WHEN "1101" =>
                    binary_in <= display(7 DOWNTO 4);
                    next_bit_counter <= "1011";
                WHEN "1011" =>
                    next_bit_counter <= "0111";
                    binary_in <= display(11 DOWNTO 8);
                WHEN OTHERS =>
                    binary_in <= display(15 DOWNTO 12);
                    next_bit_counter <= "1110";
            END CASE;
        END IF;
    END PROCESS;

    PROCESS (sign, overflow)
    BEGIN
        IF sign = '1'THEN
            soo <= "1010"; -- signed caculation
        ELSIF overflow = '1'THEN
            soo <= "1011"; -- overflow
        ELSE
            soo <= "1111";
        END IF;
    END PROCESS;
    PROCESS (binary_in)
    BEGIN
        IF binary_in = "0000" THEN
            sev_seg <= "1000000";
        ELSIF binary_in = "0001" THEN
            sev_seg <= "1111001";
        ELSIF binary_in = "0010" THEN
            sev_seg <= "0100100";
        ELSIF binary_in = "0011" THEN
            sev_seg <= "0110000";
        ELSIF binary_in = "0100" THEN
            sev_seg <= "0011001";
        ELSIF binary_in = "0101" THEN
            sev_seg <= "0010010";
        ELSIF binary_in = "0110" THEN
            sev_seg <= "0000010";
        ELSIF binary_in = "0111" THEN
            sev_seg <= "1111000";
        ELSIF binary_in = "1000" THEN
            sev_seg <= "0000000";
        ELSIF binary_in = "1001" THEN
            sev_seg <= "0010000";
        ELSIF binary_in = "1010" THEN
            sev_seg <= "0111111";
        ELSIF binary_in = "1011" THEN
            sev_seg <= "0111000";
        ELSE
            sev_seg <= "1111111";
        END IF;
    END PROCESS;
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                bit_counter <= "1110";  -- Initialize to a valid starting value
                clk_counter <= (OTHERS => '0');
            ELSE
                bit_counter <= next_bit_counter;
                clk_counter <= clk_counter + 1;
                IF clk_counter = 9999 THEN
                    clk_counter <= (OTHERS => '0');
                END IF;
                DIGIT_ANODE <= bit_counter;
                SEGMENT <= sev_seg;
                display <= soo & '0' & '0' & BCD_digit;
            END IF;
        END IF;
    END PROCESS;
END behavioral;