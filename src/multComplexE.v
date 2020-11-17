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
// mult data on complex +fi and -fi
// в данный момент модуль начинае обрабатывать данные когда старые обработаны
// а так он может начинать обработку новых данных пока трарые еще обрабатываються так можно выиграть ~6тактов
// вычисляет 1 операция ~24 тактов
//////////////////////////////////////////////////////////////////////////////////

//TODO добавить размерность данных
module multComplexE #(parameter SIZE_DATA_FI = 2/*LOG2(NFFT)*/,
                      parameter FAST = "slow",/*slow fast ultrafast slow mult x1 fast mult x2 ultrafast mult x4*/
                      parameter TYPE = "forvard"/*forvard invers*/)(
    clk,
    en,
    in_data_i,
    in_data_q,
    fi_deg,/*NOTE только положительные данные для данного модуля size [SIZE_DATA_FI-2:0]*/
    out_data_minus_i,
    out_data_minus_q,
    out_data_plus_i,
    out_data_plus_q,
    outValid,
    /*debug flasg*/
    minusReady,
    plusReady,
    module_en
    );
    
    input clk;
    input en;
    input [15:0] in_data_i;
    input [15:0] in_data_q;
    input [15:0] fi_deg;
    output [15:0] out_data_minus_i;
    output [15:0] out_data_minus_q;
    output [15:0] out_data_plus_i;
    output [15:0] out_data_plus_q;
    output reg outValid = 1'b1;
    
    output minusReady;
    output plusReady;
    
    wire minusPhiReady;
    wire plusPhiReady;
    
    wire minusDataReady;
    wire plusDataReady;
    
    assign minusReady = minusPhiReady & minusDataReady;
    assign plusReady = /*plusPhiReady & plusDataReady*/minusReady;
    
    //входные данные 1 а фазы то зеркальные
    assign out_data_plus_i = -out_data_minus_i;
    assign out_data_plus_q = -out_data_minus_q;
    
    wire minusValid;
    wire plusValid;
    assign plusValid = minusValid;
    
    output reg module_en = 1'b0;
    
    genvar i;
    generate
    if(SIZE_DATA_FI > 2) 
    begin
    
    //12868->90ged
    //25736->180deg
//    parameter def_fi = {{16{1'b0}}, 16'd51472};
//    reg [31:0] fi = def_fi;
//    wire [15:0] m_fi;
//    wire [15:0] p_fi;
    reg _module_en = 1'b0;
    reg mult = 1'b0;
    reg multDone = 1'b0;
    
//    if(FORVARD == "true")
//    begin
//        assign m_fi = -fi[15+SIZE_DATA_FI:SIZE_DATA_FI]/* /4 or >> 2 */;
////        assign p_fi = 16'd25736 - fi[15+SIZE_DATA_FI:SIZE_DATA_FI]/* /4 or >> 2 */;
//    end
//    else
//    begin
//        assign m_fi = fi[15+SIZE_DATA_FI:SIZE_DATA_FI]/* /4 or >> 2 */;
////        assign p_fi = -16'd25736 + fi[15+SIZE_DATA_FI:SIZE_DATA_FI]/* /4 or >> 2 */ ;
//    end
    
    
    // 1:когда приходит информация по отрицательному клоку выставляю данные на шину выставляю en 
    // 2:в следуйший такт убирают en(valid) и дальше жду пока обы модуля вычисля
    // 3:оба модуля вычислили и выставляю такт что оба модуля все вычислсли
    always @(posedge clk)
    begin
//        if(en & /*minusReady & plusReady &*/ outValid/*если пришли входные данные и модули готовы к расчеты и в буфере ничего нету*/) fi <= def_fi*fi_deg[SIZE_DATA_FI-2:0]; /*1*/
        if(en & /*minusReady & plusReady &*/ outValid)      begin outValid <= 1'b0; module_en <= 1'b1;  end /*1*/
        else if(/*minusValid & plusValid*/multDone)                 begin outValid <= 1'b1;                     end /*3*/
        else                                            begin                   module_en <= 1'b0;  end /*2*/
    end
    
    reg [16:0] in_cos = 0;
    reg [16:0] in_sin = 0;
    
    wire [31:0] outData_i;
    wire [31:0] outData_q;
    
    wire multComplexComplete;
    
    multComplex #(.SIZE_DATA(16), .FAST(FAST))
    _multComplex(
    .clk(clk),
    .en(mult),
    .in_data1_i(in_data_i),
    .in_data1_q(in_data_q),
    .in_data2_i(in_cos),
    .in_data2_q(in_sin),
    .out_data_i(outData_i),
    .out_data_q(outData_q),
    .outputValid(multComplexComplete)
    );

    //(* ram_style="block" *)
    //(* ram_style="distributed" *)
    //(* ram_style="register" *)
    //(* ram_style="ultra" *)
    //специальные cos sin для FFT
    /*(* ram_style="distributed" *)*/ reg [16:0] cos [2**(SIZE_DATA_FI)/2-1:0];
    /*(* ram_style="distributed" *)*/ reg [16:0] sin [2**(SIZE_DATA_FI)/2-1:0];
    
    assign out_data_minus_i = outData_i[30:15];
    assign out_data_minus_q = outData_q[30:15];
