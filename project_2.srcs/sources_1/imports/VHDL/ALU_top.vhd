LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ALU_top IS
   PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      b_Enter : IN STD_LOGIC;
      b_Sign : IN STD_LOGIC;
      input : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      seven_seg : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
      anode : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
   );
END ALU_top;

ARCHITECTURE structural OF ALU_top IS
   COMPONENT debouncer
      PORT (
         clk : IN STD_LOGIC;
         reset : IN STD_LOGIC;
         button_in : IN STD_LOGIC;
         button_out : OUT STD_LOGIC
      );
   END COMPONENT;

   COMPONENT ALU_ctrl
      PORT (
         clk : IN STD_LOGIC;
         reset : IN STD_LOGIC;
         enter : IN STD_LOGIC;
         sign : IN STD_LOGIC;
         FN : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
         RegCtrl : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
      );
   END COMPONENT;

   COMPONENT regUpdate
      PORT (
         clk : IN STD_LOGIC;
         reset : IN STD_LOGIC;
         RegCtrl : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
         input : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
         A : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
         B : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
      );
   END COMPONENT;

   COMPONENT ALU
      PORT (
         A : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
         B : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
         FN : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
         result : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
         overflow : OUT STD_LOGIC;
         sign : OUT STD_LOGIC
      );
   END COMPONENT;

   COMPONENT binary2BCD
      PORT (
         binary_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
         BCD_out : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
         clk : IN STD_LOGIC;
         reset : IN STD_LOGIC
      );
   END COMPONENT;

   COMPONENT seven_seg_driver
      PORT (
         clk : IN STD_LOGIC;
         reset : IN STD_LOGIC;
         BCD_digit : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
         sign : IN STD_LOGIC;
         overflow : IN STD_LOGIC;
         DIGIT_ANODE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
         SEGMENT : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
      );
   END COMPONENT;

   -- Internal signals
   SIGNAL Enter, Sign : STD_LOGIC;
   SIGNAL A, B, ALU_result : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL FN : STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL RegCtrl : STD_LOGIC_VECTOR(1 DOWNTO 0);
   SIGNAL overflow, sign_out : STD_LOGIC;
   SIGNAL BCD_out : STD_LOGIC_VECTOR(9 DOWNTO 0);
   SIGNAL reset_n : STD_LOGIC;

BEGIN
   reset_n <= not reset;
   -- Debouncer for Enter button
   debouncer1 : debouncer
   PORT MAP(
      clk => clk,
      reset => reset_n,
      button_in => b_Enter,
      button_out => Enter
   );

   -- Debouncer for Sign button
   debouncer2 : debouncer
   PORT MAP(
      clk => clk,
      reset => reset_n,
      button_in => b_Sign,
      button_out => Sign
   );

   -- ALU Controller
   alu_controller : ALU_ctrl
   PORT MAP(
      clk => clk,
      reset => reset_n,
      enter => Enter,
      sign => Sign,
      FN => FN,
      RegCtrl => RegCtrl
   );

   -- Register Update
   reg_update : regUpdate
   PORT MAP(
      clk => clk,
      reset => reset_n,
      RegCtrl => RegCtrl,
      input => input,
      A => A,
      B => B
   );

   -- ALU
   alu_unit : ALU
   PORT MAP(
      A => A,
      B => B,
      FN => FN,
      result => ALU_result,
      overflow => overflow,
      sign => sign_out
   );

   -- Binary to BCD Converter
   bcd_converter : binary2BCD
   PORT MAP(
      binary_in => ALU_result,
      BCD_out => BCD_out,
      clk => clk,
      reset => reset_n
   );

   -- 7-Segment Display Driver
   seg7_driver : seven_seg_driver
   PORT MAP(
      clk => clk,
      reset => reset_n,
      BCD_digit => BCD_out,
      sign => sign_out,
      overflow => overflow,
      DIGIT_ANODE => anode,
      SEGMENT => seven_seg
   );

END structural;