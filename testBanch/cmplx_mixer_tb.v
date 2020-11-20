`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.11.2020 11:40:25
// Design Name: 
// Module Name: cmplx_mixer_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cmplx_mixer_tb();

reg clk = 0;

wire oval;
wire [19:0] odat_re;
wire [19:0] odat_im;

reg [16:0] memCos [7:0];
reg [16:0] memSin [7:0];

reg [16:0] dataCos;
reg [16:0] dataSin;
reg valid = 1'b0;

initial
begin
    $readmemh("cos16.mem",memCos);
    $readmemh("sin16.mem",memSin);
end

always
    #10 clk = !clk;
    
integer i;
    
initial
begin
    for(i = 0; i < 8; i = i + 1)
    begin
        valid = 1'b1;
        dataCos = memCos[i];
        dataSin = memSin[i];
        #100
        valid = 1'b0;
        #100;
    end
end
    
    

cmplx_mixer
#(
  .pIDAT_W(17) ,
  .pDDS_W(17) ,
  .pODAT_W(20) ,
  .pMUL_W(0) ,
  .pCONJ(0) ,
  .pUSE_DSP_ADD(1) , // use altera dsp internal adder or not (differ registers)
  .pUSE_ROUND(0)
)
cmplx_mult(
  .iclk(clk)    ,
  .ireset(0)  ,
  .iclkena(1'b1) ,
  //
  .ival(valid)    ,
  .idat_re(740) ,
  .idat_im(740) ,
  //
  .icos(dataCos)    ,
  .isin(dataSin)    ,
  //
  .oval(oval),
  .odat_re(odat_re) ,
  .odat_im(odat_im)
);




endmodule
