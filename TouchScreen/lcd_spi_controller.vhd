

library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
entity lcd_spi_controller is
port (
--Host side
iCLK: in STD_LOGIC; --Clock
iRST_n: in STD_LOGIC; -- Reset button
--3wire side
o3WIRE_SCLK : out STD_LOGIC;
io3WIRE_SDAT : inout STD_LOGIC;
o3WIRE_SCEN: out STD_LOGIC;
o3WIRE_BUSY_n : out STD_LOGIC
);
end lcd_spi_controller;
architecture SPI_Contrl of lcd_spi_controller is
component three_wire_controller is
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
end component;
--=============================================================================
-- Signal declarations
--=============================================================================
signal m3wire_str : STD_LOGIC;
signal m3wire_rdy : STD_LOGIC;
signal m3wire_ack : STD_LOGIC;
signal m3wire_clk : STD_LOGIC;
signal m3wire_data : STD_LOGIC_VECTOR(15 downto 0);
signal lut_data : STD_LOGIC_VECTOR(15 downto 0);
--signal lut_index : STD_LOGIC_VECTOR(5 downto 0);
signal lut_index : integer;
--signal msetup_st : STD_LOGIC_VECTOR(3 downto 0);
signal msetup_st : integer;
signal v_reverse : STD_LOGIC; --display Vertical reverse function
signal h_reverse : STD_LOGIC; --display Horizontal reverse function
constant g0 : STD_LOGIC_VECTOR(15 downto 0) := "0000000001101010"; --106
constant g1 : STD_LOGIC_VECTOR(15 downto 0) := "0000000011001000"; --200
constant g2 : STD_LOGIC_VECTOR(15 downto 0) := "0000000100100001"; --289
constant g3 : STD_LOGIC_VECTOR(15 downto 0) := "0000000101110111"; --375
constant g4 : STD_LOGIC_VECTOR(15 downto 0) := "0000000111001100"; --460
constant g5 : STD_LOGIC_VECTOR(15 downto 0) := "0000001000011111"; --543
constant g6 : STD_LOGIC_VECTOR(15 downto 0) := "0000001001110001"; --625
constant g7 : STD_LOGIC_VECTOR(15 downto 0) := "0000001011000001"; --705
constant g8 : STD_LOGIC_VECTOR(15 downto 0) := "0000001100010001"; --785
constant g9 : STD_LOGIC_VECTOR(15 downto 0) := "0000001101100000"; --864
constant g10 : STD_LOGIC_VECTOR(15 downto 0) := "0000001110101110"; --942
constant g11 : STD_LOGIC_VECTOR(15 downto 0) := "0000001111111100"; --1020
-- LUT Data Number
constant LUT_SIZE : integer := 20;
begin
three_wire_controller_inst : three_wire_controller PORT MAP (
iCLK => iCLK,
iRST => iRST_n,
iDATA => m3wire_data,
iSTR => m3wire_str,
oACK => m3wire_ack,
oRDY => m3wire_rdy,
oCLK => m3wire_clk,
oSCEN => o3WIRE_SCEN,
SDA => io3WIRE_SDAT,
oSCLK => o3WIRE_SCLK
);
process(m3wire_clk, iRST_n)
begin
if (iRST_n = '0') then
lut_index <= 0;
msetup_st <= 0;
m3wire_str <= '0';
o3WIRE_BUSY_n <= '0';
elsif (m3wire_clk'event and m3wire_clk = '1') then
if(lut_index<LUT_SIZE) then
o3WIRE_BUSY_n <= '0';
case msetup_st is
when 0 =>
msetup_st <= 1;
when 1 =>
msetup_st <= 2;
when 2 =>
m3wire_data <= lut_data;
m3wire_str <= '1';
msetup_st <= 3;
when 3 =>
if(m3wire_rdy = '1') then
if(m3wire_ack = '1') then
msetup_st <= 4;
else
msetup_st <= 0;
end if;
m3wire_str <= '0';
end if;
when 4 =>
lut_index <= lut_index+1;
msetup_st <= 0;
when others =>
null;
end case;
else
o3WIRE_BUSY_n <= '1';
end if;
end if;
end process;
--///////////////////// Config Data LUT //////////////////////////
process(LUT_INDEX)
begin
case LUT_INDEX is
when 0 =>
lut_data <= "010001" & "01" & g0(9 downto 8) & g1(9
downto 8) & g2(9 downto 8) & g3(9 downto 8);
when 1 =>
lut_data <= "010010" & "01" & g4(9 downto 8) & g5(9
downto 8) & g6(9 downto 8) & g7(9 downto 8);
when 2 =>
lut_data <= "010011" & "01" & g8(9 downto 8) & g9(9
downto 8) & g10(9 downto 8) & g11(9 downto 8);
when 3 =>
lut_data <= "010100" & "01" & g0(7 downto 0);
when 4 =>
lut_data <= "010101" & "01" & g1(7 downto 0);
when 5 =>
lut_data <= "010110" & "01" & g2(7 downto 0);
when 6 =>
lut_data <= "010111" & "01" & g3(7 downto 0);
when 7 =>
lut_data <= "011000" & "01" & g4(7 downto 0);
when 8 =>
lut_data <= "011001" & "01" & g5(7 downto 0);
when 9 =>
lut_data <= "011010" & "01" & g6(7 downto 0);
when 10 =>
lut_data <= "011011" & "01" & g7(7 downto 0);
when 11 =>
lut_data <= "011100" & "01" & g8(7 downto 0);
when 12 =>
lut_data <= "011101" & "01" & g9(7 downto 0);
when 13 =>
lut_data <= "011110" & "01" & g10(7 downto 0);
when 14 =>
lut_data <= "011111" & "01" & g11(7 downto 0);
when 15 =>
lut_data <= "100000" & "01" & "1111" & "0000";
when 16 =>
lut_data <= "100001" & "01" & "1111" & "0000";
when 17 =>
lut_data <= "000011" & "01" & "1101" & "1111";
when 18 =>
lut_data <= "000010" & "01" & "0000" & "0111";
when 19 =>
lut_data <= "000100" & "01" & "000101" & not(v_reverse)
& not(h_reverse);
when others =>
LUT_DATA <= X"0000";
end case;
end process;
h_reverse <= '1';
v_reverse <= '0';
end SPI_Contrl;

