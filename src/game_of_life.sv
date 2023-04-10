`define WIDTH 50
`define HEIGHT 40

module game_of_life (
    ///////// Clocks /////////
    input              MAX10_CLK1_50,

    ///////// KEY /////////
    input    [ 1: 0]   KEY,

    ///////// SW /////////
    input    [ 9: 0]   SW,

    ///////// LEDR /////////
    output   [ 9: 0]   LEDR,

    ///////// HEX /////////
    output   [ 7: 0]   HEX0,
    output   [ 7: 0]   HEX1,
    output   [ 7: 0]   HEX2,
    output   [ 7: 0]   HEX3,
    output   [ 7: 0]   HEX4,
    output   [ 7: 0]   HEX5,

    ///////// VGA /////////
    output   logic          VGA_HS,
    output   logic          VGA_VS,
    output   logic [ 3: 0]   VGA_R,
    output   logic [ 3: 0]   VGA_G,
    output   logic [ 3: 0]   VGA_B
);

// VGA Signals
logic RESET;
logic VGA_CLK;
logic VGA_CLK_FAST;
logic blank;
logic [10:0] drawx, drawy;
logic draw;

// c0 is 162 Mhz
// c1 is 25.175

clk_multiplier clk_controller(.inclk0(MAX10_CLK1_50), .areset(RESET), .c0(VGA_CLK));
vga_controller VGA(.Clk(VGA_CLK), .Reset(RESET), .hs(VGA_HS), .vs(VGA_VS), .blank(blank), .DrawX(drawx), .DrawY(drawy));

// Game Of Life Signals
logic cells [`WIDTH][`HEIGHT];

logic reset_cells;
logic contn;

assign reset_cells = ~KEY[0];
assign RESET = ~KEY[0];

assign LEDR[9:0] = SW[9:0];

logic game_clk;
logic [31:0] counterout;

assign game_clk = (~KEY[1] | (counterout == (50000000 >> SW[3:0])));

/**
always_ff @ (posedge MAX10_CLK1_50)
begin
	
	if ((counterout >= (50000000 >> SW[3:0])) | ~KEY[1])
		counterout <= 0;
	else
		counterout <= counterout + 1;
end


genvar x, y;
generate
	for (x = 0; x < `WIDTH; x = x + 1) begin : OUTER
		for (y = 0; y < `HEIGHT; y = y + 1) begin : INNER
			logic [7:0] neighbors;
			logic reset_state;
			// Assign neighbors Clockwise starting from top left
			
			// Top Left
			if (x == 0 || y == 0)
				assign neighbors[0] = 1'b0;
			else 
				assign neighbors[0] = cells[x-1][y-1];
				
			// Top Middle
			if (y == 0)
				assign neighbors[1] = 1'b0;
			else 
				assign neighbors[1] = cells[x][y-1];
			
			// Top Right
			if (x == `WIDTH - 1 || y == 0)
				assign neighbors[2] = 1'b0;
			else 
				assign neighbors[2] = cells[x+1][y-1];
				
			// Right
			if (x == `WIDTH - 1)
				assign neighbors[3] = 1'b0;
			else 
				assign neighbors[3] = cells[x+1][y];
				
			// Bottom Right
			if (y == `HEIGHT - 1 || x == `WIDTH - 1)
				assign neighbors[4] = 1'b0;
			else 
				assign neighbors[4] = cells[x+1][y+1];
			
			// Bottom 
			if (y == `HEIGHT - 1 )
				assign neighbors[5] = 1'b0;
			else 
				assign neighbors[5] = cells[x][y+1];
			
			// Bottom Left
			if (y == `HEIGHT - 1  || x == 0)
				assign neighbors[6] = 1'b0;
			else 
				assign neighbors[6] = cells[x-1][y+1];
			
			// Left
			if (x == 0)
				assign neighbors[7] = 1'b0;
			else 
				assign neighbors[7] = cells[x-1][y];
			
			if (x == 10 || y == 5)
				assign reset_state = 1'b1;
			else 
				assign reset_state = 1'b0;
			
			// Gating clock ew
			gol_cell(.CLK(game_clk), .reset(reset_cells), .reset_state(reset_state), .neighbors(neighbors), .state(cells[x][y]));
		end
	end
endgenerate
*/
// Draw Logic

always_comb 
begin DRAW: 
	//draw = cells[drawx >> 3][drawy >> 3];
	draw = drawy[2] | drawx[2];
	
end

// Output Logic
always_ff @(posedge VGA_CLK)
begin RGB_OUTPUT:
	if (~blank) begin
		VGA_R <= 4'b0000;
		VGA_G <= 4'b0000;
		VGA_B <= 4'b0000;
	end else begin
		if (draw) begin
			VGA_R <= 4'b1111;
			VGA_G <= 4'b0000;
			VGA_B <= 4'b1111;
		end else begin
			VGA_R <= 4'b1111;
			VGA_G <= 4'b1111;
			VGA_B <= 4'b0000;
		end
	end
end

endmodule