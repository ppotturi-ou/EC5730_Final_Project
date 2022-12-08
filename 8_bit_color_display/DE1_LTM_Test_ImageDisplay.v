module DE1_LTM_Test_ImageDisplay
	(
		////////////////////	Clock Input	 	////////////////////	 
		CLOCK_24,						//	24 MHz
//		CLOCK_27,						//	27 MHz
		CLOCK_50,						//	50 MHz
		EXT_CLOCK,						//	External Clock
		////////////////////	Push Button		////////////////////
		KEY,								//	Pushbutton[3:0]
		////////////////////	DPDT Switch		////////////////////
		SW,								//	Toggle Switch[17:0]
		////////////////////	7-SEG Dispaly	////////////////////
		HEX0,								//	Seven Segment Digit 0
		HEX1,								//	Seven Segment Digit 1
		HEX2,								//	Seven Segment Digit 2
		HEX3,								//	Seven Segment Digit 3
		////////////////////////	LED		////////////////////////
		LEDG,								//	LED Green[8:0]
		LEDR,								//	LED Red[17:0]
		////////////////////////	UART	////////////////////////
		UART_TXD,						//	UART Transmitter
		UART_RXD,						//	UART Receiver
		/////////////////////	SDRAM Interface		////////////////
		DRAM_DQ,							//	SDRAM Data bus 16 Bits
		DRAM_ADDR,						//	SDRAM Address bus 12 Bits
		DRAM_LDQM,						//	SDRAM Low-byte Data Mask 
		DRAM_UDQM,						//	SDRAM High-byte Data Mask
		DRAM_WE_N,						//	SDRAM Write Enable
		DRAM_CAS_N,						//	SDRAM Column Address Strobe
		DRAM_RAS_N,						//	SDRAM Row Address Strobe
		DRAM_CS_N,						//	SDRAM Chip Select
		DRAM_BA_0,						//	SDRAM Bank Address 0
		DRAM_BA_1,						//	SDRAM Bank Address 0
		DRAM_CLK,						//	SDRAM Clock
		DRAM_CKE,						//	SDRAM Clock Enable
		////////////////////	Flash Interface		////////////////
		FL_DQ,							//	FLASH Data bus 8 Bits
		FL_ADDR,							//	FLASH Address bus 22 Bits
		FL_WE_N,							//	FLASH Write Enable
		FL_RST_N,						//	FLASH Reset
		FL_OE_N,							//	FLASH Output Enable
//		FL_CE_N,							//	FLASH Chip Enable
		////////////////////	SRAM Interface		////////////////
//		SRAM_DQ,							//	SRAM Data bus 16 Bits
//		SRAM_ADDR,						//	SRAM Address bus 18 Bits
//		SRAM_UB_N,						//	SRAM High-byte Data Mask 
//		SRAM_LB_N,						//	SRAM Low-byte Data Mask 
//		SRAM_WE_N,						//	SRAM Write Enable
//		SRAM_CE_N,						//	SRAM Chip Enable
//		SRAM_OE_N,						//	SRAM Output Enable
		////////////////////	SD_Card Interface	////////////////
//		SD_DAT,							//	SD Card Data
//	   SD_DAT3,							//	SD Card Data 3
//		SD_CMD,							//	SD Card Command Signal
//		SD_CLK,							//	SD Card Clock
		////////////////////	USB JTAG link	////////////////////
		TDI,  							// CPLD -> FPGA (data in)
		TCK,  							// CPLD -> FPGA (clk)
		TCS,  							// CPLD -> FPGA (CS)
	    TDO,  							// FPGA -> CPLD (data out)
		////////////////////	I2C		////////////////////////////
		I2C_SDAT,						//	I2C Data
		I2C_SCLK,						//	I2C Clock
		////////////////////	PS2		////////////////////////////
		PS2_DAT,							//	PS2 Data
		PS2_CLK,							//	PS2 Clock
		////////////////////	VGA		////////////////////////////
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,  							//	VGA Blue[9:0]
		////////////////	Audio CODEC		////////////////////////
		AUD_ADCLRCK,					//	Audio CODEC ADC LR Clock
		AUD_ADCDAT,						//	Audio CODEC ADC Data
		AUD_DACLRCK,					//	Audio CODEC DAC LR Clock
		AUD_DACDAT,						//	Audio CODEC DAC Data
		AUD_BCLK,						//	Audio CODEC Bit-Stream Clock
		AUD_XCK,							//	Audio CODEC Chip Clock
		////////////////////	GPIO	////////////////////////////
		GPIO_0,							//	GPIO Connection 0
		GPIO_1							//	GPIO Connection 1
	);

