-------------------------------------------------------------------------------
-- Title      : keyboard_top.vhd 
-- Project    : Keyboard VLSI Lab
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Description: 
-- 		Keyboard top level	
-- 		Functionality of all sub-modules are mentioned in manual.
--		All the required interconnects are already done, students have
-- 		to basically fill vhdl code in the sub-modules !!
--		
--
--
--
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_1164.ALL;
ENTITY keyboard_top IS
	PORT (
		clk : IN STD_LOGIC;
		rst : IN STD_LOGIC;
		kb_data : IN STD_LOGIC;
		kb_clk : IN STD_LOGIC;
		sc : OUT unsigned(7 DOWNTO 0);
		num : OUT unsigned(7 DOWNTO 0);
		seg_en : OUT unsigned(3 DOWNTO 0)
	);
END keyboard_top;

ARCHITECTURE keyboard_top_arch OF keyboard_top IS
	COMPONENT edge_detector IS
		PORT (
			clk : IN STD_LOGIC;
			rst : IN STD_LOGIC;
			kb_clk_sync : IN STD_LOGIC;
			edge_found : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT sync_keyboard IS
		PORT (
			clk : IN STD_LOGIC;
			kb_clk : IN STD_LOGIC;
			kb_data : IN STD_LOGIC;
			kb_clk_sync : OUT STD_LOGIC;
			kb_data_sync : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT convert_scancode IS
		PORT (
			clk : IN STD_LOGIC;
			rst : IN STD_LOGIC;
			edge_found : IN STD_LOGIC;
			serial_data : IN STD_LOGIC;
			valid_scan_code : OUT STD_LOGIC;
			scan_code_out : OUT unsigned(7 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT keyboard_ctrl IS
		PORT (
			clk : IN STD_LOGIC;
			rst : IN STD_LOGIC;
			valid_code : IN STD_LOGIC;
			scan_code_in : IN unsigned(7 DOWNTO 0);
			code_to_display : OUT unsigned(7 DOWNTO 0);
			seg_en : OUT unsigned(3 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT convert_to_binary IS
		PORT (
			scan_code_in : IN unsigned(7 DOWNTO 0);
			binary_out : OUT unsigned(3 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT binary_to_sg
		PORT (
			binary_in : IN unsigned(3 DOWNTO 0);
			sev_seg : OUT unsigned(7 DOWNTO 0)
		);
	END COMPONENT;

	SIGNAL kb_clk_sync, kb_data_sync : STD_LOGIC;
	SIGNAL edge_found : STD_LOGIC;
	SIGNAL scan_code : unsigned(7 DOWNTO 0);
	SIGNAL valid_scan_code : STD_LOGIC;
	SIGNAL binary_num : unsigned(3 DOWNTO 0);
	SIGNAL code_to_display : unsigned(7 DOWNTO 0);

BEGIN

	-- syncrhonize all the input signal from keyboard
	sync_keyboard_inst : sync_keyboard
	PORT MAP(
		clk => clk,
		kb_clk => kb_clk,
		kb_data => kb_data,
		kb_clk_sync => kb_clk_sync,
		kb_data_sync => kb_data_sync
	);

	-- detect the falling edge of kb_clk
	-- double check if its synthesizable !!
	edge_detector_inst : edge_detector
	PORT MAP(
		clk => clk,
		rst => rst,
		kb_clk_sync => kb_clk_sync,
		edge_found => edge_found
	);
	-- basically convert serial kb_data to parallel scan code 
	-- make sure not to use edge_found as clock !!! (i.e dont use edge_found'event)
	convert_scancode_inst : convert_scancode
	PORT MAP(
		clk => clk,
		rst => rst,
		edge_found => edge_found,
		serial_data => kb_data_sync,
		valid_scan_code => valid_scan_code,
		scan_code_out => scan_code
	);
	-- drive led with the shifted output
	sc <= scan_code;
	-- control, implement state machine
	keyboard_ctrl_inst : keyboard_ctrl
	PORT MAP(
		clk => clk,
		rst => rst,
		valid_code => valid_scan_code,
		scan_code_in => scan_code,
		code_to_display => code_to_display,
		seg_en => seg_en
	);

	convert_to_binary_inst : convert_to_binary
	PORT MAP(
		scan_code_in => code_to_display,
		binary_out => binary_num
	);
	binary_to_sg_inst : binary_to_sg
	PORT MAP(
		binary_in => binary_num,
		sev_seg => num
	);

END keyboard_top_arch;