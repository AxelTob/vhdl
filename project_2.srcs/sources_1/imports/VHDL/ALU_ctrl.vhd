library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU_ctrl is
   port ( 
      clk     : in  std_logic;
      reset   : in  std_logic;
      enter   : in  std_logic;
      sign    : in  std_logic;
      FN      : out std_logic_vector (3 downto 0);   -- ALU functions
      RegCtrl : out std_logic_vector (1 downto 0)    -- Register update control bits
   );
end ALU_ctrl;

architecture behavioral of ALU_ctrl is
    type state_type is (IDLE, INPUT_A, INPUT_B, ADD, SUB, MOD3);
    signal current_state, next_state : state_type;
    signal is_signed : std_logic := '0';
    signal enter_prev, enter_edge : std_logic := '0'; 
begin
    -- Detect rising edge of enter button
    process(clk)
    begin
        if rising_edge(clk) then
            enter_prev <= enter;
            enter_edge <= enter and not enter_prev;
        end if;
    end process;

    -- State register and sign mode
    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= IDLE;
            is_signed <= '0';
        elsif rising_edge(clk) then
            current_state <= next_state;
            if sign = '1' then
                is_signed <= not is_signed;
            end if;
        end if;
    end process;

    -- Next state logic
    process(current_state, enter_edge)
    begin
        next_state <= current_state;  -- Default: stay in current state
        case current_state is
            when IDLE => -- remove or not. Can cause probs. but easy for reset. 
                if enter_edge = '1' then next_state <= INPUT_A; end if; -- we want to move to A state on input not just enter
            when INPUT_A =>
                if enter_edge = '1' then next_state <= INPUT_B; end if;
            when INPUT_B =>
                if enter_edge = '1' then next_state <= ADD; end if;
            when ADD =>
                if enter_edge = '1' then next_state <= SUB; end if;
            when SUB =>
                if enter_edge = '1' then next_state <= MOD3; end if;
            when MOD3 =>
                if enter_edge = '1' then next_state <= ADD; end if;
        end case;
    end process;

    -- Output logic
    process(current_state, is_signed)
    begin
        case current_state is
            when IDLE =>
                FN <= "0000";  RegCtrl <= "00";
            when INPUT_A =>
                FN <= "0000";  RegCtrl <= "01";
            when INPUT_B =>
                FN <= "0001";  RegCtrl <= "10";
            when ADD =>
                if is_signed = '1' then
                    FN <= "1010";  -- Signed addition
                else
                    FN <= "0010";  -- Unsigned addition
                end if;
                RegCtrl <= "00";
            when SUB =>
                if is_signed = '1' then
                    FN <= "1011";  -- Signed subtraction
                else
                    FN <= "0011";  -- Unsigned subtraction
                end if;
                RegCtrl <= "00";
            when MOD3 =>
                if is_signed = '1' then
                    FN <= "1100";  -- Signed modulo 3
                else
                    FN <= "0100";  -- Unsigned modulo 3
                end if;
                RegCtrl <= "00";
        end case;
    end process;
end behavioral;