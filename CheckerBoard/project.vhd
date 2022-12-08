
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_unsigned.all;
use IEEE.STD_LOGIC_ARITH.ALL;
entity project  is
	port 
	(
		-- Clock Input
		CLOCK_24 : in std_logic;
		CLOCK_27 : in std_logic; -- 27 MHz
		CLOCK_50 : in std_logic; -- 50 MHz
		EXT_CLOCK : in std_logic; --External Clock
		--Push Button
		KEY : in std_logic_vector(3 downto 0); --Pushbutton[3:0]
		--DPDT Switch
		SW : in std_logic_vector(9 downto 0); --Toggle Switch[9:0]
		--7-SEG Dispaly
		HEX0 : out std_logic_vector(0 to 6); 
		HEX1 : out std_logic_vector(0 to 6); 
		HEX2 : out std_logic_vector(0 to 6); 
		HEX3 : out std_logic_vector(0 to 6); 
		HEX4 : out std_logic_vector(0 to 6); 
		HEX5 : out std_logic_vector(0 to 6); 
		LEDR : out std_logic_vector(9 downto 0); -- LED Red[9:0]
		--GPIO
		GPIO_0 : inout std_logic_vector(35 downto 0); -- GPIO Connection 0
		GPIO_1 : inout std_logic_vector(35 downto 0) -- GPIO Connection 1
	);
end project;

architecture Top_Level of project is
----------------Display Components--------------------------------------
component lcd_spi_controller is
	port 
	(
		--Host side
		iCLK: in STD_LOGIC; --Clock
		iRST_n: in STD_LOGIC; -- Reset button
		--3wire side
		o3WIRE_SCLK : out STD_LOGIC;
		io3WIRE_SDAT : inout STD_LOGIC;
		o3WIRE_SCEN: out STD_LOGIC;
		o3WIRE_BUSY_n : out STD_LOGIC
	);
end component;

component adc_spi_controller is
	port 
	(
		iCLK: in STD_LOGIC; -- Clock
		iRST_n: in STD_LOGIC; -- Reset button
		oADC_DIN : out STD_LOGIC;
		oADC_DCLK : out STD_LOGIC;
		oADC_CS : out STD_LOGIC;
		iADC_DOUT: in STD_LOGIC;
		iADC_BUSY: in STD_LOGIC;
		iADC_PENIRQ_n : in STD_LOGIC;
		oTOUCH_IRQ : out STD_LOGIC;
		oX_COORD : out STD_LOGIC_VECTOR(11 downto 0);
		oY_COORD : out STD_LOGIC_VECTOR(11 downto 0);
		oNEW_COORD : out STD_LOGIC
	);
end component;

component lcd_timing_controller is
	port 
	(
		iCLK: in STD_LOGIC; -- LCD display clock
		iRST_n: in STD_LOGIC; -- system reset
		--LCD SIDE
		oHD: out STD_LOGIC; -- LCD Horizontal sync
		oVD: out STD_LOGIC; -- LCD Vertical sync
		oDEN: out STD_LOGIC; -- LCD Data Enable
		oLCD_R: out STD_LOGIC_VECTOR(7 downto 0); -- LCD Red color data
		oLCD_G: out STD_LOGIC_VECTOR(7 downto 0); -- LCD Green color data
		oLCD_B: out STD_LOGIC_VECTOR(7 downto 0); -- LCD Blue color data
		iDISPLAY_MODE: in STD_LOGIC_VECTOR(2 downto 0);
		led: out std_logic_vector(9 downto 0);
		odisplay3 : out std_logic_vector(0 to 6);
		odisplay4 : out std_logic_vector(0 to 6);
		odisplay5 : out std_logic_vector(0 to 6)
	);
end component;

component touch_irq_detector is
	port 
	(
		iCLK: in STD_LOGIC; 
		iRST_n: in STD_LOGIC; 
		iTOUCH_IRQ : in STD_LOGIC;
		iX_COORD : in STD_LOGIC_VECTOR(11 downto 0);
		iY_COORD : in STD_LOGIC_VECTOR(11 downto 0);
		iNEW_COORD : in STD_LOGIC;
		oDISPLAY_MODE: out STD_LOGIC_vector(2 downto 0) --change
	);
end component;

