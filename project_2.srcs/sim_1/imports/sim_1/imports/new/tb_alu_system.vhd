LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_alu_system IS
END ENTITY;

ARCHITECTURE tb OF tb_alu_system IS
    -- ALU signals
    SIGNAL a, b, alu_result : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL fn : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL overflow, sign : STD_LOGIC;

    -- ALU Controller signals
    SIGNAL clk, reset, enter, sign_ctrl : STD_LOGIC;
    SIGNAL reg_ctrl : STD_LOGIC_VECTOR(1 DOWNTO 0);

    -- Clock period definition
    CONSTANT clk_period : TIME := 2500 ns;

    -- Function to convert std_logic_vector to string
    FUNCTION to_string(vec : STD_LOGIC_VECTOR) RETURN STRING IS
        VARIABLE result : STRING(1 TO vec'length);
    BEGIN
        FOR i IN vec'RANGE LOOP
            CASE vec(i) IS
                WHEN '0' => result(i + 1) := '0';
                WHEN '1' => result(i + 1) := '1';
                WHEN OTHERS => result(i + 1) := 'X';
            END CASE;
        END LOOP;
        RETURN result;
    END FUNCTION;

BEGIN
    -- Instantiate the ALU
    uut_alu : ENTITY work.ALU
        PORT MAP(
            A => a,
            B => b,
            FN => fn,
            result => alu_result,
            overflow => overflow,
            sign => sign
        );

    -- Instantiate the ALU Controller
    uut_ctrl : ENTITY work.ALU_ctrl
        PORT MAP(
            clk => clk,
            reset => reset,
            enter => enter,
            sign => sign_ctrl,
            FN => fn,
            RegCtrl => reg_ctrl
        );

    -- Clock process
    clk_process : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR clk_period/2;
        clk <= '1';
        WAIT FOR clk_period/2;
    END PROCESS;

    -- Stimulus process
    stim_proc : PROCESS
        PROCEDURE pulse(SIGNAL s : OUT STD_LOGIC) IS
        BEGIN
            s <= '1';
            WAIT FOR clk_period;
            s <= '0';
            WAIT FOR clk_period;
        END PROCEDURE;

        PROCEDURE check_equal(actual, expected : IN STD_LOGIC_VECTOR; msg : IN STRING) IS
        BEGIN
            ASSERT actual = expected
            REPORT msg & ". Expected " & to_string(expected) & ", but got " & to_string(actual)
                SEVERITY error;
        END PROCEDURE;

    BEGIN
        -- MVP tests --

        -- Initialize inputs
        reset <= '0';
        enter <= '0';
        sign_ctrl <= '0';
        a <= (OTHERS => '0');
        b <= (OTHERS => '0');

        -- Reset the system
        reset <= '1';
        WAIT FOR clk_period;
        reset <= '0';
        WAIT FOR clk_period;

        -- Test input sequence
        a <= STD_LOGIC_VECTOR(to_unsigned(10, 8));
        pulse(enter);
        WAIT FOR clk_period;
        check_equal(fn, "0000", "FN should be 0000 for Input A");
        check_equal(reg_ctrl, "01", "RegCtrl should be 01 for Input A");

        b <= STD_LOGIC_VECTOR(to_unsigned(5, 8));
        pulse(enter);
        WAIT FOR clk_period;
        check_equal(fn, "0001", "FN should be 0001 for Input B");
        check_equal(reg_ctrl, "10", "RegCtrl should be 10 for Input B");

        -- Test ALU operations
        pulse(enter); -- Addition
        WAIT FOR clk_period;
        check_equal(fn, "0010", "FN should be 0010 for unsigned addition");
        check_equal(alu_result, STD_LOGIC_VECTOR(to_unsigned(15, 8)), "10 + 5 should equal 15 UNSIGNED");

        pulse(enter); -- Subtraction
        WAIT FOR clk_period;
        check_equal(fn, "0011", "FN should be 0011 for unsigned subtraction");
        check_equal(alu_result, STD_LOGIC_VECTOR(to_unsigned(5, 8)), "10 - 5 should equal 5 UNSIGNED");

        pulse(enter); -- Modulo 3
        WAIT FOR clk_period;
        check_equal(fn, "0100", "FN should be 0100 for unsigned modulo 3");
        check_equal(alu_result, STD_LOGIC_VECTOR(to_unsigned(1, 8)), "10 mod 3 should equal 1 UNSIGNED");

        -- Test signed operations
        reset <= '1';
        WAIT FOR clk_period;
        reset <= '0';
        WAIT FOR clk_period;

        a <= STD_LOGIC_VECTOR(to_signed(-10, 8));
        pulse(enter);
        WAIT FOR clk_period;
        b <= STD_LOGIC_VECTOR(to_signed(5, 8));
        pulse(enter);
        WAIT FOR clk_period;

        pulse(sign_ctrl); -- Toggle to signed mode

        pulse(enter); -- Signed Addition
        WAIT FOR clk_period;
        check_equal(fn, "1010", "FN should be 1010 for signed addition");
        check_equal(alu_result, STD_LOGIC_VECTOR(to_signed(-5, 8)), "-10 + 5 should equal -5 SIGNED");

        pulse(enter); -- Signed Subtraction
        WAIT FOR clk_period;
        check_equal(fn, "1011", "FN should be 1011 for signed subtraction SIGNED");
        check_equal(alu_result, STD_LOGIC_VECTOR(to_signed(-15, 8)), "-10 - 5 should equal -15 SIGNED");

        pulse(enter); -- Signed Modulo 3
        WAIT FOR clk_period;
        check_equal(fn, "1100", "FN should be 1100 for signed modulo 3");
        check_equal(alu_result, STD_LOGIC_VECTOR(to_signed(2, 8)), "-10 mod 3 should equal -1 SIGNED");

        -- HARDER TESTS . IF WE PASS I THINK WE GOOD --

        -- Test with larger numbers
        reset <= '1';
        WAIT FOR clk_period;
        reset <= '0';
        WAIT FOR clk_period;

        a <= STD_LOGIC_VECTOR(to_unsigned(200, 8));
        pulse(enter);
        WAIT FOR clk_period;
        b <= STD_LOGIC_VECTOR(to_unsigned(100, 8));
        pulse(enter);
        WAIT FOR clk_period;

        pulse(enter); -- Unsigned Addition
        WAIT FOR clk_period;
        check_equal(fn, "0010", "FN should be 0010 for unsigned addition");
        check_equal(alu_result, STD_LOGIC_VECTOR(to_unsigned(44, 8)), "200 + 100 should equal 44 UNSIGNED (with overflow)");
        ASSERT overflow = '1' REPORT "Overflow should be set for 200 + 100 UNSIGNED" SEVERITY error;

        pulse(enter); -- Unsigned Subtraction
        WAIT FOR clk_period;
        check_equal(fn, "0011", "FN should be 0011 for unsigned subtraction");
        check_equal(alu_result, STD_LOGIC_VECTOR(to_unsigned(100, 8)), "200 - 100 should equal 100 UNSIGNED");

        pulse(enter); -- Unsigned Modulo 3
        WAIT FOR clk_period;
        check_equal(fn, "0100", "FN should be 0100 for unsigned modulo 3");
        check_equal(alu_result, STD_LOGIC_VECTOR(to_unsigned(2, 8)), "200 mod 3 should equal 2 UNSIGNED");

        -- Test with negative numbers
        reset <= '1';
        WAIT FOR clk_period;
        reset <= '0';
        WAIT FOR clk_period;

        a <= STD_LOGIC_VECTOR(to_signed(-128, 8));
        pulse(enter);
        WAIT FOR clk_period;
        b <= STD_LOGIC_VECTOR(to_signed(127, 8));
        pulse(enter);
        WAIT FOR clk_period;

        pulse(sign_ctrl); -- Toggle to signed mode

        pulse(enter); -- Signed Addition
        WAIT FOR clk_period;
        check_equal(fn, "1010", "FN should be 1010 for signed addition");
        check_equal(alu_result, STD_LOGIC_VECTOR(to_signed(-1, 8)), "-128 + 127 should equal -1 SIGNED");

        pulse(enter); -- Signed Subtraction
        WAIT FOR clk_period;
        check_equal(fn, "1011", "FN should be 1011 for signed subtraction");
        check_equal(alu_result, STD_LOGIC_VECTOR(to_signed(1, 8)), "-128 - 127 should equal 1 SIGNED (with overflow)");
        ASSERT overflow = '1' REPORT "Overflow should be set for -128 - 127 SIGNED" SEVERITY error;

        pulse(enter); -- Signed Modulo 3
        WAIT FOR clk_period;
        check_equal(fn, "1100", "FN should be 1100 for signed modulo 3");
        check_equal(alu_result, STD_LOGIC_VECTOR(to_signed(1, 8)), "-128 mod 3 should equal -2 SIGNED");

        -- Test with zero
        reset <= '1';
        WAIT FOR clk_period;
        reset <= '0';
        WAIT FOR clk_period;

        a <= STD_LOGIC_VECTOR(to_unsigned(0, 8));
        pulse(enter);
        WAIT FOR clk_period;
        b <= STD_LOGIC_VECTOR(to_signed(-5, 8));
        pulse(enter);
        WAIT FOR clk_period;

        pulse(sign_ctrl); -- Toggle to signed mode

        pulse(enter); -- Signed Addition
        WAIT FOR clk_period;
        check_equal(fn, "1010", "FN should be 1010 for signed addition");
        check_equal(alu_result, STD_LOGIC_VECTOR(to_signed(-5, 8)), "0 + (-5) should equal -5 SIGNED");

        pulse(enter); -- Signed Subtraction
        WAIT FOR clk_period;
        check_equal(fn, "1011", "FN should be 1011 for signed subtraction");
        check_equal(alu_result, STD_LOGIC_VECTOR(to_signed(5, 8)), "0 - (-5) should equal 5 SIGNED");

        pulse(enter); -- Signed Modulo 3
        WAIT FOR clk_period;
        check_equal(fn, "1100", "FN should be 1100 for signed modulo 3");
        check_equal(alu_result, STD_LOGIC_VECTOR(to_signed(0, 8)), "0 mod 3 should equal 0 SIGNED");

        -- End simulation
        WAIT;
    END PROCESS;
END ARCHITECTURE;