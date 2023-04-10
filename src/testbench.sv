module testbench();

timeunit 1ps;	// Half clock cycle at 50 MHz
			
///////// Clocks /////////
logic              Clk;

///////// KEY /////////
logic    [ 1: 0]   KEY;

///////// SW /////////
logic    [ 9: 0]   SW;

///////// LEDR /////////
logic   [ 9: 0]   LEDR;

///////// HEX /////////
logic   [ 7: 0]   HEX0;
logic   [ 7: 0]   HEX1;
logic   [ 7: 0]   HEX2;
logic   [ 7: 0]   HEX3;
logic   [ 7: 0]   HEX4;
logic   [ 7: 0]   HEX5;

///////// VGA /////////
logic             VGA_HS;
logic             VGA_VS;
logic   [ 3: 0]   VGA_R;
logic   [ 3: 0]   VGA_G;
logic   [ 3: 0]   VGA_B;

integer TestsFailed = 0;

game_of_life DUT(.MAX10_CLK1_50(Clk), .*);

always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end 



initial begin: TEST_VECTORSs
KEY[0] = 1'b1;

#1000000000
#1000000000
#1000000000
#1000000000
#1000000000
#1000000000
#1000000000
#1000000000
#1000000000
#1000000000
#1000000000
#1000000000
#1000000000
#1000000000
#1000000000
#1000000000
#1000000000
#1000000000
#1000000000
#1000000000
#1000000000
#1000000000
#1000000000
#1000000000
#1000000000
#1000000000
#1000000000
KEY[0] = 1'b1;
end

endmodule