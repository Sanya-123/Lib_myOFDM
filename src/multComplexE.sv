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


module multComplexE_SV #(parameter SIZE_DATA_FI = 2/*LOG2(NFFT)*/)(
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
    assign plusReady = plusPhiReady & plusDataReady;
    
    wire minusValid;
    wire plusValid;
    
    output reg module_en = 1'b0;
    
    generate
    if(SIZE_DATA_FI > 1) 
    begin
    
    //12868->90ged
    //25736->180deg
    parameter def_fi = {{16{1'b0}}, 16'd51472};
    reg [31:0] fi = def_fi;
    wire [15:0] m_fi;
    wire [15:0] p_fi;
    assign p_fi = 16'd25736 - fi[15+SIZE_DATA_FI:SIZE_DATA_FI]/* /4 or >> 2 */;
    assign m_fi = -fi[15+SIZE_DATA_FI:SIZE_DATA_FI]/* /4 or >> 2 */;
    
    // 1:когда приходит информация по отрицательному клоку выставляю данные на шину выставляю en 
    // 2:в следуйший такт убирают en(valid) и дальше жду пока обы модуля вычисля
    // 3:оба модуля вычислили и выставляю такт что оба модуля все вычислсли
    always @(negedge clk)
    begin
        if(en & minusReady & plusReady & outValid/*если пришли входные данные и модули готовы к расчеты и в буфере ничего нету*/) fi <= def_fi*fi_deg[SIZE_DATA_FI-2:0]; /*1*/
        if(en & minusReady & plusReady & outValid)      begin outValid <= 1'b0; module_en <= 1'b1;  end /*1*/
        else if(minusValid & plusValid)                 begin outValid <= 1'b1;                     end /*3*/
        else                                            begin                   module_en <= 1'b0;  end /*2*/
    end

    cordic_0
    _cordic_minux
    (
        .aclk(clk),
        .s_axis_phase_tvalid(module_en),
        .s_axis_phase_tdata(m_fi),
        .s_axis_cartesian_tvalid(module_en),
        .s_axis_cartesian_tdata({in_data_q, in_data_i}),
        .m_axis_dout_tvalid(minusValid),
        .m_axis_dout_tdata({out_data_minus_q, out_data_minus_i}),
        .s_axis_phase_tready(minusPhiReady),
        .s_axis_cartesian_tready(minusDataReady)
    );
    
    cordic_0
    _cordic_plus
    (
        .aclk(clk),
        .s_axis_phase_tvalid(module_en),
        .s_axis_phase_tdata(p_fi),
        .s_axis_cartesian_tvalid(module_en),
        .s_axis_cartesian_tdata({in_data_q, in_data_i}),
        .m_axis_dout_tvalid(plusValid),
        .m_axis_dout_tdata({out_data_plus_q, out_data_plus_i}),
        .s_axis_phase_tready(plusPhiReady),
        .s_axis_cartesian_tready(plusDataReady)
    );
    
    end
    endgenerate
    
    
endmodule
