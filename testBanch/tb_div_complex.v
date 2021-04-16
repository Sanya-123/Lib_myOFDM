`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.03.2021 15:38:23
// Design Name: 
// Module Name: tb_div_complex
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


module tb_div_complex();

reg clk = 0;

always  #5 clk = !clk;

wire oval;
wire [15:0] odat_re;
wire [15:0] odat_im;

//reg [16:0] memCos [7:0];
//reg [16:0] memSin [7:0];

//reg [16:0] dataCos;
//reg [16:0] dataSin;
reg valid = 1'b0;

reg [15:0] i_data_a_i;
reg [15:0] i_data_a_q;

reg [15:0] i_data_b_i;
reg [15:0] i_data_b_q;

//wire [31:0] mult_data_i;
//wire [31:0] mult_data_q;

//wire [31:0] ab_2;

initial begin
    #20
    i_data_a_i = 740;
    i_data_a_q = 740;
    i_data_b_i = 10;
    i_data_b_q = 10;
    valid = 1'b1;
    #10;
    i_data_a_i = 1000;
    i_data_a_q = 0;
    i_data_b_i = 200;
    i_data_b_q = 10;
    valid = 1'b1;
    #10 ;
    i_data_a_i = 740;
    i_data_a_q = 45;
    i_data_b_i = 0;
    i_data_b_q = 156;
    valid = 1'b1;
    #10 ;
    i_data_a_i = 789;
    i_data_a_q = 65;
    i_data_b_i = 4;
    i_data_b_q = 1;
    valid = 1'b1;
    #10 ;
    valid = 1'b0;
end 

div_complex #(.DATA_SIZE(16))
    _div_complex(
    .i_clk(clk),
    .i_reset(1'b0),
    .i_valid(valid),
    .i_data_a_i(i_data_a_i),
    .i_data_a_q(i_data_a_q),
    .i_data_b_i(i_data_b_i),
    .i_data_b_q(i_data_b_q),
    .o_data_i(odat_re),
    .o_data_q(odat_im),
    .o_valid(oval)
    );

endmodule
