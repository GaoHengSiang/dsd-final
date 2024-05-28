module cache(
    clk,
    proc_reset,
    proc_read,
    proc_write,
    proc_addr,
    proc_rdata,
    proc_wdata,
    proc_stall,
    mem_read,
    mem_write,
    mem_addr,
    mem_rdata,
    mem_wdata,
    mem_ready
);
    
//==== input/output definition ============================
    input          clk;
    // processor interface
    input          proc_reset;
    input          proc_read, proc_write;
    input   [29:0] proc_addr;
    input   [31:0] proc_wdata;
    output         proc_stall;
    output  [31:0] proc_rdata;
    // memory interface
    input  [127:0] mem_rdata;
    input          mem_ready;
    output         mem_read, mem_write;
    output  [27:0] mem_addr;
    output [127:0] mem_wdata;

//==== parameters =========================================
parameter BLOCK_NUM = 4;
parameter BLOCK_IDX_W = 2;
parameter BLOCK_OFFSET_W = 2;//4 words(32 bits each) in a block
parameter PROC_ADDR_W = 30;
parameter PROC_DATA_W = 32;
parameter TAG_W = PROC_ADDR_W -  BLOCK_IDX_W - BLOCK_OFFSET_W;//26 bits
parameter DATA_W = 128;//4 words * 32 bits/word
parameter DIRTY = DATA_W + TAG_W;//the bit position 
parameter VALID = DIRTY + 1;//the bit position = 155
//VALID_DIRTY____TAG____DATA_____
//155...154...153:128...127:0

localparam IDLE         = 2'd0;
localparam WRITE_BACK   = 2'd1;
localparam ALLOCATE     = 2'd2;
//==== wire/reg definition ================================
reg [VALID: 0] cache0_r [0: BLOCK_NUM-1], cache0_w [0: BLOCK_NUM-1];//cache has 128+26+2 = 156bits
reg [VALID: 0] cache1_r [0: BLOCK_NUM-1], cache1_w [0: BLOCK_NUM-1];
reg LRU_r[0: BLOCK_NUM-1], LRU_w[0: BLOCK_NUM-1];//indicates which block should be replaced should the need arise
reg [1: 0] state_r, state_w;

wire CACHE_HIT, CACHE_MISS, READ, WRITE;
wire tageq0, tageq1, hit0, hit1;

wire [TAG_W-1: 0] proc_tag;
wire [TAG_W-1: 0] cache0_tag, cache1_tag;
wire [BLOCK_IDX_W-1: 0] proc_block;
wire [BLOCK_OFFSET_W-1: 0] proc_bk_offset;
wire cache0_valid, cache1_valid, cache0_dirty, cache1_dirty;
wire [DATA_W-1: 0] cache0_data, cache1_data;

reg proc_stall_w;
reg [PROC_DATA_W-1: 0] proc_rdata_w;
reg mem_read_w, mem_write_w;
reg [27: 0] mem_addr_w;
reg [DATA_W-1: 0] mem_wdata_w;

integer i;
//==== combinational circuit ==============================
//continuous assignments
assign READ = proc_read && !proc_write;
assign WRITE = proc_write && !proc_read;

assign {proc_tag, proc_block, proc_bk_offset} = proc_addr;
assign {cache0_valid, cache0_dirty, cache0_tag, cache0_data} = cache0_r[proc_block];
assign {cache1_valid, cache1_dirty, cache1_tag, cache1_data} = cache1_r[proc_block];

assign tageq0 = proc_tag == cache0_tag;
assign tageq1 = proc_tag == cache1_tag;
assign hit0 = tageq0 && cache0_valid;
assign hit1 = tageq1 && cache1_valid;
assign CACHE_HIT = hit0 || hit1;
assign CACHE_MISS = !CACHE_HIT;

//assign outputs
assign proc_stall = proc_stall_w;
assign proc_rdata = proc_rdata_w;
assign mem_read = mem_read_w;
assign mem_write = mem_write_w;
assign mem_addr = mem_addr_w;
assign mem_wdata = mem_wdata_w;

