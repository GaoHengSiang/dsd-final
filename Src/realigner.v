module realigner (
    input             clk,
    input             rst_n,
    input      [31:0] pc,            // target PC
    input             stall,
    input             step,
    output reg        ready,
    output reg        compressed,
    output     [31:0] inst,
    //-------ICACHE interface-------
    output            ICACHE_ren,
    output            ICACHE_wen,
    output     [29:0] ICACHE_addr,
    output     [31:0] ICACHE_wdata,
    input      [31:0] ICACHE_rdata,
    input             ICACHE_stall
);

    assign ICACHE_ren   = 1;
    assign ICACHE_wen   = 0;
    assign ICACHE_wdata = 0;

    reg [29:0] stored_addr_r, stored_addr_w;
    reg [15:0] stored_inst_r, stored_inst_w;
    reg        unaligned;
    reg        buffered;
    reg        b_r, b_w;
    reg [31:0] rdata_i;
    reg [29:0] fetch_word_addr;
    reg [29:0] pc_word_addr;
    reg [31:0] completed_inst;
    reg [29:0] fetch_next_addr;
    reg        shit;
    always @(*) begin
        pc_word_addr = pc[31:2];
        fetch_next_addr = pc_word_addr + 1;
        unaligned = (pc[1:0] != 2'b00);
        rdata_i = {ICACHE_rdata[7:0], ICACHE_rdata[15:8], ICACHE_rdata[23:16], ICACHE_rdata[31:24]};
        compressed = (completed_inst[1:0] != 2'b11);
        buffered = (stored_addr_r == pc_word_addr);
        stored_addr_w = (ICACHE_stall || stall) ? stored_addr_r : fetch_word_addr;
        stored_inst_w = (ICACHE_stall || stall) ? stored_inst_r : rdata_i[31:16];
    end

    always @(*) begin
        fetch_word_addr = 0;
        completed_inst = rdata_i;
        ready = !ICACHE_stall;
        b_w = !ICACHE_stall && !stall;
        if (unaligned) begin
            completed_inst = {rdata_i[15:0], stored_inst_r[15:0]};
            if (b_r) begin
                fetch_word_addr = fetch_next_addr;
                b_w = !ICACHE_stall && step;
            end else begin
                fetch_word_addr = pc_word_addr;
                b_w = !ICACHE_stall && !stall;
                ready = 0;
            end
        end else begin
            b_w = !ICACHE_stall && !stall && (step && compressed);
            fetch_word_addr = pc_word_addr;
        end
        shit = ready && (b_r != buffered);
        // b_w = (pc_w[31:2] == stored_addr_w);
        
    end

    assign inst = completed_inst;

    assign ICACHE_addr = fetch_word_addr;

    always @(posedge clk) begin
        if (!rst_n) begin
            stored_addr_r <= 0;
            stored_inst_r <= 0;
            b_r <= 0;
        end else begin
            stored_addr_r <= stored_addr_w;
            stored_inst_r <= stored_inst_w;
            b_r <= b_w;
        end
    end


endmodule
