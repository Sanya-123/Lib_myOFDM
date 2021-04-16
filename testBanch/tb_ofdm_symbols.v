`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.11.2020 12:23:41
// Design Name: 
// Module Name: tb_ofdm_symbols
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


module tb_ofdm_symbols();

localparam DATA_SIZE = 200;

reg clk = 1'b0;
always  #5 clk = !clk;

reg in_data_en = 0;
wire out_done;
wire [15:0] out_data_i;
wire [15:0] out_data_q;
wire [21:0] res_data_i;
wire [21:0] res_data_q;
wire [15:0] res_data_i_div;
wire [15:0] res_data_q_div;

assign res_data_i_div = res_data_i[21:6];
assign res_data_q_div = res_data_q[21:6];

wire [15:0] counter_data;

reg [7:0] in_data;
reg [7:0] in_data_mas [DATA_SIZE-1:0];
wire wayt_recive;

wire walid_data_mod;
wire wayt_res_data;

integer f, i;
//read data from file
initial
begin
    f = $fopen("testDataOFDM.txt", "r");
    for(i = 0; i < DATA_SIZE; i = i + 1)
    begin
        $fscanf(f, "%d", in_data_mas[i]);
    end
    $fclose(f);
end

initial
begin
    #10
    in_data_en = 1'b1;
    for(i = 0; i < 200; )
    begin
        if(wayt_res_data)       in_data = in_data_mas[i];
        if(wayt_res_data)       i = i + 1;
        #10;
    end
    in_data_en = 1'b0;
    #10;
end

    wire [15:0] mod_data_i;
    wire [15:0] mod_data_q;
    wire o_flag_ready_recive;
    
    ofdm_modulation #(.DATA_SIZE(16))
    _ofdm_modulation(
        .i_clk(clk),
        .i_reset(1'b0),
        .i_valid(in_data_en),
        .i_modulation(3'd4),
        .i_data(in_data),
        .o_wayt_res_data(wayt_res_data),
        .o_valid_data(walid_data_mod),
        .i_wayt_data(o_flag_ready_recive),
        .o_data_i(mod_data_i),
        .o_data_q(mod_data_q)
    );

        
    ofdm_payload_gen #(.DATA_SIZE(16))
    _ofdm_payload_gen(
        .i_clk(clk),
        .i_reset(1'b0),
        .in_data_en(walid_data_mod),
        .in_data_i(mod_data_i),
        .in_data_q(mod_data_q),
        .o_flag_ready_recive(o_flag_ready_recive),
        .out_done(out_done),
        .out_data_i(out_data_i),
        .out_data_q(out_data_q),
        .o_counter_data(counter_data),
        .i_wayt_recive_data(wayt_recive)
    );


//    ofdm_payload_gen #(.DATA_SIZE(16))
//    _ofdm_payload_gen(
//        .clk(clk),
//        .reset(1'b0),
//        .in_data_en(in_data_en),
//        .in_data(in_data),
//        .modulation(3'd4),
//        .out_done(out_done),
//        .out_data_i(out_data_i),
//        .out_data_q(out_data_q),
//        .counter_data(counter_data),
//        .wayt_recive_data(wayt_recive)
//    );
    
wire complete;
wire [2:0] stateFFT;
    
    myFFT
#(.SIZE_BUFFER(8), .DATA_FFT_SIZE(16), .TYPE("invers")/*forvard invers*/, .FAST("ultrafast")/*slow fast ultrafast*/, 
  .COMPENS_FP("add")/*false true or add razrad*/, .MIN_FFT_x4(1))
_myFFT
(
    .clk(clk),
    .reset(1'b0),
    .valid(out_done),
    .clk_i_data(clk),
    .data_in_i(out_data_i),
    .data_in_q(out_data_q),
    .clk_o_data(),
    .data_out_i(res_data_i),
    .data_out_q(res_data_q),
    .complete(complete),
    .stateFFT(stateFFT),
    .flag_wayt_data(wayt_recive),
    .flag_ready_recive(/*wayt_recive*/1'b1)
);


endmodule
