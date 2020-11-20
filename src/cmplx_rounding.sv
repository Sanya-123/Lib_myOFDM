/*



  parameter int pIDAT_W     = 24 ;
  parameter int pODAT_W     =  8 ;
  parameter int pDIV        = pIDAT_W - pODAT_W;
  parameter bit pFULL_SCALE =  0 ;


  logic                 cmplx_rounding__iclk    ;
  logic                 cmplx_rounding__ireset  ;
  logic                 cmplx_rounding__iclkena ;
  logic                 cmplx_rounding__ival    ;
  logic [pIDAT_W-1 : 0] cmplx_rounding__idat_re ;
  logic [pIDAT_W-1 : 0] cmplx_rounding__idat_im ;
  logic                 cmplx_rounding__oval    ;
  logic [pODAT_W-1 : 0] cmplx_rounding__odat_re ;
  logic [pODAT_W-1 : 0] cmplx_rounding__odat_im ;



  cmplx_rounding
  #(
    .pIDAT_W     ( pIDAT_W     ) ,
    .pODAT_W     ( pODAT_W     ) ,
    .pDIV        ( pDIV        ) ,
    .pFULL_SCALE ( pFULL_SCALE )
  )
  cmplx_rounding
  (
    .iclk    ( cmplx_rounding__iclk    ) ,
    .ireset  ( cmplx_rounding__ireset  ) ,
    .iclkena ( cmplx_rounding__iclkena ) ,
    .ival    ( cmplx_rounding__ival    ) ,
    .idat_re ( cmplx_rounding__idat_re ) ,
    .idat_im ( cmplx_rounding__idat_im ) ,
    .oval    ( cmplx_rounding__oval    ) ,
    .odat_re ( cmplx_rounding__odat_re ) ,
    .odat_im ( cmplx_rounding__odat_im )
  );


  assign cmplx_rounding__iclk    = '0 ;
  assign cmplx_rounding__ireset  = '0 ;
  assign cmplx_rounding__iclkena = '0 ;
  assign cmplx_rounding__ival    = '0 ;
  assign cmplx_rounding__idat_re = '0 ;
  assign cmplx_rounding__idat_im = '0 ;



*/

//
// block for count floor(x/div + 0.5) with bitwidth conversion
//

module cmplx_rounding
#(
  parameter int pIDAT_W     = 24 ,
  parameter int pODAT_W     =  8 ,
  parameter int pDIV        = pIDAT_W - pODAT_W , // round mode else round + saturation mode
  parameter int pFULL_SCALE =  0
)
(
  iclk    ,
  ireset  ,
  iclkena ,
  //
  ival    ,
  idat_re ,
  idat_im ,
  //
  oval    ,
  odat_re ,
  odat_im
);

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                 iclk    ;
  input  logic                 ireset  ;
  input  logic                 iclkena ;
  //
  input  logic                 ival    ;
  input  logic [pIDAT_W-1 : 0] idat_re ;
  input  logic [pIDAT_W-1 : 0] idat_im ;
  //
  output logic                 oval    ;
  output logic [pODAT_W-1 : 0] odat_re ;
  output logic [pODAT_W-1 : 0] odat_im ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  rounding
  #(
    .pIDAT_W     ( pIDAT_W     ) ,
    .pODAT_W     ( pODAT_W     ) ,
    .pDIV        ( pDIV        ) ,
    .pFULL_SCALE ( pFULL_SCALE )
  )
  round_re
  (
    .iclk    ( iclk    ) ,
    .ireset  ( ireset  ) ,
    .iclkena ( iclkena ) ,
    //
    .ival    ( ival    ) ,
    .idat    ( idat_re ) ,
    //
    .oval    ( oval    ) ,
    .odat    ( odat_re )
  );

  rounding
  #(
    .pIDAT_W     ( pIDAT_W     ) ,
    .pODAT_W     ( pODAT_W     ) ,
    .pDIV        ( pDIV        ) ,
    .pFULL_SCALE ( pFULL_SCALE )
  )
  round_im
  (
    .iclk    ( iclk    ) ,
    .ireset  ( ireset  ) ,
    .iclkena ( iclkena ) ,
    //
    .ival    ( ival    ) ,
    .idat    ( idat_im ) ,
    //
    .oval    (         ) ,
    .odat    ( odat_im )
  );

endmodule
