LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE ALU_components_pack IS

   -- Button debouncing 
   COMPONENT debouncer
      PORT (
         clk : IN STD_LOGIC;
         reset : IN STD_LOGIC;
         button_in : IN STD_LOGIC;
         button_out : OUT STD_LOGIC
      );
   END COMPONENT;

   -- ADD MORE COMPONENTS HERE IF NEEDED 

END ALU_components_pack;

-------------------------------------------------------------------------------
-- ALU component pack body
-------------------------------------------------------------------------------
PACKAGE BODY ALU_components_pack IS

END ALU_components_pack;

-------------------------------------------------------------------------------
-- debouncer component: There is no need to use this component, thogh if you get 
--                      unwanted moving between states of the FSM because of pressing
--                      push-button this component might be useful.
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY debouncer IS
   PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      button_in : IN STD_LOGIC;
      button_out : OUT STD_LOGIC
   );
END debouncer;

ARCHITECTURE behavioral OF debouncer IS

   SIGNAL count : unsigned(19 DOWNTO 0); -- Range to count 20ms with 50 MHz clock
   SIGNAL button_tmp : STD_LOGIC;

BEGIN

   PROCESS (clk)
   BEGIN
      IF clk'event AND clk = '1' THEN
         IF reset = '0' THEN
            count <= (OTHERS => '0');
         ELSE
            count <= count + 1;
            button_tmp <= button_in;

            IF (count = 0) THEN
               button_out <= button_tmp;
            END IF;
         END IF;
      END IF;
   END PROCESS;

END behavioral;

