`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.03.2021 16:37:35
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


/*



  parameter int pTYPE     = 0  ;
  parameter int pITER     = 20 ;
  parameter int pDAT_W    = 20 ;
  parameter int pANG_W    = 30 ;
  parameter int pMAG_W    = 25 ;


  logic                        cordic_atan_qo__iclk     ;
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
    .ireset  ( cordic_atan_qo__ireset  ) ,
    .iclkena ( cordic_atan_qo__iclkena ) ,
    .ival    ( cordic_atan_qo__ival    ) ,
    .idat_re ( cordic_atan_qo__idat_re ) ,
    .idat_im ( cordic_atan_qo__idat_im ) ,
    .oval    ( cordic_atan_qo__oval    ) ,
    .oquart  ( cordic_atan_qo__oquart  ) ,
    .oangle  ( cordic_atan_qo__oangle  ) ,
    .omag    ( cordic_atan_qo__omag    ) ,
    .odat_re ( cordic_atan_qo__odat_re ) ,
    .odat_im ( cordic_atan_qo__odat_im )
  );


  assign cordic_atan_qo__iclk    = '0 ;
  assign cordic_atan_qo__ireset  = '0 ;
  assign cordic_atan_qo__iclkena = '0 ;
  assign cordic_atan_qo__ival    = '0 ;
  assign cordic_atan_qo__idat_re = '0 ;
  assign cordic_atan_qo__idat_im = '0 ;



*/

// module of cordic method calculate atan
// output in limit 0 .. pi/2
// Max iteration number is 20
//
// Angle = oangle + pi/2 * oquart;
// oquart = 2'b00 - I; 2'b01 - II; 2'b11 - III; 2'b10 - IV;
//
// cordic data output delay = (pITER + 2)

module cordic_atan_qo
#(
  parameter int pTYPE     = 0  ,   // type of angle output in 0 - bin, 1 - rad, 2 - deg,
  parameter int pITER     = 20 ,   // number of iteration 1..20
  parameter int pDAT_W    = 20 ,
  parameter int pANG_W    = 30 ,
  parameter int pMAG_W    = 25
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
  oquart  ,
  oangle  ,
  omag    ,
  odat_re ,
  odat_im
);

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                 iclk     ;
  input  logic                 ireset   ;
  input  logic                 iclkena  ;
  //
  input  logic                 ival     ;
  input  logic  [pDAT_W-1 : 0] idat_re  ;
  input  logic  [pDAT_W-1 : 0] idat_im  ;
  //
  output logic                 oval     ;
  output logic         [1 : 0] oquart   ;
  output logic  [pANG_W-1 : 0] oangle   ;
  output logic  [pMAG_W-1 : 0] omag     ;
  output logic  [pDAT_W-1 : 0] odat_re  ;
  output logic  [pDAT_W-1 : 0] odat_im  ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam int cANGLE_W = 30;
  localparam int cDAT_ADD_W =  pITER; // expanding of width data line
  localparam int cDAT_W = pDAT_W + 1 + cDAT_ADD_W;

  // Angle tab:
  // binary
  // radians [0 bit.29 bit]
  // degrees [6 bit.23 bit]

  localparam logic [cANGLE_W-1 : 0] angle_tab[0 : 2][0 : 19] =
  '{ '{ 30'h20000000, 30'h12E4051E, 30'h09FB385B, 30'h051111D4, 30'h028B0D43, 30'h0145D7E1, 30'h00A2F61E,
         30'h00517C55, 30'h0028BE53, 30'h00145F2F, 30'h000A2F98, 30'h000517CC, 30'h00028BE6, 30'h000145F3,
         30'h0000A2FA, 30'h0000517D, 30'h000028BE, 30'h0000145F, 30'h00000A30, 30'h00000518 },

    '{ 421657428, 248918915, 131521918, 66762579, 33510843, 16771758, 8387925, 4194219, 2097141, 1048575,
        524288, 262144, 131072, 65536, 32768, 16384, 8192, 4096, 2048, 1024 },

     '{ 377487360, 222843801, 117744544, 59768969, 30000467, 15014858, 7509261, 3754860, 1877459,
        938733, 469367, 234683, 117342, 58671, 29335, 14668, 7334, 3667, 1833, 917 }};

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

                            logic                 [1 : 0] in_angle_quarter = 0;
  (* dont_touch = "true" *) logic signed   [pDAT_W-1 : 0] dat_us_re = 0;
  (* dont_touch = "true" *) logic signed   [pDAT_W-1 : 0] dat_us_im = 0;
                            //
  (* dont_touch = "true" *) logic signed   [cDAT_W-1 : 0] dat_re          [0 : pITER-1] = '{default : 0};
  (* dont_touch = "true" *) logic signed   [cDAT_W-1 : 0] dat_im          [0 : pITER-1] = '{default : 0};
                            //
                            logic signed   [cANGLE_W : 0] angle          [0 : pITER-1] = '{default : 0}; // + 1 bit for sign
                            logic                 [1 : 0] angle_quarter  [0 : pITER-1] = '{default : 0};
                            //
                            logic             [pITER : 0] val_delay_line = 0;

                            logic          [pDAT_W-1 : 0] dat_re_delay_line [0 : pITER] = '{default : 0};
                            logic          [pDAT_W-1 : 0] dat_im_delay_line [0 : pITER] = '{default : 0};

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------
  // synthesis translate_off
  initial begin : ini
//    in_angle_quarter   <= '0 ;
//    dat_us_re          <= '0 ;
//    dat_us_im          <= '0 ;
//    dat_re             <= '{default : 0};
//    dat_im             <= '{default : 0};
//    angle              <= '{default : 0};
//    angle_quarter      <= '{default : 0};
//    val_delay_line     <= '0 ;
//    dat_re_delay_line  <= '{default : 0};
//    dat_im_delay_line  <= '{default : 0};
  end
  // synthesis translate_on
  //------------------------------------------------------------------------------------------------------
  // input data rotator
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk) begin
    if (iclkena & ival) begin
      case ({idat_re[pDAT_W-1], idat_im[pDAT_W-1]})
        2'b00: begin
          // I quarter - not rotate
          dat_us_re <= (idat_re ^ {{pDAT_W}{idat_re[pDAT_W-1]}}) + idat_re[pDAT_W-1];
          dat_us_im <= (idat_im ^ {{pDAT_W}{idat_im[pDAT_W-1]}}) + idat_im[pDAT_W-1];
          in_angle_quarter <= 2'b00;
        end
        2'b10: begin
          // II quarter - rotate
          dat_us_re <= (idat_im ^ {{pDAT_W}{idat_im[pDAT_W-1]}}) + idat_im[pDAT_W-1];
          dat_us_im <= (idat_re ^ {{pDAT_W}{idat_re[pDAT_W-1]}}) + idat_re[pDAT_W-1];
          in_angle_quarter <= 2'b01;
        end
        2'b11: begin
          // III quarter - not rotate
          dat_us_re <= (idat_re ^ {{pDAT_W}{idat_re[pDAT_W-1]}}) + idat_re[pDAT_W-1];
          dat_us_im <= (idat_im ^ {{pDAT_W}{idat_im[pDAT_W-1]}}) + idat_im[pDAT_W-1];
          in_angle_quarter <= 2'b11;
        end
        2'b01: begin
          // IV quarter - rotate
          dat_us_re <= (idat_im ^ {{pDAT_W}{idat_im[pDAT_W-1]}}) + idat_im[pDAT_W-1];
          dat_us_im <= (idat_re ^ {{pDAT_W}{idat_re[pDAT_W-1]}}) + idat_re[pDAT_W-1];
          in_angle_quarter <= 2'b10;
        end
      endcase
    end
  end

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk or posedge ireset) begin
    if (ireset) begin
      val_delay_line <= '0;
    end
    else if (iclkena) begin
      val_delay_line  <= (val_delay_line << 1) | ival;
    end
  end

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      dat_re_delay_line[0] <= idat_re;
      dat_im_delay_line[0] <= idat_im;
      angle_quarter[0]     <= in_angle_quarter;

      dat_re[0] <= (dat_us_re <<< cDAT_ADD_W) + (dat_us_im <<< cDAT_ADD_W);
      dat_im[0] <= (dat_us_im <<< cDAT_ADD_W) - (dat_us_re <<< cDAT_ADD_W);

      angle[0] <= $signed({1'b0,angle_tab[pTYPE][0]});

      for (int i = 1; i < pITER; i++) begin
        angle_quarter[i]  <= angle_quarter[i-1];
        dat_re_delay_line[i] <= dat_re_delay_line[i-1];
        dat_im_delay_line[i] <= dat_im_delay_line[i-1];
        //
        if (~dat_im[i-1][cDAT_W-1]) begin
          dat_re[i] <= dat_re[i-1] + (dat_im[i-1] >>> i);
          dat_im[i] <= dat_im[i-1] - (dat_re[i-1] >>> i);
          //
          angle[i] <= angle[i-1] + angle_tab[pTYPE][i];
        end
        else begin
          dat_re[i] <= dat_re[i-1] - (dat_im[i-1] >>> i);
          dat_im[i] <= dat_im[i-1] + (dat_re[i-1] >>> i);
          //
          angle[i] <= angle[i-1] - angle_tab[pTYPE][i];
        end
      end
      //
      dat_re_delay_line[pITER] <= dat_re_delay_line[pITER-1];
      dat_im_delay_line[pITER] <= dat_im_delay_line[pITER-1];
      //
      odat_re <= dat_re_delay_line[pITER];
      odat_im <= dat_im_delay_line[pITER];
      //
      oval   <= val_delay_line[pITER];
      oquart <= angle_quarter[pITER-1];
    end
  end

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

generate
if (cANGLE_W >= pANG_W) begin
  always_ff @(posedge iclk) if (iclkena) begin // if angle is nagative, set null to output
    oangle <= (angle[pITER-1][cANGLE_W])? '0 : angle[pITER-1][cANGLE_W-1 : cANGLE_W-pANG_W];
  end
end
else begin
  always_ff @(posedge iclk) if (iclkena) begin // if angle is nagative, set null to output
    oangle <= (angle[pITER-1][cANGLE_W])? '0 : { angle[pITER-1][cANGLE_W-1 : 0], {(pANG_W-cANGLE_W){1'b0}} };
  end
end
endgenerate

generate
if (cDAT_W >= pMAG_W) begin
  always_ff @(posedge iclk) if (iclkena) begin
    omag <= dat_re[pITER-1][cDAT_W-1 : cDAT_W-pMAG_W];
  end
end
else begin
  always_ff @(posedge iclk) if (iclkena) begin
    omag <= { {(pMAG_W-cDAT_W){1'b0}}, dat_re[pITER-1][cDAT_W-1 : 0] };
  end
end
endgenerate

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

endmodule