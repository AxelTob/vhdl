LIBRARY ieee;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_1164.ALL;
ENTITY keyboard_ctrl IS
	PORT (
		clk : IN STD_LOGIC;
		rst : IN STD_LOGIC;
		valid_code : IN STD_LOGIC;
		scan_code_in : IN unsigned(7 DOWNTO 0);
		code_to_display : OUT unsigned(7 DOWNTO 0);
		seg_en : OUT unsigned(3 DOWNTO 0)
	);
END keyboard_ctrl;

ARCHITECTURE keyboard_ctrl_arch OF keyboard_ctrl IS
	SIGNAL bit_counter : unsigned(3 DOWNTO 0) := (OTHERS => '1');
	SIGNAL next_bit_counter : unsigned(3 DOWNTO 0) := (OTHERS => '1');
	SIGNAL got_break : STD_LOGIC := '0';
	SIGNAL next_got_break : STD_LOGIC := '0';
	SIGNAL clk_counter : INTEGER RANGE 0 TO 9999 := 0;
	SIGNAL shift_scancode : unsigned(31 DOWNTO 0) := (OTHERS => '1');
	SIGNAL next_shift_scancode : unsigned(31 DOWNTO 0) := (OTHERS => '1');

BEGIN
	PROCESS (rst, clk)
	BEGIN
		IF rising_edge(clk) THEN
			IF rst = '1' THEN
				got_break <= '0';
				shift_scancode <= (OTHERS => '1');
				clk_counter <= 0;
				bit_counter <= "1111"; -- Initial value
				seg_en <= "1111"; -- All enabled initially
			ELSE
				got_break <= next_got_break;
				shift_scancode <= next_shift_scancode;
				clk_counter <= clk_counter + 1;
				bit_counter <= next_bit_counter;
				seg_en <= bit_counter; -- Update seg_en here
			END IF;
		END IF;
	END PROCESS;

	-- Combinational Process
	PROCESS (scan_code_in, valid_code, got_break, shift_scancode)
	BEGIN
		next_got_break <= got_break;
		next_shift_scancode <= shift_scancode;

		IF valid_code = '1' THEN
			IF scan_code_in = "11110000" THEN
				next_got_break <= '1';
			ELSIF got_break = '1' THEN
				next_shift_scancode <= shift_scancode(23 DOWNTO 0) & scan_code_in(7 DOWNTO 0);
				next_got_break <= '0';
			ELSE
				next_got_break <= '0';
				next_shift_scancode <= shift_scancode;
			END IF;
		ELSE
			next_got_break <= got_break;
			next_shift_scancode <= shift_scancode;
		END IF;
	END PROCESS;
	
	PROCESS (clk_counter, bit_counter)
	BEGIN
		-- Default assignment
		next_bit_counter <= bit_counter; -- Maintain current value by default

		IF clk_counter = 9999 THEN
			CASE bit_counter IS
				WHEN "1110" =>
					next_bit_counter <= "1101";
				WHEN "1101" =>
					next_bit_counter <= "1011";
				WHEN "1011" =>
					next_bit_counter <= "0111";
				WHEN "0111" =>
					next_bit_counter <= "1110";
				WHEN OTHERS =>
					next_bit_counter <= "1110";
			END CASE;
		END IF;
	END PROCESS;

	PROCESS (bit_counter, shift_scancode) --use bit_counter to decide which one shoud be on display;
	BEGIN
		CASE bit_counter IS
			WHEN "1110" =>
				code_to_display <= shift_scancode(7 DOWNTO 0);
			WHEN "1101" =>
				code_to_display <= shift_scancode(15 DOWNTO 8);
			WHEN "1011" =>
				code_to_display <= shift_scancode(23 DOWNTO 16);
			WHEN "0111" =>
				code_to_display <= shift_scancode(31 DOWNTO 24);
			WHEN OTHERS =>
				code_to_display <= "11111111";
		END CASE;
	END PROCESS;
END keyboard_ctrl_arch;