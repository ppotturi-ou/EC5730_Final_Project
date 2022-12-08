

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
entity lcd_timing_controller is
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
		iDISPLAY_MODE: in STD_LOGIC_VECTOR(1 downto 0);
		led : out std_logic_vector(9 downto 0);
		odisplay3 : out std_logic_vector(0 to 6);
		odisplay4 : out std_logic_vector(0 to 6);
		odisplay5 : out std_logic_vector(0 to 6);
		oCount0 : out std_logic_vector(3 downto 0);
		oCount1 : out std_logic_vector(3 downto 0)
	);
end lcd_timing_controller;

architecture LCD_Tim of lcd_timing_controller is
signal x_cnt: std_logic_vector(10 downto 0);
signal y_cnt: std_logic_vector(9 downto 0);
signal mred: std_logic_vector(7 downto 0);
signal mgreen: std_logic_vector(7 downto 0);
signal mblue: std_logic_vector(7 downto 0);
signal display_area: std_logic;
signal mhd: std_logic;
signal mvd: std_logic;
signal mden: std_logic;
signal mREAD_SDRAM_EN: std_logic;
signal msel: std_logic_vector(1 downto 0);
signal red_1: std_logic_vector(7 downto 0); 
signal green_1: std_logic_vector(7 downto 0);
signal blue_1: std_logic_vector(7 downto 0);
signal count : std_logic_vector(3 downto 0);
signal count1 : std_logic_vector(3 downto 0);
signal graycnt: std_logic_vector(7 downto 0);
signal pattern_data: std_logic_vector(7 downto 0);
constant H_LINE : integer := 1056;
constant V_LINE : integer := 525;
constant Hsync_Blank : integer := 216;
constant Hsync_Front_Porch : integer := 40;
constant Vertical_Back_Porch : integer := 35;
constant Vertical_Front_Porch : integer := 10;
constant bmp_image_Array_Size : integer := (3200-1);
signal bmp_Pixel_Cnt: integer :=54;

--Creates a 16 x 96003 array for a bmp pic


