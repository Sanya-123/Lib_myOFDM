`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.11.2020 14:48:23
// Design Name: 
// Module Name: multComplexE_tb
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


module multComplexE_tb();

reg clk = 1'b0;
    always
        #5 clk = !clk;

wire [15:0] res_m_phi_i;
wire [15:0] res_m_phi_q;
wire [15:0] res_p_phi_i;
wire [15:0] res_p_phi_q;
reg [15:0] phi;
wire dataComplete;
wire minusReady;
wire plusReady;
reg en;
wire module_en;

//wire [15:0] res_m_phi_i_f;
//wire [15:0] res_m_phi_q_f;
//wire [15:0] res_p_phi_i_f;
//wire [15:0] res_p_phi_q_f;

integer i;

    initial
    begin
//        phi = 16'd1;//90
//        en = 0;
//        #30
//        en = 1;
////        #30
////        en = 0;
//        #180
//        phi = 16'd0;//45
//        #150
//        phi = 16'd2;//22.5
//        #150
//        phi = 16'd2;//180
//        #150
//        phi = 16'd0;//-90
//        #150
//        phi = 16'd0;//-45
//        #150
//        phi = 16'd3;

        en = 0;
        #30
        en = 1;
        for(i = 0;i < 8;i = i + 1)
        begin
            phi = i;//90
           #10 ;
        end
        #20;
        en = 0;
        
    end

multComplexE #(.SIZE_DATA_FI(4)/*LOG2(NFFT)*/, .DATA_FFT_SIZE(16), .TYPE("forvard"), .COMPENS_FP("add")/*false add*/)
_multComplexE
    (
    .clk(clk),
    .en(en),
    .in_data_i(16'd749),
    .in_data_q(16'd749),
    .fi_deg(phi),
    .out_data_minus_i(res_m_phi_i),
    .out_data_minus_q(res_m_phi_q),
    .out_data_plus_i(res_p_phi_i),
    .out_data_plus_q(res_p_phi_q),
    .outValid(dataComplete)
    );
    
    
//    wire [31:0]outData_i;
//    wire [31:0]outData_q;
    
//    wire [15:0] out_data_minus_i;
//    wire [15:0] out_data_minus_q;
    
//    assign out_data_minus_i = outData_q[30:15];
//    assign out_data_minus_q = outData_i[30:15];
    
//multComplex #(.SIZE_DATA(16))
//    _multComplex(
//    .clk(clk),
//    .en(1'b1),
//    .in_data1_i(16'd749),
//    .in_data1_q(-16'd749),
//    .in_data2_i(17'd0),
//    .in_data2_q(-17'd32768),
//    .out_data_i(outData_i),
//    .out_data_q(outData_q)
//    );
    
//    wire [32:0] multRes;
    
//    mult_fft 
//    _mult_fft (
//        .CLK(clk),
//        .A(16'd500),
//        .B(17'd3500),
//        .P(multRes)
//    );
    
    
    
//multComplexE #(.SIZE_DATA_FI(3)/*LOG2(NFFT)*/, .FORVARD("false"))
//_multComplexE_I
//    (
//    .clk(clk),
//    .en(en),
//    .in_data_i(16'd749),
//    .in_data_q(16'd749),
//    .fi_deg(phi),
//    .out_data_minus_i(res_m_phi_i_f),
//    .out_data_minus_q(res_m_phi_q_f),
//    .out_data_plus_i(res_p_phi_i_f),
//    .out_data_plus_q(res_p_phi_q_f),
//    .outValid(),
//    .minusReady(),
//    .plusReady(),
//    .module_en()
//    );
    
    

//wire [15:0] res_phi_i;
//wire [15:0] res_phi_q;
//reg [15:0] phi;
//wire dataComplete;

//    initial
//    begin
//        phi = 16'd12868;//90
//        #230
//        phi = 16'd12868/2;//45
//        #150
//        phi = 16'd12868/4;//22.5
//        #150
//        phi = 16'd12868*2;//180
//        #150
//        phi = -16'd12868;//-90
//        #150
//        phi = -16'd12868/2;//-45
//        #150
//        phi = 16'd1000;
        
//    end

//multComplexE #(.SIZE_DATA_FI(16))
//    _testComplexE(
//    .clk(clk),
//    .en(1'b1),
//    .in_data_i(16'd749),
//    .in_data_q(16'd0),
//    .fi_deg(phi),
//    .out_data_i(res_phi_i),
//    .out_data_q(res_phi_q),
//    .outValid(dataComplete)
//    );
    
//reg [15:0] phiCosSin;
//wire [15:0] cos;
//wire [15:0] sin;
//wire phase_ready;
//wire completeSinCos;

//initial
//    begin
//        phiCosSin = 16'd100;
//        #230
//        phiCosSin = 16'd1000;
//        #150
//        phiCosSin = 16'd16536;
//        #150
//        phiCosSin = 16'd12868;
//        #150
//        phiCosSin = {8'd000, {8{1'b1}}};
//        #150
//        phiCosSin = 16'd600;
//        #150
//        phiCosSin = 16'd1000;
        
//    end

//    cordic_0
//    _cordic_plus
//    (
//        .aclk(clk),
//        .s_axis_phase_tvalid(1'b1),
//        .s_axis_phase_tdata(phiCosSin),
//        .s_axis_cartesian_tvalid(1'b1),
//        .s_axis_cartesian_tdata({16'd1000, 16'd1000}),
//        .m_axis_dout_tvalid(completeSinCos),
//        .m_axis_dout_tdata({sin, cos}),
//        .s_axis_phase_tready(phase_ready)
////        .s_axis_cartesian_tready(1'b1)
//    );

//cordic_sinCos 
//  _csoSin (
//    .aclk(clk),
//    .s_axis_phase_tvalid(1'b1),
//    .s_axis_phase_tready(phase_ready),
//    .s_axis_phase_tdata(phiCosSin),
//    .m_axis_dout_tvalid(completeSinCos),
//    .m_axis_dout_tdata({sin, cos})
//  );


//multComplex
//_multC
//(
//    .clk(clk),
//    .en(1'b1),
//    .in_data1_i(16'd25),
//    .in_data1_q(16'd32),
//    .in_data2_i(-16'd12),
//    .in_data2_q(16'd16),
//    .out_data_i(res_summ_i),
//    .out_data_q(res_summ_q)
//);

endmodule
