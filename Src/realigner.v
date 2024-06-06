module realigner(
    input         clk,
    input         rst_n,
    input [31:0]  pc, // target PC
    output  reg   ready,
    output  reg   compressed,
    output [31:0] inst,
//-------ICACHE interface-------
    output        ICACHE_ren,
    output        ICACHE_wen,
    output [29: 0] ICACHE_addr,
    output [31: 0] ICACHE_wdata,
    input  [31: 0] ICACHE_rdata,
    input          ICACHE_stall
);	
    assign ICACHE_ren = 1;
    assign ICACHE_wen = 0;
    assign ICACHE_wdata = 0;
    localparam S_INIT = 0, S_FETCH = 1;
    reg           state_r, state_w;
    reg    [31:0] stored_addr_r, stored_addr_w;
    reg    [15:0] stored_inst_r, stored_inst_w;
    reg           unaligned;
    reg           buffered;
    reg    [31:0] rdata_i;
    reg    [31:0] fetch_addr;
    reg           store;
    reg    [31:0] completed_inst;

    always @(posedge clk) begin
        if (!rst_n) begin
            state_r <= S_INIT;
        end else begin
            state_r <= state_w;
        end
    end
    
    always @(*) begin
        unaligned = (pc[1:0] != 2'b00);
        rdata_i = {ICACHE_rdata[7:0], ICACHE_rdata[15:8], ICACHE_rdata[23:16], ICACHE_rdata[31:24]};
        compressed = (completed_inst[1:0] != 2'b11);
        buffered = (stored_addr_r == pc);
        stored_addr_w = fetch_addr + 2;
        stored_inst_w = rdata_i[31:16];
    end

    always @(*) begin
        fetch_addr = 0;
        completed_inst = rdata_i;
        ready = !ICACHE_stall;
        if (state_r == S_INIT) begin
            if (unaligned) begin
                completed_inst = {rdata_i[15:0], stored_inst_r[15:0]};
                if (buffered) begin
                    fetch_addr = pc + 2;
                end else begin
                    fetch_addr = pc - 2;
                    ready = 0;
                end
            end else begin
                fetch_addr = pc;
            end
        end else begin
            completed_inst = {rdata_i[15:0], stored_inst_r[15:0]};
            fetch_addr = pc + 2;
        end
    end

    assign inst = completed_inst;

    assign ICACHE_addr = fetch_addr[31:2];
    always @(*) begin:state_logic
        state_w = state_r;
        if (state_r == S_INIT) begin
            if (ICACHE_stall) 
                state_w = S_INIT;
            else if (unaligned && !buffered)
                state_w = S_FETCH;
        end else begin
            if (ICACHE_stall) 
                state_w = S_FETCH;
            else
                state_w = S_INIT;
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            stored_addr_r <= 0;
            stored_inst_r <= 0;
        end else begin
            stored_addr_r <= stored_addr_w;
            stored_inst_r <= stored_inst_w;
        end
    end


endmodule