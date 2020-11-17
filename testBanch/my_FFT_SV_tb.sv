`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.10.2020 15:21:02
// Design Name: 
// Module Name: my_FFT_SV_tb
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


module my_FFT_SV_tb();

parameter sizeDataMas = 2;
parameter NFFT = 1 << sizeDataMas;

reg clk = 0;
reg [15:0] data_i [NFFT-1:0];
reg [15:0] data_q [NFFT-1:0];
//reg [15:0] data_i_1;
//reg [15:0] data_q_1;
wire [15:0] res_data_i [NFFT-1:0];
wire [15:0] res_data_q [NFFT-1:0];
//wire [15:0] res_data_i_1;
//wire [15:0] res_data_q_1; 
wire complete;
wire [2:0] stateFFT;

    initial
    begin
        data_i = {{-9}, {15}, {77}, {12}};
        data_q = {{5}, {8}, {78}, {47}};
//        data_i[0] = 12;
//        data_q[0] = 47;
//        data_i[1] = 77;
//        data_q[1] = 78;
//        data_i[2] = 15;
//        data_q[2] = 8;
//        data_i[3] = -9;
//        data_q[3] = 5;
        
    end
    
    always
        #5 clk = !clk;
        
//    myFFT_SV#
//        (.NFFT(1 << sizeDataMas),
//        .SIZE_BUFFER(sizeDataMas)/*log2(NFFT)*/
//        )
//        _tetsFFT
//        (
//        .clk(clk),
//        .valid(1'b1),
//        .clk_i_data(clk),
//        .data_in_i(data_i),
//        .data_in_q(data_q),
//        .clk_o_data(),
//        .data_out_i(res_data_i),
//        .data_out_q(res_data_q),
//        .complete(complete),
//        .stateFFT(stateFFT)
//        );
        
    myFFT_SV_x4
    _tetsFFT
        (
        .clk(clk),
        .valid(1'b1),
        .clk_i_data(clk),
        .data_in_i(data_i),
        .data_in_q(data_q),
        .clk_o_data(),
        .data_out_i(res_data_i),
        .data_out_q(res_data_q),
        .complete(complete),
        .stateFFT(stateFFT)
        );

endmodule
