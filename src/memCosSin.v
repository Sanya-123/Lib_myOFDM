`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.11.2020 17:02:43
// Design Name: 
// Module Name: memCosSin
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


module memCosSin #(parameter SIZE_DATA_FI = 2 /*log2(NFFT)*/)
    (
    clk,
    addr,
    cos,
    sin
    );
    
    input clk;
    input [SIZE_DATA_FI-2:0] addr;
    output reg [16-1:0] cos;
    output reg [16-1:0] sin;
    
    //mem
    reg [15:0] mem_cos [2**(SIZE_DATA_FI)/2-1:0];
    reg [15:0] mem_sin [2**(SIZE_DATA_FI)/2-1:0];
    
    always @(posedge clk)
    begin
        cos <= mem_cos[addr];
        sin <= mem_sin[addr];
    end
        
    initial
    begin
        if(SIZE_DATA_FI == 2)//4dot
        begin
            mem_cos[0] = 16'd32767;
            mem_sin[0] = 16'd0;
            
            mem_cos[1] = 16'd0;
            mem_sin[1] = -16'd32767;
        end
        else if(SIZE_DATA_FI == 3)//8dot
        begin
            mem_cos[0] = 16'd32767;
            mem_sin[0] = 16'd0;
            
            mem_cos[1] = 16'd23170;
            mem_sin[1] = -16'd23170;
            
            mem_cos[2] = 16'd0;
            mem_sin[2] = -16'd32767;
            
            mem_cos[3] = -16'd23170;
            mem_sin[3] = -16'd23170;
        end
        else if(SIZE_DATA_FI == 4)//16dot
        begin
            mem_cos[0] = 16'd32767;
            mem_sin[0] = 16'd0;
            
            mem_cos[1] = 16'd30273;
            mem_sin[1] = -16'd12539;
            
            mem_cos[2] = 16'd23170;
            mem_sin[2] = -16'd23170;
            
            mem_cos[3] = 16'd12539;
            mem_sin[3] = -16'd30273;
            
            mem_cos[4] = 16'd0;
            mem_sin[4] = -16'd32767;
            
            mem_cos[5] = -16'd12539;
            mem_sin[5] = -16'd30273;
            
            mem_cos[6] = -16'd23170;
            mem_sin[6] = -16'd23170;
            
            mem_cos[7] = -16'd30273;
            mem_sin[7] = -16'd12539;
        end
    end
    
    
    
endmodule
