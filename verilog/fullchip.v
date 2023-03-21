// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module fullchip (clk1, clk2, mem_in1, mem_in2, inst1, inst2, reset, out1, out2, fifo_full,fifo_empty);

parameter col = 8;
parameter bw = 4;
parameter bw_psum = 2*bw+4;
parameter pr = 16;

//Insert fifos for dual-core
parameter simd = 1;

input  clk1, clk2; 
input  [pr*bw-1:0] mem_in1,mem_in2; 
input  [18:0] inst1, inst2; //sfp added to core, 2 more bits instr needed
input sum_ready1, sum_ready2; 
input  clk_1; 
input  clk_2;
input  [pr*bw-1:0] mem_in_1; 
input  [pr*bw-1:0] mem_in_2;
input  [18:0] inst; //sfp added to core, 2 more bits instr needed 
input  reset;
input  fifo_ext_rd;

wire [bw_psum+3:0] sum_in1,sum_in2;
wire [bw_psum+3:0] sum_out1,sum_out2;
wire [bw_psum+3:0] sum_in1,sum_in2;
output [bw_psum*col-1:0] out1,out2;
output reg [1:0] fifo_full;
output reg [1:0] fifo_empty;


core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_instance1 (
      .reset(reset), 
      .clk(clk1),
      .sum_in(sum_in1), 
      .sum_out(sum_out1),
      .out(out1),
      .mem_in(mem_in1), 
      .inst(inst1)
);

core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_instance2 (

core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_instance_2 (
      .reset(reset), 
      .clk(clk2),
      .sum_in(sum_in2),  
      .sum_out(sum_out2),
      .out(out2),
      .mem_in(mem_in2), 
      .inst(inst2)
      .clk(clk_2), 
      .ext_rd_clk(clk_1),
      .sum_in(sum_out_1),
      .sum_out(sum_out_2),
      .out(out_2),
      .mem_in(mem_in_2), 
      .inst(inst),
      .fifo_ext_rd(fifo_ext_rd)
);

multi_bit_sync #(.bw(bw_psum+4)) mb_sync1 (
      .in(sum_out2),
      .clk(clk1),
      .out(sum_in1)
);

multi_bit_sync #(.bw(bw_psum+4)) mb_sync2 (
      .in(sum_out1),
      .clk(clk2),
      .out(sum_in2)
);
endmodule
