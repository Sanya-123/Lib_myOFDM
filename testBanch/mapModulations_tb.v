`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.11.2020 15:41:40
// Design Name: 
// Module Name: mapModulations_tb
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


module mapModulations_tb();

reg clk = 0;

reg [7:0] dataRequeRx = 0;

    always
        #5 clk = !clk;
        
    always
    begin
        #40
        dataRequeRx = dataRequeRx + 1;
    end
    
    wire [15:0] BPSK_wire_i [7:0];
    wire [15:0] BPSK_wire_q [7:0];
        
    mapModulations #(.DATA_SIZE(16),.MODULATION("BPSK") /*BPSK QPSK QAM16 QAM64 QAM256*/)
    BPSK_modulation(
        .clk(clk),
        .en(1'b1),
        .in_data({8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, dataRequeRx}),
        .out_data0_i(BPSK_wire_i[0]),
        .out_data1_i(BPSK_wire_i[1]),
        .out_data2_i(BPSK_wire_i[2]),
        .out_data3_i(BPSK_wire_i[3]),
        .out_data4_i(BPSK_wire_i[4]),
        .out_data5_i(BPSK_wire_i[5]),
        .out_data6_i(BPSK_wire_i[6]),
        .out_data7_i(BPSK_wire_i[7]),
        .out_data0_q(BPSK_wire_q[0]),
        .out_data1_q(BPSK_wire_q[1]),
        .out_data2_q(BPSK_wire_q[2]),
        .out_data3_q(BPSK_wire_q[3]),
        .out_data4_q(BPSK_wire_q[4]),
        .out_data5_q(BPSK_wire_q[5]),
        .out_data6_q(BPSK_wire_q[6]),
        .out_data7_q(BPSK_wire_q[7])
    );
    
    wire [15:0] QPSK_wire_i [7:0];
    wire [15:0] QPSK_wire_q [7:0];
        
    mapModulations #(.DATA_SIZE(16),.MODULATION("QPSK") /*BPSK QPSK QAM16 QAM64 QAM256*/)
    QPSK_modulation(
        .clk(clk),
        .en(1'b1),
        .in_data({8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, dataRequeRx}),
        .out_data0_i(QPSK_wire_i[0]),
        .out_data1_i(QPSK_wire_i[1]),
        .out_data2_i(QPSK_wire_i[2]),
        .out_data3_i(QPSK_wire_i[3]),
        .out_data4_i(QPSK_wire_i[4]),
        .out_data5_i(QPSK_wire_i[5]),
        .out_data6_i(QPSK_wire_i[6]),
        .out_data7_i(QPSK_wire_i[7]),
        .out_data0_q(QPSK_wire_q[0]),
        .out_data1_q(QPSK_wire_q[1]),
        .out_data2_q(QPSK_wire_q[2]),
        .out_data3_q(QPSK_wire_q[3]),
        .out_data4_q(QPSK_wire_q[4]),
        .out_data5_q(QPSK_wire_q[5]),
        .out_data6_q(QPSK_wire_q[6]),
        .out_data7_q(QPSK_wire_q[7])
    );
    
    wire [15:0] QAM16_wire_i [7:0];
    wire [15:0] QAM16_wire_q [7:0];
        
    mapModulations #(.DATA_SIZE(16),.MODULATION("QAM16") /*BPSK QPSK QAM16 QAM64 QAM256*/)
    QAM16_modulation(
        .clk(clk),
        .en(1'b1),
        .in_data({8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, dataRequeRx}),
        .out_data0_i(QAM16_wire_i[0]),
        .out_data1_i(QAM16_wire_i[1]),
        .out_data2_i(QAM16_wire_i[2]),
        .out_data3_i(QAM16_wire_i[3]),
        .out_data4_i(QAM16_wire_i[4]),
        .out_data5_i(QAM16_wire_i[5]),
        .out_data6_i(QAM16_wire_i[6]),
        .out_data7_i(QAM16_wire_i[7]),
        .out_data0_q(QAM16_wire_q[0]),
        .out_data1_q(QAM16_wire_q[1]),
        .out_data2_q(QAM16_wire_q[2]),
        .out_data3_q(QAM16_wire_q[3]),
        .out_data4_q(QAM16_wire_q[4]),
        .out_data5_q(QAM16_wire_q[5]),
        .out_data6_q(QAM16_wire_q[6]),
        .out_data7_q(QAM16_wire_q[7])
    );
    
    wire [15:0] QAM64_wire_i [7:0];
    wire [15:0] QAM64_wire_q [7:0];
        
    mapModulations #(.DATA_SIZE(16),.MODULATION("QAM64") /*BPSK QPSK QAM16 QAM64 QAM256*/)
    QAM64_modulation(
        .clk(clk),
        .en(1'b1),
        .in_data({8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, dataRequeRx}),
        .out_data0_i(QAM64_wire_i[0]),
        .out_data1_i(QAM64_wire_i[1]),
        .out_data2_i(QAM64_wire_i[2]),
        .out_data3_i(QAM64_wire_i[3]),
        .out_data4_i(QAM64_wire_i[4]),
        .out_data5_i(QAM64_wire_i[5]),
        .out_data6_i(QAM64_wire_i[6]),
        .out_data7_i(QAM64_wire_i[7]),
        .out_data0_q(QAM64_wire_q[0]),
        .out_data1_q(QAM64_wire_q[1]),
        .out_data2_q(QAM64_wire_q[2]),
        .out_data3_q(QAM64_wire_q[3]),
        .out_data4_q(QAM64_wire_q[4]),
        .out_data5_q(QAM64_wire_q[5]),
        .out_data6_q(QAM64_wire_q[6]),
        .out_data7_q(QAM64_wire_q[7])
    );
    
    wire [15:0] QAM256_wire_i [7:0];
    wire [15:0] QAM256_wire_q [7:0];
        
    mapModulations #(.DATA_SIZE(16),.MODULATION("QAM256") /*BPSK QPSK QAM16 QAM64 QAM256*/)
    QAM256_modulation(
        .clk(clk),
        .en(1'b1),
        .in_data({8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, dataRequeRx}),
        .out_data0_i(QAM256_wire_i[0]),
        .out_data1_i(QAM256_wire_i[1]),
        .out_data2_i(QAM256_wire_i[2]),
        .out_data3_i(QAM256_wire_i[3]),
        .out_data4_i(QAM256_wire_i[4]),
        .out_data5_i(QAM256_wire_i[5]),
        .out_data6_i(QAM256_wire_i[6]),
        .out_data7_i(QAM256_wire_i[7]),
        .out_data0_q(QAM256_wire_q[0]),
        .out_data1_q(QAM256_wire_q[1]),
        .out_data2_q(QAM256_wire_q[2]),
        .out_data3_q(QAM256_wire_q[3]),
        .out_data4_q(QAM256_wire_q[4]),
        .out_data5_q(QAM256_wire_q[5]),
        .out_data6_q(QAM256_wire_q[6]),
        .out_data7_q(QAM256_wire_q[7])
    );
endmodule
