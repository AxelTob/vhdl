library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_alu_system is
end entity;

architecture tb of tb_alu_system is
    -- ALU signals
    signal a, b, alu_result : std_logic_vector(7 downto 0);
    signal fn : std_logic_vector(3 downto 0);
    signal overflow, sign : std_logic;

    -- ALU Controller signals
    signal clk, reset, enter, sign_ctrl : std_logic;
    signal reg_ctrl : std_logic_vector(1 downto 0);

    -- Clock period definition
    constant clk_period : time := 2500 ns;

    -- Function to convert std_logic_vector to string
    function to_string(vec : std_logic_vector) return string is
        variable result : string(1 to vec'length);
    begin
        for i in vec'range loop
            case vec(i) is
                when '0' => result(i+1) := '0';
                when '1' => result(i+1) := '1';
                when others => result(i+1) := 'X';
            end case;
        end loop;
        return result;
    end function;

begin
    -- Instantiate the ALU
    uut_alu: entity work.ALU
    port map (
        A => a,
        B => b,
        FN => fn,
        result => alu_result,
        overflow => overflow,
        sign => sign
    );

    -- Instantiate the ALU Controller
    uut_ctrl: entity work.ALU_ctrl
    port map (
        clk => clk,
        reset => reset,
        enter => enter,
        sign => sign_ctrl,
        FN => fn,
        RegCtrl => reg_ctrl
    );

    -- Clock process
    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
        procedure pulse(signal s: out std_logic) is
        begin
            s <= '1';
            wait for clk_period;
            s <= '0';
            wait for clk_period;
        end procedure;

        procedure check_equal(actual, expected: in std_logic_vector; msg: in string) is
        begin
            assert actual = expected
                report msg & ". Expected " & to_string(expected) & ", but got " & to_string(actual)
                severity error;
        end procedure;

    begin
        -- MVP tests --
        
        -- Initialize inputs
        reset <= '0';
        enter <= '0';
        sign_ctrl <= '0';
        a <= (others => '0');
        b <= (others => '0');
        
        -- Reset the system
        reset <= '1';
        wait for clk_period;
        reset <= '0';
        wait for clk_period;

        -- Test input sequence
        a <= std_logic_vector(to_unsigned(10, 8));
        pulse(enter);
        wait for clk_period;
        check_equal(fn, "0000", "FN should be 0000 for Input A");
        check_equal(reg_ctrl, "01", "RegCtrl should be 01 for Input A");
        
        b <= std_logic_vector(to_unsigned(5, 8));
        pulse(enter);
        wait for clk_period;
        check_equal(fn, "0001", "FN should be 0001 for Input B");
        check_equal(reg_ctrl, "10", "RegCtrl should be 10 for Input B");

        -- Test ALU operations
        pulse(enter); -- Addition
        wait for clk_period;
        check_equal(fn, "0010", "FN should be 0010 for unsigned addition");
        check_equal(alu_result, std_logic_vector(to_unsigned(15, 8)), "10 + 5 should equal 15 UNSIGNED");
        
        pulse(enter); -- Subtraction
        wait for clk_period;
        check_equal(fn, "0011", "FN should be 0011 for unsigned subtraction");
        check_equal(alu_result, std_logic_vector(to_unsigned(5, 8)), "10 - 5 should equal 5 UNSIGNED");
        
        pulse(enter); -- Modulo 3
        wait for clk_period;
        check_equal(fn, "0100", "FN should be 0100 for unsigned modulo 3");
        check_equal(alu_result, std_logic_vector(to_unsigned(1, 8)), "10 mod 3 should equal 1 UNSIGNED");

        -- Test signed operations
        reset <= '1';
        wait for clk_period;
        reset <= '0';
        wait for clk_period;

        a <= std_logic_vector(to_signed(-10, 8));
        pulse(enter);
        wait for clk_period;
        b <= std_logic_vector(to_signed(5, 8));
        pulse(enter);
        wait for clk_period;
        
        pulse(sign_ctrl); -- Toggle to signed mode
        
        pulse(enter); -- Signed Addition
        wait for clk_period;
        check_equal(fn, "1010", "FN should be 1010 for signed addition");
        check_equal(alu_result, std_logic_vector(to_signed(-5, 8)), "-10 + 5 should equal -5 SIGNED");
        
        pulse(enter); -- Signed Subtraction
        wait for clk_period;
        check_equal(fn, "1011", "FN should be 1011 for signed subtraction SIGNED");
        check_equal(alu_result, std_logic_vector(to_signed(-15, 8)), "-10 - 5 should equal -15 SIGNED");
        
        pulse(enter); -- Signed Modulo 3
        wait for clk_period;
        check_equal(fn, "1100", "FN should be 1100 for signed modulo 3");
        check_equal(alu_result, std_logic_vector(to_signed(-1, 8)), "-10 mod 3 should equal -1 SIGNED");
        
        -- HARDER TESTS . IF WE PASS I THINK WE GOOD --
        
        -- Test with larger numbers
        reset <= '1';
        wait for clk_period;
        reset <= '0';
        wait for clk_period;
        
        a <= std_logic_vector(to_unsigned(200, 8));
        pulse(enter);
        wait for clk_period;
        b <= std_logic_vector(to_unsigned(100, 8));
        pulse(enter);
        wait for clk_period;
        
        pulse(enter); -- Unsigned Addition
        wait for clk_period;
        check_equal(fn, "0010", "FN should be 0010 for unsigned addition");
        check_equal(alu_result, std_logic_vector(to_unsigned(44, 8)), "200 + 100 should equal 44 UNSIGNED (with overflow)");
        assert overflow = '1' report "Overflow should be set for 200 + 100 UNSIGNED" severity error;
        
        pulse(enter); -- Unsigned Subtraction
        wait for clk_period;
        check_equal(fn, "0011", "FN should be 0011 for unsigned subtraction");
        check_equal(alu_result, std_logic_vector(to_unsigned(100, 8)), "200 - 100 should equal 100 UNSIGNED");
        
        pulse(enter); -- Unsigned Modulo 3
        wait for clk_period;
        check_equal(fn, "0100", "FN should be 0100 for unsigned modulo 3");
        check_equal(alu_result, std_logic_vector(to_unsigned(2, 8)), "200 mod 3 should equal 2 UNSIGNED");
        
        -- Test with negative numbers
        reset <= '1';
        wait for clk_period;
        reset <= '0';
        wait for clk_period;
        
        a <= std_logic_vector(to_signed(-128, 8));
        pulse(enter);
        wait for clk_period;
        b <= std_logic_vector(to_signed(127, 8));
        pulse(enter);
        wait for clk_period;
        
        pulse(sign_ctrl); -- Toggle to signed mode
        
        pulse(enter); -- Signed Addition
        wait for clk_period;
        check_equal(fn, "1010", "FN should be 1010 for signed addition");
        check_equal(alu_result, std_logic_vector(to_signed(-1, 8)), "-128 + 127 should equal -1 SIGNED");
        
        pulse(enter); -- Signed Subtraction
        wait for clk_period;
        check_equal(fn, "1011", "FN should be 1011 for signed subtraction");
        check_equal(alu_result, std_logic_vector(to_signed(1, 8)), "-128 - 127 should equal 1 SIGNED (with overflow)");
        assert overflow = '1' report "Overflow should be set for -128 - 127 SIGNED" severity error;
        
        pulse(enter); -- Signed Modulo 3
        wait for clk_period;
        check_equal(fn, "1100", "FN should be 1100 for signed modulo 3");
        check_equal(alu_result, std_logic_vector(to_signed(-2, 8)), "-128 mod 3 should equal -2 SIGNED");
        
        -- Test with zero
        reset <= '1';
        wait for clk_period;
        reset <= '0';
        wait for clk_period;
        
        a <= std_logic_vector(to_unsigned(0, 8));
        pulse(enter);
        wait for clk_period;
        b <= std_logic_vector(to_signed(-5, 8));
        pulse(enter);
        wait for clk_period;
        
        pulse(sign_ctrl); -- Toggle to signed mode
        
        pulse(enter); -- Signed Addition
        wait for clk_period;
        check_equal(fn, "1010", "FN should be 1010 for signed addition");
        check_equal(alu_result, std_logic_vector(to_signed(-5, 8)), "0 + (-5) should equal -5 SIGNED");
        
        pulse(enter); -- Signed Subtraction
        wait for clk_period;
        check_equal(fn, "1011", "FN should be 1011 for signed subtraction");
        check_equal(alu_result, std_logic_vector(to_signed(5, 8)), "0 - (-5) should equal 5 SIGNED");
        
        pulse(enter); -- Signed Modulo 3
        wait for clk_period;
        check_equal(fn, "1100", "FN should be 1100 for signed modulo 3");
        check_equal(alu_result, std_logic_vector(to_signed(0, 8)), "0 mod 3 should equal 0 SIGNED");

        -- End simulation
        wait;
    end process;
end architecture;