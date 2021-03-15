`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.03.2021 18:42:14
// Design Name: 
// Module Name: ofdm_freq_sync
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


module ofdm_freq_sync#( parameter DATA_SIZE = 16
                        )(
    i_clk,
    i_reset,
    i_en,
    i_valid,
    in_data_i,
    in_data_q,
    out_data_i,
    out_data_q,
    i_findPreamble_a,
    i_findPreamble_b,
    i_preamble_a_i,
    i_preamble_a_q,
    i_preamble_b_i,
    i_preamble_b_q,
//    out_sync,
    out_valid,
    o_wayt_data
    
    
    ,
    d_phase_a,
    d_phase_b,
    d_begin_phase,
    d_add_phase,
    d_cos,
    d_sin
    );
    
    //WARNING возможно стоит добавить флаг пропуска приамбулы
    
    input i_clk;
    input i_reset;
    input i_en;
    input i_valid;
    input [DATA_SIZE-1:0] in_data_i;
    input [DATA_SIZE-1:0] in_data_q;
    
    output [DATA_SIZE-1:0] out_data_i;
    output [DATA_SIZE-1:0] out_data_q; 
    
    input i_findPreamble_a;
    input i_findPreamble_b;
    
    input [DATA_SIZE+7:0] i_preamble_a_i;
    input [DATA_SIZE+7:0] i_preamble_a_q;
    
    input [DATA_SIZE+7:0] i_preamble_b_i;
    input [DATA_SIZE+7:0] i_preamble_b_q;
    
    output out_valid;
    output o_wayt_data;
    
    output [33:0] d_phase_a;
    output [33:0] d_phase_b;
    
    output [33:0] d_begin_phase;
    output [33:0] d_add_phase;
    
    output [13:0] d_cos;
    output [13:0] d_sin;
    
    
    localparam WAYT_PREAMBLE_A  =   2'b00;
    localparam WAYT_PREAMBLE_B  =   2'b01;
    localparam CALC_OFFSET      =   2'b10;
    localparam OUTPUT_DATA      =   2'b11;
    
    reg [1:0] state = WAYT_PREAMBLE_A;
    
    reg [DATA_SIZE+7:0] r_preamble_a_i;
    reg [DATA_SIZE+7:0] r_preamble_a_q;
    
    reg [DATA_SIZE+7:0] r_preamble_b_i;
    reg [DATA_SIZE+7:0] r_preamble_b_q;
    
    //calc phase
    reg en_phase_a = 0;
    reg en_phase_b = 0;
    wire valid_phase_a;
    wire valid_phase_b;
    reg d1_valid_phase_a = 0;
    reg d1_valid_phase_b = 0;
    
    wire [31:0] qo_phase_a;
    wire [31:0] qo_phase_b;
    
    wire [1:0] qo_quart_a;
    wire [1:0] qo_quart_b;
    
    reg [33:0] phase_a;
    reg [33:0] phase_b;
    
    reg [33:0] begin_phase;
    reg [33:0] add_phase;
    
    wire [13:0] cos;
    wire [13:0] sin;
    
    reg en_dds = 1'b0;
    
    assign o_wayt_data = state != CALC_OFFSET;
    
    assign d_phase_a = phase_a;
    assign d_phase_b = phase_b;
    
    assign d_begin_phase = begin_phase;
    assign d_add_phase = add_phase;
    
    assign d_cos = cos;
    assign d_sin = sin;
    
//    reg offset_
    
    always @(posedge i_clk)
    begin : RECIVE_PREAMBLE_VALUE
        if(i_findPreamble_a)        r_preamble_a_i <= i_preamble_a_i;
        if(i_findPreamble_a)        r_preamble_a_q <= i_preamble_a_q;
        
        if(i_findPreamble_b)        r_preamble_b_i <= i_preamble_b_i;
        if(i_findPreamble_b)        r_preamble_b_q <= i_preamble_b_q;
    end
    
    always @(posedge i_clk)
    begin : FSM
        if(i_reset)         state <= WAYT_PREAMBLE_A;
        else
        begin
            if(i_findPreamble_a)                                                        state <= WAYT_PREAMBLE_B;
            /*найдена преамбула A после преамбулы Б*/
            else if((state == WAYT_PREAMBLE_B) && i_findPreamble_b)                     state <= CALC_OFFSET;
            /*1 такт на расчет оффсета*/
            else if((state == CALC_OFFSET) && d1_valid_phase_a && d1_valid_phase_b)     state <= OUTPUT_DATA;
            /*если найденна преамбула Б а преамбула А не найдена то данный кадр будет пропушен*/
            else if(i_findPreamble_b)                                                   state <= WAYT_PREAMBLE_A;
        end
    end
    
    always @(posedge i_clk)
    begin
        d1_valid_phase_a <= valid_phase_a;
        d1_valid_phase_b <= valid_phase_b;
    end
    
    always @(posedge i_clk)
    begin
        if(i_reset) en_dds <= 1'b0;
        else if(state == WAYT_PREAMBLE_A)               en_dds <= 1'b0;
        else if(state == WAYT_PREAMBLE_B)               en_dds <= 1'b0;
        else if(d1_valid_phase_a && d1_valid_phase_b)   en_dds <= 1'b1;
    end
    
    always @(posedge i_clk)
    begin : CALC_FREQ_OFFSET
        if(state == CALC_OFFSET)
        begin
            en_phase_a <= 1'b1;
            en_phase_b <= 1'b1;
            if(d1_valid_phase_a && d1_valid_phase_b)
            begin
                //begin_phase = -phase_b
                //add_phase = -(phase_b - phase_a)/SIZE_PREAMBLE_B
                //phase = qo_quart == 0 ? phase : qo_quart == 1 ? phase + pi/2 : qo_quart == 3 ? -(pi - phase) : -(pi/2 - phase)
                phase_a[33] <= qo_quart_a[1] == 1'b1;
                phase_a[32] <= qo_quart_a == 0 ? 1'b0 : qo_quart_a == 1 ? 1'b1 : qo_quart_a == 3 ? 1'b0 : 1'b1;
                phase_a[31:0] <= qo_phase_a;
                
                phase_b[33] <= qo_quart_a[1] == 1'b1;
                phase_b[32] <= qo_quart_b == 0 ? 1'b0 : qo_quart_b == 1 ? 1'b1 : qo_quart_b == 3 ? 1'b0 : 1'b1;
                phase_b[31:0] <= qo_phase_b;
            end
        end
        else
        begin
            en_phase_a <= 1'b0;
            en_phase_b <= 1'b0;
        end
    end
    
    always @(posedge i_clk)
    begin
        begin_phase <= -phase_b;
        add_phase <= -(({8'b00000000, phase_b[33:8]} - {8'b00000000, phase_a[33:8]}));
    end
    
    
    
  cordic_atan_qo
  #(
    .pTYPE    ( 0    ) ,
    .pITER    ( 20    ) ,
    .pDAT_W   ( DATA_SIZE+8   ) ,
    .pANG_W   ( 32   ) ,
    .pMAG_W   ( 29   )
  )
  _phase_a
  (
    .iclk    ( i_clk    ) ,
    .ireset  ( i_reset  ) ,
    .iclkena ( /*cordic_atan_qo__iclkena*/1'b1 ) ,
    .ival    ( en_phase_a    ) ,
    .idat_re ( r_preamble_a_i ) ,
    .idat_im ( r_preamble_a_q ) ,
    .oval    ( valid_phase_a    ) ,
    .oquart  ( qo_quart_a  ) ,
    .oangle  ( qo_phase_a  ) ,
    .omag    (     ) ,
    .odat_re (  ) ,
    .odat_im (  )
  );
  
  cordic_atan_qo
  #(
    .pTYPE    ( 0    ) ,
    .pITER    ( 20    ) ,
    .pDAT_W   ( DATA_SIZE+8   ) ,
    .pANG_W   ( 32   ) ,
    .pMAG_W   ( 29   )
  )
  _phase_b
  (
    .iclk    ( i_clk    ) ,
    .ireset  ( i_reset  ) ,
    .iclkena ( /*cordic_atan_qo__iclkena*/1'b1 ) ,
    .ival    ( en_phase_b    ) ,
    .idat_re ( r_preamble_b_i ) ,
    .idat_im ( r_preamble_b_q ) ,
    .oval    ( valid_phase_b    ) ,
    .oquart  ( qo_quart_b  ) ,
    .oangle  ( qo_phase_b  ) ,
    .omag    (     ) ,
    .odat_re (  ) ,
    .odat_im (  )
  );
  
  dds
  #(
    .pFR_W  ( 34  ) ,
    .pPH_W  ( 15  ) ,
    .pDDS_W ( 14 )
  )
  dds1
  (
    .iclk    ( i_clk    ) ,
    .ireset  ( (!en_dds) || i_reset  ) ,
    .iclkena ( en_dds ) ,
    .ifreq   ( add_phase   ) ,
    .iph_cos ( begin_phase[33:19] ) ,
    .iph_sin ( begin_phase[33:19] ) ,
    .osin    ( cos    ) ,
    .ocos    ( sin    )
  );
  
    cmplx_mixer
    #(
      .pIDAT_W(DATA_SIZE) ,
      .pDDS_W(14) ,
      .pODAT_W(DATA_SIZE) ,
      .pMUL_W(0) ,
      .pCONJ(0) ,
      .pUSE_DSP_ADD(1) , // use altera dsp internal adder or not (differ registers)
      .pUSE_ROUND(1)
    )
    cmplx_mult1(
      .iclk(i_clk)    ,
      .ireset(i_reset)  ,
      .iclkena(1'b1) ,
      //
      .ival(state == OUTPUT_DATA)    ,
      .idat_re(in_data_i) ,
      .idat_im(in_data_q) ,
      //
      .icos(cos)    ,
      .isin(sin)    ,
      //
      .oval(out_valid),
      .odat_re(out_data_i) ,
      .odat_im(out_data_q)
    );    
    
    
endmodule
