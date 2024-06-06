/*
 * include a cache, a write buffer, and a controller, prioritize read miss over write miss
 */
module dache_wrapper(
    input         clk,
    input         proc_reset,
    input         proc_read,
    input         proc_write,
    input  [29:0] proc_addr,
    input  [31:0] proc_rdata,
    input  [31:0] proc_wdata,
    output         proc_stall,
    output         mem_read,
    output         mem_write,
    output [27:0]  mem_addr,
    output [127:0] mem_wdata,

);
    
cache U0(
    .clk(clk),
    .rst_n(proc_reset),
    .read(proc_read),
    .write(proc_write),
    .addr(proc_addr),
    .rdata(proc_rdata),
    .wdata(proc_wdata),
    .stall(proc_stall),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_addr(mem_addr),
    .mem_wdata(mem_wdata)
);
endmodule