/*



  parameter int pFR_W   = 32 ;
  parameter int pPH_W   = 15 ;
  parameter int pDDS_W  = 14 ;



  logic                dds__iclk     ;
  logic                dds__ireset   ;
  logic                dds__iclkena  ;
  logic  [pFR_W-1 : 0] dds__ifreq    ;
  logic  [pPH_W-1 : 0] dds__iph_cos  ;
  logic  [pPH_W-1 : 0] dds__iph_sin  ;
  logic [pDDS_W-1 : 0] dds__osin     ;
  logic [pDDS_W-1 : 0] dds__ocos     ;



  dds
  #(
    .pFR_W  ( pFR_W  ) ,
    .pPH_W  ( pPH_W  ) ,
    .pDDS_W ( pDDS_W )
  )
  dds
  (
    .iclk    ( dds__iclk    ) ,
    .ireset  ( dds__ireset  ) ,
    .iclkena ( dds__iclkena ) ,
    .ifreq   ( dds__ifreq   ) ,
    .iph_cos ( dds__iph_cos ) ,
    .iph_sin ( dds__iph_sin ) ,
    .osin    ( dds__osin    ) ,
    .ocos    ( dds__ocos    )
  );


  assign dds__iclk    = '0 ;
  assign dds__ireset  = '0 ;
  assign dds__iclkena = '0 ;
  assign dds__ifreq   = '0 ;
  assign dds__iph_cos = '0 ;
  assign dds__iph_sin = '0 ;



*/



