LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_binary2BCD IS
END tb_binary2BCD;

ARCHITECTURE behavior OF tb_binary2BCD IS
    -- Component Declaration
    COMPONENT binary2BCD
        PORT (
            binary_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            BCD_out : OUT unsigned(9 DOWNTO 0);
            clk : IN STD_LOGIC;
            reset : IN STD_LOGIC
        );
    END COMPONENT;

    -- Inputs
    SIGNAL binary_in : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL reset : STD_LOGIC := '0';

    -- Outputs
    SIGNAL BCD_out : unsigned(9 DOWNTO 0);

    -- Clock period definitions
    CONSTANT clk_period : TIME := 10 ns;

BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut : binary2BCD PORT MAP(
        binary_in => binary_in,
        BCD_out => BCD_out,
        clk => clk,
        reset => reset
    );

    -- Clock process definitions
    clk_process : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR clk_period/2;
        clk <= '1';
        WAIT FOR clk_period/2;
    END PROCESS;

    -- Stimulus process
    stim_proc : PROCESS
    BEGIN
        -- Reset
        reset <= '1';
        WAIT FOR clk_period * 10;
        reset <= '0';
        WAIT FOR clk_period * 10;

        -- Test case 1: 0
        binary_in <= "00000000";
        WAIT FOR clk_period * 10;
        ASSERT BCD_out = "0000000000" REPORT "Test case 1 failed" SEVERITY error;

        -- Test case 2: 127
        binary_in <= "01111111";
        WAIT FOR clk_period * 10;
        ASSERT BCD_out = "0001100111" REPORT "Test case 2 failed" SEVERITY error;

        -- Test case 3: 255
        binary_in <= "11111111";
        WAIT FOR clk_period * 10;
        ASSERT BCD_out = "0010110101" REPORT "Test case 3 failed" SEVERITY error;

        -- Test case 4: 42
        binary_in <= "00101010";
        WAIT FOR clk_period * 10;
        ASSERT BCD_out = "0000100010" REPORT "Test case 4 failed" SEVERITY error;

        -- Test case 5: 199
        binary_in <= "11000111";
        WAIT FOR clk_period * 10;
        ASSERT BCD_out = "0001111001" REPORT "Test case 5 failed" SEVERITY error;

        -- End the simulation
        WAIT;
    END PROCESS;
END;