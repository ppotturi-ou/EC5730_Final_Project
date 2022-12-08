-- ECE 5730
-- Group Project
--// --------------------------------------------------------------------
--// Copyright (c) 2005 by Terasic Technologies Inc. 
--// --------------------------------------------------------------------
--//
--// --------------------------------------------------------------------
--//           
--//                     Terasic Technologies Inc
--//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
--//                     HsinChu County, Taiwan
--//                     302
--//
--//                     web: http://www.terasic.com/
--//                     email: support@terasic.com
--//
--// --------------------------------------------------------------------
--// Permission:
--//
--//   Terasic grants permission to use and modify this code for use
--//   in synthesis for all Terasic Development Boards and Altera Development 
--//   Kits made by Terasic.  Other use of this code, including the selling 
--//   ,duplication, or modification of any portion is strictly prohibited.
--//
--//
--// --------------------------------------------------------------------
--//           
-- Library
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
		iDISPLAY_MODE: in STD_LOGIC_VECTOR(2 downto 0);
		led : out std_logic_vector(9 downto 0);
		odisplay3 : out std_logic_vector(0 to 6);
		odisplay4 : out std_logic_vector(0 to 6);
		odisplay5 : out std_logic_vector(0 to 6);
		oCount0 : out std_logic_vector(3 downto 0);
		oCount1 : out std_logic_vector(3 downto 0)
	);
end lcd_timing_controller;

architecture LCD_Tim of lcd_timing_controller is



--//=============================================================================
--// REG/SIgnal declarations
--//=============================================================================
	signal x_cnt: integer;
	signal y_cnt: integer;
	signal mred: std_logic_vector(7 downto 0);
	signal mgreen: std_logic_vector(7 downto 0);
	signal mblue: std_logic_vector(7 downto 0);
	signal display_area: std_logic;
	signal mhd: std_logic;
	signal mvd: std_logic;
	signal mden: std_logic;
	signal mREAD_SDRAM_EN: std_logic;
	signal msel: std_logic_vector(1 downto 0);
	signal mselx: std_logic_vector(1 downto 0); -- Update x axis
	signal msel1: std_logic_vector(1 downto 0);
	signal mselx1: std_logic_vector(1 downto 0); -- Update x axis
	signal msel2: std_logic_vector(1 downto 0);
	signal mselx2: std_logic_vector(1 downto 0); -- Update x axis
	--//=============================================================================
--// Color commination
--//=============================================================================
	signal red_1: std_logic_vector(7 downto 0); 
	signal green_1: std_logic_vector(7 downto 0);
	signal blue_1: std_logic_vector(7 downto 0);
	signal red_2: std_logic_vector(7 downto 0); 
	signal green_2: std_logic_vector(7 downto 0);
	signal blue_2: std_logic_vector(7 downto 0);
	signal red_3: std_logic_vector(7 downto 0); 
	signal green_3: std_logic_vector(7 downto 0);
	signal blue_3: std_logic_vector(7 downto 0);
	signal red_4: std_logic_vector(7 downto 0); 
	signal green_4: std_logic_vector(7 downto 0);
	signal blue_4: std_logic_vector(7 downto 0);
		--//=============================================================================
--// Count touch
--//=============================================================================
	signal count : std_logic_vector(3 downto 0);
	signal count1 : std_logic_vector(3 downto 0);
	signal graycnt: std_logic_vector(7 downto 0);
	signal graycnt1: std_logic_vector(7 downto 0); -- update gray


	
--//============================================================================
--// Constant PARAMETER declarations
--//============================================================================
	signal pattern_data: std_logic_vector(7 downto 0);
	constant H_LINE : integer := 1056;
	constant V_LINE : integer := 525;
	constant Hsync_Blank : integer := 216;
	constant Hsync_Front_Porch : integer := 40;
	constant Vertical_Back_Porch : integer := 35;
	constant Vertical_Front_Porch : integer := 10;
	constant num_of_combination : integer := 16;
	

	
	
--	
--//=============================================================================
--// Structural coding
--//=============================================================================

