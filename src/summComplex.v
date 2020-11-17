`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.10.2020 18:27:12
// Design Name: 
// Module Name: summComplex
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

//TODO добавить размерность данных
module summComplex(
    clk,
    en,
    data_in0_i,
    data_in0_q,
    data_in1_i,
    data_in1_q,
    data_out0_i,
    data_out0_q
    );
    
`include "common.vh"

    input clk;
    input en;
    //DATA_FFT_SIZE = 16
    input [16-1:0] data_in0_i;
    input [16-1:0] data_in0_q;
    input [16-1:0] data_in1_i;
    input [16-1:0] data_in1_q;
    output reg [16-1:0] data_out0_i;
    output reg [16-1:0] data_out0_q;
    
    always @(posedge clk)
    begin
        if(en)  data_out0_i <= data_in0_i + data_in1_i;
//        else    data_out0_i <= 0;
        if(en)  data_out0_q <= data_in0_q + data_in1_q;
//        else    data_out0_q <= 0;
    end
    
endmodule
