library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ALU_components_pack.all;

entity ALU_top is
   port ( clk        : in  std_logic;
          reset      : in  std_logic;
          b_Enter    : in  std_logic;
          b_Sign     : in  std_logic;
          input      : in  std_logic_vector(7 downto 0);
          seven_seg  : out std_logic_vector(6 downto 0);
          anode      : out std_logic_vector(3 downto 0)
        );
end ALU_top;

architecture structural of ALU_top is

   -- SIGNAL DEFINITIONS
   signal Enter : std_logic;

begin

   ---- to provide a clean signal out of a bouncy one coming from the push button
   ---- input(b_Enter) comes from the pushbutton; output(Enter) goes to the FSM 
   --debouncer1: debouncer
   --port map ( clk          => clk,
   --           reset        => reset,
   --           button_in    => b_Enter,
   --           button_out   => Enter
   --         );

   -- ****************************
   -- DEVELOPE THE STRUCTURE OF ALU_TOP HERE
   -- ****************************

end structural;
