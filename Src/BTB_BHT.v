module BTB_BHT#(
   parameter PCW = 31, // The width of valid PC
   parameter BTBW = 5 // The width of btb address
)(
    // Outputs
   output pre_take_o, 
   output [PCW-1: 0] pre_destination_o,
    // Inputs
   input clk, 
   input rst_n, 
   input [PCW-1: 0] pc_i, // PC of current branch instruction

   //correction signals
   input feedback_valid_i, 
   input [PCW-1: 0] set_pc_i, 
   input set_taken_i, 
   input [PCW-1: 0] set_target_i
);
    
   // Local Parameters
   localparam SCS_STRONGLY_TAKEN = 2'b11;
   localparam SCS_WEAKLY_TAKEN = 2'b10;
   localparam SCS_WEAKLY_NOT_TAKEN = 2'b01;
   localparam SCS_STRONGLY_NOT_TAKEN = 2'b00;
    
   wire [BTBW-1:0] tb_entry;
   wire [BTBW-1:0] set_tb_entry;
   
   // Saturating counters
   reg [1:0] counter_r [(1<<BTBW)-1:0], counter_w [(1<<BTBW)-1:0];

   // BTB vectors
   reg [PCW-1:0] btb_r [(1<<BTBW)-1:0], btb_w [(1<<BTBW)-1:0];
    
   // PC Address hash mapping
   assign tb_entry = pc_i[BTBW-1:0];
   assign set_tb_entry = set_pc_i[BTBW-1:0];
    
   assign pre_take_o = counter_r [tb_entry][1];
   assign pre_destination_o = btb_r[tb_entry];

   // Saturating counters
   integer entry;
   always @(*) begin: saturation_counter_comb
      //default
      for(entry=0; entry < (1<<BTBW); entry=entry+1) begin
            counter_w[entry] = counter_r[entry];
      end
      if(feedback_valid_i && set_taken_i && counter_r[set_tb_entry] != SCS_STRONGLY_TAKEN) begin
         counter_w[set_tb_entry] = counter_r[set_tb_entry] + 2'b01;
      end
      else if(feedback_valid_i && !set_taken_i && counter_r[set_tb_entry] != SCS_STRONGLY_NOT_TAKEN) begin
         counter_w[set_tb_entry] = counter_r[set_tb_entry] - 2'b01;
      end
   end

   always @(posedge clk) begin: saturation_counter_seq
      if(!rst_n) begin
         for(entry=0; entry < (1<<BTBW); entry=entry+1) begin// reset BTB entries
            counter_r[entry] <= 2'b00;
         end
      end
      else begin
         for(entry=0; entry < (1<<BTBW); entry=entry+1) begin// reset BTB entries
            counter_r[entry] <= counter_w[entry];
         end         
      end
   end



    
   always @(*) begin: BTB_comb
      //default
      for(entry = 0; entry < (1<<BTBW); entry = entry+1) begin 
         btb_w[entry] = btb_r[entry];
      end
      if(feedback_valid_i)
         btb_w[set_tb_entry] = set_target_i;
   end

   always @(posedge clk) begin: BTB_seq
      if(!rst_n) begin
         for(entry=0; entry < (1<<BTBW); entry=entry+1) begin // reset BTB entries
            btb_r[entry] <= {PCW{1'b0}};
         end
      end
      else begin
         for(entry=0; entry < (1<<BTBW); entry=entry+1) begin // reset BTB entries
            btb_r[entry] <= btb_w[entry];
         end
      end
   end 
endmodule