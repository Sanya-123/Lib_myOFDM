`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.10.2020 13:23:34
// Design Name: 
// Module Name: memForFFT_tb
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


module memForFFT_tb();

    reg clk = 0;
    always
        #5 clk = !clk;
        
    reg writeEn = 1'b0;
    reg addr;
    reg addr_r;
    reg [15:0] inData;
    wire [15:0] outData;
    
    initial
    begin
        addr <= 0;
        inData <= 16'h2556;
        writeEn <= 1'b1;
        #10
        addr <= 1;
        inData <= 16'h8899;
        writeEn <= 1'b1;
        #10
        writeEn <= 1'b0;
        #50
        addr_r <= 0;
        #10
        addr_r <= 1;
    end        
        
    memForFFT #(.DATA_FFT_SIZE(16),
                .SIZE_BITS_ADDRES(1) )
    mem(
    .clk(clk),
    .writeEn(writeEn),
    .addr(addr),
    .addr_r(addr_r),
    .inData(inData),
    .outData(outData),
    .writeEn2(),
    .addr2(),
    .addr_r2(),
    .inData2(),
    .outData2()
    );
        
   
endmodule
