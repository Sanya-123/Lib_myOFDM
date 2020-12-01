/*



  parameter int pIN_W       = 24 ;
  parameter int pOUT_W      =  8 ;
  parameter bit pFULL_SCALE =  0 ;
  parameter bit pUSE_ROUND  =  0 ;



  logic                saturation__iclk ;
  logic                saturation__iena ;
  logic  [pIN_W-1 : 0] saturation__idat ;
  logic                saturation__oena ;
  logic [pOUT_W-1 : 0] saturation__odat ;
  logic                saturation__over ;



  saturation
  #(
    .pIN_W       ( pIN_W       ) ,
    .pOUT_W      ( pOUT_W      ) ,
    .pFULL_SCALE ( pFULL_SCALE ) ,
    .pUSE_ROUND  ( pUSE_ROUND  )
  )
  saturation
  (
    .iclk ( saturation__iclk ) ,
    .iena ( saturation__iena ) ,
    .idat ( saturation__idat ) ,
    .oena ( saturation__oena ) ,
    .odat ( saturation__odat ) ,
    .over ( saturation__over )
  );


  assign saturation__iclk = '0 ;
  assign saturation__iena = '0 ;
  assign saturation__idat = '0 ;



*/

//
// block for saturation
// saturation rule when pOUT_W < pIN_W is
//    -2**(pOUT_W-1)    <= odat <= 2**(pOUT_W-1)-1 when pFULL_SCALE = 1
//    -2**(pOUT_W-1)+1  <= odat <= 2**(pOUT_W-1)-1 when pFULL_SCALE = 0
// saturation rule when pOUT_W >= pIN_W is
//  odat <= signed_resize(idat);
//
// rounding rule is
// odat <= idat               when pUSE_ROUND = 0
// odat <= idat + sign(idat)  when pUSE_ROUND = 1
//

module saturation
#(
  parameter int pIN_W       = 24 ,
  parameter int pOUT_W      =  8 ,
  parameter bit pFULL_SCALE =  0 ,
  parameter bit pUSE_ROUND  =  0
)
(
  iclk ,
  iena ,
  idat ,
  oena ,
  odat ,
  over
);

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                iclk ;
  input  logic                iena ;
  input  logic  [pIN_W-1 : 0] idat ;
  output logic                oena ;
  output logic [pOUT_W-1 : 0] odat ;
  output logic                over ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam int cSIGN_LSB  = pOUT_W - 1;
  localparam int cSIGN_MSB  = pIN_W - 1;
  localparam int cSIGN_W    = cSIGN_MSB - cSIGN_LSB + 1;

  logic [cSIGN_W-1 : 0] sign_bits;
  logic [cSIGN_W-1 : 0] sign_golden_bits;
  logic                 overflow ;
  logic  [pOUT_W-1 : 0] overflow_value;
  logic  [pOUT_W-1 : 0] noverflow_value;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------
  // synthesis translate_off
  initial begin : ini
//    oena <= '0;
//    odat <= '0;
  end
  // synthesis translate_on
  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  generate
    if (pOUT_W < pIN_W) begin : gen_saturate

      assign sign_bits         = idat[cSIGN_MSB  : cSIGN_LSB] ;
      assign sign_golden_bits  = {cSIGN_W{idat[cSIGN_MSB]}}   ;

      //
      // positive overflow occured when sign_bits = 'b000100
      // negative overflow occured when sign_bits = 'b111011
      assign overflow = (sign_bits != sign_golden_bits);

      //  positive overflow_value  = 'b011...111
      //  negative overflow_value  = 'b100...000 or 'b100...001
      assign overflow_value   = {idat[cSIGN_MSB], {{pOUT_W-2}{~idat[cSIGN_MSB]}}, (~idat[cSIGN_MSB] | ~pFULL_SCALE) };

      assign noverflow_value  = idat[pOUT_W-1 : 0] + (pUSE_ROUND & idat[cSIGN_MSB]);

    end

    else begin : gen_resize

      assign overflow         = 1'b0;

      assign overflow_value   = '0;

      assign noverflow_value  = {{{pOUT_W - pIN_W}{idat[pIN_W - 1]}}, idat} + (pUSE_ROUND & idat[cSIGN_MSB]);

    end
  endgenerate


  always_ff @(posedge iclk) begin
`ifndef __USE_ALTERA_MACRO__
    if (iena) begin
      if (overflow)
        odat <= overflow_value;
      else
        odat <= noverflow_value;
    end
`endif
    oena <= iena;
    over <= overflow;
  end

`ifdef __USE_ALTERA_MACRO__

  generate
    genvar i;
    for (i = 0; i < pOUT_W; i++) begin : dffeas_gen

      dffeas
      dffeas
      (
        .clk    ( iclk                ) ,
        .d      ( noverflow_value [i] ) ,
        .ena    ( iena                ) ,
        .asdata ( overflow_value [i]  ) ,
        .sclr   ( 1'b0                ) ,
        .sload  ( overflow            ) ,
        .q      ( odat            [i] )
      );
    end
  endgenerate

`endif

endmodule

//// synthesis translate_off
//module tbs ;

//  parameter int  pIN_W  = 9 ;
//  parameter int  pOUT_W = 8 ;



//  logic                iclk ;
//  logic                iena ;
//  logic  [pIN_W-1 : 0] idat ;
//  logic                oena ;
//  logic [pOUT_W-1 : 0] odat ;



//  saturation
//  #(
//    .pIN_W       ( pIN_W  ) ,
//    .pOUT_W      ( pOUT_W ) ,
//    .pFULL_SCALE (1)
//  )
//  saturation
//  (
//    .*
//  );

//  default clocking cb @(posedge iclk);
//  endclocking

//  initial begin : clk_gen
//    iclk = '0;
//    #5ns forever #5ns iclk = ~iclk;
//  end

//  assign iena = 1'b1;

//  const int MAX =   2**(pIN_W-1)-1;
//  const int MIN = -(2**(pIN_W-1));

//  initial begin : main
//    idat = '0;
//    ##2;

//    idat <= -(2**(pOUT_W-1))-20;
//    ##1;

//    for (int i = MIN; i <= MAX; i++) begin
//      idat = i;
//      ##1;
//    end
//    ##10;
//    $stop;
//  end

//endmodule
//// synthesis translate_on




