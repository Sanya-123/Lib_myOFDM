`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.10.2020 13:38:10
// Design Name: 
// Module Name: multComplexE
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

module multComplexE #(parameter SIZE_DATA_FI = 2/*LOG2(NFFT)*/,
                      parameter DATA_FFT_SIZE = 16,
                      parameter FAST = "slow",/*slow fast ultrafast slow mult x1 fast mult x2 ultrafast mult x4*/
                      parameter TYPE = "forvard",/*forvard invers*/
                      parameter COMPENS_FP = "false" /*false true or add razrad*/)(
    clk,
    en,
    in_data_i,
    in_data_q,
    fi_deg,/*NOTE только положительные данные для данного модуля size [SIZE_DATA_FI-2:0]*/
    out_data_minus_i,
    out_data_minus_q,
    out_data_plus_i,
    out_data_plus_q,
    outValid
    /*debug flasg*/
//    minusReady,
//    plusReady,
//    module_en
    );
    
    //есть 2 возможных способа увеличенияточности
    //1 увеличивать по 1 биту кажду раз
    //2 data_int = (data_float*2 + 1)/2 
    
    input clk;
    input en;
    input [DATA_FFT_SIZE-1:0] in_data_i;
    input [DATA_FFT_SIZE-1:0] in_data_q;
    input [15:0] fi_deg;
    output [DATA_FFT_SIZE-1 + (COMPENS_FP=="add"?1:0) :0] out_data_minus_i;
    output [DATA_FFT_SIZE-1 + (COMPENS_FP=="add"?1:0) :0] out_data_minus_q;
    output [DATA_FFT_SIZE-1 + (COMPENS_FP=="add"?1:0) :0] out_data_plus_i;
    output [DATA_FFT_SIZE-1 + (COMPENS_FP=="add"?1:0) :0] out_data_plus_q;
    output reg outValid = 1'b0;
    
    //входные данные 1 а фазы то зеркальные
    assign out_data_plus_i = -out_data_minus_i;
    assign out_data_plus_q = -out_data_minus_q;
    
//    output reg module_en = 1'b0;
    
    genvar i;
    generate
    if(SIZE_DATA_FI > 2) 
    begin
    

    reg _module_en = 1'b0;
    reg mult = 1'b0;
    reg multDone = 1'b0;

    
    reg [16:0] in_cos = 0;
    reg [16:0] in_sin = 0;
    
//    wire [31:0] outData_i;
//    wire [31:0] outData_q;

    reg [DATA_FFT_SIZE-1:0] in_mult_data_i;
    reg [DATA_FFT_SIZE-1:0] in_mult_data_q;
    
    wire multComplexComplete;

    cmplx_mixer
    #(
      .pIDAT_W(DATA_FFT_SIZE) ,
      .pDDS_W(17) ,
      .pODAT_W(DATA_FFT_SIZE+2 + (COMPENS_FP=="add"?1:0)) ,
      .pMUL_W(0) ,
      .pCONJ(0) ,
      .pUSE_DSP_ADD(1) , // use altera dsp internal adder or not (differ registers)
      .pUSE_ROUND(0)
    )
    cmplx_mult(
      .iclk(clk)    ,
      .ireset(0)  ,
      .iclkena(1'b1) ,
      //
      .ival(mult)    ,
      .idat_re(/*in_data_i*/in_mult_data_i) ,
      .idat_im(/*in_data_q*/in_mult_data_q) ,
      //
      .icos(in_cos)    ,
      .isin(in_sin)    ,
      //
      .oval(multComplexComplete),
      .odat_re(out_data_minus_i) ,
      .odat_im(out_data_minus_q)
    );

    //(* ram_style="block" *)
    //(* ram_style="distributed" *)
    //(* ram_style="register" *)
    //(* ram_style="ultra" *)
    //специальные cos sin для FFT
    /*(* ram_style="block" *)*/reg [16:0] cos [2**(SIZE_DATA_FI)/2-1:0];
    /*(* ram_style="block" *)*/reg [16:0] sin [2**(SIZE_DATA_FI)/2-1:0];

    reg [3:0] timer_4clock = 0;
    
    
//    always @(posedge clk)
//    begin
        
//        if(mult)        timer_4clock <= timer_4clock + 1;
//        else if(en)     timer_4clock <= 1;
//        else            timer_4clock <= 0;
        
//        if(timer_4clock == 3)   outValid <= 1'b1;
//        else if(en)             outValid <= 1'b0;
        
//        if(en)
//        begin
//            if(!mult)   in_cos = cos[fi_deg[SIZE_DATA_FI-2:0]];
//            if(TYPE == "forvard")
//            begin
//            if(!mult)   in_sin = sin[fi_deg[SIZE_DATA_FI-2:0]];
//            end
//            else if(TYPE == "invers")
//            begin
//            if(!mult)   in_sin = -sin[fi_deg[SIZE_DATA_FI-2:0]];
//            end
            
            
//            if(!mult) mult <= 1'b1;//begin mult(on second clk mult will be done)
//            else if(timer_4clock == 3) mult <= 1'b0;
//        end
//        else if(timer_4clock == 3) mult <= 1'b0;
//    end

    always @(posedge clk)
    begin
        
        if(mult | en)   begin if(timer_4clock < 3) timer_4clock <= timer_4clock + 1;end
        else            timer_4clock <= 0;
        
        if(timer_4clock == 3)   outValid <= 1'b1;
        else /*if(en)*/             outValid <= 1'b0;
        
        if(en)
        begin
            in_cos = cos[fi_deg[SIZE_DATA_FI-2:0]];
            
            if(TYPE == "forvard")
            begin
                in_sin = sin[fi_deg[SIZE_DATA_FI-2:0]];
            end
            else if(TYPE == "invers")
            begin
                in_sin = -sin[fi_deg[SIZE_DATA_FI-2:0]];
            end
            
            in_mult_data_i <= in_data_i;
            in_mult_data_q <= in_data_q;
            
            
            if(!mult) mult <= 1'b1;//begin mult(on second clk mult will be done)
            else if((timer_4clock == 3) & (en == 1'b0)) mult <= 1'b0;
        end
        else if((timer_4clock == 3) & (en == 1'b0)) mult <= 1'b0;
    end

    initial
    begin
        if(SIZE_DATA_FI == 2)//8dot
        begin
            $readmemh("cos4.mem",cos);
            $readmemh("sin4.mem",sin);
        end
        else if(SIZE_DATA_FI == 3)//8dot
        begin
            $readmemh("cos8.mem",cos);
            $readmemh("sin8.mem",sin);
        end
        else if(SIZE_DATA_FI == 4)//16dot
        begin
            $readmemh("cos16.mem",cos);
            $readmemh("sin16.mem",sin);
        end
        else if(SIZE_DATA_FI == 5)//32dot
        begin
            $readmemh("cos32.mem",cos);
            $readmemh("sin32.mem",sin);
        end
        else if(SIZE_DATA_FI == 6)//64dot
        begin
            $readmemh("cos64.mem",cos);
            $readmemh("sin64.mem",sin);
        end
        else if(SIZE_DATA_FI == 7)//128dot
        begin
            $readmemh("cos128.mem",cos);
            $readmemh("sin128.mem",sin);
        end
        else if(SIZE_DATA_FI == 8)//256dot
        begin
            $readmemh("cos256.mem",cos);
            $readmemh("sin256.mem",sin);
        end
        
//        for(i = SIZE_DATA_FI/2; i < SIZE_DATA_FI; i=i+1)
//        begin
//            cos[i] = sin[i - SIZE_DATA_FI/2];
//            sin[i] = -cos[i - SIZE_DATA_FI/2];
//        end
    end
    
    end
    else if(SIZE_DATA_FI == 2)//если 4 точки в этом случае все просто
    begin
        reg multDone = 1'b0;
        
        reg [DATA_FFT_SIZE-1:0] data_i;
        reg [DATA_FFT_SIZE-1:0] data_q;
        assign out_data_minus_i = data_i;
        assign out_data_minus_q = data_q;
        always @(posedge clk)
        begin
            if(/*module_en*/en)
            begin
                multDone <= 1'b1;
                if(TYPE == "forvard")
                begin
                    if(fi_deg[0])   data_i <= in_data_q;
                    else            data_i <= in_data_i;
                    if(fi_deg[0])   data_q <= -in_data_i;
                    else            data_q <= in_data_q;
                end
                else if(TYPE == "invers")
                begin
                    if(fi_deg[0])   data_i <= -in_data_q;
                    else            data_i <= in_data_i;
                    if(fi_deg[0])   data_q <= in_data_i;
                    else            data_q <= in_data_q;
                end
            end
            else
            begin
                multDone <= 1'b0;
            end
        end
        
    end
    else//в случае если 2 или меньше точек FFT
    begin
    assign out_data_minus_i = in_data_i;
    assign out_data_minus_q = in_data_q;
    end
    endgenerate
    
    
endmodule
