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
module summComplex #(parameter DATA_FFT_SIZE = 16)(
    clk,
    en,
    data_in0_i,
    data_in0_q,
    data_in1_i,
    data_in1_q,
    data_out0_i,
    data_out0_q
    );

    input clk;
    input en;
    //DATA_FFT_SIZE = 16
    input [DATA_FFT_SIZE-1:0] data_in0_i;
    input [DATA_FFT_SIZE-1:0] data_in0_q;
    input [DATA_FFT_SIZE-1:0] data_in1_i;
    input [DATA_FFT_SIZE-1:0] data_in1_q;
    output reg [DATA_FFT_SIZE-1:0] data_out0_i;
    output reg [DATA_FFT_SIZE-1:0] data_out0_q;
    
    always @(posedge clk)
    begin
        if(en)  data_out0_i <= data_in0_i + data_in1_i;
//        else    data_out0_i <= 0;
        if(en)  data_out0_q <= data_in0_q + data_in1_q;
//        else    data_out0_q <= 0;
    end

//    output [DATA_FFT_SIZE-1:0] data_out0_i;
//    output [DATA_FFT_SIZE-1:0] data_out0_q;
    
//    assign data_out0_i = data_in0_i + data_in1_i;
//    assign data_out0_q = data_in0_q + data_in1_q;
    
endmodule
