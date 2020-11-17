`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.11.2020 13:44:59
// Design Name: 
// Module Name: viterbi_coder
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


module viterbi_coder(
    clk,
    en,
    reset,
    in_data,
    out_data
    );
    
    input clk;
    input en;
    input reset;
    input [3:0] in_data;
    output reg [7:0] out_data;
    
    
    reg [2:0] viterbiReg = 3'b000;
    
    //out0 = 1^0^1
    //out1 = 1^1^1
    
    always @(posedge clk)
    begin
        if(reset)   viterbiReg <= 3'b000;
        else if(en)
        begin
            out_data[0] <= viterbiReg[1] ^ in_data[0];
            out_data[1] <= viterbiReg[1] ^ viterbiReg[0] ^ in_data[0];
            
            out_data[2] <= viterbiReg[0] ^ in_data[1];
            out_data[3] <= viterbiReg[0] ^ in_data[0] ^ in_data[1];
            
            out_data[4] <= in_data[0] ^ in_data[2];
            out_data[5] <= in_data[0] ^ in_data[1] ^ in_data[2];
            
            out_data[6] <= in_data[1] ^ in_data[3];
            out_data[7] <= in_data[1] ^ in_data[2] ^ in_data[3];
            
            viterbiReg <= in_data[3:1];
        end
    end
endmodule
