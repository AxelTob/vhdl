-------------------------------------------------------------------------------
-- Title      : edge_detector.vhd 
-- Project    : Keyboard VLSI Lab
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Description: 
-- 		        Make sure not to use 'EVENT on anyother signals than clk
-- 		        
--
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_1164.ALL;
ENTITY edge_detector IS
	PORT (
		clk : IN STD_LOGIC;
		rst : IN STD_LOGIC;
		kb_clk_sync : IN STD_LOGIC;
		edge_found : OUT STD_LOGIC
	);
END edge_detector;
ARCHITECTURE edge_detector_arch OF edge_detector IS
	TYPE sync_array IS ARRAY(0 TO 1) OF STD_LOGIC;
	SIGNAL kb_samples_ff : sync_array := (OTHERS => '0');
BEGIN
	PROCESS (kb_clk_sync, rst, clk)
	BEGIN
		IF rst = '1' THEN
			kb_samples_ff <= (OTHERS => '0');
			edge_found <= '0';
		ELSIF rising_edge(clk) THEN
			kb_samples_ff(0) <= kb_clk_sync;
			kb_samples_ff(1) <= kb_samples_ff(0);
			IF kb_samples_ff(1) = '1' AND kb_samples_ff(0) = '0' THEN
				edge_found <= '1';
			ELSE
				edge_found <= '0';
			END IF;
		END IF;
	END PROCESS;
END edge_detector_arch;