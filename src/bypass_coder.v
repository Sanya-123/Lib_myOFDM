`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.11.2020 14:07:25
// Design Name: 
// Module Name: bypass_coder
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


module bypass_coder(
    input clk,
    input [7:0] in_data,
    output [7:0] out_data
    );
    
    assign out_data = in_data;
    
endmodule
