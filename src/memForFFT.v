`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.10.2020 12:49:35
// Design Name: 
// Module Name: memForFFT
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
// double memory for my fft
//////////////////////////////////////////////////////////////////////////////////


module memForFFT #(parameter DATA_FFT_SIZE = 16,
                   parameter SIZE_BITS_ADDRES = 4 /*log2(size mem)*//*, parameter name="nonoe"*/)
    (
    clk,
    writeEn,
    readEn,
    addr,
    addr_r,
    inData,
    outData,
    writeEn2,
    readEn2,
    addr2,
    addr_r2,
    inData2,
    outData2
    );
    
    input clk;
    input writeEn;
    input readEn;
    input [SIZE_BITS_ADDRES-1:0] addr;
    input [SIZE_BITS_ADDRES-1:0] addr_r;
    input [DATA_FFT_SIZE-1:0] inData;
    output reg [DATA_FFT_SIZE-1:0] outData;
    
    input writeEn2;
    input readEn2;
    input [SIZE_BITS_ADDRES-1:0] addr2;
    input [SIZE_BITS_ADDRES-1:0] addr_r2;
    input [DATA_FFT_SIZE-1:0] inData2;
    output reg [DATA_FFT_SIZE-1:0] outData2;
    
    reg [DATA_FFT_SIZE-1:0] data [2**SIZE_BITS_ADDRES-1:0];
    reg [DATA_FFT_SIZE-1:0] data2 [2**SIZE_BITS_ADDRES-1:0];
    
    always @(posedge clk)
    begin
        if(readEn)  outData <= data[addr_r];//read
        if(writeEn) data[addr] <= inData;//write
        
        if(readEn2) outData2 <= data2[addr_r2];//read
        if(writeEn2) data2[addr2] <= inData2;//write
    end
    
endmodule
