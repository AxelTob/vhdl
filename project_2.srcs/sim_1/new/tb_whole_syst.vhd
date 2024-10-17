LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ALU_top_tb IS
END ALU_top_tb;

ARCHITECTURE behavior OF ALU_top_tb IS 
    COMPONENT ALU_top
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         b_Enter : IN  std_logic;
         b_Sign : IN  std_logic;
         input : IN  std_logic_vector(7 downto 0);
         seven_seg : OUT  std_logic_vector(6 downto 0);
         anode : OUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal b_Enter : std_logic := '0';
   signal b_Sign : std_logic := '0';
   signal input : std_logic_vector(7 downto 0) := (others => '0');
   signal seven_seg : std_logic_vector(6 downto 0);
   signal anode : std_logic_vector(3 downto 0);

   constant clk_period : time := 20 ns;  -- 50 MHz clock
   constant debounce_time : time := 21 ms;  -- Slightly more than the debouncer delay

BEGIN
   uut: ALU_top PORT MAP (
          clk => clk,
          reset => reset,
          b_Enter => b_Enter,
          b_Sign => b_Sign,
          input => input,
          seven_seg => seven_seg,
          anode => anode
        );

   clk_process :process
   begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
   end process;

   stim_proc: process
   begin        
      reset <= '1';
      wait for 100 ns;    
      reset <= '0';
      wait for debounce_time;

      -- Test Case 1: Unsigned Addition (5 + 3)
      -- Input A
      input <= "00000101";  -- 5 in binary
      wait for clk_period*10;
      b_Enter <= '1';
      wait for debounce_time;
      b_Enter <= '0';
      wait for debounce_time;

      -- Input B
      input <= "00000011";  -- 3 in binary
      wait for clk_period*10;
      b_Enter <= '1';
      wait for debounce_time;
      b_Enter <= '0';
      wait for debounce_time;

      -- Trigger addition (should show 8)
      b_Enter <= '1';
      wait for debounce_time;
      b_Enter <= '0';
      wait for debounce_time;

      -- 5 - 3 = 2
      b_Enter <= '1';
      wait for debounce_time;
      b_Enter <= '0';
      wait for debounce_time;
      
      -- 5 mod 3 = 2
      b_Enter <= '1';
      wait for debounce_time;
      b_Enter <= '0';
      wait for debounce_time;
      
      --- now lets reset and try signed ---
      reset <= '1';
      WAIT FOR clk_period;
      reset <= '0';
    WAIT FOR clk_period;
    -- A
    input <= STD_LOGIC_VECTOR(to_signed(-128, 8));
    b_Enter <= '1';
      wait for debounce_time;
      b_Enter <= '0';
      wait for debounce_time;
     -- B
    input <= STD_LOGIC_VECTOR(to_signed(200, 8));
    b_Enter <= '1';
      wait for debounce_time;
      b_Enter <= '0';
      wait for debounce_time;
    WAIT FOR clk_period;

      b_Sign <= '1';
      wait for debounce_time;
      b_Sign <= '0';
      wait for debounce_time;
      
      -- add,...
      b_Enter <= '1';
      wait for debounce_time;
      b_Enter <= '0';
      wait for debounce_time;

      -- 5 - 3 = 2
      b_Enter <= '1';
      wait for debounce_time;
      b_Enter <= '0';
      wait for debounce_time;
      
      -- 5 mod 3 = 2
      b_Enter <= '1';
      wait for debounce_time;
      b_Enter <= '0';
      wait for debounce_time;

      wait;
   end process;

END;