//    if(FORVARD == "true")
//    begin
//    assign out_data_minus_q = -outData_q[30:15];
//    end
//    else
//    begin
//    assign out_data_minus_q = outData_q[30:15];
//    end
    
    
    always @(posedge clk)
    begin
        if(module_en)   begin        _module_en <= 1'b1;  end
        else if(mult)begin           _module_en <= 1'b0;  end
        else begin multDone <=  1'b0; end
        
        if(multComplexComplete) multDone <= 1'b1;
        
        if(_module_en | module_en)
        begin
            if(!mult)   in_cos = cos[fi_deg[SIZE_DATA_FI-2:0]];
//            if(!mult)   in_sin = -sin[fi_deg[SIZE_DATA_FI-2:0]];
            if(TYPE == "forvard")
            begin
            if(!mult)   in_sin = sin[fi_deg[SIZE_DATA_FI-2:0]];
            end
            else if(TYPE == "invers")
            begin
            if(!mult)   in_sin = -sin[fi_deg[SIZE_DATA_FI-2:0]];
            end
//            else    $error()
            
            if(!mult) mult <= 1'b1;//begin mult(on second clk mult will be done)
            else mult <= 1'b0;
        end
//        else
//            mult <= 1'b0;
    end

//    cordic_0
//    _cordic_minux
//    (
//        .aclk(clk),
//        .s_axis_phase_tvalid(module_en),
//        .s_axis_phase_tdata(m_fi),
//        .s_axis_cartesian_tvalid(module_en),
//        .s_axis_cartesian_tdata({in_data_q, in_data_i}),
//        .m_axis_dout_tvalid(minusValid),
//        .m_axis_dout_tdata({out_data_minus_q, out_data_minus_i}),
//        .s_axis_phase_tready(minusPhiReady),
//        .s_axis_cartesian_tready(minusDataReady)
//    );

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
            
//            cos[0] =  17'd32768;
//            sin[0] =  17'd0;
            
//            cos[1] =  17'd32610;
//            sin[1] = -17'd3212;
            
//            cos[2] =  17'd32138;
//            sin[2] = -17'd6393;
            
//            cos[3] =  17'd31357;
//            sin[3] = -17'd9512;
            
//            cos[4] =  17'd30274;
//            sin[4] = -17'd12539;
            
//            cos[5] =  17'd29900;
//            sin[5] = -17'd15447;
            
//            cos[6] =  17'd27246;
//            sin[6] = -17'd18204;
            
//            cos[7] =  17'd25330;
//            sin[7] = -17'd20787;
            
//            cos[8] =  17'd23170;
//            sin[8] = -17'd23170;
            
//            cos[9] =  17'd20787;
//            sin[9] = -17'd25330;
            
//            cos[10] = 17'd18205;
//            sin[10] = -17'd27248;
            
//            cos[11] = 17'd15447;
//            sin[11] = -17'd29900;
            
//            cos[12] =  17'd12540;
//            sin[12] = -17'd30274;
            
//            cos[13] = 17'd9512;
//            sin[13] = -17'd31357;
            
//            cos[14] =  17'd6393;
//            sin[14] = -17'd32138;
            
//            cos[15] =  17'd3212;
//            sin[15] = -17'd32610;
            
//            cos[16] =  17'd0;
//            sin[16] = -17'd32768;
            
//            cos[17] = -17'd3212;
//            sin[17] = -17'd32610;
            
//            cos[18] = -17'd6393;
//            sin[18] = -17'd32138;
            
//            cos[19] = -17'd9512;
//            sin[19] = -17'd31357;
            
//            cos[20] = -17'd12540;
//            sin[20] = -17'd30274;
            
//            cos[21] = -17'd15447;
//            sin[21] = -17'd29900;
            
//            cos[22] = -17'd18205;
//            sin[22] = -17'd27248;
            
//            cos[23] = -17'd20787;
//            sin[23] = -17'd25330;
            
//            cos[24] = -17'd23170;
//            sin[24] = -17'd23170;
            
//            cos[25] = -17'd25330;
//            sin[25] = -17'd20787;
            
//            cos[26] = -17'd27246;
//            sin[26] = -17'd18204;
            
//            cos[27] = -17'd29900;
//            sin[27] = -17'd15447;
            
//            cos[28] = -17'd30274;
//            sin[28] = -17'd12539;
            
//            cos[29] = -17'd31357;
//            sin[29] = -17'd9512;
            
//            cos[30] = -17'd32138;
//            sin[30] = -17'd6393;
            
//            cos[31] = -17'd32610;
//            sin[31] = -17'd3212;
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
//        reg delay1 = 1'b0;
        always @(posedge clk)
        begin
            if(en & outValid)       begin outValid <= 1'b0; module_en <= 1'b1;  end /*1*/
            else if(multDone)       begin outValid <= 1'b1; module_en <= 1'b0;  end /*3*/
//            else if(multDone)       begin delay1 <= 1'b1; module_en <= 1'b0;  end /*3*/      
//            else if(delay1)         begin outValid <= 1'b1; delay1 <= 1'b0;  end /*3*/
            else                    begin module_en <= 1'b0; end /*2*/
        end
        
        reg [15:0] data_i;
        reg [15:0] data_q;
        assign out_data_minus_i = data_i;
        assign out_data_minus_q = data_q;
        always @(posedge clk)
        begin
            if(module_en)
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
