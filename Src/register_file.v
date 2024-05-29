module register_file(
        clk,
        rst_n,
        rs1,
        rs2,
        rd,
        wen,
        rddata1,
        rddata2,
        wrdata
);
    parameter DATA_WIDTH = 32;
    parameter NR_REG = 32;

    input clk, rst_n;
    input [4:0] rs1, rs2, rd;
    input wen;
    input [DATA_WIDTH-1:0] wrdata;
    output [DATA_WIDTH-1:0] rddata1, rddata2;

    integer i;
    reg [DATA_WIDTH-1:0]  reg_data_r[0:NR_REG-1], reg_data_w [1:NR_REG-1];
    
    assign rddata1 = (wen && (rd == rs1) && (rd != 0))? wrdata : reg_data_r[rs1];
    assign rddata2 = (wen && (rd == rs2) && (rd != 0))? wrdata : reg_data_r[rs2];

    always @(*) begin
        for (i = 1; i < NR_REG; i = i + 1) reg_data_w[i] = (wen && (i == rd)) ? wrdata : reg_data_r[i];
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            for(i = 0; i < NR_REG; i = i + 1) reg_data_r[i] <= 0;
        end else begin
            reg_data_r[0] <= 0;
            for(i = 1; i < NR_REG; i = i + 1) reg_data_r[i] <= reg_data_w[i];
        end
    end

endmodule