-- r_Choice <= r_Number(0#, 1);
 
-- r_Number(3#, 2) <= 9;

 
-- Accessing The Array:
-- r_Choice <= r_Number(0, 1);
 
-- r_Number(3, 2) <= 9;

begin
rgb_Deer <= t_bmp_pic_init;
---------------------------------------------------------
--process(iCLK, iRST_n)
--begin
-- if ((>(Hsync_Blank-1)) AND (x_cnt<(H_LINE-Hsync_Front_Porch)) AND (y_cnt>(Vertical_Back_Porch-1)) AND (y_cnt<(V_LINE - Vertical_Front_Porch))) then 
--	display_area <= '1';
-- else 
--	display_area<= '0';
-- end if;
--end process;

display_area = ((x_cnt>(Hsync_Blank-1)&& //>215
						(x_cnt<(H_LINE-Hsync_Front_Porch))&& //< 1016
						(y_cnt>(Vertical_Back_Porch-1))&& 
						(y_cnt<(V_LINE - Vertical_Front_Porch))
						))  ? 1'b1 : 1'b0;

--x y counter and lcd hd generator
process(iCLK, iRST_n)
begin
	if (iRST_n = '0') then
		x_cnt <= (others => '0');
		mhd <= '0';
	elsif (iCLK'event and iCLK = '1') then
		if(x_cnt = (H_LINE-1)) then
			x_cnt <= (others => '0');
			mhd <= '0';
		else
			x_cnt <= x_cnt + 1;
			mhd <= '1';
		end if;
	end if;
end process;

process(iCLK, iRST_n)
begin
	if (iRST_n = '0') then
		y_cnt <= (others => '0');
	elsif (iCLK'event and iCLK = '1') then
		if(x_cnt = (H_LINE-1)) then
			if(y_cnt = (V_LINE-1)) then
				y_cnt <= (others => '0');
			else
				y_cnt <= y_cnt + 1;
			end if;
		end if;
	end if;
end process;

--touch panel timing
process(iCLK, iRST_n)
begin
	if (iRST_n = '0') then
		mvd <= '1';
	elsif (iCLK'event and iCLK = '1') then
		if(y_cnt = 0) then
			mvd <= '0';
		else
			mvd <= '1';
		end if;
	end if;
end process;

process(iCLK, iRST_n)
begin
	if (iRST_n = '0') then
		mden <= '0';
	elsif (iCLK'event and iCLK = '1') then
		if(display_area = '0') then
			mden <= '1';
		else
			mden <= '0';
		end if;
	end if;
end process;


--gray level patten generator
process(iCLK, iRST_n)
begin
	if (iRST_n = '0') then
		graycnt <= (others => '0');
	elsif (iCLK'event and iCLK = '1') then
		if((x_cnt>(Hsync_Blank-1))AND(x_cnt<(H_LINE-Hsync_Front_Porch))) then
			graycnt <= graycnt + 1;
		else
			graycnt <= (others => '0');
		end if;
	end if;
end process;

led(0)<=iDISPLAY_MODE(0);
led(1)<=iDISPLAY_MODE(1);

process(iCLK, iRST_n)
--			constant filename:  string := "boeing.bmp"; -- local to sim
--        variable char_val:  character;
--        variable status: FILE_OPEN_STATUS;
--        variable openfile:  boolean;  -- FALSE by default
--        type f is file of character;
--        file ffile: f;
--        variable char_count:    natural := 0;
begin
	if (iRST_n = '0') then
		oHD <= '0';
		oVD <= '0';
		oDEN <= '0';
		oLCD_R <= (others => '0');
		oLCD_G <= (others => '0');
		oLCD_B <= (others => '0');
		if (bmp_Pixel_Cnt>bmp_image_Array_Size) then
			bmp_Pixel_Cnt <= 54;
		end if;
	else
	   msel		=	(y_cnt<88)					?	2'b01:
						(y_cnt>=88	&& y_cnt<136)	?	2'b10	:
						(y_cnt>=136	&& y_cnt<184)	?	2'b11	:
						(y_cnt>=184	&& y_cnt<232)	?	2'b01	:
						(y_cnt>=232	&& y_cnt<280)	?	2'b10	:
						(y_cnt>=280	&& y_cnt<328)	?	2'b11	:
						(y_cnt>=328	&& y_cnt<376)	?	2'b01	:
						(y_cnt>=376	&& y_cnt<424)	?	2'b10	:
						(y_cnt>=424	&& y_cnt<472)	?	2'b11	:
						   								   2'b00	;
																
		oHD <= mhd;
		oVD <= mvd;
		oDEN <= display_area;

		if(iDISPLAY_MODE = "11") then
			if(msel==0)
					begin
						pattern_data <= pattern_data + 1;		
						red_1 <= 0;
						green_1 <= 0;
						blue_1 <= 8'hFF;
					end	
				else if (msel==2)
					begin
						pattern_data <= pattern_data + 1;
						red_1 <= 0;
						green_1 <= 8'hFF;
						blue_1 <= 0;
					end	
				else if (msel==1)
					begin
						pattern_data <= pattern_data + 1;
						red_1 <= 0;
						green_1 <= 0;
						blue_1 <= 8'hFF;
					end
				else if (msel==3)
					begin
						pattern_data <= pattern_data + 1;
						red_1 <= 8'hFF;
						green_1 <= 0;
						blue_1 <= 0;
					end	
			oLCD_R <= "00011111";
			oLCD_G <= "10100000";
			oLCD_B <= "00000000";
			odisplay5<="1111010";--r
			odisplay4<="0110000";--E
			odisplay3<="1000011";--d

		--if(iDISPLAY_MODE = "11") then
		--oLCD_R <= std_logic_vector(to_unsigned(rgb_Deer(bmp_Pixel_Cnt),oLCD_R'length));
		--oLCD_G <= std_logic_vector(to_unsigned(rgb_Deer(bmp_Pixel_Cnt+1),oLCD_G'length));
		--oLCD_B <= std_logic_vector(to_unsigned(rgb_Deer(bmp_Pixel_Cnt+2),oLCD_B'length));
		--odisplay5<="1111010";--r
		--odisplay4<="0110000";--E
		--odisplay3<="1000010";--d
		--bmp_Pixel_Cnt <= (bmp_Pixel_Cnt)+4;
		--	if (bmp_Pixel_Cnt>bmp_image_Array_Size) then
		--		bmp_Pixel_Cnt <= 54;
		--	end if;


		elsif(iDISPLAY_MODE = "10") then
			oLCD_R <= "11000110";
			oLCD_G <= "00011111";
			oLCD_B <= "11011100";
			odisplay5<="0100000";--G
			odisplay4<="1111010";--R
			odisplay3<="1101010";--n
		elsif(iDISPLAY_MODE = "01") then
			oLCD_R <= "11111111";
			oLCD_G <= "10000000";
			oLCD_B <= "11111111";
			odisplay5<="1100000";--b
			odisplay4<="1110001";--l
			odisplay3<="1000001";--U
		else
			oLCD_R <= "11111111";
			oLCD_G <= "10000000";
			oLCD_B <= "00000000";
			odisplay5<="0000001";--0
			odisplay4<="0111000";--F
			odisplay3<="0111000";--F
		end if;
	end if;
end process;
end LCD_Tim;
