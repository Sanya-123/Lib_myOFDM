`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.03.2021 16:48:30
// Design Name: 
// Module Name: cordic_atan_qo
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


module tb_cordic_atan_qo();

  parameter int pTYPE     = 0  ;
  parameter int pITER     = 20 ;
  parameter int pDAT_W    = 24 ;
  parameter int pANG_W    = 32 ;
  parameter int pMAG_W    = 29 ;


  logic                        cordic_atan_qo__iclk = 0 ;
  logic                        cordic_atan_qo__ireset   ;
  logic                        cordic_atan_qo__iclkena  ;
  logic                        cordic_atan_qo__ival     ;
  logic signed  [pDAT_W-1 : 0] cordic_atan_qo__idat_re  ;
  logic signed  [pDAT_W-1 : 0] cordic_atan_qo__idat_im  ;
  logic                        cordic_atan_qo__oval     ;
  logic                [1 : 0] cordic_atan_qo__oquart   ;
  logic         [pANG_W-1 : 0] cordic_atan_qo__oangle   ;
  logic         [pMAG_W-1 : 0] cordic_atan_qo__omag     ;
  logic signed  [pDAT_W-1 : 0] cordic_atan_qo__odat_re  ;
  logic signed  [pDAT_W-1 : 0] cordic_atan_qo__odat_im  ;
  
  always #5 cordic_atan_qo__iclk = !cordic_atan_qo__iclk;
  
  initial begin
    #10;
    cordic_atan_qo__idat_re <= 24'h001000;
    cordic_atan_qo__idat_im <= 24'h001000;
    #500;
    cordic_atan_qo__idat_re <= 24'h001000;
    cordic_atan_qo__idat_im <= 24'h000000;
    #500;
    cordic_atan_qo__idat_re <= 24'h000001;
    cordic_atan_qo__idat_im <= 24'h001000;
    #500;
    cordic_atan_qo__idat_re <= 24'h001000;
    cordic_atan_qo__idat_im <= 24'h000800;
    #500;
    cordic_atan_qo__idat_re <= 24'h000800;
    cordic_atan_qo__idat_im <= 24'h001000;
    #500;
    cordic_atan_qo__idat_re <= 24'h000001;
    cordic_atan_qo__idat_im <= 24'h001000;
    
    #500;
    cordic_atan_qo__idat_re <= 24'h000001;
    cordic_atan_qo__idat_im <= -24'h001000;
    
    #500;
    cordic_atan_qo__idat_re <= -24'h000800;
    cordic_atan_qo__idat_im <= 24'h001000;
    
    #500;
    cordic_atan_qo__idat_re <= 24'h000800;
    cordic_atan_qo__idat_im <= -24'h001000;
    #500;
    cordic_atan_qo__idat_re <= 24'h001000;
    cordic_atan_qo__idat_im <= -24'h001000;
    #500;
    cordic_atan_qo__idat_re <= -24'h001000;
    cordic_atan_qo__idat_im <= -24'h001000;
    #500;
    cordic_atan_qo__idat_re <= -24'h001000;
    cordic_atan_qo__idat_im <= 24'h001000;
    #500;
    cordic_atan_qo__idat_re <= -24'h001000;
    cordic_atan_qo__idat_im <= 24'h000800;
    #500;
    cordic_atan_qo__idat_re <= -24'h000800;
    cordic_atan_qo__idat_im <= 24'h001000;
    #500;
    cordic_atan_qo__idat_re <= -24'h000800;
    cordic_atan_qo__idat_im <= -24'h001000;
  end


  cordic_atan_qo
  #(
    .pTYPE    ( pTYPE    ) ,
    .pITER    ( pITER    ) ,
    .pDAT_W   ( pDAT_W   ) ,
    .pANG_W   ( pANG_W   ) ,
    .pMAG_W   ( pMAG_W   )
  )
  cordic_atan_qo
  (
    .iclk    ( cordic_atan_qo__iclk    ) ,
    .ireset  ( /*cordic_atan_qo__ireset*/1'b0  ) ,
    .iclkena ( /*cordic_atan_qo__iclkena*/1'b1 ) ,
    .ival    ( /*cordic_atan_qo__ival*/1'b1    ) ,
    .idat_re ( cordic_atan_qo__idat_re ) ,
    .idat_im ( cordic_atan_qo__idat_im ) ,
    .oval    ( cordic_atan_qo__oval    ) ,
    .oquart  ( cordic_atan_qo__oquart  ) ,
    .oangle  ( cordic_atan_qo__oangle  ) ,
    .omag    ( cordic_atan_qo__omag    ) ,
    .odat_re ( cordic_atan_qo__odat_re ) ,
    .odat_im ( cordic_atan_qo__odat_im )
  );
  
  
endmodule
