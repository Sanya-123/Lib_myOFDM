/*



  parameter int pIDAT_W      = 18 ;
  parameter int pDDS_W       = 14 ;
  parameter int pODAT_W      = 18 ;
  parameter int pMUL_W       =  0 ;
  parameter bit pCONJ        =  0 ;
  parameter bit pUSE_DSP_ADD =  0 ;
  parameter bit pUSE_ROUND   =  0 ;



  logic                 cmplx_mixer__iclk     ;
  logic                 cmplx_mixer__ireset   ;
  logic                 cmplx_mixer__iclkena  ;
  logic                 cmplx_mixer__ival     ;
  logic [pIDAT_W-1 : 0] cmplx_mixer__idat_re  ;
  logic [pIDAT_W-1 : 0] cmplx_mixer__idat_im  ;
  logic  [pDDS_W-1 : 0] cmplx_mixer__icos     ;
  logic  [pDDS_W-1 : 0] cmplx_mixer__isin     ;
  logic                 cmplx_mixer__oval     ;
  logic [pODAT_W-1 : 0] cmplx_mixer__odat_re  ;
  logic [pODAT_W-1 : 0] cmplx_mixer__odat_im  ;



  cmplx_mixer
  #(
    .pIDAT_W      ( pIDAT_W      ) ,
    .pDDS_W       ( pDDS_W       ) ,
    .pODAT_W      ( pODAT_W      ) ,
    .pMUL_W       ( pMUL_W       ) ,
    .pCONJ        ( pCONJ        ) ,
    .pUSE_DSP_ADD ( pUSE_DSP_ADD ) ,
    .pUSE_ROUND   ( pUSE_ROUND   )
  )
  cmplx_mixer
  (
    .iclk    ( cmplx_mixer__iclk    ) ,
    .ireset  ( cmplx_mixer__ireset  ) ,
    .iclkena ( cmplx_mixer__iclkena ) ,
    .ival    ( cmplx_mixer__ival    ) ,
    .idat_re ( cmplx_mixer__idat_re ) ,
    .idat_im ( cmplx_mixer__idat_im ) ,
    .icos    ( cmplx_mixer__icos    ) ,
    .isin    ( cmplx_mixer__isin    ) ,
    .oval    ( cmplx_mixer__oval    ) ,
    .odat_re ( cmplx_mixer__odat_re ) ,
    .odat_im ( cmplx_mixer__odat_im )
  );


  assign cmplx_mixer__iclk    = '0 ;
  assign cmplx_mixer__ireset  = '0 ;
  assign cmplx_mixer__iclkena = '0 ;
  assign cmplx_mixer__ival    = '0 ;
  assign cmplx_mixer__idat_re = '0 ;
  assign cmplx_mixer__idat_im = '0 ;
  assign cmplx_mixer__icos    = '0 ;
  assign cmplx_mixer__isin    = '0 ;



*/

//------------------------------------------------------------------------------------------------------
// complex mixer.
// module latency = (no round) ? 3 tick : 4 tick
//------------------------------------------------------------------------------------------------------