////////////////////////	Clock Input	 	////////////////////////
input	[1:0]		CLOCK_24;				//	24 MHz
//input				CLOCK_27;				//	27 MHz
input				CLOCK_50;				//	50 MHz
input				EXT_CLOCK;				//	External Clock
////////////////////////	Push Button		////////////////////////
input		[3:0]	KEY;						//	Pushbutton[3:0]
////////////////////////	DPDT Switch		////////////////////////
input		[9:0]SW;						//	Toggle Switch[17:0]
////////////////////////	7-SEG Dispaly	////////////////////////
output	[6:0]	HEX0;						//	Seven Segment Digit 0
output	[6:0]	HEX1;						//	Seven Segment Digit 1
output	[6:0]	HEX2;						//	Seven Segment Digit 2
output	[6:0]	HEX3;						//	Seven Segment Digit 3
////////////////////////////	LED		////////////////////////////
output	[7:0]	LEDG;						//	LED Green[7:0]
output	[9:0]	LEDR;						//	LED Red[9:0]
////////////////////////////	UART	////////////////////////////
output			UART_TXD;				//	UART Transmitter
input				UART_RXD;				//	UART Receiver
///////////////////////		SDRAM Interface	////////////////////////
inout	[15:0]	DRAM_DQ;					//	SDRAM Data bus 16 Bits
output[11:0]	DRAM_ADDR;				//	SDRAM Address bus 12 Bits
output			DRAM_LDQM;				//	SDRAM Low-byte Data Mask 
output			DRAM_UDQM;				//	SDRAM High-byte Data Mask
output			DRAM_WE_N;				//	SDRAM Write Enable
output			DRAM_CAS_N;				//	SDRAM Column Address Strobe
output			DRAM_RAS_N;				//	SDRAM Row Address Strobe
output			DRAM_CS_N;				//	SDRAM Chip Select
output			DRAM_BA_0;				//	SDRAM Bank Address 0
output			DRAM_BA_1;				//	SDRAM Bank Address 0
output			DRAM_CLK;				//	SDRAM Clock
output			DRAM_CKE;				//	SDRAM Clock Enable
////////////////////////	Flash Interface	////////////////////////
inout		[7:0]	FL_DQ;					//	FLASH Data bus 8 Bits
output	[21:0]FL_ADDR;					//	FLASH Address bus 22 Bits
output			FL_WE_N;					//	FLASH Write Enable
output			FL_RST_N;				//	FLASH Reset
output			FL_OE_N;					//	FLASH Output Enable
//output			FL_CE_N;					//	FLASH Chip Enable
////////////////////////	SRAM Interface	////////////////////////
//inout	[15:0]	SRAM_DQ;					//	SRAM Data bus 16 Bits
//output[17:0]	SRAM_ADDR;				//	SRAM Address bus 18 Bits
//output			SRAM_UB_N;				//	SRAM High-byte Data Mask 
//output			SRAM_LB_N;				//	SRAM Low-byte Data Mask 
//output			SRAM_WE_N;				//	SRAM Write Enable
//output			SRAM_CE_N;				//	SRAM Chip Enable
//output			SRAM_OE_N;				//	SRAM Output Enable
////////////////////	SD Card Interface	////////////////////////
//inout				SD_DAT;					//	SD Card Data
//inout				SD_DAT3;					//	SD Card Data 3
//inout				SD_CMD;					//	SD Card Command Signal
//output			SD_CLK;					//	SD Card Clock
////////////////////////	I2C		////////////////////////////////
inout				I2C_SDAT;				//	I2C Data
output			I2C_SCLK;				//	I2C Clock
////////////////////////	PS2		////////////////////////////////
input		 		PS2_DAT;					//	PS2 Data
input				PS2_CLK;					//	PS2 Clock
////////////////////	USB JTAG link	////////////////////////////
input  			TDI;						// CPLD -> FPGA (data in)
input  			TCK;						// CPLD -> FPGA (clk)
input  			TCS;						// CPLD -> FPGA (CS)
output 			TDO;						// FPGA -> CPLD (data out)
////////////////////////	VGA			////////////////////////////
output			VGA_HS;					//	VGA H_SYNC
output			VGA_VS;					//	VGA V_SYNC
output	[3:0]	VGA_R;   				//	VGA Red[3:0]
output	[3:0]	VGA_G;	 				//	VGA Green[3:0]
output	[3:0]	VGA_B;   				//	VGA Blue[3:0]
////////////////////	Audio CODEC		////////////////////////////
inout				AUD_ADCLRCK;			//	Audio CODEC ADC LR Clock
input				AUD_ADCDAT;				//	Audio CODEC ADC Data
inout				AUD_DACLRCK;			//	Audio CODEC DAC LR Clock
output			AUD_DACDAT;				//	Audio CODEC DAC Data
inout				AUD_BCLK;				//	Audio CODEC Bit-Stream Clock
output			AUD_XCK;					//	Audio CODEC Chip Clock
////////////////////////	GPIO	////////////////////////////////
inout	[35:0]	GPIO_0;					//	GPIO Connection 0
inout	[35:0]	GPIO_1;					//	GPIO Connection 1

