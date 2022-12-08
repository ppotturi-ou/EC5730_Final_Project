
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
entity touch_irq_detector is
port (
iCLK: in STD_LOGIC; 
iRST_n: in STD_LOGIC; 
iTOUCH_IRQ : in STD_LOGIC;
iX_COORD : in STD_LOGIC_VECTOR(11 downto 0);
iY_COORD : in STD_LOGIC_VECTOR(11 downto 0);
iNEW_COORD : in STD_LOGIC;
oDISPLAY_MODE: out STD_LOGIC_vector(2 downto 0)
);
end touch_irq_detector;

architecture IRQ_Detect of touch_irq_detector is
signal touch_en : std_logic;
signal touch_en_clr : std_logic;
signal touch_delay_cnt: std_logic_vector(24 downto 0);
signal mDISPLAY_MODE: STD_LOGIC_VECTOR(2 downto 0); --change array size
signal count : std_logic_vector(3 downto 0);
signal count1 : std_logic_vector(3 downto 0);
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
process(iCLK, iRST_n)
variable carry : std_logic;
begin
if (iRST_n = '0') then
mDISPLAY_MODE <= "000"; -- change
elsif (iCLK'event and iCLK = '1') then
if (iTOUCH_IRQ = '1' AND touch_en = '0') then 
mDISPLAY_MODE <= mDISPLAY_MODE + 1 ;

end if;
end if;
end process;
oDISPLAY_MODE <= mDISPLAY_MODE; --change
end IRQ_Detect;
