`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.01.2021 14:38:40
// Design Name: 
// Module Name: fast_myFFT_x4
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


module fast_myFFT_x4 #( parameter SIZE_DATA = 16,
                        parameter TYPE = "forvard"/*forvard invers*/)(
        clk,
        valid,
        data0_in_i,
        data0_in_q,
        data1_in_i,
        data1_in_q,
        data2_in_i,
        data2_in_q,
        data3_in_i,
        data3_in_q,
        data0_out_i,
        data0_out_q,
        data1_out_i,
        data1_out_q,
        data2_out_i,
        data2_out_q,
        data3_out_i,
        data3_out_q,
        complete
    );
    
    input clk;
    input valid;
    input [SIZE_DATA-1:0] data0_in_i;
    input [SIZE_DATA-1:0] data0_in_q;
    input [SIZE_DATA-1:0] data1_in_i;
    input [SIZE_DATA-1:0] data1_in_q;
    input [SIZE_DATA-1:0] data2_in_i;
    input [SIZE_DATA-1:0] data2_in_q;
    input [SIZE_DATA-1:0] data3_in_i;
    input [SIZE_DATA-1:0] data3_in_q;
    output reg [SIZE_DATA-1:0] data0_out_i;
    output reg [SIZE_DATA-1:0] data0_out_q;
    output reg [SIZE_DATA-1:0] data1_out_i;
    output reg [SIZE_DATA-1:0] data1_out_q;
    output reg [SIZE_DATA-1:0] data2_out_i;
    output reg [SIZE_DATA-1:0] data2_out_q;
    output reg [SIZE_DATA-1:0] data3_out_i;
    output reg [SIZE_DATA-1:0] data3_out_q;
    output reg complete = 1'b0;
    
    always @(posedge clk)   complete <= valid;
    
    
    always @(posedge clk)
    begin
        if(valid)
        begin
            data0_out_i <= data0_in_i + data1_in_i + data2_in_i + data3_in_i;
            data0_out_q <= data0_in_q + data1_in_q + data2_in_q + data3_in_q;
            
            data2_out_i <= data0_in_i - data1_in_i + data2_in_i - data3_in_i;
            data2_out_q <= data0_in_q - data1_in_q + data2_in_q - data3_in_q;
        end
    end
    
    generate
    if(TYPE == "forvard")
    begin
        always @(posedge clk)
        begin
            if(valid)
            begin
                data1_out_i <= data0_in_i + data1_in_q - data2_in_i - data3_in_q;
                data1_out_q <= data0_in_q - data1_in_i - data2_in_q + data3_in_i;
                
                data3_out_i <= data0_in_i - data1_in_q - data2_in_i + data3_in_q;
                data3_out_q <= data0_in_q + data1_in_i - data2_in_q - data3_in_i;
            end
        end  
    end
    else
    begin
        always @(posedge clk)
        begin
            if(valid)
            begin
                data3_out_i <= data0_in_i + data1_in_q - data2_in_i - data3_in_q;
                data3_out_q <= data0_in_q - data1_in_i - data2_in_q + data3_in_i;
                
                data1_out_i <= data0_in_i - data1_in_q - data2_in_i + data3_in_q;
                data1_out_q <= data0_in_q + data1_in_i - data2_in_q - data3_in_i;
            end
        end
    end
    endgenerate
        
endmodule
