module icache_dm (
    input clk,
    // processor interface
    input proc_reset,
    input proc_read,  //read only
    input [29:0] proc_addr,
    output proc_stall,
    output [31:0] proc_rdata,
    // memory interface
    input [127:0] mem_rdata,
    input mem_ready,
    output  reg mem_read,
    output mem_write,
    output [27:0] mem_addr,
    output [127:0] mem_wdata
);
    //==== parameter definition ===============================
    parameter BLOCK_WIDTH = 128;
    parameter TAG_WIDTH = 25;
    parameter WORD_WIDTH = 32;
    parameter LINE_NUM = 8;
    localparam S_IDLE = 0, S_FETCH = 2;

    integer i;
    //==== wire/reg definition ================================
    reg valid_next;  // updated valid bit
    reg [BLOCK_WIDTH-1:0] wdata;  // data written to cache line
    wire [BLOCK_WIDTH-1:0] rdata;

    reg [29:0] addr_r, addr_w;

    // memory control signals
    wire [2:0] index_i;
    wire [1:0] offset_i;
    wire [TAG_WIDTH-1:0]    tag;
    reg [1:0] state_r, state_w;
    wire            hit;  // hit is ORed result from all the hit signal in each way
    reg             stall;
    reg             wen;  // wen for cache set
    reg             update;
    
    //==== combinational circuit ==============================
    assign index_i = (state_r == S_IDLE) ? proc_addr[4:2] : addr_r[4:2];
    assign offset_i = (state_r == S_IDLE) ? proc_addr[1:0] : addr_r[1:0];

    /* memory control signal */
    assign mem_write = 0;  //READ ONLY
    assign mem_addr = (state_r == S_IDLE) ? proc_addr[29:2] : addr_r[29:2];
    assign mem_wdata = 0;

    assign proc_stall = (!(state_r == S_IDLE && hit) && (proc_read));
    assign proc_rdata = rdata[WORD_WIDTH*offset_i+:WORD_WIDTH];

    iset iset_0(
        .clk(clk),
        .rst(proc_reset),
        .write_i(wen),
        .update_i(update),
        .valid_i(valid_next),
        .wdata_i(wdata),
        .addr_i(state_r == S_IDLE ? proc_addr : addr_r),
        .hit_o(hit),
        .tag_o(tag),
        .rdata_o(rdata)
    );
    always @(*) begin : state_logic
        mem_read = 0;
        state_w = state_r;
        update = 0;
        valid_next = 0;
        wen = 0;
        wdata = 0;
        addr_w = addr_r;
        case (state_r)
            S_IDLE: begin
                if (proc_read) begin
                    if (!hit) begin
                        state_w = S_FETCH;
                        mem_read = 1;
                        addr_w  = proc_addr;
                    end else begin
                        state_w = S_IDLE;
                    end
                end else begin
                    state_w = S_IDLE;
                end
            end
            S_FETCH: begin
                if (mem_ready) begin
                    state_w = S_IDLE;
                    wen = 1;
                    update = 1;
                    valid_next = 1;
                    wdata = mem_rdata;
                end else begin
                    mem_read = 1;
                    state_w = S_FETCH;
                end
            end
        endcase
    end


    //==== sequential circuit =================================
    always @(posedge clk) begin
        if (proc_reset) begin
            state_r <= S_IDLE;
            addr_r <= 0;
        end else begin
            state_r <= state_w;
            addr_r <= addr_w;
        end
    end



endmodule

module iset #(
    parameter LINE_NUM = 8,
    parameter TAG_WIDTH = 25,
    parameter BLOCK_WIDTH = 128
) (
    input                    clk,
    input                    rst,
    input                    write_i,
    input                    update_i,
    input                    valid_i,
    input  [BLOCK_WIDTH-1:0] wdata_i,
    input  [           29:0] addr_i,
    output                   valid_o,
    output                   hit_o,
    output [  TAG_WIDTH-1:0] tag_o,
    output [BLOCK_WIDTH-1:0] rdata_o
);

    /* data read from cache line */
    wire valid_lines[0:LINE_NUM-1];
    wire [TAG_WIDTH-1:0] tag_lines[0:LINE_NUM-1];
    wire [BLOCK_WIDTH-1:0] rdata_lines[0:LINE_NUM-1];

    /* information from input addr */
    wire [TAG_WIDTH-1:0] tag_i;
    wire [2:0] index_i;
    wire [1:0] offset_i;

    /* generate signal */
    wire valid;
    wire hit;
    wire [BLOCK_WIDTH-1:0] rdata;
    wire [1:0] offset;

    /* control signal for cache lines */
    reg wen_lines[0:LINE_NUM-1];  // write enable signal for each line
    wire valid_next;  // updated valid signal
    reg [BLOCK_WIDTH-1:0] wdata;  // data written to cache line, the source could by CPU or memory

    genvar gen_i;
    integer i;
    assign {tag_i, index_i, offset_i} = addr_i;

    assign valid = valid_lines[index_i];
    assign rdata = rdata_lines[index_i];
    assign hit = (valid && (tag_i == tag_lines[index_i]));

    /* output assignment */
    assign valid_o = valid;
    assign hit_o = hit;
    assign rdata_o = rdata;
    assign tag_o = tag_lines[index_i];
    /* instantiate cache lines */
    generate
        for (gen_i = 0; gen_i < LINE_NUM; gen_i = gen_i + 1) begin : gen_blk2
            iline l (
                .clk(clk),
                .rst(rst),
                .write_i(wen_lines[gen_i]),
                .valid_i(valid_next),
                .tag_i(tag_i),
                .wdata_i(wdata),
                .valid_o(valid_lines[gen_i]),
                .tag_o(tag_lines[gen_i]),
                .rdata_o(rdata_lines[gen_i])
            );
        end
    endgenerate

    /* prepare wdata for cache line */
    always @(*) begin
        for (i = 0; i < LINE_NUM; i = i + 1) begin
            wen_lines[i] = (write_i || update_i) && (index_i == i);
        end
        if (write_i) begin
            /* input can only be from data memory, write 128 bit at once */
            wdata = wdata_i;
        end else begin
            wdata = rdata;
        end
    end

    /* update attributes of cache lines */
    assign valid_next = (update_i) ? valid_i : valid;

endmodule

module iline #(
    parameter TAG_WIDTH   = 25,
    parameter BLOCK_WIDTH = 128,
    parameter WORD_WIDTH  = 32
) (
    input clk,
    input rst,
    input write_i,
    input valid_i,
    input [TAG_WIDTH-1:0] tag_i,
    input [BLOCK_WIDTH-1:0] wdata_i,
    output valid_o,
    output [TAG_WIDTH-1:0] tag_o,
    output [BLOCK_WIDTH-1:0] rdata_o
);

    integer i;
    reg valid_r, valid_w;
    reg [TAG_WIDTH-1:0] tag_r, tag_w;
    reg [BLOCK_WIDTH-1:0] data_r, data_w;

    /* output logic */
    assign valid_o = valid_r;
    assign tag_o   = tag_r;
    assign rdata_o = data_r;

    always @(*) begin : update_logic
        if (write_i) begin
            valid_w = valid_i;
            tag_w   = tag_i;
            data_w  = wdata_i;
        end else begin
            valid_w = valid_r;
            tag_w   = tag_r;
            data_w  = data_r;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            valid_r <= 0;
            tag_r   <= 0;
            data_r  <= 0;
        end else begin
            valid_r <= valid_w;
            tag_r   <= tag_w;
            data_r  <= data_w;
        end
    end
endmodule
