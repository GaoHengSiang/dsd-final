module pred_pmu(
    input clk,
    input rst_n,
    input        EX_feedback_valid,
    input        EX_prediction_incorrect,
    output [31:0] prediction_cnt,
    output [31:0] prediction_wrong_cnt      
);

    reg [31:0] prediction_cnt_r, prediction_cnt_w;
    reg [31:0] prediction_wrong_cnt_r, prediction_wrong_cnt_w;

    assign prediction_cnt = prediction_cnt_r;
    assign prediction_wrong_cnt = prediction_wrong_cnt_r;


    always @(*) begin
        prediction_cnt_w = EX_feedback_valid ? prediction_cnt_r + 1 : prediction_cnt_r;
        prediction_wrong_cnt_w =(EX_feedback_valid && EX_prediction_incorrect) ? prediction_wrong_cnt_r + 1 : prediction_wrong_cnt_r;
    end
    always @(posedge clk) begin
        if (!rst_n) begin
            prediction_cnt_r <= 0;
            prediction_wrong_cnt_r <= 0;
        end else begin
            prediction_cnt_r <= prediction_cnt_w;
            prediction_wrong_cnt_r <= prediction_wrong_cnt_w;

        end
    end

endmodule