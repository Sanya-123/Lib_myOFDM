`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.10.2020 17:09:34
// Design Name: 
// Module Name: myFFT_x2
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


module myFFT_x2(
    clk,
    valid,
    in_data_i_0,
    in_data_q_0,
    in_data_i_1,
    in_data_q_1,
    out_data_i_0,
    out_data_q_0,
    out_data_i_1,
    out_data_q_1,
    complete
    );
    
    input clk;
    input valid;
    input [15:0] in_data_i_0;
    input [15:0] in_data_q_0;
    input [15:0] in_data_i_1;
    input [15:0] in_data_q_1;
    input [15:0] out_data_i_0;
    input [15:0] out_data_q_0;
    output [15:0] out_data_i_1;
    output [15:0] out_data_q_1;
    output reg complete;
    
    wire [15:0] x_i;
    wire [15:0] x_q;
    
    assign x_i = -in_data_i_1;
    assign x_q = -in_data_q_1;
    
    summComplex _summ0(
        .clk(clk),
        .en(valid),
        .data_in0_i(in_data_i_0),
        .data_in0_q(in_data_q_0),
        .data_in1_i(in_data_i_1),
        .data_in1_q(in_data_q_1),
        .data_out0_i(out_data_i_0),
        .data_out0_q(out_data_q_0)
    );
    summComplex _summ1(
        .clk(clk),
        .en(valid),
        .data_in0_i(in_data_i_0),
        .data_in0_q(in_data_q_0),
        .data_in1_i(x_i),
        .data_in1_q(x_q),
        .data_out0_i(out_data_i_1),
        .data_out0_q(out_data_q_1)
    );
    
    parameter stateWaytData = 3'b000;
    parameter stateComplete = 4'b111;
    
    reg [2:0] state = stateWaytData;
    
    always @(posedge clk)
    begin
        //машина конечных состоояние по состоянию данных
        if(state == stateWaytData)
        begin
            if(valid) state <= stateComplete;
        end
        else if(state == stateComplete)
        begin
            state <= stateWaytData;
        end
    end
    
    always @(negedge clk)//flag complete
    begin
        if(state == stateComplete)  complete <= 1'b1;
        else                        complete <= 1'b0;
    end
    
endmodule
