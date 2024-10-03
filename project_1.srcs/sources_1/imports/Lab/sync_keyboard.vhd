-------------------------------------------------------------------------------
-- Title      : sync_keyboard.vhd 
-- Project    : Keyboard VLSI Lab
-------------------------------------------------------------------------------

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity sync_keyboard is
    port (
	     clk : in std_logic; 
	     kb_clk : in std_logic;
	     kb_data : in std_logic;
	     kb_clk_sync : out std_logic;
	     kb_data_sync : out std_logic
	 );
end sync_keyboard;

architecture sync_keyboard_arch of sync_keyboard is
    type sync_array is array(0 to 1) of std_logic;
    -- not sure about good default values
    signal kb_clk_ff : sync_array := (others => '0');
    signal kb_data_ff : sync_array := (others => '0');

begin
	process (clk, kb_clk, kb_data)
	begin	   
		if rising_edge(clk) then
			kb_clk_ff(0) <= kb_clk;
			kb_clk_ff(1) <= kb_clk_ff(0);
			
			-- same for data
			kb_data_ff(0) <= kb_data;
			kb_data_ff(1) <= kb_data_ff(0);
		end if;
	end process;
    kb_clk_sync <= kb_clk_ff(1);
    kb_data_sync <= kb_data_ff(1);
end sync_keyboard_arch;
