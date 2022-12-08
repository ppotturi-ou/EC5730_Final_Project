
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
entity counter is
port (
iCLK: in STD_LOGIC; 
iRST_n: in STD_LOGIC; 
iTOUCH_IRQ : in STD_LOGIC;
oDisplay : out std_logic_vector(0 to 6);			
oCount0 : out std_logic_vector(3 downto 0);	 --To calculate the value of first hexadecimal count
oCount1 : out std_logic_vector(3 downto 0)	--To calculate the value of Second hexadecimal count
); 
end counter;
architecture arch of counter is
signal count : std_logic_vector(3 downto 0);
signal count1 : std_logic_vector(3 downto 0);
signal touch_en : std_logic;
signal touch_en_clr : std_logic;
signal touch_delay_cnt: std_logic_vector(24 downto 0);
constant TOUCH_CNT_CLEAR : std_logic_vector(23 downto 0) := X"ffffff";
begin
process(iCLK, iRST_n)
begin
if (iRST_n = '0') then
touch_en <= '0';
elsif (iCLK'event and iCLK = '1') then
if (touch_en_clr = '1') then
touch_en <= '0';
end if;
if (iTOUCH_IRQ = '1') then
touch_en <= '1';
end if;
end if;
end process;
process(iCLK, iRST_n)
begin
if (iRST_n = '0') then
touch_delay_cnt <= (others => '0');
touch_en_clr <= '0';
elsif (iCLK'event and iCLK = '1') then
if (touch_delay_cnt = TOUCH_CNT_CLEAR) then
touch_delay_cnt <= (others => '0');
touch_en_clr <= '1';
elsif (touch_en = '1') then
touch_delay_cnt <= touch_delay_cnt + 1;
else
touch_delay_cnt <= (others => '0');
touch_en_clr <= '0';
end if;
end if;
end process;
--Counting the count values for each touch
process(iCLK, iRST_n)
begin
if (iRST_n = '0') then
count<="0000";
count1<="0000";
elsif (iCLK'event and iCLK = '1') then
if (iTOUCH_IRQ = '1' and touch_en = '0') then 
count<= count+1;
if(count="1111") then
count<="0000";
count1<=count1+"0001";
end if;
end if;
end if;
end process;
oCount0<=count;
oCount1<=count1;
end arch;

