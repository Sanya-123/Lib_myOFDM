`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.11.2020 11:54:49
// Design Name: 
// Module Name: interconnect_four_sFFT_to_mFFT
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


module interconnect_four_sFFT_to_mFFT #(parameter SIZE_BUFFER = 1,/*log2(NFFT)*/
                                       parameter SIZE_OUT_DATA_S_FFT = 16,
                                       parameter SIZE_OUT_DATA = 16,
                                       parameter TYPE = "forvard",/*forvard invers*/
                                       parameter COMPENS_FP = "false", /*false true or add razrad*/
                                       parameter FAST = "slow",/*slow fast ultrafast slow mult x1 fast mult x2 ultrafast mult x4*/
                                       parameter USE_ROUND = 1,/*0 or 1*/
                                       parameter USE_DSP = 1,/*0 or 1*/
                                       parameter PARAPEL_THIS_FFT = 1)
    (
        clk,
        reset,
        
        data_from_secondFFT_0_i,
        data_from_secondFFT_0_q,
        data_from_secondFFT_1_i,
        data_from_secondFFT_1_q,
        data_from_secondFFT_2_i,
        data_from_secondFFT_2_q,
        data_from_secondFFT_3_i,
        data_from_secondFFT_3_q,
        
        flag_complete_0,
        flag_complete_1,
        flag_complete_2,
        flag_complete_3,
        
        resiveFrom_0,
        resiveFrom_1,
        resiveFrom_2,
        resiveFrom_3,
        
        mutDone,
        
        out_summ_0_i,
        out_summ_0_q,
        out_summ_1_i,
        out_summ_1_q,
        out_summ_2_i,
        out_summ_2_q,
        out_summ_3_i,
        out_summ_3_q,
        
        counterMultData2,
    

        dataComplete
    );
    
    localparam NFFT = 1 << SIZE_BUFFER;
    
    input clk;
    input reset;
    
    input [SIZE_OUT_DATA_S_FFT-1:0] data_from_secondFFT_0_i;
    input [SIZE_OUT_DATA_S_FFT-1:0] data_from_secondFFT_0_q;
    input [SIZE_OUT_DATA_S_FFT-1:0] data_from_secondFFT_1_i;
    input [SIZE_OUT_DATA_S_FFT-1:0] data_from_secondFFT_1_q;
    input [SIZE_OUT_DATA_S_FFT-1:0] data_from_secondFFT_2_i;
    input [SIZE_OUT_DATA_S_FFT-1:0] data_from_secondFFT_2_q;
    input [SIZE_OUT_DATA_S_FFT-1:0] data_from_secondFFT_3_i;
    input [SIZE_OUT_DATA_S_FFT-1:0] data_from_secondFFT_3_q;
    
    input flag_complete_0;
    input flag_complete_1;
    input flag_complete_2;
    input flag_complete_3;
    
    output  resiveFrom_0;
    output  resiveFrom_1;
    output  resiveFrom_2;
    output  resiveFrom_3;
    
    input mutDone;
    
    output [SIZE_OUT_DATA-1:0] out_summ_0_i;
    output [SIZE_OUT_DATA-1:0] out_summ_0_q;
    output [SIZE_OUT_DATA-1:0] out_summ_1_i;
    output [SIZE_OUT_DATA-1:0] out_summ_1_q;
    output [SIZE_OUT_DATA-1:0] out_summ_2_i;
    output [SIZE_OUT_DATA-1:0] out_summ_2_q;
    output [SIZE_OUT_DATA-1:0] out_summ_3_i;
    output [SIZE_OUT_DATA-1:0] out_summ_3_q;
    
    output reg [SIZE_BUFFER-1:0] counterMultData2 = 0;
    
    output dataComplete;
   


//    reg resiveFromChet = 1'b1;
//    reg resiveFromNChet = 1'b1;
            
       /*****************************SLOW FFT*****************************/
    reg enMult = 1'b0;
    reg [15:0] phi = 16'd0;
    
    wire [SIZE_OUT_DATA-1:0] mult_1_i;
    wire [SIZE_OUT_DATA-1:0] mult_1_q;
    wire [SIZE_OUT_DATA-1:0] mult_2_i;
    wire [SIZE_OUT_DATA-1:0] mult_2_q;
    wire [SIZE_OUT_DATA-1:0] mult_3_i;
    wire [SIZE_OUT_DATA-1:0] mult_3_q;
    wire multR4Complete;
    assign resiveFrom_3 = flag_complete_3;//задержка га 1 такс
    
    multComplexE_R4 #(.SIZE_DATA_FI(SIZE_BUFFER)/*LOG2(NFFT)*/, .DATA_FFT_SIZE(SIZE_OUT_DATA_S_FFT), .FAST(FAST), .TYPE(TYPE), .COMPENS_FP(COMPENS_FP), .USE_ROUND(USE_ROUND), .USE_DSP(USE_DSP))
    _multComplexE
        (
        .clk(clk),
        .en(enMult),
        .in_data1_i(data_from_secondFFT_1_i),
        .in_data1_q(data_from_secondFFT_1_q),
        .in_data2_i(data_from_secondFFT_2_i),
        .in_data2_q(data_from_secondFFT_2_q),
        .in_data3_i(data_from_secondFFT_3_i),
        .in_data3_q(data_from_secondFFT_3_q),
        .fi_deg(phi),
        .out_data1_i(mult_1_i),
        .out_data1_q(mult_1_q),
        .out_data2_i(mult_2_i),
        .out_data2_q(mult_2_q),
        .out_data3_i(mult_3_i),
        .out_data3_q(mult_3_q),
        .outValid(multR4Complete)
    );
    
        
    wire [SIZE_OUT_DATA-1:0] w_data_summ_0_i;
    wire [SIZE_OUT_DATA-1:0] w_data_summ_0_q;
    
    if((COMPENS_FP == "add") && (SIZE_OUT_DATA > SIZE_OUT_DATA_S_FFT))//если разная разрядность то должен учитывать знак
    begin
//        assign w_data_summ_chet_i[SIZE_OUT_DATA-1:1] = data_summ_chet_i[SIZE_OUT_DATA_S_FFT-1:0];
//        assign w_data_summ_chet_q[SIZE_OUT_DATA-1:1] = data_summ_chet_q[SIZE_OUT_DATA_S_FFT-1:0];
        
        assign w_data_summ_0_i[SIZE_OUT_DATA-1:2] = data_from_secondFFT_0_i[SIZE_OUT_DATA_S_FFT-1:0];
        assign w_data_summ_0_q[SIZE_OUT_DATA-1:2] = data_from_secondFFT_0_q[SIZE_OUT_DATA_S_FFT-1:0];
        
        assign w_data_summ_0_i[1:0] = 0;
        assign w_data_summ_0_q[1:0] = 0;  
    end
    else
    begin
       
        assign w_data_summ_0_i = data_from_secondFFT_0_i;
        assign w_data_summ_0_q = data_from_secondFFT_0_q;
    end
    
//    assign out_summ_0_i = w_data_summ_0_i;
//    assign out_summ_0_q = w_data_summ_0_q;
//    assign out_summ_1_i = mult_1_i;
//    assign out_summ_1_q = mult_1_q;
//    assign out_summ_2_i = mult_2_i;
//    assign out_summ_2_q = mult_2_q;
//    assign out_summ_3_i = mult_3_i;
//    assign out_summ_3_q = mult_3_q;
//    assign dataComplete = multR4Complete;
    
    fast_myFFT_x4 #(.SIZE_DATA(SIZE_OUT_DATA),
                    .TYPE(TYPE))
    _fast_myFFT_x4(
        .clk(clk),
        .valid(multR4Complete),
        .data0_in_i(w_data_summ_0_i),
        .data0_in_q(w_data_summ_0_q),
        .data1_in_i(mult_1_i),
        .data1_in_q(mult_1_q),
        .data2_in_i(mult_2_i),
        .data2_in_q(mult_2_q),
        .data3_in_i(mult_3_i),
        .data3_in_q(mult_3_q),
        .data0_out_i(out_summ_0_i),
        .data0_out_q(out_summ_0_q),
        .data1_out_i(out_summ_1_i),
        .data1_out_q(out_summ_1_q),
        .data2_out_i(out_summ_2_i),
        .data2_out_q(out_summ_2_q),
        .data3_out_i(out_summ_3_i),
        .data3_out_q(out_summ_3_q),
        .complete(dataComplete)
    );
    
        
    reg beginReadSummData = 1'b0;
    reg flagWayt = 1'b1;//flag ожидать пока начнеться умножения
    
    reg old_flag_complete_3 = 1'b0;
    reg old_old_flag_complete_3 = 1'b0;
    
    reg d1_enMult = 0;
    
    assign resiveFrom_0 = multR4Complete | (!flag_complete_0);
    assign resiveFrom_1 = flag_complete_3;
    assign resiveFrom_2 = flag_complete_3;
    
        
    always @(posedge clk)//summ FFT
    begin : summFFT
        
        if(reset | mutDone)
        begin
            enMult <= 1'b0;
            counterMultData2 <= 0;
            phi <= 0;
        end
        else
        begin
            d1_enMult <= enMult;
//            old_flag_complete_0 <= flag_complete_0;

            
            if(old_flag_complete_3) phi <= phi + 1;
            else    phi <= 0;
            
            old_flag_complete_3 <= flag_complete_3;
            old_old_flag_complete_3 <= old_flag_complete_3;
            
            enMult <= old_old_flag_complete_3 | old_flag_complete_3 | flag_complete_3;
             
//            if(old_flag_complete_3 | flag_complete_3)  enMult <= 1'b1;
//            else if(counterMultData2 == (NFFT/4-2))     enMult <= 1'b0;

            
            if(mutDone)         counterMultData2 <= 0;
            else
            begin
                if(multR4Complete)    counterMultData2 <= counterMultData2 + 1;
                else    counterMultData2 <= 0;
            end
        end
    end
    /*****************************END SLOW FFT*****************************/
            
endmodule
