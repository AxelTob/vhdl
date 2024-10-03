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

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;


entity edge_detector is
    port (
	     clk : in std_logic;
	     rst : in std_logic;
	     kb_clk_sync : in std_logic;
	     edge_found : out std_logic
	 );
end edge_detector;


architecture edge_detector_arch of edge_detector is
    type sync_array is array(0 to 1) of std_logic;
    -- not sure about good default values
    signal kb_samples_ff : sync_array := (others => '0');
begin
    process (kb_clk_sync, rst, clk)
	begin
	    if rst = '1' then
	       kb_samples_ff <= (others => '0');
	       edge_found <= '0';
	    elsif rising_edge(clk) then
		    kb_samples_ff(0) <= kb_clk_sync;
			kb_samples_ff(1) <= kb_samples_ff(0);
			
			if kb_samples_ff(1) = '1' and kb_samples_ff(0) = '0' then
			     edge_found <= '1';
		    else
		      edge_found <= '0';
			end if;
		end if;
	end process;
end edge_detector_arch;
