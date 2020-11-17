`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.10.2020 15:09:15
// Design Name: 
// Module Name: myFFT_SV
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


module myFFT_SV#
    (parameter NFFT = 2,
    parameter SIZE_BUFFER = 1/*log2(NFFT)*/
    )
    (
    clk,
    valid,
    clk_i_data,
    data_in_i,
    data_in_q,
    clk_o_data,
    data_out_i,
    data_out_q,
    complete,
    stateFFT
    );
    
`include "common.vh"

localparam DATA_FFT_SIZE_SV=16;
    
    input clk;
    input valid;//flag data is valid
    input clk_i_data;
    input [DATA_FFT_SIZE_SV-1:0] data_in_i [NFFT-1 :0];
    input [DATA_FFT_SIZE_SV-1:0] data_in_q [NFFT-1 :0];
    output clk_o_data;
    output [DATA_FFT_SIZE_SV-1:0] data_out_i [NFFT-1:0];
    output [DATA_FFT_SIZE_SV-1:0] data_out_q [NFFT-1:0];
    output reg complete;
    output [2:0] stateFFT;
    
    assign clk_o_data = clk;//NOTE возможно потребуеться давать клок только когда данные отправляюьбся
    
    //TODO размеры массивов
    //reg [SIZE_BUFFER+1:0] counter;
//    reg [SIZE_BUFFER+1:0] counterSendData;
    reg [2:0] state;
    
//    reg [DATA_FFT_SIZE_SV-1:0] data_out_mas_i [SIZE_BUFFER:0];
//    reg [DATA_FFT_SIZE_SV-1:0] data_out_mas_q [SIZE_BUFFER:0];
    
    
    assign stateFFT = state;
    
//    parameter stateWaytData = 3'b000;
//    parameter stateWriteData = 3'b001;
//    parameter stateWaytFFT = 3'b010;
    
////    parameter stateSummFFT = 4'b100;
//    parameter stateSummFFT = 4'b100;
//    parameter stateComplete = 4'b111;
    
    initial
    begin
//        counter = 0;
        complete = 0;
//        counterSendData = 0;
//        state = stateWaytData;
//        data_for_secondFFT_chet_i = 0;
//        data_for_secondFFT_chet_q = 0;
//        data_for_secondFFT_Nchet_i = 0;
//        data_for_secondFFT_Nchet_q = 0;
    end
    
//    wire [DATA_FFT_SIZE_SV-1:0] wire_data_i [SIZE_BUFFER-1 : 0];
//    wire [DATA_FFT_SIZE_SV-1:0] wire_data_q [SIZE_BUFFER-1 : 0];
    
    
    
    
    genvar i;
    generate
    for(i = 0; i < (SIZE_BUFFER); i++)
    begin
    
       myFFT_x2
       _myFFT_x2
       (
        .clk(clk),
        .valid(valid),
        .in_data_i_0(data_in_i[i]),
        .in_data_q_0(data_in_q[i]),
        .in_data_i_1(data_in_i[i + NFFT/2]),
        .in_data_q_1(data_in_q[i + NFFT/2]),
        .out_data_i_0(data_out_i[i]),
        .out_data_q_0(data_out_q[i]),
        .out_data_i_1(data_out_i[i + NFFT/2]),
        .out_data_q_1(data_out_q[i + NFFT/2]),
        .complete()
        );
        
        
    end
    endgenerate
    
    
    
//    genvar j;
//    genvar k;
//    generate
//    for(j = 0; j < (SIZE_BUFFER); j++)
//    begin
//        for(k = 0; k < NFFT/(j+1); k++)
//        begin
            
//        end  
//    end  
//    endgenerate

    
    //recursi
//    wire flag_complete_chet;
//    wire flag_complete_Nchet;
    
    /*wire [DATA_FFT_SIZE_SV-1:0] wire_data_i_chet [SIZE_BUFFER-1 : 0];
    wire [DATA_FFT_SIZE_SV-1:0] wire_data_q_chet [SIZE_BUFFER-1 : 0];
    wire [DATA_FFT_SIZE_SV-1:0] wire_data_i_Nchet [SIZE_BUFFER-1 : 0];
    wire [DATA_FFT_SIZE_SV-1:0] wire_data_q_Nchet [SIZE_BUFFER-1 : 0];

    wire [DATA_FFT_SIZE_SV-1:0] data_from_secondFFT_chet_i [SIZE_BUFFER-1 : 0];
    wire [DATA_FFT_SIZE_SV-1:0] data_from_secondFFT_chet_q [SIZE_BUFFER-1 : 0];
    wire [DATA_FFT_SIZE_SV-1:0] data_from_secondFFT_Nchet_i [SIZE_BUFFER-1 : 0];
    wire [DATA_FFT_SIZE_SV-1:0] data_from_secondFFT_Nchet_q [SIZE_BUFFER-1 : 0];*/
    
//    generate
    
//    endgenerate
    /*for(int i = 0; i < SIZE_BUFFER-1; i++)
    begin
        assign wire_data_i_chet[i] = data_in_i[i*2];
        assign wire_data_q_chet[i] = data_in_q[i*2];
        
        assign wire_data_i_Nchet[i] = data_in_i[i*2+1];
        assign wire_data_q_Nchet[i] = data_in_q[i*2+1];
    end*/
    


    
    
//    always @(negedge clk)//flag complete
//    begin
//        if(state == stateComplete)  complete <= 1'b1;
//        else                        complete <= 1'b0;
//    end
    
    
endmodule
