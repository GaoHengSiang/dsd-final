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

    icache u_cache (
        .clk       (clk),
        .proc_reset(proc_reset),
        .proc_read (proc_read),
        .proc_addr (proc_addr),
        .proc_rdata(proc_rdata),
        .proc_stall(proc_stall),
        .mem_read  (mem_read),
        .mem_write (mem_write),
        .mem_addr  (mem_addr),
        .mem_rdata (mem_rdata),
        .mem_wdata (mem_wdata),
        .mem_ready (mem_ready)
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
endmodule
