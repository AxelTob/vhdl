LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ALU_ctrl IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        enter : IN STD_LOGIC;
        sign : IN STD_LOGIC;
        FN : OUT STD_LOGIC_VECTOR (3 DOWNTO 0); -- ALU functions
        RegCtrl : OUT STD_LOGIC_VECTOR (1 DOWNTO 0) -- Register update control bits
    );
END ALU_ctrl;

ARCHITECTURE behavioral OF ALU_ctrl IS
    TYPE state_type IS (IDLE, INPUT_A, INPUT_B, ADD, SUB, MOD3);
    SIGNAL current_state, next_state : state_type;
    SIGNAL is_signed : STD_LOGIC := '0';
    SIGNAL enter_prev, enter_edge : STD_LOGIC := '0';
BEGIN
    -- Detect rising edge of enter button
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            enter_prev <= enter;
            enter_edge <= enter AND NOT enter_prev;
        END IF;
    END PROCESS;

    -- State register and sign mode
    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            current_state <= IDLE;
            is_signed <= '0';
        ELSIF rising_edge(clk) THEN
            current_state <= next_state;
            is_signed <= sign;
        END IF;
    END PROCESS;

    -- Next state logic
    PROCESS (current_state, enter_edge)
    BEGIN
        next_state <= current_state; -- Default: stay in current state
        CASE current_state IS
            WHEN IDLE => -- remove or not. Can cause probs. but easy for reset. 
                IF enter_edge = '1' THEN
                    next_state <= INPUT_A;
                END IF; -- we want to move to A state on input not just enter
            WHEN INPUT_A =>
                IF enter_edge = '1' THEN
                    next_state <= INPUT_B;
                END IF;
            WHEN INPUT_B =>
                IF enter_edge = '1' THEN
                    next_state <= ADD;
                END IF;
            WHEN ADD =>
                IF enter_edge = '1' THEN
                    next_state <= SUB;
                END IF;
            WHEN SUB =>
                IF enter_edge = '1' THEN
                    next_state <= MOD3;
                END IF;
            WHEN MOD3 =>
                IF enter_edge = '1' THEN
                    next_state <= ADD;
                END IF;
        END CASE;
    END PROCESS;

    -- Output logic
    PROCESS (current_state, is_signed)
    BEGIN
        CASE current_state IS
            WHEN IDLE =>
                FN <= "0000";
                RegCtrl <= "00";
            WHEN INPUT_A =>
                FN <= "0000";
                RegCtrl <= "01";
            WHEN INPUT_B =>
                FN <= "0001";
                RegCtrl <= "10";
            WHEN ADD =>
                IF is_signed = '1' THEN
                    FN <= "1010"; -- Signed addition
                ELSE
                    FN <= "0010"; -- Unsigned addition
                END IF;
                RegCtrl <= "00";
            WHEN SUB =>
                IF is_signed = '1' THEN
                    FN <= "1011"; -- Signed subtraction
                ELSE
                    FN <= "0011"; -- Unsigned subtraction
                END IF;
                RegCtrl <= "00";
            WHEN MOD3 =>
                IF is_signed = '1' THEN
                    FN <= "1100"; -- Signed modulo 3
                ELSE
                    FN <= "0100"; -- Unsigned modulo 3
                END IF;
                RegCtrl <= "00";
        END CASE;
    END PROCESS;
END behavioral;