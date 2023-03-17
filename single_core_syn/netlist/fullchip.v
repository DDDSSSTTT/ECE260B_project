// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module fullchip (clk, mem_in, inst, reset, out, sum_out);

parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+4;
parameter pr = 16;

input  clk; 
input  [pr*bw-1:0] mem_in; 
input  [18:0] inst; //sfp added to core, 2 more bits instr needed 
input  reset;



output [bw_psum+3:0] sum_out;
output [bw_psum*col-1:0] out;


core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_instance (
      .reset(reset), 
      .clk(clk), 
      .sum_out(sum_out),
      .out(out),
      .mem_in(mem_in), 
      .inst(inst)
);

endmodule
