LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
-- mod reflection. Pretty dry. Can maybe make prettier.

ENTITY ALU IS
    PORT (
        A : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        B : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        FN : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        result : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        overflow : OUT STD_LOGIC;
        sign : OUT STD_LOGIC
    );
END ALU;

ARCHITECTURE behavioral OF ALU IS
    CONSTANT MOD3_192 : unsigned(7 DOWNTO 0) := to_unsigned(192, 8);
    CONSTANT MOD3_96 : unsigned(7 DOWNTO 0) := to_unsigned(96, 8);
    CONSTANT MOD3_48 : unsigned(7 DOWNTO 0) := to_unsigned(48, 8);
    CONSTANT MOD3_24 : unsigned(7 DOWNTO 0) := to_unsigned(24, 8);
    CONSTANT MOD3_12 : unsigned(7 DOWNTO 0) := to_unsigned(12, 8);
    CONSTANT MOD3_6 : unsigned(7 DOWNTO 0) := to_unsigned(6, 8);
    CONSTANT MOD3_3 : unsigned(7 DOWNTO 0) := to_unsigned(3, 8);
BEGIN
    PROCESS (A, B, FN)
        VARIABLE temp_result : signed(8 DOWNTO 0);
        VARIABLE temp_result_u : unsigned(8 DOWNTO 0);
        VARIABLE unsigned_a, unsigned_b : unsigned(7 DOWNTO 0);
        VARIABLE signed_a, signed_b : signed(7 DOWNTO 0);
        VARIABLE mod3_temp : unsigned(7 DOWNTO 0);
    BEGIN
        unsigned_a := unsigned(A);
        unsigned_b := unsigned(B);
        signed_a := signed(A);
        signed_b := signed(B);

        overflow <= '0';
        sign <= '0';
        CASE FN IS
            WHEN "0000" => -- Input A
                result <= A;

            WHEN "0001" => -- Input B
                result <= B;

            WHEN "0010" => -- Unsigned (A + B)
                temp_result_u := resize(unsigned_a, 9) + resize(unsigned_b, 9);
                result <= STD_LOGIC_VECTOR(temp_result_u(7 DOWNTO 0));
                overflow <= temp_result_u(8);

            WHEN "0011" => -- Unsigned (A - B)
                IF unsigned_a >= unsigned_b THEN
                    result <= STD_LOGIC_VECTOR(unsigned_a - unsigned_b);
                ELSE
                    result <= STD_LOGIC_VECTOR(to_unsigned(256, 8) - (unsigned_b - unsigned_a)); -- hm
                    overflow <= '1';
                END IF;

            WHEN "0100" => -- Unsigned (A) mod 3
                mod3_temp := unsigned(A);
                IF mod3_temp >= MOD3_192 THEN
                    mod3_temp := mod3_temp - MOD3_192;
                END IF;
                IF mod3_temp >= MOD3_96 THEN
                    mod3_temp := mod3_temp - MOD3_96;
                END IF;
                IF mod3_temp >= MOD3_48 THEN
                    mod3_temp := mod3_temp - MOD3_48;
                END IF;
                IF mod3_temp >= MOD3_24 THEN
                    mod3_temp := mod3_temp - MOD3_24;
                END IF;
                IF mod3_temp >= MOD3_12 THEN
                    mod3_temp := mod3_temp - MOD3_12;
                END IF;
                IF mod3_temp >= MOD3_6 THEN
                    mod3_temp := mod3_temp - MOD3_6;
                END IF;
                IF mod3_temp >= MOD3_3 THEN
                    mod3_temp := mod3_temp - MOD3_3;
                END IF;
                result <= STD_LOGIC_VECTOR("000000" & mod3_temp(1 DOWNTO 0));
            WHEN "1010" => -- Signed (A + B)
                temp_result := resize(signed_a, 9) + resize(signed_b, 9); -- '0' & ...
                result <= STD_LOGIC_VECTOR(temp_result(7 DOWNTO 0));
                --inputs have same sign, input and result sign differ
                overflow <= (signed_a(7) XNOR signed_b(7)) AND (signed_a(7) XOR temp_result(7));
                sign <= temp_result(7);
                

            WHEN "1011" => -- Signed (A - B)
               -- temp_result := resize(signed_a, 9) - resize(signed_b, 9);
                --result <= STD_LOGIC_VECTOR(temp_result(7 DOWNTO 0));
                -- if A and B have same sign (ex. -). and result and sign(of either a,b) is same.
                --overflow <= (signed_a(7) XOR signed_b(7)) AND (signed_a(7) XOR temp_result(7));
                --sign <= temp_result(7);
                IF signed_a >= signed_b THEN
                    result <= STD_LOGIC_VECTOR(signed_a - signed_b);
                ELSE
                    result <= STD_LOGIC_VECTOR(signed_b - signed_a); -- hm
                    sign <= '1';
                END IF;

            WHEN "1100" => -- Signed (A) mod 3. 
                IF A(7) = '0' THEN -- Positive number
                    mod3_temp := unsigned(A);
                ELSE -- Negative number
                    mod3_temp := unsigned(NOT A) + 1; -- Two's complement
                END IF;

                IF mod3_temp >= MOD3_192 THEN
                    mod3_temp := mod3_temp - MOD3_192;
                END IF;
                IF mod3_temp >= MOD3_96 THEN
                    mod3_temp := mod3_temp - MOD3_96;
                END IF;
                IF mod3_temp >= MOD3_48 THEN
                    mod3_temp := mod3_temp - MOD3_48;
                END IF;
                IF mod3_temp >= MOD3_24 THEN
                    mod3_temp := mod3_temp - MOD3_24;
                END IF;
                IF mod3_temp >= MOD3_12 THEN
                    mod3_temp := mod3_temp - MOD3_12;
                END IF;
                IF mod3_temp >= MOD3_6 THEN
                    mod3_temp := mod3_temp - MOD3_6;
                END IF;
                IF mod3_temp >= MOD3_3 THEN
                    mod3_temp := mod3_temp - MOD3_3;
                END IF;

                IF A(7) = '1' AND mod3_temp /= 0 THEN -- Adjust for negative numbers
                    mod3_temp := 3 - mod3_temp;
                END IF;

                result <= STD_LOGIC_VECTOR("000000" & mod3_temp(1 DOWNTO 0));

            WHEN OTHERS =>
                result <= (OTHERS => '0');
        END CASE;
    END PROCESS;
END behavioral;