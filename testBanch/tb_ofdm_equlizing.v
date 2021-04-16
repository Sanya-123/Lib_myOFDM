`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.03.2021 19:31:50
// Design Name: 
// Module Name: tb_ofdm_equlizing
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


module tb_ofdm_equlizing();

reg clk = 0;

always  #5 clk = !clk;

reg [15:0] memI [255:0];
reg [15:0] memQ [255:0];

reg [15:0] in_data_i;
reg [15:0] in_data_q;
reg valid_data;

wire [15:0] out_data_i;
wire [15:0] out_data_q;
wire out_valid;
wire wayt_data;

    wire [16-1:0] d_data_for_div_i;
    wire [16-1:0] d_data_for_div_q;
    wire [16-1:0] d_div_coeff_i;
    wire [16-1:0] d_div_coeff_q;

integer i;
initial 
begin
    valid_data = 0;
    in_data_i = 0;
    in_data_q = 0;
    #50;
    valid_data = 1'b1;
    for(i = 0; i < 256; i = i + 1)
    begin
        in_data_i = 7680 + i*0;
        in_data_q = 7680 + i*0;

        #10;
    end
    #0 valid_data = 1'b0;
    #20;
    valid_data = 1'b1;
    in_data_i = 5760;
    in_data_q = 5760;
    #2560 valid_data = 1'b0;
end

ofdm_equalizing #(.DATA_SIZE(16))
_ofdm_equalizin(
    .i_clk(clk),
    .i_reset(1'b0),
    .i_data_i(in_data_i),
    .i_data_q(in_data_q),
    .i_valid(valid_data),
    .o_data_i(out_data_i),
    .o_data_q(out_data_q),
    .i_sync_frame(1'b0),
    .o_valid(out_valid),
    .o_wayt_data(wayt_data)
//    i_wayt_data
    ,
    .d_data_for_div_i(d_data_for_div_i),
    .d_data_for_div_q(d_data_for_div_q),
    .d_div_coeff_i(d_div_coeff_i),
    .d_div_coeff_q(d_div_coeff_q)
    );
    

endmodule
