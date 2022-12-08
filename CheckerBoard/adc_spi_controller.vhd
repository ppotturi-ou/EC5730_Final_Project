

library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
entity adc_spi_controller is
port (
iCLK: in STD_LOGIC; --Clock
iRST_n: in STD_LOGIC; -- Reset button
oADC_DIN : out STD_LOGIC;
oADC_DCLK : out STD_LOGIC;
oADC_CS : out STD_LOGIC;
iADC_DOUT: in STD_LOGIC;
iADC_BUSY: in STD_LOGIC;
iADC_PENIRQ_n : in STD_LOGIC;
oTOUCH_IRQ : out STD_LOGIC; --Reference from main file
oX_COORD : out STD_LOGIC_VECTOR(11 downto 0);
oY_COORD : out STD_LOGIC_VECTOR(11 downto 0);
oNEW_COORD : out STD_LOGIC
);
end adc_spi_controller;

architecture ADC_SPI_Contrl of adc_spi_controller is
--=====================================================================
-- Signal declarations
--=====================================================================
signal d1_PENIRQ_n : std_logic;
signal d2_PENIRQ_n : std_logic;
signal touch_irq : std_logic;
signal dclk_cnt : std_logic_vector(15 downto 0);
signal dclk : std_logic;
signal transmit_en : std_logic;
signal spi_ctrl_cnt : std_logic_vector(6 downto 0);
signal mcs : std_logic;
signal mdclk : std_logic;
signal x_config_reg : std_logic_vector(7 downto 0);
signal y_config_reg : std_logic_vector(7 downto 0);
signal ctrl_reg : std_logic_vector(7 downto 0);
signal mdata_in : std_logic_vector(7 downto 0);
signal y_coordinate_config : std_logic;
signal eof_transmition : std_logic;
signal bit_cnt : std_logic_vector(5 downto 0);
signal madc_out : std_logic;
signal mx_coordinate: std_logic_vector(11 downto 0);
signal my_coordinate: std_logic_vector(11 downto 0);
signal rd_coord_strob: std_logic;
signal irq_cnt : std_logic_vector(5 downto 0);
signal clk_cnt : std_logic_vector(15 downto 0);
--=====================================================================
-- PARAMETER declarations
--=====================================================================
constant SYSCLK_FRQ : integer := 50000000;
constant ADC_DCLK_FRQ : integer := 1000;
constant ADC_DCLK_CNT : integer := SYSCLK_FRQ/(ADC_DCLK_FRQ*2);
begin
x_config_reg <= X"92";
y_config_reg <= X"d2";
process(iCLK, iRST_n)
begin
if (iRST_n = '0') then
madc_out <= '0';
elsif (iCLK'event and iCLK = '1') then
madc_out <= iADC_DOUT;
end if;
end process;
--pen irq detect
process(iCLK, iRST_n)
begin
if (iRST_n = '0') then
d1_PENIRQ_n <= '0';
d2_PENIRQ_n <= '0';
elsif (iCLK'event and iCLK = '1') then
d1_PENIRQ_n <= iADC_PENIRQ_n;
d2_PENIRQ_n <= d1_PENIRQ_n;
end if;
end process;
-- if iADC_PENIRQ_n form high to low , touch_irq goes high
touch_irq <= d2_PENIRQ_n AND not(d1_PENIRQ_n);
oTOUCH_IRQ <= touch_irq;
-- if touch_irq goes high , starting transmit procedure ,transmit_en goes high
-- if end of transmition and no penirq , transmit procedure stop.
process(iCLK, iRST_n)
begin
if (iRST_n = '0') then
transmit_en <= '0';
elsif (iCLK'event and iCLK = '1') then
if (eof_transmition = '1' AND iADC_PENIRQ_n = '1') then
transmit_en <= '0';
elsif (touch_irq = '1') then
transmit_en <= '1';
end if;
end if;
end process;
-- dclk_cnt
process(iCLK, iRST_n)
begin
if (iRST_n = '0') then
dclk_cnt <= (others => '0');
elsif (iCLK'event and iCLK = '1') then
if (transmit_en = '1') then
if (dclk_cnt = ADC_DCLK_CNT) then
dclk_cnt <= (others => '0');
else
dclk_cnt <= dclk_cnt + 1;
end if;
else
dclk_cnt <= (others => '0');
end if;
end if;
end process;
dclk <= '1' when dclk_cnt = ADC_DCLK_CNT else '0';
-- spi_ctrl_cnt
process(iCLK, iRST_n)
begin
if (iRST_n = '0') then
spi_ctrl_cnt <= (others => '0');
elsif (iCLK'event and iCLK = '1') then
if (dclk = '1') then
if (spi_ctrl_cnt = 65) then
spi_ctrl_cnt <= (others => '0');
else
spi_ctrl_cnt <= spi_ctrl_cnt + 1;
end if;
end if;
end if;
end process;
process(iCLK, iRST_n)
begin
if (iRST_n = '0') then
mcs <= '1';
mdclk <= '0';
mdata_in <= (others => '0');
y_coordinate_config <= '0';
mx_coordinate <= (others => '0');
my_coordinate <= (others => '0');
elsif (iCLK'event and iCLK = '1') then
if (transmit_en = '1') then
if (dclk = '1') then
if (spi_ctrl_cnt = 0) then
mcs <= '0';
mdata_in <= ctrl_reg;
elsif(spi_ctrl_cnt = 49) then
mdclk <= '0';
y_coordinate_config <= not(y_coordinate_config);
if (y_coordinate_config = '1') then
mcs <= '1';
else
mcs <= '0';
end if;
elsif(spi_ctrl_cnt /= 0) then
mdclk <= not(mdclk);
end if;
if (mdclk = '1') then
mdata_in <= mdata_in(6 downto 0) & '0';
elsif (mdclk = '0') then
if(rd_coord_strob = '1') then
if(y_coordinate_config = '1') then
my_coordinate <= my_coordinate(10 downto 0) & madc_out;
else
mx_coordinate <= mx_coordinate(10 downto 0) & madc_out;
end if;
end if;
end if;
end if;
end if;
end if;
end process;
oADC_CS <= mcs;
oADC_DIN <= mdata_in(7);
oADC_DCLK <= mdclk;
ctrl_reg <= y_config_reg when y_coordinate_config = '1' else x_config_reg;
eof_transmition <= '1' when (y_coordinate_config = '1' AND (spi_ctrl_cnt = 49) AND dclk ='1') else '0';
rd_coord_strob <= '1' when ((spi_ctrl_cnt >=19)AND(spi_ctrl_cnt<=41)) else '0';
--X and Y coordinates
process(iCLK, iRST_n)
begin
if (iRST_n = '0') then
oX_COORD <= (others => '0');
oY_COORD <= (others => '0');
elsif (iCLK'event and iCLK = '1') then
if (eof_transmition = '1' AND my_coordinate /= 0) then
oX_COORD <= mx_coordinate;
oY_COORD <= my_coordinate;
end if;
end if;
end process;
--New coordinates
process(iCLK, iRST_n)
begin
if (iRST_n = '0') then
oNEW_COORD <= '0';
elsif (iCLK'event and iCLK = '1') then
if (eof_transmition = '1' AND my_coordinate /= 0) then
oNEW_COORD <= '1';
else
oNEW_COORD <= '0';
end if;
end if;
end process;	
end ADC_SPI_Contrl;




