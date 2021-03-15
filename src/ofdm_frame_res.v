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

`include "commonOFDM.vh"

module ofdm_frame_res #(parameter DATA_SIZE = 16
                        )(
    i_clk,
    i_en,
    i_reset,
    i_valid,
    in_data_i,
    in_data_q,
    o_flag_wayt_data,
    o_find_preamble_a,
    o_find_preamble_b,
    o_fft_valid,
    o_fft_data_i,
    o_fft_data_q
    
    ,
    d_in_fft_valid,
    d_in_fft_data_i,
    d_in_fft_data_q
    );
    
    input i_clk;
    input i_en;
    input i_reset;
    input i_valid;
    input [DATA_SIZE-1:0] in_data_i;
    input [DATA_SIZE-1:0] in_data_q;
    
    output o_flag_wayt_data;
    
    output o_find_preamble_a;
    output o_find_preamble_b;
    
    output o_fft_valid;
    output [DATA_SIZE-1:0 ] o_fft_data_i;
    output [DATA_SIZE-1:0 ] o_fft_data_q;
    
    output  d_in_fft_valid;
    output [DATA_SIZE-1:0 ] d_in_fft_data_i;
    output [DATA_SIZE-1:0 ] d_in_fft_data_q;
    
    
    wire signed [DATA_SIZE+7:0] out_preamble_a_i;
    wire signed [DATA_SIZE+7:0] out_preamble_a_q;
    
    wire signed [DATA_SIZE+7:0] out_preamble_b_i;
    wire signed [DATA_SIZE+7:0] out_preamble_b_q;
    
    
    wire [DATA_SIZE-1:0] in_data_fs_i;
    wire [DATA_SIZE-1:0] in_data_fs_q;
    wire frame_sync;
    wire data_fs_valid;
    
    
    wire walid_output_remove_cp;
    wire [DATA_SIZE-1:0 ] data_remove_cp_i;
    wire [DATA_SIZE-1:0 ] data_remove_cp_q;
    
    
    wire [DATA_SIZE+5:0 ] symbol_FFT_i;
    wire [DATA_SIZE+5:0 ] symbol_FFT_q;
    wire complete_fft;
    
    wire fft_flag_wayt_data;
    wire wayt_data_ofdm_payload_recive;
    
    assign o_fft_valid = complete_fft;
    assign o_fft_data_i = symbol_FFT_i[DATA_SIZE+5:6];
    assign o_fft_data_q = symbol_FFT_q[DATA_SIZE+5:6]; 
    
    assign d_in_fft_valid = walid_output_remove_cp;
    assign d_in_fft_data_i = data_remove_cp_i;
    assign d_in_fft_data_q = data_remove_cp_q;
    
    ofdm_find_preamble #(.DATA_SIZE(DATA_SIZE),
            .PREAMBLE_MEM_I(256'b0111011000000011111111100000011111111100000011100100100110011111001101100110010011000000001111110000001100011000111111100001001100000110001100000001100110011001111110111001111001110110001000110010001110011100011001110111100000111001111000000111000000111000),
            .PREAMBLE_MEM_Q(256'b0001110010001111111000101110001110010001100010011110001100100001111111111001111000010000111100110011111011000100110011111110000011111001100110010011000001000111100011111111111000000000110000111000111001110011000111011001110000001000011001001110100011100111))
    _ofdm_find_preambleA(
        .clk(i_clk),
        .en(i_valid & i_en),
        .in_data_i(in_data_i),
        .in_data_q(in_data_q),
        .find(o_find_preamble_a),
        .out_data_i(out_preamble_a_i),
        .out_data_q(out_preamble_a_q),
        .outPorog()
    );
    
    ofdm_find_preamble #(.DATA_SIZE(DATA_SIZE),
            .PREAMBLE_MEM_I(256'b1001100110000100001001100111000010000110010011110101111100000010010011110111111001110010001110001100100110010000000000100111000011001101111100010010010000110111100110011100011111110011111001000111110000011111100100001101111001011011000011111101000000110110),
            .PREAMBLE_MEM_Q(256'b1000011000101100111001001100011011000111111000110110110010110011011111001111001100000111001001011000011000011111110000110001111111000000011100001100100001000000001100111101101100111010011011001000011010111110000111101110000000100011011011010011110100110011))
    _ofdm_find_preambleB(
        .clk(i_clk),
        .en(i_valid & i_en),
        .in_data_i(in_data_i),
        .in_data_q(in_data_q),
        .find(o_find_preamble_b),
        .out_data_i(out_preamble_b_i),
        .out_data_q(out_preamble_b_q),
        .outPorog()
    );
    
//    ofdm_freq_sync#( .DATA_SIZE(DATA_SIZE)
//    )
//    _ofdm_freq_sync(
//        .i_clk(i_clk),
//        .i_en(i_en),
//        .i_reset(i_reset),
//        .i_valid(i_valid),
//        .in_data_i(in_data_i),
//        .in_data_q(in_data_q),
//        .out_data_i(in_data_fs_i),
//        .out_data_q(in_data_fs_q),
//        .i_findPreamble_a(o_find_preamble_a),
//        .i_findPreamble_b(o_find_preamble_b),
//        .out_valid(data_fs_valid),
//        .o_wayt_data(o_flag_wayt_data)
//    );

/****************************************************************************/
//tmp only frame sync
    reg r_data_fs_valid = 0;
    
    assign data_fs_valid = r_data_fs_valid;
    assign frame_sync = o_find_preamble_a;
    
    assign in_data_fs_i = in_data_i;
    assign in_data_fs_q = in_data_q;
    assign o_flag_wayt_data = fft_flag_wayt_data;
    
    always @(posedge i_clk)
    begin
        if(i_reset)                 r_data_fs_valid <= 0;
        else if(o_find_preamble_a)  r_data_fs_valid <= 0;
        else if(o_find_preamble_b)  r_data_fs_valid <= 1;
    end
/****************************************************************************/
    
    ofdm_remove_cp #(  .DATA_SIZE(DATA_SIZE),
                       .SYMBOLS_SIZE(256),
                       .CP_LENGHT(8))
    _ofdm_remove_cp(
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_valid(data_fs_valid & i_en & i_valid & o_flag_wayt_data),
        .in_data_i(in_data_fs_i),
        .in_data_q(in_data_fs_q),
        .i_frame_sync(frame_sync),
        .out_valid(walid_output_remove_cp),
        .out_data_i(data_remove_cp_i),
        .out_data_q(data_remove_cp_q)
    );
  
    
    myFFT_R4
    #(.SIZE_BUFFER(8),/*log2(NFFT)*/
      .DATA_FFT_SIZE(16),
      .FAST("ultrafast"),/*slow fast ultrafast slow mult x1 fast mult x2 ultrafast mult x4*/
      .TYPE("forvard"),/*forvard  invers*/
      .COMPENS_FP("add"),/*false true or add razrad*/
      .MIN_FFT_x4(1),
      .USE_ROUND(1),/*0 or 1*/
      .USE_DSP(1),/*0 or 1*/
      .PARAREL_FFT(9'b111111111)/*example 9'b 111000000 fft 256,128,64 matht pararel anaouther fft math conv; FFT 256 optimal time/resource 111100000 in OFDM systeam optimum 111000000*/
    )
    _fft_OFDM(
        .clk(i_clk),
        .reset(i_reset),
        .valid(walid_output_remove_cp),
        .clk_i_data(i_clk),
        .data_in_i(data_remove_cp_i),
        .data_in_q(data_remove_cp_q),
        .clk_o_data(),
        .data_out_i(symbol_FFT_i),
        .data_out_q(symbol_FFT_q),
        .complete(complete_fft),
        .stateFFT(),
        .flag_wayt_data(fft_flag_wayt_data),
        .flag_ready_recive(wayt_data_ofdm_payload_recive)
    );
    
    assign wayt_data_ofdm_payload_recive = 1'b1;
    
//    ofdm_payload_recive #(.DATA_SIZE(DATA_SIZE))
//    _ofdm_payload_recive(
//        .clk(clk),
//        .reset(reset),
//        .in_data_en(complete_fft),
//        .in_data_i(symbol_OFDM_i[DATA_SIZE+5:6]),
//        .in_data_q(symbol_OFDM_i[DATA_SIZE+5:6]),
//        .modulation(),
//        .out_done(),
//        .out_data(),
//        .counter_data(),
//        .wayt_recive_data(wayt_data_ofdm_payload_recive)
//    );
    
    
    
    
    
    
    
    
endmodule
