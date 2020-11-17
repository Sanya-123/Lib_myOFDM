`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.11.2020 14:02:01
// Design Name: 
// Module Name: test_viterbi_coder
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


module test_viterbi_coder();

reg clk = 1'b0;
reg [3:0] inData;
wire [7:0] outData;

always
    #5 clk = !clk;
    
    initial
    begin
        inData <= 4'b0101;
        #10
        inData <= 4'b1100;
        #10
        inData <= 4'b1011;
        #10
        inData <= 4'b0000;
        #10
        inData <= 4'b1111;
    end

viterbi_coder
    _viterbi(
    .clk(clk),
    .en(1),
    .reset(0),
    .in_data(inData),
    .out_data(outData)
    );
    
    
endmodule