Begin

	display_area <='1' when ((x_cnt>(Hsync_Blank-1) and -->215
						(x_cnt<(H_LINE-Hsync_Front_Porch))and --< 1016
						(y_cnt>(Vertical_Back_Porch-1)) and
						(y_cnt<(V_LINE - Vertical_Front_Porch))
						)) else '0';
						
--	///////////////////////// x  y counter  and lcd hd generator //////////////////

process(iCLK, iRST_n)
	begin
		if (iRST_n = '0') then
			x_cnt <= 0;
			mhd <= '0';
		elsif (iCLK'event and iCLK = '1') then
			if(x_cnt = (H_LINE-1)) then
				x_cnt <= 0;
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
		y_cnt <= 0;
	elsif (iCLK'event and iCLK = '1') then
		if(x_cnt = (H_LINE-1)) then
			if(y_cnt = (V_LINE-1)) then
				y_cnt <= 0;
			else
				y_cnt <= y_cnt + 1;
			end if;
		end if;
	end if;
end process;




--	///////////////////////// touch panel timing //////////////////

process(iCLK, iRST_n)
begin
	if (iRST_n = '0') then
			mvd  <= '1';
		elsif (y_cnt = 0) then
			mvd  <= '0';
		else
			mvd  <= '1';
		end if;
end process;

process(iCLK, iRST_n)
begin
	if (iRST_n = '0') then
			mden  <= '0';
		elsif (display_area='1') then
			mden  <= '1';
		else
			mden  <= '0';
		end if;
end process;

--//////////////RGB color patten generator ///////
	


msel <= "01" when (y_cnt>=40 and y_cnt <88) else "10" when (y_cnt>=88 and y_cnt<136) else
				"11" when (y_cnt>=136	and y_cnt<184) else "01" when (y_cnt>=184	and y_cnt<232)
				else "10" when (y_cnt>=232	and y_cnt<280) else "11" when (y_cnt>=280	and y_cnt<328)
				else "01" when (y_cnt>=328	and y_cnt<376) else "10" when (y_cnt>=376	and y_cnt<424)
				else "11" when ((y_cnt>=424)	and (y_cnt<472)) else "00" when (y_cnt>=472);
				

mselx <= "01" when (x_cnt>=256 and x_cnt<336) else "10" when (x_cnt>=336	and x_cnt<416) else
				"11" when (x_cnt>=416	and x_cnt<496) else "01" when (x_cnt>=496	and x_cnt<576)
				else "10" when (x_cnt>=576	and x_cnt<656) else "11" when (x_cnt>=656	and x_cnt<736)
				else "01" when (x_cnt>=736	and x_cnt<816) else "10" when (x_cnt>=816	and x_cnt<896)
				else "11" when (x_cnt>=896	and x_cnt<976) else "00" when (x_cnt>=976);
				
				
-- Cordinate wise color 
msel1 <= "01" when (y_cnt>=40 and y_cnt <88) else "10" when (y_cnt>=88 and y_cnt<136) else
				"01" when (y_cnt>=136	and y_cnt<184) else "10" when (y_cnt>=184	and y_cnt<232)
				else "01" when (y_cnt>=232	and y_cnt<280) else "10" when (y_cnt>=280	and y_cnt<328)
				else "01" when (y_cnt>=328	and y_cnt<376) else "10" when (y_cnt>=376	and y_cnt<424)
				else "01" when ((y_cnt>=424)	and (y_cnt<472)) else "00" when (y_cnt>=472);
				

mselx1 <= "01" when (x_cnt>=256 and x_cnt<336) else "10" when (x_cnt>=336	and x_cnt<416) else
				"01" when (x_cnt>=416	and x_cnt<496) else "10" when (x_cnt>=496	and x_cnt<576)
				else "01" when (x_cnt>=576	and x_cnt<656) else "10" when (x_cnt>=656	and x_cnt<736)
				else "01" when (x_cnt>=736	and x_cnt<816) else "10" when (x_cnt>=816	and x_cnt<896)
				else "01" when (x_cnt>=896	and x_cnt<976) else "00" when (x_cnt>=976);

msel2 <= "01" when (y_cnt>=40 and y_cnt <88) else "10" when (y_cnt>=88 and y_cnt<136) else
				"01" when (y_cnt>=136	and y_cnt<184) else "10" when (y_cnt>=184	and y_cnt<232)
				else "01" when (y_cnt>=232	and y_cnt<280) else "10" when (y_cnt>=280	and y_cnt<328)
				else "01" when (y_cnt>=328	and y_cnt<376) else "10" when (y_cnt>=376	and y_cnt<424)
				else "01" when ((y_cnt>=424)	and (y_cnt<472)) else "00" when (y_cnt>=472);
				

mselx2 <= "01" when (x_cnt>=256 and x_cnt<336) else "10" when (x_cnt>=336	and x_cnt<416) else
				"01" when (x_cnt>=416	and x_cnt<496) else "10" when (x_cnt>=496	and x_cnt<576)
				else "01" when (x_cnt>=576	and x_cnt<656) else "10" when (x_cnt>=656	and x_cnt<736)
				else "01" when (x_cnt>=736	and x_cnt<816) else "10" when (x_cnt>=816	and x_cnt<896)
				else "01" when (x_cnt>=896	and x_cnt<976) else "00" when (x_cnt>=976);
				
				
process(iCLK, iRST_n,mselx,msel)
	begin
		if (iRST_n = '0') then
			pattern_data	<=	 X"00";
		elsif(mselx="00") then
			
				red_1 <= X"FF";
				green_1 <= X"FF";
				blue_1 <= X"FF";
				
				red_4 <= X"B4";
				green_4 <= X"8E";
				blue_4 <= X"45";
		elsif(mselx="01") then
			
				if(msel="00") then
					
		
						red_1 <= X"FF";
						green_1 <= X"FF";
						blue_1 <= X"FF";
						
						red_4 <= X"B4";
						green_4 <= X"8E";
						blue_4 <= X"45";
						
				elsif (msel="10") then
					

						red_1 <= X"00";
						green_1 <= X"FF";
						blue_1 <= X"00";
						
						red_4 <= X"3E";
						green_4 <= X"48";
						blue_4 <= X"6F";
						
				elsif (msel="01") then
					

						red_1 <= X"00";
						green_1 <= X"00";
						blue_1 <= X"FF";
						
						red_4 <= X"6F";
						green_4 <= X"3E";
						blue_4 <= X"6F";
					
				elsif (msel="11") then
					

						red_1 <= X"FF";
						green_1 <= X"00";
						blue_1 <= X"00";
						
						red_4 <= X"FC";
						green_4 <= X"0D";
						blue_4 <= X"2A";
				end if;		
			
		   elsif(mselx="10") then
			
				if(msel="00") then
					
	
						red_1 <= X"FF";
						green_1 <= X"FF";
						blue_1 <= X"FF";
						
						red_4 <= X"B4";
						green_4 <= X"8E";
						blue_4 <= X"45";
						
				elsif (msel="01") then
					

						red_1 <= X"00";
						green_1 <= X"FF";
						blue_1 <= X"00";
						
						red_4 <= X"3E";
						green_4 <= X"48";
						blue_4 <= X"6F";
						
				elsif (msel="11") then
					

						red_1 <= X"00";
						green_1 <= X"00";
						blue_1 <= X"FF";
					   
						red_4 <= X"6F";
						green_4 <= X"3E";
						blue_4 <= X"6F";
				elsif (msel="10") then
					

						red_1 <= X"FF";
						green_1 <= X"00";
						blue_1 <= X"00";
						
						red_4 <= X"FC";
						green_4 <= X"0D";
						blue_4 <= X"2A";
				end if;		
			
			elsif(mselx="11") then
			
				if(msel="00") then
					
		
						red_1 <= X"FF";
						green_1 <= X"FF";
						blue_1 <= X"FF";
						
						red_4 <= X"B4";
						green_4 <= X"8E";
						blue_4 <= X"45";
				elsif (msel="11") then
					

						red_1 <= X"00";
						green_1 <= X"FF";
						blue_1 <= X"00";
						
						red_4 <= X"3E";
						green_4 <= X"48";
						blue_4 <= X"6F";
						
				elsif (msel="10") then
					

						red_1 <= X"00";
						green_1 <= X"00";
						blue_1 <= X"FF";
						
						red_4 <= X"6F";
						green_4 <= X"3E";
						blue_4 <= X"6F";
					
				elsif (msel="01") then
					

						red_1 <= X"FF";
						green_1 <= X"00";
						blue_1 <= X"00";
						
						red_4 <= X"FC";
						green_4 <= X"0D";
						blue_4 <= X"2A";
				end if;		
			 
			else
				pattern_data<=	X"00";
			end if;	
end process;			

	
	
--gray level patten generator
process(iCLK, iRST_n)
begin
	if (iRST_n = '0') then
		graycnt <= (others => '0');
	
	elsif((x_cnt>(Hsync_Blank-1))AND(x_cnt<(H_LINE-Hsync_Front_Porch))) then
			graycnt <= graycnt + 1;
	else
			graycnt <= (others => '0');
	end if;
	
end process;






process(iCLK, iRST_n)
	begin
		if (iRST_n = '0') then
		
			pattern_data	<=	 X"00";
			
		elsif(mselx1="00") then
		
			graycnt1 <= X"ff";
			
		elsif(mselx1 ="10") then
		
			
				if(msel1 ="10") then
					
						graycnt1 <= X"d9";
					
				elsif (msel1 = "01") then
					
						graycnt1 <= X"00";
				
				else
					graycnt1 <= X"d9";
				end if;
				
		elsif(mselx1="01") then
				
				if(msel1 ="10") then
					
						graycnt1 <= X"00";
					
					
				elsif (msel1 = "01") then
					
						graycnt1 <= X"d9";						
				
				else
					graycnt1 <= X"d9";
					
				end if;
		elsif(mselx1="11") then
				if(msel1 ="10") then
					
						graycnt1 <= X"d9";
					
					
				elsif (msel1 = "01") then
					
						graycnt1 <= X"00";						
				
				else
					graycnt1 <= X"d9";
					
				end if;
		else
			pattern_data	<=	 X"00";	
		end if;
	end process;


process(iCLK, iRST_n,mselx2,msel2)
	begin
		if (iRST_n = '0') then
			pattern_data	<=	 X"00";
		elsif(mselx2="00") then
			
				red_2 <= X"FF";
				green_2 <= X"FF";
				blue_2 <= X"FF";
				
				red_3 <= X"00";
				green_3 <= X"9B";
				blue_3 <= X"FF";
		
		elsif(mselx2="01") then
			
				if(msel2="00") then
						red_3 <= X"00";
						green_3 <= X"9B";
						blue_3 <= X"FF";
		
						red_2 <= X"FF";
						green_2 <= X"FF";
						blue_2 <= X"FF";
						
				elsif (msel2="10") then
					
						
						red_2 <= X"00";
						green_2 <= X"00";
						blue_2 <= X"00";
						
						red_3 <= X"E1";
						green_3 <= X"22";
						blue_3 <= X"28";
						
				elsif (msel2="01") then
					
						red_2 <= X"FF";
						green_2 <= X"3d";
						blue_2 <= X"FF";
						
						red_3 <= X"0A";
						green_3 <= X"09";
						blue_3 <= X"09";
					
				elsif (msel2="11") then
					

						red_2 <= X"F3";
						green_2 <= X"F3";
						blue_2 <= X"F3";
						
						red_3 <= X"09";
						green_3 <= X"0A";
						blue_3 <= X"0A";
				end if;		
			
		   elsif(mselx2="10") then
			
				if(msel2="00") then
					
	
						red_2 <= X"FF";
						green_2 <= X"FF";
						blue_2 <= X"FF";
						
						red_3 <= X"00";
						green_3 <= X"9B";
						blue_3 <= X"FF";
						
				elsif (msel2="01") then
					

						red_2 <= X"00";
						green_2 <= X"00";
						blue_2 <= X"00";
						
						red_3 <= X"E1";
						green_3 <= X"22";
						blue_3 <= X"28";
						
				elsif (msel2="11") then
					

						red_2 <= X"00";
						green_2 <= X"00";
						blue_2 <= X"00";
						
						red_3 <= X"E1";
						green_3 <= X"22";
						blue_3 <= X"28";
					
				elsif (msel2="10") then
					

						red_2 <= X"FF";
						green_2 <= X"3d";
						blue_2 <= X"FF";
						
						red_3 <= X"0A";
						green_3 <= X"09";
						blue_3 <= X"09";
				end if;		
			
			elsif(mselx2="11") then
			
				if(msel2="00") then
					
		
						red_2 <= X"FF";
						green_2 <= X"FF";
						blue_2 <= X"FF";
						
						red_3 <= X"00";
						green_3 <= X"9B";
						blue_3 <= X"FF";
						
				elsif (msel2="11") then
					

						red_2 <= X"00";
						green_2 <= X"00";
						blue_2 <= X"00";
						
						red_3 <= X"E1";
						green_3 <= X"22";
						blue_3 <= X"28";
						
				elsif (msel2="10") then
					

						red_2 <= X"00";
						green_2 <= X"00";
						blue_2 <= X"00";
						
						red_3 <= X"E1";
						green_3 <= X"22";
						blue_3 <= X"28";
					
				elsif (msel2="01") then
					

						red_2 <= X"F3";
						green_2 <= X"F3";
						blue_2 <= X"F3";
						red_3 <= X"09";
						green_3 <= X"0A";
						blue_3 <= X"0A";
				end if;		
			 
			else
				pattern_data<=	X"00";
			end if;	
end process;
	
led(0)<=iDISPLAY_MODE(0);
				led(1)<=iDISPLAY_MODE(1);	
				led(2)<=iDISPLAY_MODE(2);
				
--
--////////////// displayed color pattern selection //////////////
mred    <= X"28" when (iDISPLAY_MODE = "111") else red_3 when  
			     (iDISPLAY_MODE = "011")else graycnt1 when  
				 (iDISPLAY_MODE = "010") else red_1 when  
			     (iDISPLAY_MODE = "001") else red_4 when  
			     (iDISPLAY_MODE = "100") else red_4 when  
			     (iDISPLAY_MODE = "101") else red_2; 
				  
mgreen    <= X"8A" when (iDISPLAY_MODE = "111") else green_3 when  
			     (iDISPLAY_MODE = "011") else graycnt1 when  
				 (iDISPLAY_MODE = "010") else green_1 when  
			     (iDISPLAY_MODE = "001") else green_4 when  
			     (iDISPLAY_MODE = "100") else green_3 when  
			     (iDISPLAY_MODE = "101") else green_2; 
				  
mblue    <= X"8D" when (iDISPLAY_MODE = "111")else blue_3 when  
			     (iDISPLAY_MODE = "011") else graycnt1 when  
				 (iDISPLAY_MODE = "010") else blue_1 when  
			     (iDISPLAY_MODE = "001") else blue_4 when  
			     (iDISPLAY_MODE = "100") else blue_3 when  
			     (iDISPLAY_MODE = "101") else blue_2; 

process(iCLK, iRST_n)

	begin
		if (iRST_n = '0') then
			
				oHD	<= '0';
				oVD	<= '0';
				oDEN <= '0';
				oLCD_R <= X"00";
				oLCD_G <= X"00";
				oLCD_B <= X"00";
				odisplay5<="1111010";--r
				odisplay4<="0110000";--E
				odisplay3<="1000010";--d
			
		else
			
				oHD	<= mhd;
				oVD	<= mvd;
				oDEN <= display_area;
				oLCD_R <= mred;
				oLCD_G <= mgreen;
				oLCD_B <= mblue;
				odisplay5<="1111010";--r
				odisplay4<="0110000";--E
				odisplay3<="1000010";--d
		end if;
	end process;



end LCD_Tim;

