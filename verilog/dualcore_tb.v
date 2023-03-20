// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 

`timescale 1ns/1ps

module dualcore_tb;

parameter total_cycle = 8;   // how many streamed Q vectors will be processed
parameter bw = 4;            // Q & K vector bit precision
parameter bw_psum = 2*bw+4;  // partial sum bit precision
parameter pr = 16;           // how many products added in each dot product 
parameter col = 8;           // how many dot product units are equipped

integer qk_file ; // file handler
integer qk_scan_file ; // file handler


integer  captured_data;
integer  weight [col*pr-1:0];
`define NULL 0




integer  K0[col-1:0][pr-1:0], K1[col-1:0][pr-1:0];
integer  Q[total_cycle-1:0][pr-1:0];
integer  result[total_cycle-1:0][col-1:0];
integer  result2[total_cycle-1:0][col-1:0];
integer  sfp_result[total_cycle-1:0][col-1:0];
integer  sfp_result2[total_cycle-1:0][col-1:0];
integer  this_sum[total_cycle-1:0];
integer  this_sum2[total_cycle-1:0];
integer  abs_temp;
integer i,j,k,t,p,q,s,u, m;





reg reset = 1;
reg clk = 0;
reg [pr*bw-1:0] mem_in1, mem_in2;
reg ofifo_rd = 0;
wire [18:0] inst,inst1,inst2; //Changed to 18:0 for sfp instr(acc,div), and also a tricky structure for inst
reg qmem_rd = 0;
reg qmem_wr = 0;
reg qmem_wr2 = 0; 
reg kmem_rd = 0;
reg kmem_wr = 0;
reg kmem_wr2 = 0;
reg pmem_rd = 0; 
reg pmem_wr = 0; 
reg execute = 0;
reg load = 0;
reg [3:0] qkmem_add = 0;
reg [3:0] qkmem_add2 = 0;
reg [3:0] pmem_add = 0;
reg div_ready = 0;
reg acc_ready = 0;

assign inst1[18] = div_ready;
assign inst1[17] = acc_ready;
assign inst1[16] = ofifo_rd;
assign inst1[15:12] = qkmem_add;
assign inst1[11:8]  = pmem_add;
assign inst1[7] = execute;
assign inst1[6] = load;
assign inst1[5] = qmem_rd;
assign inst1[4] = qmem_wr;
assign inst1[3] = kmem_rd;
assign inst1[2] = kmem_wr;
assign inst1[1] = pmem_rd;
assign inst1[0] = pmem_wr;

assign inst2[18] = div_ready;
assign inst2[17] = acc_ready;
assign inst2[16] = ofifo_rd;
assign inst2[15:12] = qkmem_add2;
assign inst2[11:8]  = pmem_add;
assign inst2[7] = execute;
assign inst2[6] = load;
assign inst2[5] = qmem_rd;
assign inst2[4] = qmem_wr2;
assign inst2[3] = kmem_rd;
assign inst2[2] = kmem_wr2;
assign inst2[1] = pmem_rd;
assign inst2[0] = pmem_wr;

reg [bw_psum-1:0] temp5b, temp5b2;
reg [bw_psum*col-1:0] temp16b,temp16b2;
wire [bw_psum*col-1:0] out1, out2; 


fullchip #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) fullchip_instance (
  .reset(reset),
  .clk1(clk), 
  .clk2(clk), 
  .mem_in1(mem_in1), 
  .mem_in2(mem_in2), 
  .inst1(inst1),
  .inst2(inst2),  
  .out1(out1), 
  .out2(out2)
);



initial begin 

  $dumpfile("dualcore_tb.vcd");
  $dumpvars(0,dualcore_tb);



///// Q data txt reading /////

