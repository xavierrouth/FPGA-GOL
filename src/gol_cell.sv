module gol_cell (
    input CLK,
    input [7:0] neighbors,
	 input reset,
	 input reset_state,
    output state
);

logic [3:0] sum;

assign sum = neighbors[7] + neighbors[6] + neighbors[5] + neighbors[4] + neighbors[3] + neighbors[2] + neighbors[1] + neighbors[0];

always_ff @ (posedge CLK)
begin
	if (reset)
		state <= reset_state;
	else 
		state <= (sum == 2) & state | sum == 3;
end

endmodule
