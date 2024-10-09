library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.ALU_components_pack.all;

entity binary2BCD is
   generic ( WIDTH : integer := 8   -- 8 bit binary to BCD
           );
   port ( binary_in : in  std_logic_vector(WIDTH-1 downto 0);  -- binary input width
          BCD_out   : out unsigned(9 downto 0);       -- BCD output, 10 bits [2|4|4] to display a 3 digit BCD value when input has length 8
          clk       : in std_logic;    --changed port
          reset     : in std_logic     --changed port
        );
end binary2BCD;

architecture structural of binary2BCD is 
    signal  bcd_register :  unsigned(19 downto 0) :=(others =>'0');
    signal  counter : integer range 0 to 8 := 0;
    signal  got_bcd : std_logic  :='0';
    signal  next_counter : integer range 0 to 8 := 0;
-- SIGNAL DEFINITIONS HERE IF NEEDED
  
begin  
    process(clk,reset)
    begin
        if rising_edge (clk) then 
            
            if reset = '1' then 
                counter <= 0;
                bcd_register <= (others => '0');
                got_bcd <= '0';
            else 
                if counter = 0 then 
                    bcd_register(7 downto 0) <= unsigned(binary_in);
                 else
                 bcd_register <= '0'& bcd_register(17 downto 0);
                 counter <= next_counter;
                end if;
            end if;
          end if;
     end process;
     process(counter)
     begin 
        next_counter <= counter +1;
        if counter = 8 then
        BCD_out <= bcd_register( 17 downto 8);
        end if;
        if bcd_register(19 downto 16) > "0110" then 
            bcd_register(19 downto 16) <=  bcd_register(19 downto 16) +3;
        end if;
        if bcd_register(15 downto 12) > "0110" then 
            bcd_register(15 downto 12) <=  bcd_register(15 downto 12) +3;
        end if;
        if bcd_register(11 downto 8)> "0110" then 
            bcd_register(11 downto 8)<=  bcd_register(11 downto 8) +3;
        end if;     
    end process;             
               
    
-- DEVELOPE YOUR CODE HERE

end structural;
