-------------------------------------------------------------------------------
-- Title      : sync_keyboard.vhd 
-- Project    : Keyboard VLSI Lab
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_1164.ALL;

ENTITY sync_keyboard IS
	PORT (
		clk : IN STD_LOGIC;
		kb_clk : IN STD_LOGIC;
		kb_data : IN STD_LOGIC;
		kb_clk_sync : OUT STD_LOGIC;
		kb_data_sync : OUT STD_LOGIC
	);
END sync_keyboard;

ARCHITECTURE sync_keyboard_arch OF sync_keyboard IS
	TYPE sync_array IS ARRAY(0 TO 1) OF STD_LOGIC;
	SIGNAL kb_clk_ff : sync_array := (OTHERS => '0');
	SIGNAL kb_data_ff : sync_array := (OTHERS => '0');

BEGIN
	PROCESS (clk, kb_clk, kb_data)
	BEGIN
		IF rising_edge(clk) THEN
			kb_clk_ff(0) <= kb_clk;
			kb_clk_ff(1) <= kb_clk_ff(0);

			kb_data_ff(0) <= kb_data;
			kb_data_ff(1) <= kb_data_ff(0);
		END IF;
	END PROCESS;
	kb_clk_sync <= kb_clk_ff(1);
	kb_data_sync <= kb_data_ff(1);
END sync_keyboard_arch;