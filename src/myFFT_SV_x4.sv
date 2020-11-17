`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.10.2020 18:15:29
// Design Name: 
// Module Name: myFFT_SV_x4
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


module myFFT_SV_x4    
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

localparam DATA_FFT_SIZE_SV_x4=16;
    
    input clk;
    input valid;//flag data is valid
    input clk_i_data;
    input [DATA_FFT_SIZE_SV_x4-1:0] data_in_i [3 :0];
    input [DATA_FFT_SIZE_SV_x4-1:0] data_in_q [3 :0];
    output clk_o_data;
    output reg [DATA_FFT_SIZE_SV_x4-1:0] data_out_i [3:0];
    output reg [DATA_FFT_SIZE_SV_x4-1:0] data_out_q [3:0];
    output reg complete;
    output [2:0] stateFFT;
    
    wire [DATA_FFT_SIZE_SV_x4-1:0] data_out_tmp_i [3:0];
    wire [DATA_FFT_SIZE_SV_x4-1:0] data_out_tmp_q [3:0];
    
    assign clk_o_data = clk;//NOTE возможно потребуеться давать клок только когда данные отправляюьбся
    
    parameter stateWaytData = 3'b000;
    parameter stateWriteData = 3'b001;
    parameter stateWaytFFT = 3'b010;
    
//    parameter stateSummFFT = 4'b100;
    parameter stateSummFFT = 4'b100;
    parameter stateComplete = 4'b111;
    
    reg [2:0] state = stateWaytData;
    
    myFFT_SV#
        (.NFFT(4),
         .SIZE_BUFFER(2)/*log2(NFFT)*/
        )
        _myFFT_SV
        (
        .clk(!clk),
        .valid(valid & (state == stateWaytData)),
        .clk_i_data(clk_i_data),
        .data_in_i(data_in_i),
        .data_in_q(data_in_q),
        .clk_o_data(),
        .data_out_i(data_out_tmp_i),
        .data_out_q(data_out_tmp_q),
        .complete(),
        .stateFFT()
        );
        
    always @(posedge clk)//summ
    begin
        if(valid & (state == stateWaytData)) state <= stateSummFFT;
        else if(state == stateSummFFT)
        begin
            //0
            data_out_i[0] <= data_out_tmp_i[0] + data_out_tmp_i[1];
            data_out_q[0] <= data_out_tmp_q[0] + data_out_tmp_q[1];
            
            //1
            data_out_i[1] <= data_out_tmp_i[2] + data_out_tmp_q[3];
            data_out_q[1] <= data_out_tmp_q[2] - data_out_tmp_i[3];
            
            //2            
            data_out_i[2] <= data_out_tmp_i[0] - data_out_tmp_i[1];
            data_out_q[2] <= data_out_tmp_q[0] - data_out_tmp_q[1];
            
            //3
            data_out_i[3] <= data_out_tmp_i[2] - data_out_tmp_q[3];
            data_out_q[3] <= data_out_tmp_q[2] + data_out_tmp_i[3];
                        
            state <= stateComplete;
        end
        else if(state == stateComplete) state <= stateWaytData;
    end
        
    always @(negedge clk)//flag complete
    begin
        if(state == stateComplete)  complete <= 1'b1;
        else                        complete <= 1'b0;
    end
        
        
endmodule
