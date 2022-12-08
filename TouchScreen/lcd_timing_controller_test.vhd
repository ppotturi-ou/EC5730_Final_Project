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
		oCount1 : out std_logic_vector(3 downto 0);
	iX_COORD : in STD_LOGIC_VECTOR(11 downto 0);
	iY_COORD : in STD_LOGIC_VECTOR(11 downto 0)
	);
end lcd_timing_controller;

architecture LCD_Tim of lcd_timing_controller is
--//=============================================================================
--// REG/SIgnal declarations
--//=============================================================================
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
	signal mselx: std_logic_vector(1 downto 0); -- Update x axis
	signal red_1: std_logic_vector(7 downto 0); 
	signal green_1: std_logic_vector(7 downto 0);
	signal blue_1: std_logic_vector(7 downto 0);
	signal count : std_logic_vector(3 downto 0);
	signal count1 : std_logic_vector(3 downto 0);
	signal graycnt: std_logic_vector(7 downto 0);
	signal graycnt1: std_logic_vector(7 downto 0); -- update gray
	signal pattern_data: std_logic_vector(7 downto 0);
	constant H_LINE : integer := 1056;
	constant V_LINE : integer := 525;
	--constant H_LINE : integer := 297;
	--constant V_LINE : integer := 118;	
	constant Hsync_Blank : integer := 216;
	constant Hsync_Front_Porch : integer := 40;
	constant Vertical_Back_Porch : integer := 35;
	constant Vertical_Front_Porch : integer := 10;
	signal mx_coordinate: std_logic_vector(9 downto 0);
	signal my_coordinate: std_logic_vector(8 downto 0);
	-- Test BMP
	constant bmp_image_Array_Size : integer := ((41*73)-1);
signal bmp_Pixel_Cnt: integer :=0;


begin

--	
--//=============================================================================
--// Structural coding
--//=============================================================================

--Begin

	display_area <='1' when ((x_cnt>(Hsync_Blank-1) and -->215
						(x_cnt<(H_LINE-Hsync_Front_Porch))and --< 1016
						(y_cnt>(Vertical_Back_Porch-1)) and
						(y_cnt<(V_LINE - Vertical_Front_Porch))
						)) else '0';
						
--	///////////////////////// x  y counter  and lcd hd generator //////////////////

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

--//////////////RGB color patten generator ///////
	
msel <= "01" when (y_cnt>=40 and y_cnt <88) else "10" when (y_cnt>=88 and y_cnt<136) else
				"11" when (y_cnt>=136	and y_cnt<184) else "01" when (y_cnt>=184	and y_cnt<232)
				else "10" when (y_cnt>=232	and y_cnt<280) else "11" when (y_cnt>=280	and y_cnt<328)
				else "01" when (y_cnt>=328	and y_cnt<376) else "10" when (y_cnt>=376	and y_cnt<424)
				else "11" when ((y_cnt>=424)	and (y_cnt<472)) else "00" when (y_cnt>=472);
				

--mselx <= "01" when (x_cnt>=256 and x_cnt<336) else "10" when (x_cnt>=336	and x_cnt<416) else
--				"11" when (x_cnt>=416	and x_cnt<496) else "01" when (x_cnt>=496	and x_cnt<576)
--				else "10" when (x_cnt>=576	and x_cnt<656) else "11" when (x_cnt>=656	and x_cnt<736)
--				else "01" when (x_cnt>=736	and x_cnt<816) else "10" when (x_cnt>=816	and x_cnt<896)
--				else "11" when (x_cnt>=896	and x_cnt<976) else "00" when (x_cnt>=976);

mselx <= "00";

