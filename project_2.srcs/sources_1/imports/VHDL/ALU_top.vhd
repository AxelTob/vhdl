library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ALU_components_pack.all;

entity ALU_top is
   port ( 
      clk        : in  std_logic;
      reset      : in  std_logic;
      b_Enter    : in  std_logic;
      b_Sign     : in  std_logic;
      input      : in  std_logic_vector(7 downto 0);
      seven_seg  : out std_logic_vector(6 downto 0);
      anode      : out std_logic_vector(3 downto 0)
   );
end ALU_top;

architecture structural of ALU_top is
   -- SIGNAL DEFINITIONS
   signal Enter, Sign : std_logic;
   signal A, B, ALU_result : std_logic_vector(7 downto 0);
   signal FN : std_logic_vector(3 downto 0);
   signal RegCtrl : std_logic_vector(1 downto 0);
   signal overflow, sign_out : std_logic;
   signal BCD_result : std_logic_vector(9 downto 0);

begin
   -- Debouncer for Enter button
   debouncer1: debouncer
   port map (
      clk          => clk,
      reset        => reset,
      button_in    => b_Enter,
      button_out   => Enter
   );

   -- Debouncer for Sign button
   debouncer2: debouncer
   port map (
      clk          => clk,
      reset        => reset,
      button_in    => b_Sign,
      button_out   => Sign
   );

   -- ALU Controller
   controller: ALU_ctrl
   port map (
      clk     => clk,
      reset   => reset,
      enter   => Enter,
      sign    => Sign,
      FN      => FN,
      RegCtrl => RegCtrl
   );

   -- Register Update
   reg_update: regUpdate
   port map (
      clk     => clk,
      reset   => reset,
      RegCtrl => RegCtrl,
      input   => input,
      A       => A,
      B       => B
   );

   -- ALU
   alu_unit: ALU
   port map (
      A        => A,
      B        => B,
      FN       => FN,
      result   => ALU_result,
      overflow => overflow,
      sign     => sign_out
   );

   -- Binary to BCD Converter
   bi_bcd: Bi_to_BCD
   port map (
      binary_in => ALU_result,
      BCD_out   => BCD_result
   );

   -- 7-Segment Display Driver
   seg7_driver: seg7_driver
   port map (
      clk       => clk,
      reset     => reset,
      BCD_in    => BCD_result,
      overflow  => overflow,
      sign      => sign_out,
      seven_seg => seven_seg,
      anode     => anode
   );

end structural;