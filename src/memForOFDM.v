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


module memForOFDM #(parameter MEMORY_SYZE = 16,
                    parameter DATA_SIZE = 16)(
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
    input [MEMORY_SYZE-1:0] addres_write;
    input [MEMORY_SYZE-1:0] addres_read;
    input [DATA_SIZE-1:0] write_data_i;
    input [DATA_SIZE-1:0] write_data_q;
    output reg [DATA_SIZE-1:0] read_data_i;
    output reg [DATA_SIZE-1:0] read_data_q;
    
    
    
    reg [DATA_SIZE-1:0] reg_data_i [2**MEMORY_SYZE - 1:0];
    reg [DATA_SIZE-1:0] reg_data_q [2**MEMORY_SYZE - 1:0];
    
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
