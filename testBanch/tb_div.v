`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.04.2021 14:11:32
// Design Name: 
// Module Name: tb_div
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


module tb_div();

reg clk = 0;
always #10 clk = ~clk;

wire s_axis_divisor_tready;
wire s_axis_dividend_tready;
wire m_axis_dout_tvalid;
reg [15:0] divisor_tdata;
reg [15:0] dividend_tdata;
wire [31:0] m_axis_dout_tdata;

reg s_axis_divisor_tvalid = 0;
reg s_axis_dividend_tvalid = 0;

initial begin
#500
s_axis_divisor_tvalid = 1;
s_axis_dividend_tvalid = 1;
divisor_tdata = 500;
dividend_tdata = 10000;
#20
divisor_tdata = 200;
dividend_tdata = 10000;
#10
divisor_tdata = 7350;
dividend_tdata = 45000;
end


div_gen_0 diveered (
  .aclk(clk),                                      // input wire aclk
  .s_axis_divisor_tvalid(s_axis_divisor_tvalid),    // input wire s_axis_divisor_tvalid
  .s_axis_divisor_tready(s_axis_divisor_tready),    // output wire s_axis_divisor_tready
  .s_axis_divisor_tdata(divisor_tdata),      // input wire [15 : 0] s_axis_divisor_tdata
  .s_axis_dividend_tvalid(s_axis_dividend_tvalid),  // input wire s_axis_dividend_tvalid
  .s_axis_dividend_tready(s_axis_dividend_tready),  // output wire s_axis_dividend_tready
  .s_axis_dividend_tdata(dividend_tdata),    // input wire [15 : 0] s_axis_dividend_tdata
  .m_axis_dout_tvalid(m_axis_dout_tvalid),          // output wire m_axis_dout_tvalid
  .m_axis_dout_tdata(m_axis_dout_tdata)            // output wire [31 : 0] m_axis_dout_tdata
);

wire [15:0] quo;
wire [15:0] rem;
wire ack;

divfunc
#(
    .XLEN(16),
    .STAGE_LIST(16'h0000)
)
_divfunc(

    .clk(clk),
    .rst(1'b0),

    .a(dividend_tdata),
    .b(divisor_tdata),
    .vld(s_axis_divisor_tvalid),


    .quo(quo),
    .rem(rem),
    .ack(ack)

);

endmodule