//procedural assignments
//state_r
always@ (*) begin
    //default
    state_w = state_r;
    case(state_r)
    IDLE: begin
        if(CACHE_HIT) begin
            state_w = state_r;
        end
        else if(LRU_r[proc_block] == 1'b1) begin
            if (cache1_dirty) begin
                state_w = WRITE_BACK;
            end
            else begin
                state_w = ALLOCATE;
            end
        end
        else if(LRU_r[proc_block] == 1'b0) begin
            if (cache0_dirty) begin
                state_w = WRITE_BACK;
            end
            else begin
                state_w = ALLOCATE;
            end
        end
    end
    WRITE_BACK: begin
        state_w = (mem_ready)? IDLE: state_r;
    end
    ALLOCATE: begin
        state_w = (mem_ready)? IDLE: state_r;
    end
    endcase
end

//proc_stall, proc_rdata
always@ (*) begin
    proc_stall_w = CACHE_MISS;
    proc_rdata_w = 32'b0;
    if(hit0) begin
        proc_rdata_w = cache0_data[(PROC_DATA_W*proc_bk_offset)+: PROC_DATA_W];
    end
    else if(hit1) begin
        proc_rdata_w = cache1_data[(PROC_DATA_W*proc_bk_offset)+: PROC_DATA_W];
    end
end

//mem_read, mem_write, mem_wdata, mem_addr
always@ (*) begin
    //default
    mem_read_w = 1'b0;
    mem_write_w = 1'b0;
    mem_wdata_w = 128'b0;
    mem_addr_w = 28'b0;
    case(state_r)
    IDLE: begin

    end
    WRITE_BACK: begin//clean the LRU block if necessary
        mem_read_w = 1'b0;
        mem_write_w = 1'b1;
        //look at LRU to write back
        mem_wdata_w = (LRU_r[proc_block] == 1'b1)? cache1_data: cache0_data;
        mem_addr_w = (LRU_r[proc_block] == 1'b1)? {cache1_tag, proc_block}: {cache0_tag, proc_block};
    end
    ALLOCATE: begin
        mem_read_w = 1'b1;
        mem_write_w = 1'b0;
        mem_addr_w = {proc_tag, proc_block};
    end
    endcase
end


//cache_w
always@ (*) begin
    //default
    for(i = 0; i < BLOCK_NUM; i = i+1) begin
        cache0_w[i] = cache0_r[i];
        cache1_w[i] = cache1_r[i];
    end
    case(state_r) 
    IDLE: begin
        if(CACHE_HIT && WRITE) begin
            //priority: 1. write to same tag 2.write to clean
            if(hit0) begin//cache0 has same tag
                cache0_w[proc_block][(PROC_DATA_W*proc_bk_offset)+: PROC_DATA_W] = proc_wdata;
                cache0_w[proc_block][(VALID)-:(2+TAG_W)] = {1'b1, 1'b1, proc_tag};//valid and dirty after write
            end
            else if(hit1) begin//cache1 has same tag
                cache1_w[proc_block][(PROC_DATA_W*proc_bk_offset)+: PROC_DATA_W] = proc_wdata;
                cache1_w[proc_block][(VALID)-:(2+TAG_W)] = {1'b1, 1'b1, proc_tag};//valid and dirty after write
            end
        end
    end
    WRITE_BACK: begin //only function is to clean the block, other status don't change
        if(mem_ready) begin
            //clean the LRU
            if(LRU_r[proc_block] == 1'b0) begin
                cache0_w[proc_block][DIRTY] = 1'b0;//clean
            end
            else if(LRU_r[proc_block] == 1'b1) begin
                cache1_w[proc_block][DIRTY] = 1'b0;
            end
        end
    end
    ALLOCATE: begin//replace the clean 
        //overwrite the LRU, it should be clean already
        if(mem_ready) begin
            //replace LRU
            if(LRU_r[proc_block] == 1'b0) begin
                cache0_w[proc_block][DATA_W-1: 0] = mem_rdata;
                cache0_w[proc_block][(VALID)-:(2+TAG_W)] = {1'b1, 1'b0, proc_tag};//valid and clean
            end
            else if(LRU_r[proc_block] == 1'b1) begin
                cache1_w[proc_block][DATA_W-1: 0] = mem_rdata;
                cache1_w[proc_block][(VALID)-:(2+TAG_W)] = {1'b1, 1'b0, proc_tag};//valid and clean
            end
        end
    end
    endcase
end 

//LRU
always@ (*) begin
    //default
    for(i = 0; i < BLOCK_NUM; i = i+1) begin
        LRU_w[i] = LRU_r[i];
    end
    if(hit0) begin
        LRU_w[proc_block] = 1'b1;
    end
    else if(hit1) begin
        LRU_w[proc_block] = 1'b0;
    end
end

//==== sequential circuit =================================
always@(posedge clk or posedge proc_reset) begin
    if( proc_reset ) begin
        for (i = 0; i < BLOCK_NUM; i = i+1) begin
            cache0_r[i] <= {(VALID+1){1'b0}};
            cache1_r[i] <= {(VALID+1){1'b0}};
            LRU_r[i] <= 1'b0;
        end
        state_r <= 2'b0;
    end
    else begin
        for (i = 0; i < BLOCK_NUM; i = i+1) begin
            cache0_r[i] <= cache0_w[i];
            cache1_r[i] <= cache1_w[i];
            LRU_r[i] <= LRU_w[i];
        end     
        state_r <= state_w;  
    end
end

endmodule