assign	LCD_ON		=	1'b1;
assign	LCD_BLON	=	1'b1;

//	All inout port turn to tri-state
assign	DRAM_DQ		=	16'hzzzz;
assign	FL_DQ			=	8'hzz;
//assign	SRAM_DQ		=	16'hzzzz;
assign	OTG_DATA		=	16'hzzzz;
assign	LCD_DATA		=	8'hzz;
assign	SD_DAT		=	1'bz;
assign	ENET_DATA	=	16'hzzzz;
assign	AUD_ADCLRCK	=	1'bz;
assign	AUD_DACLRCK	=	1'bz;
assign	AUD_BCLK		=	1'bz;
assign	GPIO_1		=	36'hzzzzzzzzz;
//=============================================================================
// REG/WIRE declarations
//=============================================================================
// Touch panel signal //
wire	[7:0]	ltm_r;		//	LTM Red Data 8 Bits
wire	[7:0]	ltm_g;		//	LTM Green Data 8 Bits
wire	[7:0]	ltm_b;		//	LTM Blue Data 8 Bits
wire			ltm_nclk;	//	LTM Clcok
wire			ltm_hd;		
wire			ltm_vd;		
wire			ltm_den;
wire			ltm_grst;
// lcd 3wire interface//
wire			ltm_sclk;		
wire			ltm_sda;		
wire			ltm_scen;
wire 			ltm_3wirebusy_n;	
// Touch Screen Digitizer ADC	
wire 			adc_dclk;
wire 			adc_cs;
wire 			adc_penirq_n;
wire 			adc_busy;
wire 			adc_din;
wire 			adc_dout;
wire 			adc_ltm_sclk;		

wire	[11:0]x_coord;
wire	[11:0]y_coord;
wire			new_coord;	
wire	[1:0]	display_mode;
reg 	[31:0]div;