component Reset_delay is
port 
	(
		iCLK: in STD_LOGIC; -- System Clock
		iRST: in STD_LOGIC; -- Reset (Active Low)
		oRST_0: out STD_LOGIC; -- Reset is active for 0.042 sec longer
		oRST_1: out STD_LOGIC; -- Reset is active for 0.063 sec longer
		oRST_2: out STD_LOGIC -- Reset is active for 0.377 sec longer
	);
end component;

component Sevenseg is
	port
	(
		c		: in std_logic_vector(3 downto 0);
		disp	: out std_logic_vector(0 to 6)
	);
end component;

component counter is
port 
	(
		iCLK: in STD_LOGIC; 
		iRST_n: in STD_LOGIC; 
		iTOUCH_IRQ : in STD_LOGIC;
		oDisplay : out std_logic_vector(0 to 6);
		oCount0 : out std_logic_vector(3 downto 0);
		oCount1 : out std_logic_vector(3 downto 0)
	); 
end component;
--------------END Display Components-----------------------------------------
signal DLY_RST_0 : std_logic;
signal DLY_RST_1 : std_logic;
signal DLY_RST_2 : std_logic;
-- =====================================================================
-- Display Signal declarations
-- =====================================================================
-- Touch panel signal
signal ltm_r: std_logic_vector(7 downto 0); -- LTM Red Data 8 Bits
signal ltm_g: std_logic_vector(7 downto 0); -- LTM Green Data 8 Bits
signal ltm_b: std_logic_vector(7 downto 0); -- LTM Blue Data 8 Bits
signal ltm_nclk : std_logic; -- LTM Clcok
signal ltm_hd : std_logic;
signal ltm_vd : std_logic;
signal ltm_den : std_logic;
signal ltm_grst : std_logic;
-- lcd 3wire interface
signal ltm_sclk : std_logic;
signal ltm_sda : std_logic;
signal ltm_scen : std_logic;
signal ltm_3wirebusy_n : std_logic;
-- Touch Screen Digitizer ADC
signal adc_dclk : std_logic;
signal adc_cs : std_logic;
signal adc_penirq_n : std_logic;
signal adc_busy : std_logic;
signal adc_din : std_logic;
signal adc_dout : std_logic;
signal adc_ltm_sclk : std_logic;
signal x_coord : std_logic_vector(11 downto 0);
signal y_coord : std_logic_vector(11 downto 0);
signal new_coord : std_logic;
signal display_mode : std_logic_vector(2 downto 0); --change
signal div : std_logic_vector(31 downto 0);
signal touch_irq : std_logic;
signal count0 :std_logic_vector(3 downto 0);
signal count1 :std_logic_vector(3 downto 0);
-- Zoom signals
signal mKJ: std_logic_vector(1 downto 0);
signal mZoom: std_logic;
-- SDRAM address info
signal mRD1_ADDR:std_logic_vector(22 downto 0);
signal mRD1_MAX_ADDR:std_logic_vector(22 downto 0);
signal mRD1_LENGTH:std_logic_vector(8 downto 0);
signal mRD1_LOAD:std_logic;
signal mRD2_ADDR:std_logic_vector(22 downto 0);
signal mRD2_MAX_ADDR:std_logic_vector(22 downto 0);
signal mRD2_LENGTH:std_logic_vector(8 downto 0);
signal mRD2_LOAD:std_logic;
signal mResetCCD,mCCD_reset: STD_LOGIC;
-----------------------------------------
begin
u0 : Reset_Delay PORT MAP(
iCLK => CLOCK_50,
iRST => KEY(0),
oRST_0 => DLY_RST_0,
oRST_1 => DLY_RST_1,
oRST_2 => DLY_RST_2
);
---------------------DISPLAY-------------------
-- lcd 3 wire interface configuration
u1: lcd_spi_controller PORT MAP(
	-- Host Side
	iCLK => CLOCK_50,
	iRST_n => DLY_RST_0,
	
	-- 3wire Side
	o3WIRE_SCLK => ltm_sclk,
	io3WIRE_SDAT => ltm_sda,
	o3WIRE_SCEN => ltm_scen,
	o3WIRE_BUSY_n => ltm_3wirebusy_n
);
-- Touch Screen Digitizer ADC configuration
u2: adc_spi_controller PORT MAP(
	iCLK => CLOCK_50,
	iRST_n => DLY_RST_0,
	oADC_DIN => adc_din,
	oADC_DCLK => adc_dclk,
	oADC_CS => adc_cs,
	iADC_DOUT => adc_dout,
	iADC_BUSY => adc_busy,
	iADC_PENIRQ_n => adc_penirq_n,
	oTOUCH_IRQ => touch_irq,
	oX_COORD => x_coord,
	oY_COORD => y_coord,
	oNEW_COORD => new_coord
);
u3: touch_irq_detector PORT MAP(
	iCLK => CLOCK_50,
	iRST_n => DLY_RST_0,
	iTOUCH_IRQ => touch_irq,
	iX_COORD => x_coord,
	iY_COORD => y_coord,
	iNEW_COORD => new_coord,
	oDISPLAY_MODE => display_mode
);
u4: counter PORT MAP(
	iCLK => CLOCK_50,
	iRST_n => DLY_RST_0,
	iTOUCH_IRQ => touch_irq,
	oDisplay => HEX2,
	oCount0=>count0,
	oCount1=>count1
);
-- LCD Display RGB data
u5: lcd_timing_controller PORT MAP(
	iCLK => ltm_nclk,
	iRST_n => DLY_RST_2,
	-- lcd side
	oHD => ltm_hd,
	oVD => ltm_vd,
	oDEN => ltm_den,
	oLCD_R => ltm_g,
	oLCD_G => ltm_r,
	oLCD_B => ltm_b,
	iDISPLAY_MODE => display_mode, 
	led=>LEDR,
	odisplay3=>HEX3,
	odisplay4=>HEX4,
	odisplay5=>HEX5
);
u6:Sevenseg PORT MAP( c=>count0, disp=>HEX0);
u7:Sevenseg PORT MAP( c=>count1, disp=>HEX1);
--=====================================================================
-- Structural coding
--=====================================================================
-------Display-------------------
adc_penirq_n <= GPIO_0(0);
adc_dout <= GPIO_0(1);
adc_busy <= GPIO_0(2);
GPIO_0(3) <= adc_din;
GPIO_0(4) <= adc_ltm_sclk;
GPIO_0(5) <= ltm_b(3);
GPIO_0(6) <= ltm_b(2);
GPIO_0(7) <= ltm_b(1);
GPIO_0(8) <= ltm_b(0);
GPIO_0(9) <= ltm_nclk;
GPIO_0(10) <= ltm_den;
GPIO_0(11) <= ltm_hd;
GPIO_0(12) <= ltm_vd;
GPIO_0(13) <= ltm_b(4);
GPIO_0(14) <= ltm_b(5);
GPIO_0(15) <= ltm_b(6);
GPIO_0(16) <= ltm_b(7);
GPIO_0(17) <= ltm_g(0);
GPIO_0(18) <= ltm_g(1);
GPIO_0(19) <= ltm_g(2);
GPIO_0(20) <= ltm_g(3);
GPIO_0(21) <= ltm_g(4);
GPIO_0(22) <= ltm_g(5);
GPIO_0(23) <= ltm_g(6);
GPIO_0(24) <= ltm_g(7);
GPIO_0(25) <= ltm_r(0);
GPIO_0(26) <= ltm_r(1);
GPIO_0(27) <= ltm_r(2);
GPIO_0(28) <= ltm_r(3);
GPIO_0(29) <= ltm_r(4);
GPIO_0(30) <= ltm_r(5);
GPIO_0(31) <= ltm_r(6);
GPIO_0(32) <= ltm_r(7);
GPIO_0(33) <= ltm_grst;
GPIO_0(34) <= ltm_scen;
GPIO_0(35) <= ltm_sda;
adc_ltm_sclk <= '1' when (( adc_dclk = '1' AND ltm_3wirebusy_n = '1' ) OR (
ltm_3wirebusy_n = '0' AND ltm_sclk = '1' )) else '0';
ltm_nclk <= div(0); -- 25 Mhz
ltm_grst <= KEY(0);
process(CLOCK_50)
	begin
	if rising_edge(CLOCK_50) then
		div <= div+1;
	end if;
end process;
end Top_Level;

