library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regUpdate is
   port ( clk        : in  std_logic;
          reset      : in  std_logic;
          RegCtrl    : in  std_logic_vector (1 downto 0);
          input      : in  std_logic_vector (7 downto 0);
          A          : out std_logic_vector (7 downto 0);
          B          : out std_logic_vector (7 downto 0)
        );
end regUpdate;

architecture behavioral of regUpdate is
    signal next_A, next_B : std_logic_vector(7 downto 0);
begin
    -- Combinational part
    process(RegCtrl, input)
    begin
        next_A <= (others =>'0');
        next_B <= (others =>'0');
        
        case RegCtrl is
            when "01" =>  -- Update A
                next_A <= input;
            when "10" =>  -- Update B
                next_B <= input;
            when others => 
                -- nothing?
        end case;
    end process;

    -- Sequential part
    process(clk, reset)
    begin
        if reset = '1' then 
            A <= (others => '0');
            B <= (others => '0');
        elsif rising_edge(clk) then
            A <= next_A;
            B <= next_B;
        end if;
    end process;

end behavioral;