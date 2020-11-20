/*



  parameter int pIDAT_W     = 24 ;
  parameter int pODAT_W     =  8 ;
  parameter int pDIV        = pIDAT_W - pODAT_W;
  parameter bit pFULL_SCALE =  0 ;



  logic                 rounding__iclk    ;
  logic                 rounding__ireset  ;
  logic                 rounding__iclkena ;
  logic                 rounding__ival    ;
  logic [pIDAT_W-1 : 0] rounding__idat    ;
  logic                 rounding__oval    ;
  logic [pODAT_W-1 : 0] rounding__odat    ;



  rounding
  #(
    .pIDAT_W     ( pIDAT_W     ) ,
    .pODAT_W     ( pODAT_W     ) ,
    .pDIV        ( pDIV        ) ,
    .pFULL_SCALE ( pFULL_SCALE )
  )
  rounding
  (
    .iclk    ( rounding__iclk    ) ,
    .ireset  ( rounding__ireset  ) ,
    .iclkena ( rounding__iclkena ) ,
    .ival    ( rounding__ival    ) ,
    .idat    ( rounding__idat    ) ,
    .oval    ( rounding__oval    ) ,
    .odat    ( rounding__odat    )
  );


  assign rounding__iclk    = '0 ;
  assign rounding__ireset  = '0 ;
  assign rounding__iclkena = '0 ;
  assign rounding__ival    = '0 ;
  assign rounding__idat    = '0 ;



*/

//
// block for count floor(x/div + 0.5) with bitwidth conversion
//

module rounding
#(
  parameter int pIDAT_W     = 24 ,
  parameter int pODAT_W     =  8 ,
  parameter int pDIV        = pIDAT_W - pODAT_W , // round mode else round + saturation mode
  parameter bit pFULL_SCALE =  0
)
(
  iclk    ,
  ireset  ,
  iclkena ,
  //
  ival    ,
  idat    ,
  //
  oval    ,
  odat
);

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                        iclk    ;
  input  logic                        ireset  ;
  input  logic                        iclkena ;
  //
  input  logic                        ival    ;
  input  logic signed [pIDAT_W-1 : 0] idat    ;
  //
  output logic                        oval    ;
  output logic signed [pODAT_W-1 : 0] odat    ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam bit signed [pIDAT_W : 0] cROUND_0P5 = 1 <<< (pDIV-1);

  logic signed [pIDAT_W : 0] sum; // +1 bit for rounding

  //------------------------------------------------------------------------------------------------------
  // x + 0.5
  //------------------------------------------------------------------------------------------------------

  assign sum = (pDIV == 0) ? idat : (idat + cROUND_0P5);

  //------------------------------------------------------------------------------------------------------
  // floor (x + 0,5)
  //------------------------------------------------------------------------------------------------------

  saturation
  #(
    .pIN_W       ( pIDAT_W - pDIV + 1 ) ,
    .pOUT_W      ( pODAT_W            ) ,
    .pFULL_SCALE ( pFULL_SCALE        ) ,
    .pUSE_ROUND  ( 0                  )
  )
  saturation
  (
    .iclk    ( iclk                ) ,
    //
    .iena    ( iclkena & ival      ) ,
    .idat    ( sum[pIDAT_W : pDIV] ) ,
    //
    .oena    ( /* oval */          ) ,
    .odat    ( odat                ) ,
    //
    .over    (  )
  );

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      oval <= ival;
    end
  end

endmodule
