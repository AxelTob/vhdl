library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- mod reflection. Pretty dry. Can maybe make prettier.

entity ALU is
    port (
        A : in std_logic_vector (7 downto 0);
        B : in std_logic_vector (7 downto 0);
        FN : in std_logic_vector (3 downto 0);
        result : out std_logic_vector (7 downto 0);
        overflow : out std_logic;
        sign : out std_logic
    );
end ALU;

architecture behavioral of ALU is
    signal mod_out : std_logic_vector (7 downto 0);

    signal mod_comp_Ato1 : unsigned (7 downto 0);
    signal mod_comp_1to2 : unsigned (7 downto 0);
    signal mod_comp_2to3 : unsigned (7 downto 0);
    signal mod_comp_3to4 : unsigned (7 downto 0);
    signal mod_comp_4to5 : unsigned (7 downto 0);
    signal mod_comp_5to6 : unsigned (7 downto 0);
    signal mod_comp_6to7 : unsigned (7 downto 0);
    signal mod_comp_7toOut : unsigned (7 downto 0);

    signal add_out : unsigned (8 downto 0);
    signal sub_out : unsigned (8 downto 0);

    signal temp_add : unsigned (8 downto 0);
    signal temp_sub : unsigned (8 downto 0);

    signal sub_unsigned_a, sub_unsigned_b, add_unsigned_a, add_unsigned_b, unsigned_a, unsigned_b : unsigned(7 downto 0);



begin
    add_unsigned_a <= unsigned(A);
    add_unsigned_b <= unsigned(B);
    unsigned_a <= unsigned(A);
    unsigned_b <= unsigned(B);
    sub_unsigned_a <= unsigned(A);
    sub_unsigned_b <= unsigned(not B) + 1;
    
    process (A, B, FN, mod_out, sub_out, add_out, unsigned_a, unsigned_b)
-- 3 + 1 => 2. 1 +3 => 6
    begin
        overflow <= '0';
        sign <= '0';
        case FN is
            when "0000" => -- Input A
                result <= A;

            when "0001" => -- Input B
                result <= B;

            when "0010" => -- Unsigned (A + B)
                result <= std_logic_vector(add_out(7 downto 0));
                overflow <= add_out(8);

            when "0011" => -- Unsigned (A - B)
                result <= std_logic_vector(sub_out(7 downto 0));
                overflow <= not sub_out(8);

            when "0100" => -- Unsigned (A) mod 3
                result <= mod_out;
            when "1010" => -- Signed (A + B)
                if add_out(7) = '1' then
                    result <= std_logic_vector(not add_out(7 downto 0) + 1);
                else
                    result <= std_logic_vector(add_out(7 downto 0));
                end if;
                --inputs have same sign, input and result sign differ
                if (unsigned_a(7) = unsigned_b(7) and unsigned_a(7) /= add_out(7)) then
                    overflow <= '1';
                else
                    overflow <= '0';
                end if;
                sign <= add_out(7);

            when "1011" => -- Signed (A - B)               
                if sub_out(7) = '1' then
                    result <= std_logic_vector(not sub_out(7 downto 0) + 1);
                else
                    result <= std_logic_vector(sub_out(7 downto 0));
                end if;
                if (unsigned_a(7) /= B(7) and unsigned_a(7) /= sub_out(7)) then
                    overflow <= '1';
                else
                    overflow <= '0';
                end if;
                sign <= sub_out(7);

            when "1100" => -- Signed (A) mod 3. 
                result <= mod_out;

            when others =>
                result <= (others => '0');
        end case;
    end process;
    -- ADD
    PROCESS (FN, add_unsigned_a, add_unsigned_b, temp_add)
    begin
        temp_add <= resize(add_unsigned_a, 9) + resize(add_unsigned_b, 9);
        
        IF FN(1) /= '1' then
            add_out <= (others => '0');
        else
            add_out <= temp_add;
        end if;
    END PROCESS;

    -- SUB process
    PROCESS (FN, sub_unsigned_a, sub_unsigned_b, temp_sub)
    begin
        temp_sub <= resize(sub_unsigned_a, 9) + resize(sub_unsigned_b, 9);
        
        IF FN(0) /= '1' then
            sub_out <= (others => '0');
        else
            sub_out <= temp_sub;
        end if;
    END PROCESS;
    -- MOD
    process (FN, A, mod_out, mod_comp_Ato1, mod_comp_1to2, mod_comp_2to3, mod_comp_3to4, mod_comp_4to5, mod_comp_5to6, mod_comp_6to7, mod_comp_7toOut)
    begin
        if FN(2) /= '1' then
            mod_out <= (others => '0');
        end if;

        if A(7) = '1' and FN(3) = '1' then
            mod_comp_Ato1 <= unsigned(not A) + 1;
        else
            mod_comp_Ato1 <= unsigned(A);
        end if;

        if mod_comp_Ato1 >= 192 then
            mod_comp_1to2 <= mod_comp_Ato1 - 192;
        else
            mod_comp_1to2 <= mod_comp_Ato1;
        end if;

        if mod_comp_1to2 >= 96 then
            mod_comp_2to3 <= mod_comp_1to2 - 96;
        else
            mod_comp_2to3 <= mod_comp_1to2;
        end if;

        if mod_comp_2to3 >= 48 then
            mod_comp_3to4 <= mod_comp_2to3 - 48;
        else
            mod_comp_3to4 <= mod_comp_2to3;
        end if;

        if mod_comp_3to4 >= 24 then
            mod_comp_4to5 <= mod_comp_3to4 - 24;
        else
            mod_comp_4to5 <= mod_comp_3to4;
        end if;

        if mod_comp_4to5 >= 12 then
            mod_comp_5to6 <= mod_comp_4to5 - 12;
        else
            mod_comp_5to6 <= mod_comp_4to5;
        end if;

        if mod_comp_5to6 >= 6 then
            mod_comp_6to7 <= mod_comp_5to6 - 6;
        else
            mod_comp_6to7 <= mod_comp_5to6;
        end if;

        if mod_comp_6to7 >= 3 then
            mod_comp_7toOut <= mod_comp_6to7 - 3;
        else
            mod_comp_7toOut <= mod_comp_6to7;
        end if;

        mod_out <= std_logic_vector(mod_comp_7toOut);

        if FN(3) = '1' then
            if A(7) = '1' and mod_comp_7toOut(1 downto 0) /= "00" then
                mod_out <= std_logic_vector(3 - mod_comp_7toOut);
            end if;
        end if;

    end process;
end behavioral;