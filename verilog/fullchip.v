// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module fullchip (clk_1, clk_2, mem_in_1, mem_in_2, inst, reset, fifo_ext_rd, out_1, out_2, sum_out_1, sum_out_2);

parameter col = 8;
parameter bw = 4;
parameter bw_psum = 2*bw+4;
parameter pr = 16;

input  clk_1; 
input  clk_2;
input  [pr*bw-1:0] mem_in_1; 
input  [pr*bw-1:0] mem_in_2;
input  [18:0] inst; //sfp added to core, 2 more bits instr needed 
input  reset;
input  fifo_ext_rd;

output [col*bw_psum-1:0] out_core1;
output [col*bw_psum-1:0] out_core2;
wire  [bw_psum+3:0] sum_out_1;
wire  [bw_psum+3:0] sum_out_2;


core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_instance_1 (
      .reset(reset), 
      .clk(clk_1), 
      .ext_rd_clk(clk_2),
      .sum_in(sum_out_2),
      .sum_out(sum_out_1),
      .out(out_1),
      .mem_in(mem_in_1), 
      .inst(inst),
      .fifo_ext_rd(fifo_ext_rd)
);

core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_instance_2 (
      .reset(reset), 
      .clk(clk_2), 
      .ext_rd_clk(clk_1),
      .sum_in(sum_out_1),
      .sum_out(sum_out_2),
      .out(out_2),
      .mem_in(mem_in_2), 
      .inst(inst),
      .fifo_ext_rd(fifo_ext_rd)
);

// fifo_depth16 #(.bw(bw), .simd(simd)) fifo_instance1(
//       .rd_clk(), 
//       .wr_clk(), 
//       .in(), 
//       .out(), 
//       .rd(), 
//       .wr(), 
//       .o_full(), 
//       .o_empty(), 
//       .reset()
// );
// fifo_depth16 #(.bw(bw), .simd(simd)) fifo_instance2(
//       .rd_clk(), 
//       .wr_clk(), 
//       .in(), 
//       .out(), 
//       .rd(), 
//       .wr(), 
//       .o_full(), 
//       .o_empty(), 
//       .reset()
// );

endmodule
