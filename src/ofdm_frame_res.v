`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.02.2021 13:34:36
// Design Name: 
// Module Name: ofdm_frame_res
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


module ofdm_frame_res #(parameter DATA_SIZE = 16
                        )(
    clk,
    en,
    reset,
    valid,
    in_data_i,
    in_data_q,
    o_flag_wayt_data,
    find_preamble_a,
    find_preamble_b
    );
    
    input clk;
    input en;
    input reset;
    input valid;
    input [DATA_SIZE-1:0] in_data_i;
    input [DATA_SIZE-1:0] in_data_q;
    
    output o_flag_wayt_data;
    
    output find_preamble_a;
    output find_preamble_b;
    
    
    wire signed [DATA_SIZE+7:0] out_preamble_a_i;
    wire signed [DATA_SIZE+7:0] out_preamble_a_q;
    
    wire signed [DATA_SIZE+7:0] out_preamble_b_i;
    wire signed [DATA_SIZE+7:0] out_preamble_b_q;
    
    
    ofdm_find_preamble #(.DATA_SIZE(DATA_SIZE),
            .PREAMBLE_MEM_I(256'b0111011000000011111111100000011111111100000011100100100110011111001101100110010011000000001111110000001100011000111111100001001100000110001100000001100110011001111110111001111001110110001000110010001110011100011001110111100000111001111000000111000000111000),
            .PREAMBLE_MEM_Q(256'b0001110010001111111000101110001110010001100010011110001100100001111111111001111000010000111100110011111011000100110011111110000011111001100110010011000001000111100011111111111000000000110000111000111001110011000111011001110000001000011001001110100011100111))
    _ofdm_find_preamble(
        .clk(clk),
        .en(valid & en),
        .in_data_i(in_data_i),
        .in_data_q(in_data_q),
        .find(find_preamble_a),
        .out_data_i(out_preamble_a_i),
        .out_data_q(out_preamble_a_q),
        .outPorog()
    );
    
    ofdm_find_preamble #(.DATA_SIZE(DATA_SIZE),
            .PREAMBLE_MEM_I(256'b1001100110000100001001100111000010000110010011110101111100000010010011110111111001110010001110001100100110010000000000100111000011001101111100010010010000110111100110011100011111110011111001000111110000011111100100001101111001011011000011111101000000110110),
            .PREAMBLE_MEM_Q(256'b1000011000101100111001001100011011000111111000110110110010110011011111001111001100000111001001011000011000011111110000110001111111000000011100001100100001000000001100111101101100111010011011001000011010111110000111101110000000100011011011010011110100110011))
    _ofdm_find_preambleB(
        .clk(clk),
        .en(valid & en),
        .in_data_i(in_data_i),
        .in_data_q(in_data_q),
        .find(find_preamble_b),
        .out_data_i(out_preamble_b_i),
        .out_data_q(out_preamble_b_q),
        .outPorog()
    );
    
    
endmodule
