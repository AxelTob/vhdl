library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regUpdate is
   port ( clk        : in  std_logic;
          reset      : in  std_logic;
          RegCtrl    : in  std_logic_vector (1 downto 0);   -- Register update control from ALU controller
          input      : in  std_logic_vector (7 downto 0);   -- Switch inputs
          A          : out std_logic_vector (7 downto 0);   -- Input A
          B          : out std_logic_vector (7 downto 0)   -- Input B
        );
end regUpdate;

architecture behavioral of regUpdate is

-- SIGNAL DEFINITIONS HERE IF NEEDED

-- this part is simple.
-- if we send out a A signal on regCtrl. Then we put input in the A register.
-- else the B register. 

-- We have a next_input that we change on the rising clk. The seq part also resets.
begin

   -- DEVELOPE YOUR CODE HERE

end behavioral;
