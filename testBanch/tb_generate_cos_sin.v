`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.01.2021 16:25:57
// Design Name: 
// Module Name: tb_generate_cos_sin
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


module tb_generate_cos_sin();

reg clk = 0;
wire m_axis_phase_tvalid;
wire [15:0] m_axis_phase_tdata;
wire m_axis_dout_tvalid;
//wire [15:0] cos;
//wire [15:0] sin;
always #5 clk=!clk;

//dds_compiler_0 dds (
//  .aclk(clk),                                // input wire aclk
//  .m_axis_phase_tvalid(m_axis_phase_tvalid),  // output wire m_axis_phase_tvalid
//  .m_axis_phase_tdata(m_axis_phase_tdata)    // output wire [15 : 0] m_axis_phase_tdata
//);

//cordic_1 sin_cos (
//  .aclk(clk),                                // input wire aclk
//  .s_axis_phase_tvalid(m_axis_phase_tvalid),  // input wire s_axis_phase_tvalid
//  .s_axis_phase_tdata(m_axis_phase_tdata),    // input wire [15 : 0] s_axis_phase_tdata
//  .m_axis_dout_tvalid(m_axis_dout_tvalid),    // output wire m_axis_dout_tvalid
//  .m_axis_dout_tdata({cos, sin})      // output wire [31 : 0] m_axis_dout_tdata
//);

  parameter pFR_W   = 34 ;
  parameter pPH_W   = 15 ;
  parameter pDDS_W  = 14 ;
  wire [pDDS_W-1 : 0] dds__osin     ;
  wire [pDDS_W-1 : 0] dds__ocos     ;
  wire [pDDS_W-1 : 0] cos;
  wire [pDDS_W-1 : 0] sin;

  localparam beginPhase = 34'h3f7f0ee84;

  dds
  #(
    .pFR_W  ( pFR_W  ) ,
    .pPH_W  ( pPH_W  ) ,
    .pDDS_W ( pDDS_W )
  )
  dds1
  (
    .iclk    ( clk    ) ,
    .ireset  ( 0  ) ,
    .iclkena ( 1 ) ,
    .ifreq   ( 34'h000011356   ) ,
    .iph_cos ( beginPhase[33:19] ) ,
    .iph_sin ( beginPhase[33:19] ) ,
    .osin    ( dds__osin    ) ,
    .ocos    ( dds__ocos    )
  );
  
  dds
  #(
    .pFR_W  ( pFR_W  ) ,
    .pPH_W  ( pPH_W  ) ,
    .pDDS_W ( pDDS_W )
  )
  dds2
  (
    .iclk    ( clk    ) ,
    .ireset  ( 0  ) ,
    .iclkena ( 1 ) ,
    .ifreq   ( 15000   ) ,
    .iph_cos ( 0 ) ,
    .iph_sin ( 0 ) ,
    .osin    ( sin    ) ,
    .ocos    ( cos    )
  );
  
  reg [14:0] summCos;
  reg [14:0] summSin;
  
  always @(posedge clk)
  begin
    summCos <= dds__ocos + cos;
    summSin <= dds__osin + sin;
  end

endmodule
