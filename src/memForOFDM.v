`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.11.2020 14:53:09
// Design Name: 
// Module Name: memForOFDM
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


module memForOFDM #(parameter MAX_SYMBOLS_FFT = 64)(
    clk,
    write_en,
    addres_write,
    addres_read,
    write_data_i,
    write_data_q,
    read_data_i,
    read_data_q
    );
    
    input clk;
    input write_en;
    input [15:0] addres_write;
    input [15:0] addres_read;
    input [15:0] write_data_i;
    input [15:0] write_data_q;
    output reg [15:0] read_data_i;
    output reg [15:0] read_data_q;
    
    reg [15:0] reg_data_i [160+160+64*MAX_SYMBOLS_FFT - 1:0];
    reg [15:0] reg_data_q [160+160+64*MAX_SYMBOLS_FFT - 1:0];
    
    always @(posedge clk)
    begin
        if(write_en)
            reg_data_i[addres_write] <= write_data_i;
            
        if(write_en)
            reg_data_q[addres_write] <= write_data_q;
            
        read_data_i <= reg_data_i[addres_read];
        read_data_q <= reg_data_q[addres_read];
    end
    
    
endmodule