$display("##### Q data txt reading #####");


  qk_file = $fopen("qdata.txt", "r");

  //// Remove data discarding////


  for (q=0; q<total_cycle; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          Q[q][j] = captured_data;
          //$display("%d\n", K0[q][j]);
    end
  end
/////////////////////////////////




  for (q=0; q<2; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
  end




///// K data core0 txt reading /////

$display("##### K data core0 txt reading #####");

  for (q=0; q<10; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
  end
  reset = 0;

  qk_file = $fopen("kdata_core0.txt", "r");

  //// Remove data discarding ////

  for (q=0; q<col; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          K0[q][j] = captured_data;
          //$display("##### %d\n", K0[q][j]);
    end
  end
/////////////////////////////////

///// K data core1 txt reading /////

$display("##### K data core1 txt reading #####");

  for (q=0; q<10; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
  end

  qk_file = $fopen("kdata_core1.txt", "r");

  //// Remove Data Discarding ////

  for (q=0; q<col; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          K1[q][j] = captured_data;
          //$display("##### %d\n", K0[q][j]);
    end
  end
/////////////////////////////////






/////////////// Estimated result printing /////////////////


$display("##### Estimated multiplication result #####");

  for (t=0; t<total_cycle; t=t+1) begin
     for (q=0; q<col; q=q+1) begin
       result[t][q] = 0;
       result2[t][q] = 0;
     end
  end

  for (t=0; t<total_cycle; t=t+1) begin
     for (q=0; q<col; q=q+1) begin
         for (k=0; k<pr; k=k+1) begin
            result[t][q] = result[t][q] + Q[t][k] * K0[q][k];
            result2[t][q] = result2[t][q] + Q[t][k] * K1[q][k];
         end

         temp5b = result[t][q];
         temp16b = {temp16b[139:0], temp5b};
         temp5b2 = result2[t][q];
         temp16b2 = {temp16b2[139:0], temp5b2};
     end

     //$display("%d %d %d %d %d %d %d %d", result[t][0], result[t][1], result[t][2], result[t][3], result[t][4], result[t][5], result[t][6], result[t][7]);
     $display("prd array_out of core 0 @cycle%2d: %24h", t, temp16b);
     $display("prd array_out of core 1 @cycle%2d: %24h", t, temp16b2);
  end

//////////////////////////////////////////////






///// Core 0 Qmem writing  /////

$display("##### Core 0 Qmem writing  #####");
  for (q=0; q<total_cycle; q=q+1) begin

    #0.5 clk = 1'b0;  
    qmem_wr = 1;  if (q>0) qkmem_add = qkmem_add + 1; 

    //Write q data to core 0
    
    mem_in1[1*bw-1:0*bw] = Q[q][0];
    mem_in1[2*bw-1:1*bw] = Q[q][1];
    mem_in1[3*bw-1:2*bw] = Q[q][2];
    mem_in1[4*bw-1:3*bw] = Q[q][3];
    mem_in1[5*bw-1:4*bw] = Q[q][4];
    mem_in1[6*bw-1:5*bw] = Q[q][5];
    mem_in1[7*bw-1:6*bw] = Q[q][6];
    mem_in1[8*bw-1:7*bw] = Q[q][7];
    mem_in1[9*bw-1:8*bw] = Q[q][8];
    mem_in1[10*bw-1:9*bw] = Q[q][9];
    mem_in1[11*bw-1:10*bw] = Q[q][10];
    mem_in1[12*bw-1:11*bw] = Q[q][11];
    mem_in1[13*bw-1:12*bw] = Q[q][12];
    mem_in1[14*bw-1:13*bw] = Q[q][13];
    mem_in1[15*bw-1:14*bw] = Q[q][14];
    mem_in1[16*bw-1:15*bw] = Q[q][15];

    #0.5 clk = 1'b1;  

  end


  #0.5 clk = 1'b0;  
  qmem_wr = 0; 
  qkmem_add = 0;
  #0.5 clk = 1'b1;  
///////////////////////////////////////////

///// Core 1 Qmem writing  /////
$display("##### Core 1 Qmem writing  #####");

  for (q=0; q<total_cycle; q=q+1) begin

    #0.5 clk = 1'b0;  
    qmem_wr2 = 1;  if (q>0) qkmem_add2 = qkmem_add2 + 1; 

    mem_in2[1*bw-1:0*bw] = Q[q][0];
    mem_in2[2*bw-1:1*bw] = Q[q][1];
    mem_in2[3*bw-1:2*bw] = Q[q][2];
    mem_in2[4*bw-1:3*bw] = Q[q][3];
    mem_in2[5*bw-1:4*bw] = Q[q][4];
    mem_in2[6*bw-1:5*bw] = Q[q][5];
    mem_in2[7*bw-1:6*bw] = Q[q][6];
    mem_in2[8*bw-1:7*bw] = Q[q][7];
    mem_in2[9*bw-1:8*bw] = Q[q][8];
    mem_in2[10*bw-1:9*bw] = Q[q][9];
    mem_in2[11*bw-1:10*bw] = Q[q][10];
    mem_in2[12*bw-1:11*bw] = Q[q][11];
    mem_in2[13*bw-1:12*bw] = Q[q][12];
    mem_in2[14*bw-1:13*bw] = Q[q][13];
    mem_in2[15*bw-1:14*bw] = Q[q][14];
    mem_in2[16*bw-1:15*bw] = Q[q][15];

    #0.5 clk = 1'b1;  

  end


  #0.5 clk = 1'b0;  
  qmem_wr2 = 0; 
  qkmem_add2 = 0;
  #0.5 clk = 1'b1;  
///////////////////////////////////////////



///// Core 0 Kmem writing  /////
$display("##### Core 0 Kmem writing #####");

  for (q=0; q<col; q=q+1) begin

    #0.5 clk = 1'b0;  
    kmem_wr = 1; if (q>0) qkmem_add = qkmem_add + 1; 
    
    mem_in1[1*bw-1:0*bw] = K0[q][0];
    mem_in1[2*bw-1:1*bw] = K0[q][1];
    mem_in1[3*bw-1:2*bw] = K0[q][2];
    mem_in1[4*bw-1:3*bw] = K0[q][3];
    mem_in1[5*bw-1:4*bw] = K0[q][4];
    mem_in1[6*bw-1:5*bw] = K0[q][5];
    mem_in1[7*bw-1:6*bw] = K0[q][6];
    mem_in1[8*bw-1:7*bw] = K0[q][7];
    mem_in1[9*bw-1:8*bw] = K0[q][8];
    mem_in1[10*bw-1:9*bw] = K0[q][9];
    mem_in1[11*bw-1:10*bw] = K0[q][10];
    mem_in1[12*bw-1:11*bw] = K0[q][11];
    mem_in1[13*bw-1:12*bw] = K0[q][12];
    mem_in1[14*bw-1:13*bw] = K0[q][13];
    mem_in1[15*bw-1:14*bw] = K0[q][14];
    mem_in1[16*bw-1:15*bw] = K0[q][15];

    #0.5 clk = 1'b1;  

  end

  #0.5 clk = 1'b0;  
  kmem_wr = 0;  
  qkmem_add = 0;
  #0.5 clk = 1'b1;  
///////////////////////////////////////////

///// Core 1 Kmem writing  /////
$display("##### Core 1 Kmem writing #####");

  for (q=0; q<col; q=q+1) begin

    #0.5 clk = 1'b0;  
    kmem_wr2 = 1; if (q>0) qkmem_add2 = qkmem_add2 + 1; 
    
    mem_in2[1*bw-1:0*bw] = K1[q][0];
    mem_in2[2*bw-1:1*bw] = K1[q][1];
    mem_in2[3*bw-1:2*bw] = K1[q][2];
    mem_in2[4*bw-1:3*bw] = K1[q][3];
    mem_in2[5*bw-1:4*bw] = K1[q][4];
    mem_in2[6*bw-1:5*bw] = K1[q][5];
    mem_in2[7*bw-1:6*bw] = K1[q][6];
    mem_in2[8*bw-1:7*bw] = K1[q][7];
    mem_in2[9*bw-1:8*bw] = K1[q][8];
    mem_in2[10*bw-1:9*bw] = K1[q][9];
    mem_in2[11*bw-1:10*bw] = K1[q][10];
    mem_in2[12*bw-1:11*bw] = K1[q][11];
    mem_in2[13*bw-1:12*bw] = K1[q][12];
    mem_in2[14*bw-1:13*bw] = K1[q][13];
    mem_in2[15*bw-1:14*bw] = K1[q][14];
    mem_in2[16*bw-1:15*bw] = K1[q][15];

    #0.5 clk = 1'b1;  

  end

  #0.5 clk = 1'b0;  
  kmem_wr2 = 0;  
  qkmem_add2 = 0;
  #0.5 clk = 1'b1;  
///////////////////////////////////////////

  for (q=0; q<2; q=q+1) begin
    #0.5 clk = 1'b0;  
    #0.5 clk = 1'b1;   
  end




/////  K data loading  /////
$display("##### K data loading to processor #####");

  for (q=0; q<col+1; q=q+1) begin
    #0.5 clk = 1'b0;  
    load = 1; 
    if (q==1) kmem_rd = 1;
    if (q>1) begin
       qkmem_add = qkmem_add + 1;
       qkmem_add2 = qkmem_add2 + 1;
    end

    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;  
  kmem_rd = 0; qkmem_add = 0; qkmem_add2 = 0;
  #0.5 clk = 1'b1;  

  #0.5 clk = 1'b0;  
  load = 0; 
  #0.5 clk = 1'b1;  

///////////////////////////////////////////

 for (q=0; q<10; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
 end





///// execution  /////
$display("##### execute #####");

  for (q=0; q<total_cycle; q=q+1) begin
    #0.5 clk = 1'b0;  
    execute = 1; 
    qmem_rd = 1;

    if (q>0) begin
       qkmem_add = qkmem_add + 1;
       qkmem_add2 = qkmem_add2 + 1;
    end

    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;  
  qmem_rd = 0; qkmem_add = 0; qkmem_add2 = 0; execute = 0;
  #0.5 clk = 1'b1;  


///////////////////////////////////////////

 for (q=0; q<10; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
 end




////////////// output fifo rd and wb to psum mem ///////////////////

$display("##### move ofifo to pmem #####");

  for (q=0; q<total_cycle; q=q+1) begin
    #0.5 clk = 1'b0;  
    ofifo_rd = 1; 
    pmem_wr = 1; 

    if (q>0) begin
       pmem_add = pmem_add + 1;
    end

    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;  
  pmem_wr = 0; pmem_add = 0; ofifo_rd = 0;
  #0.5 clk = 1'b1;  

///////////////////////////////////////////

#0.5 clk = 1'b0;
//////Test cases for sfp///////
for (t=0; t<total_cycle; t=t+1) begin
  this_sum[t] = 0;
  this_sum2[t] = 0;
  for (q=0; q<col; q=q+1) begin
    if (result[t][q]>0) begin
        abs_temp = result[t][q];
    end else begin
        abs_temp = -result[t][q];
    end
    this_sum[t]= this_sum[t] + abs_temp;
    if (result2[t][q]>0) begin
        abs_temp = result2[t][q];
    end else begin
        abs_temp = -result2[t][q];
    end
    this_sum2[t]= this_sum2[t] + abs_temp;
  end
  this_sum[t] = this_sum[t]>>7;
  this_sum2[t] = this_sum2[t]>>7;
  for (q=0; q<col; q=q+1) begin
    sfp_result[t][q] = result[t][q]/(this_sum[t] + this_sum2[t]);
    sfp_result2[t][q] = result2[t][q]/(this_sum[t] + this_sum2[t]);
  end
  for (q=0; q<col; q=q+1) begin
    temp5b = sfp_result[t][q];
    temp5b2 = sfp_result2[t][q];
    temp16b = {temp16b[139:0],temp5b};
    temp16b2 = {temp16b2[139:0],temp5b2};
  end
  $display("prd sfp_out of core 0 @cycle%2d: %24h", t, temp16b);
  $display("prd sfp_out of core 1 @cycle%2d: %24h", t, temp16b2);
end  
for(t=0; t<total_cycle; t=t+1)begin  
  pmem_rd = 1;// start loading data from pmem to sfp, current pmem address = 0
  div_ready = 0;
  #0.5 clk = 1'b1;
  #0.5 clk = 1'b0;
  acc_ready=1;
  #0.5 clk = 1'b1; //acc: 0 -> 1, sfp_in -> sum_q
  #0.5 clk = 1'b0; 
  #0.5 clk = 1'b1;
  #0.5 clk = 1'b0; // sum_q -> sum_out
  acc_ready = 0; div_ready = 1;
  #0.5 clk = 1'b1; //div_q 0 -> 1; sum_q -> sum_this_core, sum_2core = sum_this_core + sum_in
  #0.5 clk = 1'b0;
  #0.5 clk = 1'b1; // norm_x = x/sum_2core
  #0.5 clk = 1'b0;
  $display("sfp out core 0 of cycle%2d: %24h", t, out1);
  $display("sfp out core 1 of cycle%2d: %24h", t, out2);
  pmem_add = pmem_add + 1;
end
pmem_rd = 0; div_ready=1;
#0.5 clk = 1'b1; //div_q 0 -> 1; sum_q -> sum_this_core, sum_2core = sum_this_core + sum_in
#0.5 clk = 1'b0;  
#0.5 clk = 1'b1; // norm_x = x/sum_2core
#0.5 clk = 1'b0;
pmem_add = 0;
////////////

  #10 $finish;


end

endmodule




