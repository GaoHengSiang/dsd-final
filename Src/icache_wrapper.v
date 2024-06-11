/*
 * include a cache, a write buffer, and a controller, prioritize read miss over write miss
 */
module icache_wrapper (
    input          clk,
    input          proc_reset,
    input          proc_read,
    input          proc_write,
    input  [ 29:0] proc_addr,
    input  [ 31:0] proc_wdata,
    output [ 31:0] proc_rdata,
    output         proc_stall,
    input          mem_ready,
    input  [127:0] mem_rdata,
    output         mem_read,
    output         mem_write,
    output [ 27:0] mem_addr,
    output [127:0] mem_wdata
`ifdef DEBUG_STAT
    ,
    output [ 31:0] read_count,
    output [ 31:0] write_count,
    output [ 31:0] read_miss,
    output [ 31:0] write_miss,
    output [ 31:0] read_stalled_cycles,
    output [ 31:0] write_stalled_cycles
`endif
);
    reg cache_mem_ready;
    wire cache_mem_read;
    // wire cache_mem_write;

    wire [27:0] cache_mem_addr;
    reg [127:0] cache_mem_rdata;
    // wire [127:0] cache_mem_wdata;

    reg mem_ready_r, mem_ready_w;
    reg mem_read_r, mem_read_w;
    // reg mem_write_r, mem_write_w;
    reg [27:0] mem_addr_r, mem_addr_w;
    // reg [127:0] mem_wdata_r, mem_wdata_w;
    reg [127:0] mem_rdata_r, mem_rdata_w;


    assign mem_read = mem_read_r;
    // assign mem_write = mem_write_r;
    assign mem_addr = mem_addr_r;
    // assign mem_wdata = mem_wdata_r;

    icache u_cache (
        .clk       (clk),
        .proc_reset(proc_reset),
        .proc_read (proc_read),
        .proc_addr (proc_addr),
        .proc_rdata(proc_rdata),
        .proc_stall(proc_stall),
        //output
        .mem_read  (cache_mem_read),
        .mem_write (mem_write),//tied to 0
        .mem_addr  (cache_mem_addr),
        .mem_wdata (mem_wdata),//tied to 0
        //input
        .mem_rdata (cache_mem_rdata),
        .mem_ready (cache_mem_ready)
    );
`ifdef DEBUG_STAT
    cache_pmu u_cache_pmu (
        .clk                 (clk),
        .rst                 (proc_reset),
        .cache_stall         (proc_stall),
        //input  [31:0] cache_addr,
        .cache_ren           (proc_read),
        .cache_wen           (proc_write),
        .read_count          (read_count),
        .write_count         (write_count),
        .read_miss           (read_miss),
        .write_miss          (write_miss),
        .read_stalled_cycles (read_stalled_cycles),
        .write_stalled_cycles(write_stalled_cycles)
    );
`endif

    always @(*) begin: memory_signal
        //input from memory
        mem_ready_w = mem_ready;
        mem_rdata_w = mem_ready? mem_rdata : mem_rdata_r;
        // // output to memory
        mem_read_w = mem_ready? 0: cache_mem_read;
        // mem_write_w = cache_mem_write;
        mem_addr_w = cache_mem_addr;
        // mem_wdata_w = cache_mem_wdata;

    end

    always @(*) begin: mem2cache
        cache_mem_ready = mem_ready_r;
        cache_mem_rdata = mem_rdata_r;
    end


    always @(posedge clk) begin
        if (proc_reset) begin
            mem_ready_r <= 1'b0;
            mem_read_r <= 1'b0;
            // mem_write_r <= 1'b0;
            mem_addr_r <= 28'b0;
            // mem_wdata_r <= 128'b0;
            mem_rdata_r <= 128'b0;
        end else begin
            mem_ready_r <= mem_ready_w;
            mem_read_r <= mem_read_w;
            mem_addr_r <= mem_addr_w;
            mem_rdata_r <= mem_rdata_w;
        end
    end
endmodule
