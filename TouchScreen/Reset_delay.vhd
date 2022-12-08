library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
entity Reset_delay is
port (
iCLK: in STD_LOGIC; -- System Clock
iRST: in STD_LOGIC; -- Reset (Active Low)
oRST_0: out STD_LOGIC; -- Reset is active for 0.042 sec longer
oRST_1: out STD_LOGIC; -- Reset is active for 0.063 sec longer
oRST_2: out STD_LOGIC -- Reset is active for 0.377 sec longer
);
end Reset_delay;
architecture RDEL of Reset_delay is
signal Cont : STD_LOGIC_VECTOR(31 downto 0);
begin
process(iCLK, iRST)
begin
if (iRST = '0') then -- If reset button is pushed in, clear the reset flags
Cont <= "00000000000000000000000000000000";
oRST_0 <= '0';
oRST_1 <= '0';
oRST_2 <= '0';
elsif rising_edge(iCLK) then
if(Cont /= X"11FFFFF") then -- Up counter runs up to Hex 11FFFFF(18874367) pulses. Clock input is 50 Mhz = 20 ns per clock pulse.
Cont <= Cont+1;
end if;
if(Cont >= X"1FFFFF") then -- RST_0 goes from 0 to 1 after 1FFFFF (2097151) pulses = 2097151*0.00000002 sec = 0.04194302 seconds
oRST_0 <= '1';
end if;
if(Cont >= X"2FFFFF") then -- RST_1 goes from 0 to 1 after 2FFFFF (3145727) pulses = 3145727*0.00000002 sec = 0.06291454 seconds
oRST_1 <= '1';
end if;
if(Cont >= X"11FFFFF") then -- RST_2 goes from 0 to 1 after 11FFFFF(18874367) pulses = 18874367*0.00000002 sec = 0.37748734 seconds
oRST_2 <= '1';
end if;
end if;
end process;
end RDEL;