module cmplx_mixer
#(
  parameter int pIDAT_W      = 18 ,
  parameter int pDDS_W       = 14 ,
  parameter int pODAT_W      = 18 ,
  parameter int pMUL_W       =  0 ,
  parameter bit pCONJ        =  0 ,
  parameter bit pUSE_DSP_ADD =  0 , // use altera dsp internal adder or not (differ registers)
  parameter bit pUSE_ROUND   =  0
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
  icos    ,
  isin    ,
  //
  oval    ,
  odat_re ,
  odat_im
);

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                         iclk     ;
  input  logic                         ireset   ;
  input  logic                         iclkena  ;
  //
  input  logic                         ival     ;
  input  logic signed  [pIDAT_W-1 : 0] idat_re  ;
  input  logic signed  [pIDAT_W-1 : 0] idat_im  ;
  //
  input  logic signed   [pDDS_W-1 : 0] icos     ;
  input  logic signed   [pDDS_W-1 : 0] isin     ;
  //
  output logic                         oval     ;
  output logic signed  [pODAT_W-1 : 0] odat_re  ;
  output logic signed  [pODAT_W-1 : 0] odat_im  ;

  //------------------------------------------------------------------------------------------------------
  // (re + jim)*(cos + j*sin) = (re*cos - im*sin) + j*(re*sin + im*cos)
  //------------------------------------------------------------------------------------------------------

  localparam int cMULT_W = pIDAT_W + pDDS_W;

  logic signed        [pIDAT_W-1 : 0] dat_re;
  logic signed        [pIDAT_W-1 : 0] dat_im;

  logic signed         [pDDS_W-1 : 0] cos;
  logic signed         [pDDS_W-1 : 0] sin;

  logic signed        [cMULT_W-1 : 0] mult_re_cos;
  logic signed        [cMULT_W-1 : 0] mult_re_sin;
  logic signed        [cMULT_W-1 : 0] mult_im_sin;
  logic signed        [cMULT_W-1 : 0] mult_im_cos;

  logic signed        [cMULT_W-1 : 0] mult_re;
  logic signed        [cMULT_W-1 : 0] mult_im;

  logic signed [cMULT_W-pMUL_W-1 : 0] rslt_re;
  logic signed [cMULT_W-pMUL_W-1 : 0] rslt_im;

  //------------------------------------------------------------------------------------------------------
  //
  // (re + j*im)*(cos + j*sin) = (re*cos - im*sin) + j(im*cos + re*sin)
  // (re + j*im)*(cos - j*sin) = (re*cos + im*sin) + j(im*cos - re*sin)
  //------------------------------------------------------------------------------------------------------

  generate
    if (pUSE_DSP_ADD) begin

      assign mult_re_cos = dat_re * cos;
      assign mult_re_sin = dat_re * sin;
      assign mult_im_sin = dat_im * sin;
      assign mult_im_cos = dat_im * cos;

      always_ff @(posedge iclk) begin
        if (iclkena) begin
          if (ival) begin
            dat_re  <= idat_re;
            dat_im  <= idat_im;
            //
            cos     <= icos;
            sin     <= isin;
            //
            if (pCONJ) begin
              mult_re <= mult_re_cos + mult_im_sin;
              mult_im <= mult_im_cos - mult_re_sin;
            end
            else begin
              mult_re <= mult_re_cos - mult_im_sin;
              mult_im <= mult_im_cos + mult_re_sin;
            end
            //
            rslt_re <= mult_re[cMULT_W-1-pMUL_W : 0];
            rslt_im <= mult_im[cMULT_W-1-pMUL_W : 0];
          end
        end
      end

    end
    else begin

      always_ff @(posedge iclk) begin
        if (iclkena) begin
          if (ival) begin
            dat_re  <= idat_re;
            dat_im  <= idat_im;
            //
            cos     <= icos;
            sin     <= isin;
            //
            mult_re_cos <= dat_re * cos;
            mult_re_sin <= dat_re * sin;
            mult_im_sin <= dat_im * sin;
            mult_im_cos <= dat_im * cos;
            //
            if (pCONJ) begin
              mult_re <= mult_re_cos + mult_im_sin;
              mult_im <= mult_im_cos - mult_re_sin;
            end
            else begin
              mult_re <= mult_re_cos - mult_im_sin;
              mult_im <= mult_im_cos + mult_re_sin;
            end
          end
        end
      end
      //
      assign rslt_re = mult_re[cMULT_W-1-pMUL_W : 0];
      assign rslt_im = mult_im[cMULT_W-1-pMUL_W : 0];
    end
  endgenerate

  generate
    if (pUSE_ROUND) begin
      cmplx_rounding
      #(
        .pIDAT_W ( cMULT_W-pMUL_W ) ,
        .pODAT_W ( pODAT_W        )
      )
      round
      (
        .iclk    ( iclk     ) ,
        .ireset  ( ireset   ) ,
        .iclkena ( iclkena  ) ,
        //
        .ival    ( ival     ) ,
        .idat_re ( rslt_re  ) ,
        .idat_im ( rslt_im  ) ,
        //
        .oval    ( oval     ) ,
        .odat_re ( odat_re  ) ,
        .odat_im ( odat_im  )
      );
    end
    else begin
      always_ff @(posedge iclk) begin
        if (iclkena) begin
          oval <= ival;
        end
      end

      //assign odat_re = rslt_re[cMULT_W-pMUL_W-1 -: pODAT_W] ;
      //assign odat_im = rslt_im[cMULT_W-pMUL_W-1 -: pODAT_W] ;

      assign odat_re = (cMULT_W-pMUL_W >= pODAT_W) ? rslt_re[cMULT_W-pMUL_W-1 -: pODAT_W] : {{(pODAT_W-cMULT_W+pMUL_W){rslt_re[cMULT_W-1]}}, rslt_re} ;
      assign odat_im = (cMULT_W-pMUL_W >= pODAT_W) ? rslt_im[cMULT_W-pMUL_W-1 -: pODAT_W] : {{(pODAT_W-cMULT_W+pMUL_W){rslt_im[cMULT_W-1]}}, rslt_im} ;
    end
  endgenerate

endmodule
