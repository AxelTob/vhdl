LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY regUpdate IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        RegCtrl : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        input : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        A : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        B : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
    );
END regUpdate;

ARCHITECTURE behavioral OF regUpdate IS
    SIGNAL next_A, next_B : STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN
    -- Combinational part
    PROCESS (RegCtrl, input)
    BEGIN
        next_A <= (OTHERS => '0');
        next_B <= (OTHERS => '0');

        CASE RegCtrl IS
            WHEN "01" => -- Update A
                next_A <= input;
            WHEN "10" => -- Update B
                next_B <= input;
            WHEN OTHERS =>
                -- nothing?
        END CASE;
    END PROCESS;

    -- Sequential part
    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            A <= (OTHERS => '0');
            B <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            A <= next_A;
            B <= next_B;
        END IF;
    END PROCESS;

END behavioral;