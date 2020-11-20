`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.10.2020 13:38:10
// Design Name: 
// Module Name: multComplex
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


module multComplex #(parameter SIZE_DATA=16,
                     parameter FAST = "slow",/*slow fast ultrafast slow mult x1 fast mult x2 ultrafast mult x4*/
                     parameter COMPENS_FP = "false" /*false true or add razrad*/)(
    clk,
    en,
    in_data1_i,
    in_data1_q,
    in_data2_i,
    in_data2_q,
    out_data_i,
    out_data_q,
    outputValid
    );
    
    input clk;
    input en;
    input signed [SIZE_DATA-1:0] in_data1_i;
    input signed [SIZE_DATA-1:0] in_data1_q;
    input signed [SIZE_DATA:0] in_data2_i;
    input signed [SIZE_DATA:0] in_data2_q;
    output reg [SIZE_DATA*2-1:0] out_data_i;
    output reg [SIZE_DATA*2-1:0] out_data_q;
    output reg outputValid = 1'b0;
    
    reg vait_summ = 1'b0;
    
   

    reg [SIZE_DATA-1:0] multA;
    reg [SIZE_DATA:0] multB;
    wire [SIZE_DATA*2:0] multRes; 
    mult_fft 
    _mult_fft (
        .CLK(clk),
        .A(multA),
        .B(multB),
        .P(multRes)
    );
    
    reg [SIZE_DATA-1:0] multA_f;
    reg [SIZE_DATA:0] multB_f;
    wire [SIZE_DATA*2:0] multRes_f; 
    
    reg [SIZE_DATA-1:0] multA_uf0;
    reg [SIZE_DATA:0] multB_uf0;
    wire [SIZE_DATA*2:0] multRes_uf0;
    
    reg [SIZE_DATA-1:0] multA_uf1;
    reg [SIZE_DATA:0] multB_uf1;
    wire [SIZE_DATA*2:0] multRes_uf1; 
    
    generate
    if((FAST == "fast") || (FAST == "ultrafast"))
    begin

        mult_fft 
        _mult_fft_f (
            .CLK(clk),
            .A(multA_f),
            .B(multB_f),
            .P(multRes_f)
        );
    end
    
    if(FAST == "ultrafast")
    begin
        mult_fft 
        _mult_fft_uf0 (
            .CLK(clk),
            .A(multA_uf0),
            .B(multB_uf0),
            .P(multRes_uf0)
        );
        
        mult_fft 
        _mult_fft_uf1 (
            .CLK(clk),
            .A(multA_uf1),
            .B(multB_uf1),
            .P(multRes_uf1)
        );
    end
    endgenerate

    reg [SIZE_DATA*2-1:0] mult_i_0;
    reg [SIZE_DATA*2-1:0] mult_i_1;
    reg [SIZE_DATA*2-1:0] mult_q_0;
    reg [SIZE_DATA*2-1:0] mult_q_1;
    
    //	3-MULTIPLIES:
//		It should also be possible to do this with three multiplies
//		and an extra two addition cycles.
//
//		We want
//			R+I = (a + jb) * (c + jd)
//			R+I = (ac-bd) + j(ad+bc)
//		We multiply
//			P1 = ac
//			P2 = bd
//			P3 = (a+b)(c+d)
//		Then
//			R+I=(P1-P2)+j(P3-P2-P1)
    
//    (* use_dsp="no" *) reg [SIZE_DATA*2:0] P1;
//    (* use_dsp="no" *) reg [SIZE_DATA*2:0] P2;
//    (* use_dsp="no" *) reg [SIZE_DATA*2:0] P3;
    
//    (* use_dsp="no" *) reg [SIZE_DATA*2:0] P4;
//    (* use_dsp="no" *) reg [SIZE_DATA*2:0] P5;
//    (* use_dsp="no" *) reg [SIZE_DATA*2:0] P6;

    reg [2:0] multIteration = 3'b000;
    reg vaitMult = 1'b0;
    
    generate
    
    wire ferstIteration;
    assign ferstIteration = en & (multIteration == 3'd0);
    
    always @(posedge clk)
    begin
        if(ferstIteration)    multIteration <= 3'd1;
        
        if(multIteration == 3'd1)           multIteration <= 3'd2;
//        if(multIteration == 3'd2)           multIteration <= 3'd3;
//        if(multIteration == 3'd3)           multIteration <= 3'd4;
        
        if(FAST == "ultrafast")
        begin
            if(COMPENS_FP == "false")
            begin
                if(multIteration == 3'd2)           multIteration <= 3'd0;
            end
            else
            begin
                 if(multIteration == 3'd2)           multIteration <= 3'd3;
                 if(multIteration == 3'd3)           multIteration <= 3'd0;
            end
        end
        else if(FAST == "fast")
        begin
            if(multIteration == 3'd2)           multIteration <= 3'd3;
//            if(multIteration == 3'd3)           multIteration <= 3'd0;
//            if(multIteration == 3'd4)           multIteration <= 3'd0;

            if(COMPENS_FP == "false")
            begin
                if(multIteration == 3'd3)           multIteration <= 3'd0;
            end
            else
            begin
                 if(multIteration == 3'd3)           multIteration <= 3'd4;
                 if(multIteration == 3'd4)           multIteration <= 3'd0;
            end
        end
        else if(FAST == "slow")
        begin
            if(multIteration == 3'd2)           multIteration <= 3'd3;
            if(multIteration == 3'd3)           multIteration <= 3'd4;
            if(multIteration == 3'd4)           multIteration <= 3'd5;
            if(multIteration == 3'd5)           multIteration <= 3'd6;
//            if(multIteration == 3'd6)           multIteration <= 3'd0;
            
            if(COMPENS_FP == "false")
            begin
                if(multIteration == 3'd6)           multIteration <= 3'd0;
            end
            else
            begin
                 if(multIteration == 3'd6)           multIteration <= 3'd7;
                 if(multIteration == 3'd7)           multIteration <= 3'd0;
            end
        end
        
          
        
        if(ferstIteration)           multA <= in_data1_i;
        if(ferstIteration)           multB <= in_data2_i;
        
        if((FAST == "fast") || (FAST == "ultrafast"))
        begin
            if(ferstIteration)       multA_f <= in_data1_q;
            if(ferstIteration)       multB_f <= in_data2_q;
        end
        
        if(FAST == "ultrafast")
        begin
            if(ferstIteration)       multA_uf0 <= in_data1_i;
            if(ferstIteration)       multB_uf0 <= in_data2_q;
            
            if(ferstIteration)       multA_uf1 <= in_data1_q;
            if(ferstIteration)       multB_uf1 <= in_data2_i;
        end
        
        if((FAST == "fast") || FAST == "slow")
        begin
            if(multIteration == 3'd1)           multA <= in_data1_i;
            if(multIteration == 3'd1)           multB <= in_data2_q;
        end
        
        if(FAST == "fast")
        begin
            if(multIteration == 3'd1)       multA_f <= in_data1_q;
            if(multIteration == 3'd1)       multB_f <= in_data2_i;
        end
        
        if(FAST == "slow")
        begin
            if(multIteration == 3'd2)       multA <= in_data1_q;
            if(multIteration == 3'd2)       multB <= in_data2_q;
            
            if(multIteration == 3'd3)       multA <= in_data1_q;
            if(multIteration == 3'd3)       multB <= in_data2_i;
        end
        
        
        
        if(FAST == "slow")
        begin
            if(multIteration == 3'd2)           mult_i_0 <= multRes;
            if(multIteration == 3'd3)           mult_q_0 <= multRes;
            if(multIteration == 3'd4)           mult_i_1 <= multRes;
            if(multIteration == 3'd5)           mult_q_1 <= multRes;
        end
        else if(FAST == "fast")
        begin
//            if(multIteration == 3'd2)           mult_i_0 <= multRes;
//            if(multIteration == 3'd2)           mult_i_1 <= multRes_f;
//            if(multIteration == 3'd3)           mult_q_0 <= multRes;
//            if(multIteration == 3'd3)           mult_q_1 <= multRes_f;
        end
        else if(FAST == "ultrafast")
        begin
//            if(multIteration == 3'd2)           mult_i_0 <= multRes;
//            if(multIteration == 3'd2)           mult_i_1 <= multRes_f;
//            if(multIteration == 3'd2)           mult_q_0 <= multRes_uf0;
//            if(multIteration == 3'd2)           mult_q_1 <= multRes_uf1;
        end
        
        if(FAST == "slow")
        begin
            if(multIteration == 3'd5)           vait_summ <= 1'b1;
            else                                vait_summ <= 1'b0;
        end
        else if(FAST == "fast")
        begin
//            if(multIteration == 3'd4)           vait_summ <= 1'b1;
//            else                                vait_summ <= 1'b0;
        end
        else if(FAST == "ultrafast")
        begin
//            if(multIteration == 3'd3)           vait_summ <= 1'b1;
//            else                                vait_summ <= 1'b0;
        end
        
        
//        if(en)  mult_i_0 <= in_data1_i*in_data2_i;
//        if(en)  mult_q_0 <= in_data1_i*in_data2_q;
//        if(en)  mult_i_1 <= in_data1_q*in_data2_q;
//        if(en)  mult_q_1 <= in_data1_q*in_data2_i;
//        if(en)  P1 <= in_data1_i*in_data2_i;
//        if(en)  P2 <= in_data1_q*in_data2_q;
//        if(en)  P3 <= (in_data1_i + in_data2_i)*(in_data1_q + in_data2_q);
//        if(en)  vait_summ <= 1'b1;
//        else    vait_summ <= 1'b0;
//        if(vait_summ) out_data_i <= P1 - P2;
//        if(vait_summ) out_data_q <= P3 - P2 - P1;

        if(FAST == "slow")
        begin
            if(vait_summ) out_data_i <= mult_i_0 - mult_i_1;
            if(vait_summ) out_data_q <= mult_q_0 + mult_q_1;
            else
            begin 
                if(COMPENS_FP == "true")
                begin
                    if((multIteration == 3'd7))
                    begin  
                        if(out_data_i[SIZE_DATA*2-1])   out_data_i <= out_data_i - 16384;
                        else                            out_data_i <= out_data_i + 16384;
                        
                        if(out_data_q[SIZE_DATA*2-1])   out_data_q <= out_data_q - 16384;
                        else                            out_data_q <= out_data_q + 16384;
                    end
                end
            end
            
            if(COMPENS_FP == "false")
            begin
                if(vait_summ)               outputValid <= 1'b1;
                else                        outputValid <= 1'b0;
            end
            else
            begin
                if(multIteration == 3'd7)   outputValid <= 1'b1;
                else                        outputValid <= 1'b0;
            end
            
        end
        else if(FAST == "fast")
        begin
            if(multIteration == 3'd2)   out_data_i <= multRes - multRes_f;
            if(multIteration == 3'd3)   out_data_q <= multRes + multRes_f;
            else
            begin 
                if(COMPENS_FP == "true")
                begin
                    if((multIteration == 3'd4))
                    begin  
                        if(out_data_i[SIZE_DATA*2-1])   out_data_i <= out_data_i - 16384;
                        else                            out_data_i <= out_data_i + 16384;
                        
                        if(out_data_q[SIZE_DATA*2-1])   out_data_q <= out_data_q - 16384;
                        else                            out_data_q <= out_data_q + 16384;
                    end
                end
            end
            
            if(COMPENS_FP == "false")
            begin
                if(multIteration == 3'd3)   outputValid <= 1'b1;
                else                        outputValid <= 1'b0;
            end
            else
            begin
                if(multIteration == 3'd4)   outputValid <= 1'b1;
                else                        outputValid <= 1'b0;
            end
            
//            if(multIteration == 3'd3)   outputValid <= 1'b1;
//            else                        outputValid <= 1'b0;
        end
        else if(FAST == "ultrafast")
        begin
            if(multIteration == 3'd2)   out_data_i <= multRes - multRes_f;
            if(multIteration == 3'd2)   out_data_q <= multRes_uf0 + multRes_uf1;
            else
            begin 
                if(COMPENS_FP == "true")
                begin
                    if((multIteration == 3'd3))
                    begin  
                        if(out_data_i[SIZE_DATA*2-1])   out_data_i <= out_data_i - 16384;
                        else                            out_data_i <= out_data_i + 16384;
                        
                        if(out_data_q[SIZE_DATA*2-1])   out_data_q <= out_data_q - 16384;
                        else                            out_data_q <= out_data_q + 16384;
                    end
                end
            end
            
            if(COMPENS_FP == "false")
            begin
                if(multIteration == 3'd2)   outputValid <= 1'b1;
                else                        outputValid <= 1'b0;
            end
            else
            begin
                if(multIteration == 3'd3)   outputValid <= 1'b1;
                else                        outputValid <= 1'b0;
            end
            
            
//            if(multIteration == 3'd2)   outputValid <= 1'b1;
//            else                        outputValid <= 1'b0;
        end
        
    end
    
    endgenerate
    
//    always @(posedge clk)
//    begin
//        if(en)  P1 <= in_data1_i - in_data1_q;
//        if(en)  P2 <= in_data2_i - in_data2_q;
//        if(en)  P3 <= in_data1_i + in_data1_q;
//        if(en)  vaitMult <= 1'b1;
//        else    vaitMult <= 1'b0;
        
//        if(vaitMult)   P4 <= P1*in_data2_i;
//        if(vaitMult)   P5 <= P2*in_data1_q;
//        if(vaitMult)   P6 <= P3*in_data2_q;
//        if(vaitMult)   vait_summ <= 1'b1;
//        else           vait_summ <= 1'b0;
        
////        if(vait_summ) out_data_i <= mult_i_0 - mult_i_1;
////        if(vait_summ) out_data_q <= mult_q_0 + mult_q_1;
//        if(vait_summ) out_data_i <= P4 + P5;
//        if(vait_summ) out_data_q <= P5 + P6;
//        if(vait_summ) outputValid <= 1'b1;
//        else          outputValid <= 1'b0;
        
//    end
    
//    always @(posedge clk)
//    begin
//        if(en)  mult_i_0 <= in_data1_i*in_data2_i;
//        if(en)  mult_q_0 <= in_data1_i*in_data2_q;
//        if(en)  mult_i_1 <= in_data1_q*in_data2_q;
//        if(en)  mult_q_1 <= in_data1_q*in_data2_i;
////        if(en)  P1 <= in_data1_i*in_data2_i;
////        if(en)  P2 <= in_data1_q*in_data2_q;
////        if(en)  P3 <= (in_data1_i + in_data2_i)*(in_data1_q + in_data2_q);
//        if(en)  vait_summ <= 1'b1;
//        else    vait_summ <= 1'b0;
        
//        if(vait_summ) out_data_i <= mult_i_0 - mult_i_1;
//        if(vait_summ) out_data_q <= mult_q_0 + mult_q_1;
////        if(vait_summ) out_data_i <= P1 - P2;
////        if(vait_summ) out_data_q <= P3 - P2 - P1;
//        if(vait_summ) outputValid <= 1'b1;
//        else          outputValid <= 1'b0;
        
//    end
    
endmodule
