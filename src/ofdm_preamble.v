`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.12.2020 16:40:06
// Design Name: 
// Module Name: ofdm_preamble
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


module ofdm_preamble #(parameter FILE_DATA_I = "", parameter FILE_DATA_Q = "")(
        clk,
        addr,
        en,
        dout_i,
        dout_q 
    );

    input clk;
    input      [7:0]  addr;
    input en;
    output reg [15:0] dout_i;
    output reg [15:0] dout_q;
    
    reg [15:0] mem_i [255:0];
    reg [15:0] mem_q [255:0];
    
    initial
    begin
        $readmemh(FILE_DATA_I, mem_i);
        $readmemh(FILE_DATA_Q, mem_q);
    end
    
    always @(posedge clk)
    begin
        if(en)  dout_i <= mem_i[addr];
        if(en)  dout_q <= mem_q[addr];
    end

endmodule