////////////// GPIO_O //////////////////
assign	adc_penirq_n  =GPIO_0[0];
assign	adc_dout    =GPIO_0[1];
assign	adc_busy    =GPIO_0[2];
assign	GPIO_0[3]	=adc_din;
assign	GPIO_0[4]	=adc_ltm_sclk;
assign	GPIO_0[5]	=ltm_b[3];
assign	GPIO_0[6]	=ltm_b[2];
assign	GPIO_0[7]	=ltm_b[1];
assign	GPIO_0[8]	=ltm_b[0];
assign	GPIO_0[9]	=ltm_nclk;
assign	GPIO_0[10]	=ltm_den;
assign	GPIO_0[11]	=ltm_hd;
assign	GPIO_0[12]	=ltm_vd;
assign	GPIO_0[13]	=ltm_b[4];
assign	GPIO_0[14]	=ltm_b[5];
assign	GPIO_0[15]	=ltm_b[6];
assign	GPIO_0[16]	=ltm_b[7];
assign	GPIO_0[17]	=ltm_g[0];
assign	GPIO_0[18]	=ltm_g[1];
assign	GPIO_0[19]	=ltm_g[2];
assign	GPIO_0[20]	=ltm_g[3];
assign	GPIO_0[21]	=ltm_g[4];
assign	GPIO_0[22]	=ltm_g[5];
assign	GPIO_0[23]	=ltm_g[6];
assign	GPIO_0[24]	=ltm_g[7];
assign	GPIO_0[25]	=ltm_r[0];
assign	GPIO_0[26]	=ltm_r[1];
assign	GPIO_0[27]	=ltm_r[2];
assign	GPIO_0[28]	=ltm_r[3];
assign	GPIO_0[29]	=ltm_r[4];
assign	GPIO_0[30]	=ltm_r[5];
assign	GPIO_0[31]	=ltm_r[6];
assign	GPIO_0[32]	=ltm_r[7];
assign	GPIO_0[33]	=ltm_grst;
assign	GPIO_0[34]	=ltm_scen;
assign	GPIO_0[35]	=ltm_sda;

assign adc_ltm_sclk	= ( adc_dclk & ltm_3wirebusy_n )  |  ( ~ltm_3wirebusy_n & ltm_sclk );
assign ltm_nclk = div[0]; // 25 Mhz
assign ltm_grst = KEY[0];
always @(posedge CLOCK_50)
	begin
		div <= div+1;
	end

// lcd 3 wire interface configuration  //
lcd_spi_cotroller	u1	(	
					// Host Side
					.iCLK(CLOCK_50),
					.iRST_n(DLY0),
					// 3wire Side
					.o3WIRE_SCLK(ltm_sclk),
					.io3WIRE_SDAT(ltm_sda),
					.o3WIRE_SCEN(ltm_scen),
					.o3WIRE_BUSY_n(ltm_3wirebusy_n)
					);	

// system reset  //
Reset_Delay		u2  (.iCLK(CLOCK_50),
					.iRST(KEY[0]),
					.oRST_0(DLY0),
					.oRST_1(DLY1),
					.oRST_2(DLY2)
					);
// Touch Screen Digitizer ADC configuration //
adc_spi_controller		u3	(
					.iCLK(CLOCK_50),
					.iRST_n(DLY0),
					.oADC_DIN(adc_din),
					.oADC_DCLK(adc_dclk),
					.oADC_CS(adc_cs),
					.iADC_DOUT(adc_dout),
					.iADC_BUSY(adc_busy),
					.iADC_PENIRQ_n(adc_penirq_n),
					.oTOUCH_IRQ(touch_irq),
					.oX_COORD(x_coord),
					.oY_COORD(y_coord),
					.oNEW_COORD(new_coord),
					);

touch_irq_detector	u4	(
					.iCLK(CLOCK_50),
					.iRST_n(DLY0),
					.iTOUCH_IRQ(touch_irq),
					.iX_COORD(x_coord),
					.iY_COORD(y_coord),
					.iNEW_COORD(new_coord),
					.oDISPLAY_MODE(display_mode),
					);

lcd_timing_controller		u5  ( 
					.iCLK(ltm_nclk),
					.iRST_n(DLY2),
					// lcd side
					.oLCD_R(ltm_r),
					.oLCD_G(ltm_g),
					.oLCD_B(ltm_b), 
					.oHD(ltm_hd),
					.oVD(ltm_vd),
					.oDEN(ltm_den),
					.iDISPLAY_MODE(display_mode),	
					);

endmodule