`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2021 13:22:16
// Design Name: 
// Module Name: OFDM_FCH_gen
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


module ofdm_fch_gen#(parameter DATA_SIZE = 16)(
    i_clk,
    i_reset,
    i_wayt_output_data,
    i_data_frame_size,
    i_fch_frame,
    //....
    o_data_i,
    o_data_q,
    o_valid,
    o_fch_counter
    );
    
    input i_clk;
    input i_reset;
    input i_wayt_output_data;
    input i_fch_frame;
    input [7:0] i_data_frame_size;
    
    output [DATA_SIZE-1:0] o_data_i;
    output [DATA_SIZE-1:0] o_data_q;
    output o_valid;
    output [15:0] o_fch_counter;
    
    reg [15:0] counter_FCH = 0;
    
    assign o_data_i = 0;
    assign o_data_q = 0;
    assign o_valid = i_fch_frame;
    assign o_fch_counter = counter_FCH;
    
    always @(posedge i_clk)
    begin
        if(i_reset)
        begin
            counter_FCH <= 0;
        end
        else
        begin
            if(!i_fch_frame)        counter_FCH <= 0;
            else
            begin
                if(i_wayt_output_data)  counter_FCH <= counter_FCH + 1;
            
            end
            //generete modulate FCH daca
        end
    end
    
    
endmodule
