// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module fullchip (clk1, clk2, mem_in1, mem_in2, inst1, inst2, reset, out1, out2);

parameter col = 8;
parameter bw = 4;
parameter bw_psum = 2*bw+4;
parameter pr = 16;

//Insert fifos for dual-core
parameter simd = 1;

input  clk1, clk2; 
input  [pr*bw-1:0] mem_in1,mem_in2; 
input  [18:0] inst1, inst2; //sfp added to core, 2 more bits instr needed 
input  reset;


wire [bw_psum+3:0] sum_out1,sum_out2;
output [bw_psum*col-1:0] out1,out2;


core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_instance1 (
      .reset(reset), 
      .clk(clk1),
      .sum_in(sum_out2), 
      .sum_out(sum_out1),
      .out(out1),
      .mem_in(mem_in1), 
      .inst(inst1)
);
core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_instance2 (
      .reset(reset), 
      .clk(clk2),
      .sum_in(sum_out1),  
      .sum_out(sum_out2),
      .out(out2),
      .mem_in(mem_in2), 
      .inst(inst2)
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
