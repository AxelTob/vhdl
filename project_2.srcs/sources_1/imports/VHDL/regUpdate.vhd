library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regUpdate is
   port ( clk        : in  std_logic;
          reset      : in  std_logic;
          RegCtrl    : in  std_logic_vector (1 downto 0);   -- Register update control from ALU controller
          input      : in  std_logic_vector (7 downto 0);   -- Switch inputs
          A          : out std_logic_vector (7 downto 0);   -- Input A
          B          : out std_logic_vector (7 downto 0)  -- Input B
        );
end regUpdate;

ARCHITECTURE behavioral OF regUpdate IS
    SIGNAL reg_A, reg_B, next_A, next_B : std_logic_vector(7 downto 0);
BEGIN
-- comb
    PROCESS(RegCtrl, input)
    BEGIN
        -- Default assignment
        next_A <= reg_A;
        next_B <= reg_B;
        
        CASE RegCtrl IS
            WHEN "01" =>
                next_A <= input;
            WHEN "10" =>
                next_B <= input;
            WHEN OTHERS =>
                --
        END CASE; 
    END PROCESS;
    
    PROCESS(clk, reset)
    BEGIN
        IF reset = '0' THEN
            reg_A <= (OTHERS => '0');
            reg_B <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            reg_A <= next_A;
            reg_B <= next_B;
        END IF;
    END PROCESS;
    
    A <= reg_A;
    B <= reg_B;
END behavioral;