process(iCLK, iRST_n)
	begin
		if (iRST_n = '0') then
			pattern_data	<=	"00000000";
			bmp_Pixel_Cnt <= 0;
		elsif(mselx="00") then
			
			--	red_1 <= X"FF";
			--	green_1 <= X"FF";
			--	blue_1 <= X"FF";
			
		--my_coordinate <= iX_COORD(11 downto 3); -- 10bit
		--mx_coordinate <= iY_COORD(11 downto 2); --9bit

		--mx_coordinate <= "0000000001";
		--my_coordinate <= "000000001";
		
		my_coordinate <= iY_COORD(11 downto 3); -- 10bit
		mx_coordinate <= iX_COORD(11 downto 2); --9bit
		
		
		--mx_coordinate	<= mx_coordinate;
			if((y_cnt<(V_LINE - ((my_coordinate)))) and (y_cnt> (V_LINE - (41+(my_coordinate))))) then -- 480
				if((x_cnt< (H_LINE - ((mx_coordinate)))) and (x_cnt> (H_LINE - (53+(mx_coordinate))))) then -- 800

					if (bmp_Pixel_Cnt<bmp_image_Array_Size) then	
						bmp_Pixel_Cnt <= (bmp_Pixel_Cnt)+1;
					--else
					--	bmp_Pixel_Cnt <= 0;
					end if;

					if(display_area = '0') then
						bmp_Pixel_Cnt <= 0;
					end if;
					red_1 <= X"ff";
					green_1 <= X"00";
					blue_1 <= X"00";	
				else
					red_1 <= X"FF";
					green_1 <= X"FF";
					blue_1 <= X"FF";				
				end if;
			else
				red_1 <= X"FF";
				green_1 <= X"FF";
				blue_1 <= X"FF";	
			end if;
			
		
		
		elsif(mselx="01") then
			
				if(msel="00") then
					
		
						red_1 <= X"FF";
						green_1 <= X"FF";
						blue_1 <= X"FF";
						
				elsif (msel="10") then
					

						red_1 <= "00000000";
						green_1 <= X"FF";
						blue_1 <= "00000000";
						
				elsif (msel="01") then
					

						red_1 <= "00000000";
						green_1 <= "00000000";
						blue_1 <= X"FF";
					
				elsif (msel="11") then
					

						red_1 <= X"FF";
						green_1 <= "00000000";
						blue_1 <= "00000000";
				end if;		
			
		   elsif(mselx="10") then
			
				if(msel="00") then
					
	
						red_1 <= X"FF";
						green_1 <= X"FF";
						blue_1 <= X"FF";
						
				elsif (msel="01") then
					

						red_1 <= "00000000";
						green_1 <= X"FF";
						blue_1 <= "00000000";
						
				elsif (msel="11") then
					

						red_1 <= "00000000";
						green_1 <= "00000000";
						blue_1 <= X"FF";
					
				elsif (msel="10") then
					

						red_1 <= X"FF";
						green_1 <= "00000000";
						blue_1 <= "00000000";
				end if;		
			
			elsif(mselx="11") then
			
				if(msel="00") then
					
		
						red_1 <= X"FF";
						green_1 <= X"FF";
						blue_1 <= X"FF";
						
				elsif (msel="11") then
					

						red_1 <= "00000000";
						green_1 <= X"FF";
						blue_1 <= "00000000";
						
				elsif (msel="10") then
					

						red_1 <= "00000000";
						green_1 <= "00000000";
						blue_1 <= X"FF";
					
				elsif (msel="01") then
					

						red_1 <= X"FF";
						green_1 <= "00000000";
						blue_1 <= "00000000";
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
	elsif (iCLK'event and iCLK = '1') then
		if((x_cnt>(Hsync_Blank-1))AND(x_cnt<(H_LINE-Hsync_Front_Porch))) then
			graycnt <= graycnt + 1;
		else
			graycnt <= (others => '0');
		end if;
	end if;
end process;


process(iCLK, iRST_n)
	begin
		if (iRST_n = '0') then
		
			graycnt1 <= "00000000";
			
		elsif(mselx="00") then
		
			graycnt1 <= X"ff";
			
		elsif(mselx ="10") then
		
			
				if(msel ="10") then
					
						graycnt1 <= X"7f";
					
				elsif (msel = "01" OR msel="11") then
					
						graycnt1 <= "00000000";
				
				else
					graycnt1 <= X"ff";
				end if;
				
		elsif(mselx="01" OR mselx ="11") then
				
				if(msel ="10") then
					
						graycnt1 <= "00000000";
					
					
				elsif (msel = "01" OR msel="11") then
					
						graycnt1 <= X"7f";						
				
				else
					graycnt1 <= X"ff";
					
				end if;
		else
			graycnt1 <= "00000000";		
		end if;
	end process;


led(0)<=iDISPLAY_MODE(0);
led(1)<=iDISPLAY_MODE(1);

--////////////// displayed color pattern selection //////////////

--mred    <= X"ff" when (iDISPLAY_MODE = "11") else graycnt1 when  
--				 (iDISPLAY_MODE = "10") else red_1 when  
--			     (iDISPLAY_MODE = "01") else graycnt; 
--				  
--mgreen    <= X"ff" when (iDISPLAY_MODE = "11") else graycnt1 when  
--				 (iDISPLAY_MODE = "10") else green_1 when  
--			     (iDISPLAY_MODE = "01") else graycnt; 
--				  
--mblue    <= X"ff" when (iDISPLAY_MODE = "11") else graycnt1 when  
--				 (iDISPLAY_MODE = "10") else blue_1 when  
--			     (iDISPLAY_MODE = "01") else graycnt; 

mred <= red_1;
mgreen <= green_1;
mblue <= blue_1;


process(iCLK, iRST_n)

	begin
		if (iRST_n = '0') then
			
				oHD	<= '0';
				oVD	<= '0';
				oDEN <= '0';
				oLCD_R <= "00000000";
				oLCD_G <= "00000000";
				oLCD_B <= "00000000";
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

