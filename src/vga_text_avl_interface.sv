/************************************************************************
Avalon-MM Interface VGA Text mode display

Register Map:
0x000-0x0257 : VRAM, 171x48 (2400 byte, 600 word) raster order (first column then row)
0x258        : control register

Lab 72 VRAM Format:
X->
[ 31  30-24   23-20     19-16  ][ 15  14-8     7-4      3-0    ]
[IV1][CODE1][FGD_IDX1][BGD_IDX1][IV0][CODE0][FGD_IDX0][BGD_IDX0]

IVn = Draw inverse glyph
CODEn = Glyph code from IBM codepage 437

VSYNC signal = bit which flips on every Vsync (time for new frame), used to synchronize software
BKG_R/G/B = Background color, flipped with foreground when IVn bit is set
FGD_R/G/B = Foreground color, flipped with background when Inv bit is set

************************************************************************/

module vga_text_avl_interface (
	// Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
	// We can put a clock divider here in the future to make this IP more generalizable
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,					// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,			// Avalon-MM Byte Enable
	input  logic [13:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data
	
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs						// VGA HS/VS
);

//logic [3:0][7:0] LOCAL_REG       [`NUM_REGS]; // Registers
//put other local variables here

// Font Signals
logic [12:0] font_addr;
logic [7:0] font_data;

// OCM Signals
logic wren_b_sig = 1'b0;
logic [1:0] [15:0] vram_data;
logic [15:0] vram_word;

logic [7:0] vram_byte;
logic [10:0] vram_addr;

logic [6:0] char_symbol;
logic [2:0] bit_idx;

// Colors 
logic [1:0] [15:0] PALETTE [8]; 
logic [3:0] fg_idx, bg_idx;

// Drawing Signals
logic [10:0] drawx, drawy;
logic [10:0] drawx_inc;
logic draw;
logic VGA_CLK;
logic inverted;
logic blank;

logic VGA_VS;
logic VGA_HS;

assign vs = VGA_VS;
assign hs = VGA_HS;


//assign CTRL_REG = {LOCAL_REG[`CTRL_REG][3], LOCAL_REG[`CTRL_REG][2], LOCAL_REG[`CTRL_REG][1], LOCAL_REG[`CTRL_REG][0]};
//Declare submodules..e.g. VGA controller, ROMS, etc


vram vram_inst (.clk(CLK), .avl_in(AVL_WRITEDATA), 
				.avl_addr(AVL_ADDR[12:0]), .vga_addr(vram_addr), .avl_byteen(AVL_BYTE_EN), 
				.avl_rden(AVL_READ & AVL_CS & ~AVL_ADDR[13]), .avl_wren(AVL_WRITE & AVL_CS & ~AVL_ADDR[13]), .vga_rden(1'b1), 
				.avl_out(AVL_READDATA), .vga_out(vram_data));

				
always_ff @(posedge CLK)
begin
	if (AVL_ADDR[13] & (AVL_WRITE & AVL_CS)) begin
		// Write to palette
		if (AVL_BYTE_EN == 4'b1100) 
			PALETTE[AVL_ADDR[2:0]][1] <= AVL_WRITEDATA[31:16];
		if (AVL_BYTE_EN == 4'b0011) 
			PALETTE[AVL_ADDR[2:0]][0] <= AVL_WRITEDATA[15:0];
	end
end
	
font_rom	font(.addr(font_addr), .data(font_data));

clk_multiplier clk_controller(.inclk0(CLK), .areset(RESET), .c0(VGA_CLK));

vga_controller VGA(.Clk(VGA_CLK), .Reset(RESET), .hs(VGA_HS), .vs(VGA_VS), .blank(blank), .DrawX(drawx), .DrawY(drawy));
   
// Read and write from AVL interface to register block, note that READ waitstate = 1, so this should be in always_ff

//handle drawing (may either be combinational or sequential - or both).
//int start_addr = 16 * n;
//int end_addr = start_addr + 15;


assign drawx_inc = drawx + 1;

always_comb 
begin DRAW: 
	
	begin
		// >> 5 is / 32 // [4:0] is % 32
		// Raster Order
		// Row Major ORDER
		vram_addr = (drawx_inc + ((drawy >> 4) * 1368)) >> 4;
		// 1 Cycle of delay, but should just shift pixels so maybe not that big of a  deal
		vram_word = vram_data[(drawx_inc[3:0] >> 3) + drawy[4]]; // needs to select 0 or 1
		
		char_symbol = vram_word[14:8];
		inverted = vram_word[15];
		
		fg_idx = vram_word[7:4];
		bg_idx = vram_word[3:0];
		
		font_addr = (char_symbol << 4) + drawy[3:0]; // Y Mod 16 - Choose the correct row of font data
		// index into font_data
		bit_idx = drawx_inc[2:0]; // Draw x mod 8
		if (drawx_inc > 11'd1368 | drawy > 11'd768)
			draw = 1'b0;
		else
			draw = font_data[8 - bit_idx] ^ inverted;
	end
end


always_ff @(posedge VGA_CLK)
begin RGB_OUTPUT:
	if (draw & blank) begin
		// Foreground
		// fg_idx goes from 0 to 15, but PALETTE is laid out differently.
		//TODO:: Index into the correct colors with [15:12] or something like that
		red <= PALETTE[fg_idx >> 1][fg_idx[0]][12:9]; 
		green <= PALETTE[fg_idx >> 1][fg_idx[0]][8:5];
		blue <= PALETTE[fg_idx >> 1][fg_idx[0]][4:1];
	end else if (~draw & blank) begin
		// Background
		red <=   PALETTE[bg_idx >> 1][bg_idx[0]][12:9];
		green <=  PALETTE[bg_idx >> 1][bg_idx[0]][8:5];
		blue <=  PALETTE[bg_idx >> 1][bg_idx[0]][4:1];
	end else begin
		red <= 4'b0000;
		green <= 4'b0000;
		blue <= 4'b0000;
	end
	
	
end

endmodule