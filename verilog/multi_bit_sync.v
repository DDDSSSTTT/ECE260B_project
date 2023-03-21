// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module multi_bit_sync(clk, in, out);

parameter bw = 16;

input [bw-1:0] in; 
input  clk;
output [bw-1:0] out;

reg [bw-1:0]    int1; 
reg [bw-1:0]    int2; 

assign out = int2;

always @ (posedge clk) begin
   int1 <= in;
   int2 <= int1;
end

endmodule
