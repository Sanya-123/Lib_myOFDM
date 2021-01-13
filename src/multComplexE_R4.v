`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.10.2020 13:38:10
// Design Name: 
// Module Name: multComplexE_R4
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: moduul for FFT
// для быльшей точности от умножения тут добавляеться разряд если COMPENS_FP==add
//////////////////////////////////////////////////////////////////////////////////

module multComplexE_R4 #(parameter SIZE_DATA_FI = 4/*LOG2(NFFT)*/,
                      parameter DATA_FFT_SIZE = 16,
                      parameter FAST = "slow",/*slow fast ultrafast slow mult x1 fast mult x2 ultrafast mult x4*/
                      parameter TYPE = "forvard",/*forvard invers*/
                      parameter COMPENS_FP = "false", /*false true or add razrad*/
                      parameter USE_ROUND = 1,/*0 or 1*/
                      parameter USE_DSP = 1/*0 or 1*/)(
    clk,
    en,
    in_data1_i,
    in_data1_q,
    in_data2_i,
    in_data2_q,
    in_data3_i,
    in_data3_q,
    fi_deg,/*NOTE только положительные данные для данного модуля size [SIZE_DATA_FI-2:0]*/
    out_data1_i,
    out_data1_q,
    out_data2_i,
    out_data2_q,
    out_data3_i,
    out_data3_q,
    outValid
    );
    
    localparam _USE_ROUND = USE_ROUND==0 ? 0 : 1;
    localparam _USE_DSP = USE_DSP == 0 ? 0 : 1;
    
    //есть 2 возможных способа увеличенияточности
    //1 увеличивать по 1 биту кажду раз
    //2 data_int = (data_float*2 + 1)/2 
    
    input clk;
    input en;
    input [DATA_FFT_SIZE-1:0] in_data1_i;
    input [DATA_FFT_SIZE-1:0] in_data1_q;
    input [DATA_FFT_SIZE-1:0] in_data2_i;
    input [DATA_FFT_SIZE-1:0] in_data2_q;
    input [DATA_FFT_SIZE-1:0] in_data3_i;
    input [DATA_FFT_SIZE-1:0] in_data3_q;
    input [15:0] fi_deg;
    output [DATA_FFT_SIZE-1 + (COMPENS_FP=="add"?2:0) :0] out_data1_i;
    output [DATA_FFT_SIZE-1 + (COMPENS_FP=="add"?2:0) :0] out_data1_q;
    output [DATA_FFT_SIZE-1 + (COMPENS_FP=="add"?2:0) :0] out_data2_i;
    output [DATA_FFT_SIZE-1 + (COMPENS_FP=="add"?2:0) :0] out_data2_q;
    output [DATA_FFT_SIZE-1 + (COMPENS_FP=="add"?2:0) :0] out_data3_i;
    output [DATA_FFT_SIZE-1 + (COMPENS_FP=="add"?2:0) :0] out_data3_q;
    output reg outValid = 1'b0;

    
//    output reg module_en = 1'b0;
    
    genvar i;
    generate
    if(SIZE_DATA_FI[0] == 1'b1) begin end/*2 8 32 128 ...*/
    else if(SIZE_DATA_FI > 2) /*16 64 256 ...*/
    begin
    

    reg _module_en = 1'b0;
    reg mult = 1'b0;
    reg multDone = 1'b0;

    
    reg [16:0] in_cos1 = 0;
    reg [16:0] in_sin1 = 0;
    reg [16:0] in_cos2 = 0;
    reg [16:0] in_sin2 = 0;
    reg [16:0] in_cos3 = 0;
    reg [16:0] in_sin3 = 0;

    reg [DATA_FFT_SIZE-1:0] in_mult_data1_i;
    reg [DATA_FFT_SIZE-1:0] in_mult_data1_q;
    reg [DATA_FFT_SIZE-1:0] in_mult_data2_i;
    reg [DATA_FFT_SIZE-1:0] in_mult_data2_q;
    reg [DATA_FFT_SIZE-1:0] in_mult_data3_i;
    reg [DATA_FFT_SIZE-1:0] in_mult_data3_q;
    
    wire multComplexComplete;

    cmplx_mixer
    #(
      .pIDAT_W(DATA_FFT_SIZE) ,
      .pDDS_W(17) ,
      .pODAT_W(DATA_FFT_SIZE+2 + (COMPENS_FP=="add"?2:0)) ,
      .pMUL_W(0) ,
      .pCONJ(0) ,
      .pUSE_DSP_ADD(_USE_DSP) , // use altera dsp internal adder or not (differ registers)
      .pUSE_ROUND(_USE_ROUND)
    )
    cmplx_mult1(
      .iclk(clk)    ,
      .ireset(0)  ,
      .iclkena(1'b1) ,
      //
      .ival(mult)    ,
      .idat_re(in_mult_data1_i) ,
      .idat_im(in_mult_data1_q) ,
      //
      .icos(in_cos1)    ,
      .isin(in_sin1)    ,
      //
      .oval(multComplexComplete),
      .odat_re(out_data1_i) ,
      .odat_im(out_data1_q)
    );
    cmplx_mixer
    #(
      .pIDAT_W(DATA_FFT_SIZE) ,
      .pDDS_W(17) ,
      .pODAT_W(DATA_FFT_SIZE+2 + (COMPENS_FP=="add"?2:0)) ,
      .pMUL_W(0) ,
      .pCONJ(0) ,
      .pUSE_DSP_ADD(_USE_DSP) , // use altera dsp internal adder or not (differ registers)
      .pUSE_ROUND(_USE_ROUND)
    )
    cmplx_mult2(
      .iclk(clk)    ,
      .ireset(0)  ,
      .iclkena(1'b1) ,
      //
      .ival(mult)    ,
      .idat_re(in_mult_data2_i) ,
      .idat_im(in_mult_data2_q) ,
      //
      .icos(in_cos2)    ,
      .isin(in_sin2)    ,
      //
      .oval(/*multComplexComplete*/),
      .odat_re(out_data2_i) ,
      .odat_im(out_data2_q)
    );
    cmplx_mixer
    #(
      .pIDAT_W(DATA_FFT_SIZE) ,
      .pDDS_W(17) ,
      .pODAT_W(DATA_FFT_SIZE+2 + (COMPENS_FP=="add"?2:0)) ,
      .pMUL_W(0) ,
      .pCONJ(0) ,
      .pUSE_DSP_ADD(_USE_DSP) , // use altera dsp internal adder or not (differ registers)
      .pUSE_ROUND(_USE_ROUND)
    )
    cmplx_mult3(
      .iclk(clk)    ,
      .ireset(0)  ,
      .iclkena(1'b1) ,
      //
      .ival(mult)    ,
      .idat_re(in_mult_data3_i) ,
      .idat_im(in_mult_data3_q) ,
      //
      .icos(in_cos3)    ,
      .isin(in_sin3)    ,
      //
      .oval(/*multComplexComplete*/),
      .odat_re(out_data3_i) ,
      .odat_im(out_data3_q)
    );

    //(* ram_style="block" *)
    //(* ram_style="distributed" *)
    //(* ram_style="register" *)
    //(* ram_style="ultra" *)
    //специальные cos sin для FFT
    /*(* ram_style="block" *)*/reg [16:0] cos1 [2**(SIZE_DATA_FI)/4-1:0];
    /*(* ram_style="block" *)*/reg [16:0] sin1 [2**(SIZE_DATA_FI)/4-1:0];
    /*(* ram_style="block" *)*/reg [16:0] cos2 [2**(SIZE_DATA_FI)/4-1:0];
    /*(* ram_style="block" *)*/reg [16:0] sin2 [2**(SIZE_DATA_FI)/4-1:0];
    /*(* ram_style="block" *)*/reg [16:0] cos3 [2**(SIZE_DATA_FI)/4-1:0];
    /*(* ram_style="block" *)*/reg [16:0] sin3 [2**(SIZE_DATA_FI)/4-1:0];

    reg [3:0] timer_4clock = 0;
    

    always @(posedge clk)
    begin
        
        if(mult | en)   begin if(timer_4clock < (3 + _USE_ROUND)) timer_4clock <= timer_4clock + 1;end
        else            timer_4clock <= 0;
        
        if(timer_4clock == (3 + _USE_ROUND))       outValid <= 1'b1;
        else /*if(en)*/             outValid <= 1'b0;
        
        if(en)
        begin
            in_cos1 = cos1[fi_deg[SIZE_DATA_FI-3:0]];
            in_cos2 = cos2[fi_deg[SIZE_DATA_FI-3:0]];
            in_cos3 = cos3[fi_deg[SIZE_DATA_FI-3:0]];
            
            if(TYPE == "forvard")
            begin
                in_sin1 = sin1[fi_deg[SIZE_DATA_FI-3:0]];
                in_sin2 = sin2[fi_deg[SIZE_DATA_FI-3:0]];
                in_sin3 = sin3[fi_deg[SIZE_DATA_FI-3:0]];
            end
            else if(TYPE == "invers")
            begin
                in_sin1 = -sin1[fi_deg[SIZE_DATA_FI-3:0]];
                in_sin2 = -sin2[fi_deg[SIZE_DATA_FI-3:0]];
                in_sin3 = -sin3[fi_deg[SIZE_DATA_FI-3:0]];
            end
            
            in_mult_data1_i <= in_data1_i;
            in_mult_data1_q <= in_data1_q;
            in_mult_data2_i <= in_data2_i;
            in_mult_data2_q <= in_data2_q;
            in_mult_data3_i <= in_data3_i;
            in_mult_data3_q <= in_data3_q;
            
            
            if(!mult) mult <= 1'b1;//begin mult(on second clk mult will be done)
            else if((timer_4clock == (3 + _USE_ROUND)) & (en == 1'b0)) mult <= 1'b0;
        end
        else if((timer_4clock == (3 + _USE_ROUND)) & (en == 1'b0)) mult <= 1'b0;
    end

    initial
    begin
        if(SIZE_DATA_FI == 4)//16dot
        begin
            $readmemh("cos16_1.mem",cos1);
            $readmemh("sin16_1.mem",sin1);
            $readmemh("cos16_2.mem",cos2);
            $readmemh("sin16_2.mem",sin2);
            $readmemh("cos16_3.mem",cos3);
            $readmemh("sin16_3.mem",sin3);
        end
        else if(SIZE_DATA_FI == 6)//64dot
        begin
            $readmemh("cos64_1.mem",cos1);
            $readmemh("sin64_1.mem",sin1);
            $readmemh("cos64_2.mem",cos2);
            $readmemh("sin64_2.mem",sin2);
            $readmemh("cos64_3.mem",cos3);
            $readmemh("sin64_3.mem",sin3);
        end
        else if(SIZE_DATA_FI == 8)//256dot
        begin
            $readmemh("cos256_1.mem",cos1);
            $readmemh("sin256_1.mem",sin1);
            $readmemh("cos256_2.mem",cos2);
            $readmemh("sin256_2.mem",sin2);
            $readmemh("cos256_3.mem",cos3);
            $readmemh("sin256_3.mem",sin3);
        end
        
//        for(i = SIZE_DATA_FI/2; i < SIZE_DATA_FI; i=i+1)
//        begin
//            cos1[i] = sin1[i - SIZE_DATA_FI/2];
//            sin1[i] = -cos1[i - SIZE_DATA_FI/2];
//        end
    end
    
    end
    else//в случае если 2 или меньше точек FFT
    begin
        assign out_data1_i = in_data1_i;
        assign out_data1_q = in_data1_q;
    end
    endgenerate
    
    
endmodule
