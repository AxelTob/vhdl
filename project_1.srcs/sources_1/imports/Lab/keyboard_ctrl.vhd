library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
entity keyboard_ctrl is
	port (
		clk : in std_logic;
		rst : in std_logic;
		valid_code : in std_logic;
		scan_code_in : in unsigned(7 downto 0);
		code_to_display : out unsigned(7 downto 0);
		seg_en : out unsigned(3 downto 0)
	);
end keyboard_ctrl;

architecture keyboard_ctrl_arch of keyboard_ctrl is
	signal bit_counter : unsigned(3 downto 0) := (others => '1');
	signal next_bit_counter : unsigned(3 downto 0) := (others => '1');
	signal got_break : std_logic := '0';
	signal next_got_break : std_logic := '0';
	signal clk_counter : integer range 0 to 4999999 := 0;
	signal shift_scancode : unsigned(31 downto 0) := (others => '0');
	signal next_shift_scancode : unsigned(31 downto 0) := (others => '0');

begin
	process (rst, clk, scan_code_in, valid_code, got_break) --decide when should we shift the scan_code_in;
	begin
	if rising_edge(clk) then
		if rst = '1' then
			next_got_break <= '0';
			next_shift_scancode <= (others => '0');
		elsif valid_code = '1' then
			if scan_code_in = "11110000" then
				next_got_break <= '1';
			elsif got_break = '1' then
				next_shift_scancode <= shift_scancode(23 downto 0) & scan_code_in(7 downto 0);
				next_got_break <= '0';
			else
				next_got_break <= got_break;
				next_shift_scancode <= shift_scancode;
			end if;
		else
			next_got_break <= got_break;
			next_shift_scancode <= shift_scancode;
		end if;
    end if;
	end process;
 
	process (rst, clk, bit_counter, clk_counter) --use a clock couunter to display to avoid the captical illusion;
		begin
			if rising_edge(clk) then
				if rst = '1' then
					clk_counter <= 0;
					shift_scancode <= (others => '0');
					next_bit_counter <= "0000";
					seg_en <= (others => '1');
					bit_counter <= (others => '1');
				else
					shift_scancode <= next_shift_scancode;
					seg_en <= bit_counter;
					bit_counter <= next_bit_counter;
					got_break <= next_got_break;
					if clk_counter = 9999 then
						clk_counter <= 0;
						case bit_counter is
							when "1110" => 
								next_bit_counter <= "1101";
							when "1101" => 
								next_bit_counter <= "1011";
							when "1011" => 
								next_bit_counter <= "0111";
							when "0111" => 
								next_bit_counter <= "1110";
							when others => 
								next_bit_counter <= "1110";
						end case;
 
					else
						clk_counter <= clk_counter + 1; 
					end if;
				end if;
			end if;
		end process; 
 
		process (bit_counter) --use bit_counter to decide which one shoud be on display;
			begin
				case bit_counter is
					when "1110" => 
						code_to_display <= shift_scancode(7 downto 0);
					when "1101" => 
						code_to_display <= shift_scancode(15 downto 8);
					when "1011" => 
						code_to_display <= shift_scancode(23 downto 16);
					when "0111" => 
						code_to_display <= shift_scancode(31 downto 24);
					when others => 
						code_to_display <= "11111111";
				end case;
			end process; 
end keyboard_ctrl_arch;