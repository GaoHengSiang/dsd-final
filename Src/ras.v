module ras (
    input clk_i,
    input rst_n_i,
    input push_i,
    input pop_i,
    input [31:0] return_addr_i,
    output valid_o,
    output [31:0] return_addr_o
);

parameter DEPTH = 2;
parameter RAS_ENTRY_WIDTH = 33; // 1-bit valid + 32-bit address


integer i;
reg  [RAS_ENTRY_WIDTH-1:0] stack_r [DEPTH-1:0];
reg  [RAS_ENTRY_WIDTH-1:0] stack_w [DEPTH-1:0];

assign valid_o = stack_r[0][RAS_ENTRY_WIDTH-1];
assign return_addr_o = stack_r[0][RAS_ENTRY_WIDTH-2:0];

always @(*) begin
    for (i = 0; i < DEPTH; i = i + 1) begin
        stack_w[i] = stack_r[i];
    end

    if (push_i) begin
        stack_w[0] = {1'b1, return_addr_i};
        for (i = 1; i < DEPTH-1; i = i + 1) begin
            stack_w[i] = stack_r[i-1];
        end
    end

    if (pop_i) begin
        for (i = 0; i < DEPTH-2; i = i + 1) begin
            stack_w[i] = stack_r[i+1];
        end
        stack_w[DEPTH-1] = 33'b0;
    end

    if (pop_i && push_i) begin
        for (i = 0; i < DEPTH-2; i = i + 1) begin
            stack_w[i] = stack_r[i];
        end
        stack_w[0] = {1'b1, return_addr_i};
    end

end


always @(posedge clk_i) begin
    if (!rst_n_i) begin
        for (i = 0 ;i < DEPTH-1; i = i + 1)
            stack_r[i] <= 33'b0;
    end else begin
        for (i = 0 ;i < DEPTH-1; i = i + 1)
            stack_r[i] <= stack_w[i];
    end
end

endmodule



