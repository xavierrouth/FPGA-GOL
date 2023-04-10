module vram(
    input  clk,
    
    input  [31:0] avl_in,
    input  [12:0] avl_addr, vga_addr,
	 
    input  [3:0] avl_byteen,
	 
    input  avl_rden, avl_wren, vga_rden,
    
    output reg [31:0] avl_out, vga_out

);

reg [3:0][7:0] mem [8208]; // 1200 words, 2 chars per word

always_ff @ (posedge clk) begin
	if (avl_wren) begin
			if (avl_byteen & 4'b1000)
				 mem[avl_addr][3] <= avl_in[31:24];
			if (avl_byteen & 4'b0100)
				 mem[avl_addr][2] <= avl_in[23:16];
			if (avl_byteen & 4'b0010)
				 mem[avl_addr][1] <= avl_in[15:8]; 
			if (avl_byteen & 4'b0001)
				 mem[avl_addr][0] <= avl_in[7:0]; 
	end
	if (avl_rden) begin
		avl_out <= mem[avl_addr];
	end
		 // Doesn't depend on chip select
	if (vga_rden) begin
		vga_out <= mem[vga_addr];
	end
end
endmodule