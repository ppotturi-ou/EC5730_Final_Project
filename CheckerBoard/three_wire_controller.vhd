library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;
entity three_wire_controller is
port (
iCLK: in STD_LOGIC; -- Clock
iRST: in STD_LOGIC; -- Reset button
iDATA: in STD_LOGIC_VECTOR(15 downto 0); -- DATA
iSTR: in STD_LOGIC; --
--HOST side
oACK: out STD_LOGIC;
oRDY: out STD_LOGIC;
oCLK: out STD_LOGIC;
--Serial Side
oSCEN: out STD_LOGIC;
SDA: inout STD_LOGIC; -- DATA
oSCLK: out STD_LOGIC
);
end three_wire_controller;
architecture Three_Cont of three_wire_controller is
-- Internal Register and Wire
signal mSPI_CLK: STD_LOGIC;
signal mSPI_CLK_DIV: STD_LOGIC_VECTOR(15 downto 0);
signal mSEN: STD_LOGIC;
signal mSDATA: STD_LOGIC;
signal mSCLK: STD_LOGIC;
signal mACK: STD_LOGIC;
signal mST: STD_LOGIC_VECTOR(4 downto 0);
-- Clock Setting
constant CLK_Freq : integer := 50000000; -- 50 MHz
constant SPI_Freq : integer := 20000; -- 20 KHz
begin
-- Serial Clock Generator
process(iCLK, iRST)
begin
if (iRST = '0') then
mSPI_CLK <= '0';
mSPI_CLK_DIV <= (others => '0');
elsif (iCLK'event and iCLK = '1') then
if( mSPI_CLK_DIV < (CLK_Freq/SPI_Freq) ) then
mSPI_CLK_DIV <= mSPI_CLK_DIV+1;
else
mSPI_CLK_DIV <= (others => '0');
mSPI_CLK <= not(mSPI_CLK);
end if;
end if;
end process;
-- Parallel to Serial
process(mSPI_CLK, iRST)
begin
if (iRST = '0') then
mSEN <= '1';
mSCLK <= '0';
mSDATA <= 'Z';
mACK <= '0';
mST <= "00000";
elsif(mSPI_CLK'event and mSPI_CLK = '0') then
if (iSTR = '1') then
if (mST < 17) then
mST <= mST + 1;
end if;
if (mST = 0) then
mSEN <= '0';
mSCLK <= '1';
elsif(mST = 8) then
mACK <= SDA;
elsif(mST = 16 AND mSCLK = '1') then
mSEN <= '1';
mSCLK <= '0';
end if;
if(mST < 16) then
mSDATA <= iDATA(to_integer(unsigned(15-mST)));
end if;
else
mSEN <= '1';
mSCLK <= '0';
mSDATA <= 'Z';
mACK <= '0';
mST <= "00000";
end if;
end if;
end process;
oACK <= mACK;
oRDY <= '1' when mST=17 else '0';
oSCEN <= mSEN;
oSCLK <= (mSCLK AND mSPI_CLK);
SDA <= 'Z' when mST=8 else 'Z' when mST=17 else mSDATA;
oCLK <= mSPI_CLK;
end Three_Cont;
