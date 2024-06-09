/*
 * Performance Monitoring Unit for both Data and Instruction Cache
 */
module cache_pmu (
    input         clk,
    input         rst,
    input         cache_stall,
    //input  [31:0] cache_addr,
    input         cache_ren,
    input         cache_wen,
    output [31:0] read_count,
    output [31:0] write_count,
    output [31:0] read_miss,
    output [31:0] write_miss,
    output [31:0] read_stalled_cycles,
    output [31:0] write_stalled_cycles
);

    localparam S_IDLE = 0, S_STALL = 1;
    reg state_r, state_w;
    reg [31:0]
        read_count_r,
        write_count_r,
        read_miss_r,
        write_miss_r,
        read_stalled_cycles_r,
        write_stalled_cycles_r;
    reg [31:0]
        read_count_w,
        write_count_w,
        read_miss_w,
        write_miss_w,
        read_stalled_cycles_w,
        write_stalled_cycles_w;


    assign read_count = read_count_r;
    assign write_count = write_count_r;
    assign read_miss = read_miss_r;
    assign write_miss = write_miss_r;
    assign read_stalled_cycles = read_stalled_cycles_r;
    assign write_stalled_cycles = write_stalled_cycles_r;

    reg stall_cause_r, stall_cause_w;  // 0 -> read miss, 1 -> write miss

    always @(*) begin : counter
        read_count_w = (state_r == S_IDLE && cache_ren) ? read_count_r + 1 : read_count_r;
        write_count_w = (state_r == S_IDLE && cache_wen) ? write_count_r + 1 : write_count_r;
        read_miss_w = (state_r == S_IDLE && cache_ren && cache_stall) ? read_miss_r + 1 : read_miss_r;
        write_miss_w = (state_r == S_IDLE && cache_wen && cache_stall) ? write_miss_r + 1 : write_miss_r;
        read_stalled_cycles_w = ((state_r == S_IDLE && cache_ren && cache_stall) || (state_r == S_STALL && stall_cause_r == 0))? 
            read_stalled_cycles_r + 1 : read_stalled_cycles_r;
        write_stalled_cycles_w = ((state_r == S_IDLE && cache_wen && cache_stall) || (state_r == S_STALL && stall_cause_r == 1))?
            write_stalled_cycles_r + 1 : write_stalled_cycles_r;

    end
    always @(*) begin : state_logic
        state_w = state_r;
        stall_cause_w = stall_cause_r;
        if (state_r == S_IDLE) begin
            if (cache_stall) begin
                state_w = S_STALL;
                if (cache_ren) begin
                    stall_cause_w = 0;
                end else begin
                    stall_cause_w = 1;
                end
            end
        end else begin
            if (!cache_stall) begin
                state_w = S_IDLE;
                stall_cause_w = 0;
            end else begin
                state_w = S_STALL;
            end
        end
    end


    always @(posedge clk) begin
        if (rst) begin
            state_r <= 0;
            read_count_r <= 0;
            write_count_r <= 0;
            read_miss_r <= 0;
            write_miss_r <= 0;
            read_stalled_cycles_r <= 0;
            write_stalled_cycles_r <= 0;
            stall_cause_r <= 0;
        end else begin
            state_r <= state_w;
            read_count_r <= read_count_w;
            write_count_r <= write_count_w;
            read_miss_r <= read_miss_w;
            write_miss_r <= write_miss_w;
            read_stalled_cycles_r <= read_stalled_cycles_w;
            write_stalled_cycles_r <= write_stalled_cycles_w;
            stall_cause_r <= stall_cause_w;
        end
    end


endmodule
