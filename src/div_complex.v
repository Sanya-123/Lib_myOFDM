`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.03.2021 14:24:19
// Design Name: 
// Module Name: div_complex
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


module div_complex #(parameter DATA_SIZE = 16) 
    (
    i_clk,
    i_reset,
    i_valid,
    i_data_a_i,
    i_data_a_q,
    i_data_b_i,
    i_data_b_q,
    o_data_i,
    o_data_q,
    o_valid
    );
    
    input i_clk;
    input i_reset;
    input i_valid;
    input [DATA_SIZE-1:0] i_data_a_i;
    input [DATA_SIZE-1:0] i_data_a_q;
    input [DATA_SIZE-1:0] i_data_b_i;
    input [DATA_SIZE-1:0] i_data_b_q;
    output [DATA_SIZE-1:0] o_data_i;
    output [DATA_SIZE-1:0] o_data_q;
    output o_valid;
    
    reg d1_i_valid, d2_i_valid, d3_i_valid, d4_i_valid, d5_i_valid;
    
    wire multComplexComplete;
    wire signed [DATA_SIZE*2-1:0] mult_data_i;
    wire signed [DATA_SIZE*2-1:0] mult_data_q;
    
    reg [DATA_SIZE*2-1:0] b_i_2 = 0;
    reg [DATA_SIZE*2-1:0] b_q_2 = 0;
    
    reg signed [DATA_SIZE*2:0] ab_2 = 0;
    
    reg [DATA_SIZE*2-1:0] d1_b_i_2 = 0, d2_b_i_2 = 0, d3_b_i_2 = 0;
    reg [DATA_SIZE*2-1:0] d1_b_q_2 = 0, d2_b_q_2 = 0, d3_b_q_2 = 0;
    
    always @(posedge i_clk) d1_i_valid <= i_valid;
    always @(posedge i_clk) d2_i_valid <= d1_i_valid;
    always @(posedge i_clk) d3_i_valid <= d2_i_valid;
    always @(posedge i_clk) d4_i_valid <= d3_i_valid;
    always @(posedge i_clk) d5_i_valid <= d4_i_valid;
    
    assign o_valid = d4_i_valid;
    
    cmplx_mixer
    #(
      .pIDAT_W(DATA_SIZE) ,
      .pDDS_W(DATA_SIZE) ,
      .pODAT_W(DATA_SIZE*2) ,
      .pMUL_W(0) ,
      .pCONJ(1) ,
      .pUSE_DSP_ADD(1) , // use altera dsp internal adder or not (differ registers)
      .pUSE_ROUND(1)
    )
    cmplx_mult1(
      .iclk(i_clk)    ,
      .ireset(i_reset)  ,
      .iclkena(1'b1) ,
      //
      .ival(i_valid | d1_i_valid | d2_i_valid | d3_i_valid)    ,
      .idat_re(i_data_a_i) ,
      .idat_im(i_data_a_q) ,
      //
      .icos(i_data_b_i)    ,
      .isin(i_data_b_q)    ,
      //
      .oval(multComplexComplete),
      .odat_re(mult_data_i) ,
      .odat_im(mult_data_q)
    );
    
    
    always @(posedge i_clk)         b_i_2 <= i_data_b_i*i_data_b_i;
        
    always @(posedge i_clk)         b_q_2 <= i_data_b_q*i_data_b_q;
        
    always @(posedge i_clk)         d1_b_i_2 <= b_i_2;
    always @(posedge i_clk)         d2_b_i_2 <= d1_b_i_2;
    always @(posedge i_clk)         d3_b_i_2 <= d2_b_i_2;
    
    always @(posedge i_clk)         d1_b_q_2 <= b_q_2;
    always @(posedge i_clk)         d2_b_q_2 <= d1_b_q_2;
    always @(posedge i_clk)         d3_b_q_2 <= d2_b_q_2;
    
    always @(posedge i_clk)         ab_2 <= d2_b_q_2 + d2_b_i_2;
    
//    always @(posedge i_clk)         o_data_i <= $signed({mult_data_i, 1'b1}) / $signed({ab_2, 1'b0});
//    always @(posedge i_clk)         o_data_q <= $signed({mult_data_q, 1'b1}) / $signed({ab_2, 1'b0});

//    always @(posedge i_clk)         o_data_i <= (mult_data_i) / (ab_2);
//    always @(posedge i_clk)         o_data_q <= (mult_data_q) / (ab_2);
    
    divfunc
    #(
        .XLEN(DATA_SIZE*2),
        .STAGE_LIST({DATA_SIZE*2{1'b0}})
    )
    _divfunc_I(
    
        .clk(i_clk),
        .rst(i_reset),
    
        .a(mult_data_i),
        .b(ab_2),
        .vld(o_valid),
    
    
        .quo(o_data_i),
        .rem(),
        .ack(/*o_valid*/)
    
    );
    
    divfunc
    #(
        .XLEN(DATA_SIZE*2),
        .STAGE_LIST({DATA_SIZE*2{1'b0}})
    )
    _divfunc_Q(
    
        .clk(i_clk),
        .rst(i_reset),
    
        .a(mult_data_q),
        .b(ab_2),
        .vld(o_valid),
    
    
        .quo(o_data_q),
        .rem(),
        .ack(/*o_valid*/)
    
    );
    
//    div_gen_0 diveered (
//      .aclk(i_clk),                                      // input wire aclk
//      .s_axis_divisor_tvalid(s_axis_divisor_tvalid),    // input wire s_axis_divisor_tvalid
//      .s_axis_divisor_tready(s_axis_divisor_tready),    // output wire s_axis_divisor_tready
//      .s_axis_divisor_tdata(divisor_tdata),      // input wire [15 : 0] s_axis_divisor_tdata
//      .s_axis_dividend_tvalid(s_axis_dividend_tvalid),  // input wire s_axis_dividend_tvalid
//      .s_axis_dividend_tready(s_axis_dividend_tready),  // output wire s_axis_dividend_tready
//      .s_axis_dividend_tdata(dividend_tdata),    // input wire [15 : 0] s_axis_dividend_tdata
//      .m_axis_dout_tvalid(m_axis_dout_tvalid),          // output wire m_axis_dout_tvalid
//      .m_axis_dout_tdata(m_axis_dout_tdata)            // output wire [31 : 0] m_axis_dout_tdata
//);
    
endmodule
