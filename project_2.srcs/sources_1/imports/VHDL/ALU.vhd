library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
   port ( 
      A          : in  std_logic_vector (7 downto 0);
      B          : in  std_logic_vector (7 downto 0);
      FN         : in  std_logic_vector (3 downto 0);
      result     : out std_logic_vector (7 downto 0);
      overflow   : out std_logic;
      sign       : out std_logic
   );
end ALU;

architecture behavioral of ALU is
begin
    process (A, B, FN)
        variable temp_result : signed(8 downto 0);
        variable temp_result_u : unsigned(8 downto 0);
        variable unsigned_a, unsigned_b : unsigned(7 downto 0);
        variable signed_a, signed_b : signed(7 downto 0);
        variable mod3_temp : signed(7 downto 0);
    begin
        unsigned_a := unsigned(A);
        unsigned_b := unsigned(B);
        signed_a := signed(A);
        signed_b := signed(B);
        
        overflow <= '0';
        sign <= '0';
        
        
        case FN is
            when "0000" => -- Input A
                result <= A;
            
            when "0001" => -- Input B
                result <= B;
            
            when "0010" => -- Unsigned (A + B)
                temp_result_u := resize(unsigned_a, 9) + resize(unsigned_b, 9);
                result <= std_logic_vector(temp_result_u(7 downto 0));
                overflow <= temp_result_u(8);
            
            when "0011" => -- Unsigned (A - B)
                if unsigned_a >= unsigned_b then
                    result <= std_logic_vector(unsigned_a - unsigned_b);
                else
                    result <= std_logic_vector(unsigned_b - unsigned_a); -- hm
                    overflow <= '1';
                end if;
            
            when "0100" => -- Unsigned (A) mod 3
                result <= std_logic_vector(to_unsigned(to_integer(unsigned_a) mod 3, 8));
            
            when "1010" => -- Signed (A + B)
                temp_result := resize(signed_a, 9) + resize(signed_b, 9); -- '0' & ...
                result <= std_logic_vector(temp_result(7 downto 0));
                --inputs have same sign, input and result sign differ
                overflow <= (signed_a(7) xnor signed_b(7)) and (signed_a(7) xor temp_result(7)); 
                sign <= temp_result(7);
            
            when "1011" => -- Signed (A - B)
                temp_result := resize(signed_a, 9) - resize(signed_b, 9);
                result <= std_logic_vector(temp_result(7 downto 0));
                overflow <= (signed_a(7) xor signed_b(7)) and (signed_a(7) xor temp_result(7));
                sign <= temp_result(7);
            
            when "1100" => -- Signed (A) mod 3. 
                -- should -10 mod 3 yield 2 or -1
                mod3_temp := abs(signed_a) mod 3;
                if signed_a < 0 and mod3_temp /= 0 then
                    mod3_temp := 3 - mod3_temp;
                end if;
                result <= std_logic_vector(resize(unsigned(mod3_temp), 8));
                sign <= signed_a(7);
            
            when others =>
                result <= (others => '0');
        end case;
    end process;
end behavioral;