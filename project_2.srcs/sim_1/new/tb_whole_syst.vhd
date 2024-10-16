LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ALU_top_tb IS
END ALU_top_tb;

ARCHITECTURE behavior OF ALU_top_tb IS 
    -- Component Declaration for the Unit Under Test (UUT)
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
    
   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal b_Enter : std_logic := '0';
   signal b_Sign : std_logic := '0';
   signal input : std_logic_vector(7 downto 0) := (others => '0');

   --Outputs
   signal seven_seg : std_logic_vector(6 downto 0);
   signal anode : std_logic_vector(3 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;

BEGIN
    -- Instantiate the Unit Under Test (UUT)
   uut: ALU_top PORT MAP (
          clk => clk,
          reset => reset,
          b_Enter => b_Enter,
          b_Sign => b_Sign,
          input => input,
          seven_seg => seven_seg,
          anode => anode
        );

   -- Clock process definitions
   clk_process :process
   begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
   end process;

   -- Stimulus process
   stim_proc: process
begin        
   -- Hold reset state for 100 ns.
   reset <= '1';
   wait for 100 ns;    
   reset <= '0';
   wait for clk_period*10;

   -- Test Case 1: Unsigned Addition (5 + 3)
   -- Input A
   input <= "00000101";  -- 5 in binary
   wait for clk_period*5;
   b_Enter <= '1';
   wait for clk_period*2;
   b_Enter <= '0';
   wait for clk_period*10;  -- Wait longer between inputs

   -- Input B
   input <= "00000011";  -- 3 in binary
   wait for clk_period*5;
   b_Enter <= '1';
   wait for clk_period*2;
   b_Enter <= '0';
   wait for clk_period*10;  -- Wait longer to see the result

   -- Trigger addition (should show 8)
   b_Enter <= '1';
   wait for clk_period*2;
   b_Enter <= '0';
   wait for clk_period*20;  -- Wait to see the result

   -- 5 - 3 = 2
   b_Enter <= '1';
   wait for clk_period*2;
   b_Enter <= '0';
   wait for clk_period*20;  -- Wait to see the result
   
   -- 5 mod 3 = 2
   b_Enter <= '1';
   wait for clk_period*2;
   b_Enter <= '0';
   wait for clk_period*20;  -- Wait to see the result

   wait;
end process;

END;