module dds
#(
  parameter int pFR_W   = 32 ,
  parameter int pPH_W   = 15 ,  // fixed don't change
  parameter int pDDS_W  = 14    // fixed don't change
)
(
  iclk    ,
  ireset  ,
  iclkena ,
  ifreq   ,
  iph_cos ,
  iph_sin ,
  osin    ,
  ocos
);

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  input  logic                iclk      ;
  input  logic                ireset    ;
  input  logic                iclkena   ;
  input  logic  [pFR_W-1 : 0] ifreq     ;
  input  logic  [pPH_W-1 : 0] iph_cos   ;
  input  logic  [pPH_W-1 : 0] iph_sin   ;
  output logic [pDDS_W-1 : 0] osin = '0 ;
  output logic [pDDS_W-1 : 0] ocos = '0 ;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  localparam bit [pPH_W-2 : 0] cROM_ADDR_MAX = {1'b1, {(pPH_W-2){1'b0}}};

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  logic [pFR_W-1 : 0] phase_acc = '0;
  logic [pPH_W-1 : 0] sin_phase = '0;
  logic [pPH_W-1 : 0] cos_phase = '0;

  logic       [3 : 0] sin_sign = '0;
  logic       [3 : 0] cos_sign = '0;

  logic [pPH_W-2 : 0] cos_addr2sat = '0;
  logic [pPH_W-2 : 0] sin_addr2sat = '0;

  logic [pPH_W-3 : 0] cos_addr = '0;
  logic [pPH_W-3 : 0] sin_addr = '0;

  logic [pDDS_W-2 : 0] rom_ocos ;
  logic [pDDS_W-2 : 0] rom_osin ;

  //------------------------------------------------------------------------------------------------------
  // frequency synthesis
  //------------------------------------------------------------------------------------------------------

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      phase_acc <= phase_acc + ifreq;
      sin_phase <= phase_acc[pFR_W-1 : pFR_W-pPH_W] + iph_sin;
      cos_phase <= phase_acc[pFR_W-1 : pFR_W-pPH_W] + iph_cos;
      //
      case (sin_phase[pPH_W-1 : pPH_W-2])
        2'b00   : begin sin_sign[0] <= 1'b0; sin_addr2sat <=                  sin_phase[pPH_W-3 : 0]; end
        2'b01   : begin sin_sign[0] <= 1'b0; sin_addr2sat <= cROM_ADDR_MAX -  sin_phase[pPH_W-3 : 0]; end
        2'b10   : begin sin_sign[0] <= 1'b1; sin_addr2sat <=                  sin_phase[pPH_W-3 : 0]; end
        2'b11   : begin sin_sign[0] <= 1'b1; sin_addr2sat <= cROM_ADDR_MAX -  sin_phase[pPH_W-3 : 0]; end
        default : begin end
      endcase
      //
      case (cos_phase[pPH_W-1 : pPH_W-2])
        2'b00   : begin cos_sign[0] <= 1'b0; cos_addr2sat <= cROM_ADDR_MAX -  cos_phase[pPH_W-3 : 0]; end
        2'b01   : begin cos_sign[0] <= 1'b1; cos_addr2sat <=                  cos_phase[pPH_W-3 : 0]; end
        2'b10   : begin cos_sign[0] <= 1'b1; cos_addr2sat <= cROM_ADDR_MAX -  cos_phase[pPH_W-3 : 0]; end
        2'b11   : begin cos_sign[0] <= 1'b0; cos_addr2sat <=                  cos_phase[pPH_W-3 : 0]; end
        default : begin end
      endcase
      //
      sin_addr    <= sin_addr2sat[pPH_W-2] ? '1 : sin_addr2sat[pPH_W-3 : 0];
      sin_sign[1] <= sin_sign[0];

      cos_addr    <= cos_addr2sat[pPH_W-2] ? '1 : cos_addr2sat[pPH_W-3 : 0];
      cos_sign[1] <= cos_sign[0];
    end
  end

  //------------------------------------------------------------------------------------------------------
  // rom have 2 tick's delay
  //------------------------------------------------------------------------------------------------------

`ifdef __USE_ALTERA_MACRO__
  altsyncram
  #(
    .address_reg_b              ( "CLOCK0"          ) ,
    .clock_enable_input_a       ( "NORMAL"          ) ,
    .clock_enable_input_b       ( "NORMAL"          ) ,
    .clock_enable_output_a      ( "NORMAL"          ) ,
    .clock_enable_output_b      ( "NORMAL"          ) ,
    .indata_reg_b               ( "CLOCK0"          ) ,
    .init_file                  ( "dds_romb.mif"    ) ,
    .lpm_type                   ( "altsyncram"      ) ,
    .numwords_a                 ( 8192              ) ,
    .numwords_b                 ( 8192              ) ,
    .operation_mode             ( "BIDIR_DUAL_PORT" ) ,
    .outdata_aclr_a             ( "NONE"            ) ,
    .outdata_aclr_b             ( "NONE"            ) ,
    .outdata_reg_a              ( "CLOCK0"          ) ,
    .outdata_reg_b              ( "CLOCK0"          ) ,
    .power_up_uninitialized     ( "FALSE"           ) ,
    .widthad_a                  ( 13                ) ,
    .widthad_b                  ( 13                ) ,
    .width_a                    ( 13                ) ,
    .width_b                    ( 13                ) ,
    .width_byteena_a            ( 1                 ) ,
    .width_byteena_b            ( 1                 ) ,
    .wrcontrol_wraddress_reg_b  ( "CLOCK0"          )
  )
  rom
    (
    .address_a ( cos_addr ) ,
    .address_b ( sin_addr ) ,
    .clock0    ( iclk     ) ,
    .clocken0  ( iclkena  ) ,
    .data_a    ( 13'h0    ) ,
    .data_b    ( 13'h0    ) ,
    .wren_a    ( 1'b0     ) ,
    .wren_b    ( 1'b0     ) ,
    .q_a       ( rom_ocos ) ,
    .q_b       ( rom_osin )
    // synopsys translate_off
    ,
    .aclr0 (),
    .aclr1 (),
    .addressstall_a (),
    .addressstall_b (),
    .byteena_a (),
    .byteena_b (),
    .clock1 (),
    .clocken0 (),
    .clocken1 (),
    .clocken2 (),
    .clocken3 (),
    .eccstatus (),
    .rden_a (),
    .rden_b ()
    // synopsys translate_on
  );
`else
  dds_romb
  rom
  (
    .iclk    ( iclk     ) ,
    .iclkena ( iclkena  ) ,
    .iadr0   ( cos_addr ) ,
    .iadr1   ( sin_addr ) ,
    .odat0   ( rom_ocos ) ,
    .odat1   ( rom_osin )
  );
`endif

  always_ff @(posedge iclk) begin
    if (iclkena) begin
      sin_sign[3 : 2] <= sin_sign[2 : 1];
      cos_sign[3 : 2] <= cos_sign[2 : 1];
      //
      osin <= ({1'b0, rom_osin} ^ {(pDDS_W){sin_sign[3]}}) + sin_sign[3];
      ocos <= ({1'b0, rom_ocos} ^ {(pDDS_W){cos_sign[3]}}) + cos_sign[3];
    end
  end

endmodule