`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.03.2021 19:48:35
// Design Name: 
// Module Name: tb_odm_freq_sync
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


module tb_odm_freq_sync();
reg clk = 0;
always #5 clk = !clk;

//reg signed [15:0] data_i = 0;
//reg signed [15:0] data_q = 0;

wire [15:0] data_i;
wire [15:0] data_q;

wire [15:0] o_data_i;
wire [15:0] o_data_q;

wire out_valid;
wire o_wayt_data;

//assign o_wayt_data = 1;

reg [15:0] data_i_r = 0;
reg [15:0] data_q_r = 0;

assign data_i = data_i_r;
assign data_q = data_q_r;


integer f_i, f_q, i;
//read data from file
initial
begin
    f_i = $fopen("/home/user/Projects/FPGA/pluto/pluto.sim/sim_1/behav/xsim/sim_res_data_i.txt", "r");
    f_q = $fopen("/home/user/Projects/FPGA/pluto/pluto.sim/sim_1/behav/xsim/sim_res_data_q.txt", "r");
    
    for(i = 0; i < 600;)
    begin
        #10
        if(o_wayt_data)
        begin
            i = i + 1;
        end
    end
    
    for(i = 0; i < 2000;)
    begin
        #10
        if(o_wayt_data)
        begin
            $fscanf(f_i, "%d", data_i_r);
            $fscanf(f_q, "%d", data_q_r);
            
            
            i = i + 1;
        end
    end
    $fclose(f_i);
    $fclose(f_q);
    $stop();
end

////************************************************************************
//reg beginTX = 0;
//reg valid = 0;
//initial #30 valid <= 1'b1;

//reg reset = 0;

//initial 
//begin
//    #500 reset <= 1'b1;
//    #500 reset <= 1'b0;
//end

//initial 
//begin
//    #2000 beginTX <= 1'b1;
//    #500 beginTX <= 1'b0;
//end

//    ofdm_frame_gen #(.MEMORY_SYZE(16))
//    _ofdm_frame_gen
//    (
//        .clk(clk),
//        .en(1'b1),
//        .reset(reset),
//        .beginTX(beginTX),
//        .valid(valid),
//        .in_data(8'd100),
//        .data_frame_size(10),
//        .modulation(4),
//        .i_wayt_read_data(1'b1/*din_valid_0*/),
//        .flag_ready_read(/*flag_ready_read*/),
//        .out_data_i(data_i),
//        .out_data_q(data_q),
//        .tx_valid(/*tx_valid*/),
//        .done_transmit(/*done_transmit*/),
//        .o_state_OFDM(/*o_state_OFDM*/)
////        .d_FCH_data(d_FCH_data),
////        .d_fft_data_i(d_fft_data_i),
////        .d_fft_data_q(d_fft_data_q),
////        .d_in_fft_data_i(d_in_fft_data_i),
////        .d_in_fft_data_q(d_in_fft_data_q),
////        .d_complete_fft(d_complete_fft)
//    );
////************************************************************************

    wire find_preamble_a;
    wire find_preamble_b;
    
    
    wire signed [16+7:0] out_preamble_a_i;
    wire signed [16+7:0] out_preamble_a_q;
    
    wire signed [16+7:0] out_preamble_b_i;
    wire signed [16+7:0] out_preamble_b_q;
    
    
    ofdm_find_preamble #(.DATA_SIZE(16),
            .PREAMBLE_MEM_I(256'b0111011000000011111111100000011111111100000011100100100110011111001101100110010011000000001111110000001100011000111111100001001100000110001100000001100110011001111110111001111001110110001000110010001110011100011001110111100000111001111000000111000000111000),
            .PREAMBLE_MEM_Q(256'b0001110010001111111000101110001110010001100010011110001100100001111111111001111000010000111100110011111011000100110011111110000011111001100110010011000001000111100011111111111000000000110000111000111001110011000111011001110000001000011001001110100011100111))
    _ofdm_find_preamble(
        .clk(clk),
        .en(1'b1),
        .in_data_i(data_i),
        .in_data_q(data_q),
        .find(find_preamble_a),
        .out_data_i(out_preamble_a_i),
        .out_data_q(out_preamble_a_q),
        .outPorog()
    );
    
    ofdm_find_preamble #(.DATA_SIZE(16),
            .PREAMBLE_MEM_I(256'b1001100110000100001001100111000010000110010011110101111100000010010011110111111001110010001110001100100110010000000000100111000011001101111100010010010000110111100110011100011111110011111001000111110000011111100100001101111001011011000011111101000000110110),
            .PREAMBLE_MEM_Q(256'b1000011000101100111001001100011011000111111000110110110010110011011111001111001100000111001001011000011000011111110000110001111111000000011100001100100001000000001100111101101100111010011011001000011010111110000111101110000000100011011011010011110100110011))
    _ofdm_find_preambleB(
        .clk(clk),
        .en(1'b1),
        .in_data_i(data_i),
        .in_data_q(data_q),
        .find(find_preamble_b),
        .out_data_i(out_preamble_b_i),
        .out_data_q(out_preamble_b_q),
        .outPorog()
    );

wire [33:0] d_phase_a;
wire [33:0] d_phase_b;
wire [33:0] d_begin_phase;
wire [33:0] d_add_phase;
wire [13:0] d_cos;
wire [13:0] d_sin;


ofdm_freq_sync#( .DATA_SIZE(16))
_ofdm_freq_sync(
    .i_clk(clk),
    .i_reset(1'b0),
    .i_en(1'b1),
    .i_valid(1'b1),
    .in_data_i(data_i),
    .in_data_q(data_q),
    .out_data_i(o_data_i),
    .out_data_q(o_data_q),
    .i_findPreamble_a(find_preamble_a),
    .i_findPreamble_b(find_preamble_b),
    .i_preamble_a_i(out_preamble_a_i),
    .i_preamble_a_q(out_preamble_a_q),
    .i_preamble_b_i(out_preamble_b_i),
    .i_preamble_b_q(out_preamble_b_q),
    .out_valid(out_valid),
    .o_wayt_data(o_wayt_data)
    
    
    ,
    .d_phase_a(d_phase_a),
    .d_phase_b(d_phase_b),
    .d_begin_phase(d_begin_phase),
    .d_add_phase(d_add_phase),
    .d_cos(d_cos),
    .d_sin(d_sin)
    );
  
  wire [13:0]   cos;
  wire [13:0]   sin;  
  dds
  #(
    .pFR_W  ( 34  ) ,
    .pPH_W  ( 15  ) ,
    .pDDS_W ( 14 )
  )
  dds1
  (
    .iclk    ( clk    ) ,
    .ireset  ( !out_valid ) ,
    .iclkena ( out_valid ) ,
    .ifreq   ( d_add_phase   ) ,
    .iph_cos ( d_begin_phase[33:19] ) ,
    .iph_sin ( d_begin_phase[33:19] ) ,
    .osin    ( cos    ) ,
    .ocos    ( sin    )
  );
  
    wire [14-1 : 0] dds__osin     ;
    wire [14-1 : 0] dds__ocos     ;
  
    localparam begin_phase = 34'h3f7f0ee84;

  dds
  #(
    .pFR_W  ( 34  ) ,
    .pPH_W  ( 15  ) ,
    .pDDS_W ( 14 )
  )
  dds2
  (
    .iclk    ( clk    ) ,
    .ireset  ( 1'b0  ) ,
    .iclkena ( 1 ) ,
    .ifreq   ( d_add_phase   ) ,
    .iph_cos ( d_begin_phase[33:19] ) ,
    .iph_sin ( d_begin_phase[33:19] ) ,
    .osin    ( dds__osin    ) ,
    .ocos    ( dds__ocos    )
  );
    
endmodule
