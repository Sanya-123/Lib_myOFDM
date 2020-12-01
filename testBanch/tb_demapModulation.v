`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.11.2020 19:04:28
// Design Name: 
// Module Name: tb_demapModulation
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


module tb_demapModulation();

reg clk = 0;

reg [7:0] dataRequeRx = 0;
reg [7:0] dataRequeRx2 = 0;
reg [7:0] dataRequeRx3 = 0;
reg [7:0] dataRequeRx4 = 0;
reg [7:0] dataRequeRx5 = 0;
reg [7:0] dataRequeRx6 = 0;
reg [7:0] dataRequeRx7 = 0;
reg [7:0] dataRequeRx8 = 0;

    always
        #5 clk = !clk;
        
    always
    begin
        #40
//        dataRequeRx = dataRequeRx + 1;
        dataRequeRx = $urandom();
        dataRequeRx2 = $urandom();
        dataRequeRx3 = $urandom();  
        dataRequeRx4 = $urandom();  
        dataRequeRx5 = $urandom();  
        dataRequeRx6 = $urandom();  
        dataRequeRx7 = $urandom();
        dataRequeRx8 = $urandom();        
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
        .in_data({8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, dataRequeRx2, dataRequeRx}),
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
        .in_data({8'd0, 8'd0, 8'd0, 8'd0, dataRequeRx4, dataRequeRx3, dataRequeRx2, dataRequeRx}),
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
        .in_data({8'd0, 8'd0, dataRequeRx6, dataRequeRx5, dataRequeRx4, dataRequeRx3, dataRequeRx2, dataRequeRx}),
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
        .in_data({dataRequeRx8, dataRequeRx7, dataRequeRx6, dataRequeRx5, dataRequeRx4, dataRequeRx3, dataRequeRx2, dataRequeRx}),
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
    
    wire [7:0] data_demod_BPSK;
    
    demapModulations #(.DATA_SIZE(16), .MODULATION("BPSK") /*BPSK QPSK QAM16 QAM64 QAM256*/)
    BPSK_demodulation(
        .clk(clk),
        .en(1'b1),
        .in_data_0_i(BPSK_wire_i[0]),
        .in_data_0_q(BPSK_wire_q[0]),
        .in_data_1_i(BPSK_wire_i[1]),
        .in_data_1_q(BPSK_wire_q[1]),
        .in_data_2_i(BPSK_wire_i[2]),
        .in_data_2_q(BPSK_wire_q[2]),
        .in_data_3_i(BPSK_wire_i[3]),
        .in_data_3_q(BPSK_wire_q[3]),
        .in_data_4_i(BPSK_wire_i[4]),
        .in_data_4_q(BPSK_wire_q[4]),
        .in_data_5_i(BPSK_wire_i[5]),
        .in_data_5_q(BPSK_wire_q[5]),
        .in_data_6_i(BPSK_wire_i[6]),
        .in_data_6_q(BPSK_wire_q[6]),
        .in_data_7_i(BPSK_wire_i[7]),
        .in_data_7_q(BPSK_wire_q[7]),
        .out_data(data_demod_BPSK)
    );
    
    wire [7:0] data_demod_QPSK;
    wire [7:0] data_demod_QPSK_2;
    
    demapModulations #(.DATA_SIZE(16), .MODULATION("QPSK") /*BPSK QPSK QAM16 QAM64 QAM256*/)
    QPSK_demodulation(
        .clk(clk),
        .en(1'b1),
        .in_data_0_i(QPSK_wire_i[0]),
        .in_data_0_q(QPSK_wire_q[0]),
        .in_data_1_i(QPSK_wire_i[1]),
        .in_data_1_q(QPSK_wire_q[1]),
        .in_data_2_i(QPSK_wire_i[2]),
        .in_data_2_q(QPSK_wire_q[2]),
        .in_data_3_i(QPSK_wire_i[3]),
        .in_data_3_q(QPSK_wire_q[3]),
        .in_data_4_i(QPSK_wire_i[4]),
        .in_data_4_q(QPSK_wire_q[4]),
        .in_data_5_i(QPSK_wire_i[5]),
        .in_data_5_q(QPSK_wire_q[5]),
        .in_data_6_i(QPSK_wire_i[6]),
        .in_data_6_q(QPSK_wire_q[6]),
        .in_data_7_i(QPSK_wire_i[7]),
        .in_data_7_q(QPSK_wire_q[7]),
        .out_data({data_demod_QPSK_2, data_demod_QPSK})
    );
    
    wire [7:0] data_demod_QAM16;
    wire [7:0] data_demod_QAM16_2;
    wire [7:0] data_demod_QAM16_3;
    wire [7:0] data_demod_QAM16_4;
    
    demapModulations #(.DATA_SIZE(16), .MODULATION("QAM16") /*BPSK QPSK QAM16 QAM64 QAM256*/)
    QAM16_demodulation(
        .clk(clk),
        .en(1'b1),
        .in_data_0_i(QAM16_wire_i[0]),
        .in_data_0_q(QAM16_wire_q[0]),
        .in_data_1_i(QAM16_wire_i[1]),
        .in_data_1_q(QAM16_wire_q[1]),
        .in_data_2_i(QAM16_wire_i[2]),
        .in_data_2_q(QAM16_wire_q[2]),
        .in_data_3_i(QAM16_wire_i[3]),
        .in_data_3_q(QAM16_wire_q[3]),
        .in_data_4_i(QAM16_wire_i[4]),
        .in_data_4_q(QAM16_wire_q[4]),
        .in_data_5_i(QAM16_wire_i[5]),
        .in_data_5_q(QAM16_wire_q[5]),
        .in_data_6_i(QAM16_wire_i[6]),
        .in_data_6_q(QAM16_wire_q[6]),
        .in_data_7_i(QAM16_wire_i[7]),
        .in_data_7_q(QAM16_wire_q[7]),
        .out_data({data_demod_QAM16_4, data_demod_QAM16_3, data_demod_QAM16_2, data_demod_QAM16})
    );
    
    wire [7:0] data_demod_QAM64;
    wire [7:0] data_demod_QAM64_2;
    wire [7:0] data_demod_QAM64_3;
    wire [7:0] data_demod_QAM64_4;
    wire [7:0] data_demod_QAM64_5;
    wire [7:0] data_demod_QAM64_6;
    
    demapModulations #(.DATA_SIZE(16), .MODULATION("QAM64") /*BPSK QPSK QAM16 QAM64 QAM256*/)
    QAM64_demodulation(
        .clk(clk),
        .en(1'b1),
        .in_data_0_i(QAM64_wire_i[0]),
        .in_data_0_q(QAM64_wire_q[0]),
        .in_data_1_i(QAM64_wire_i[1]),
        .in_data_1_q(QAM64_wire_q[1]),
        .in_data_2_i(QAM64_wire_i[2]),
        .in_data_2_q(QAM64_wire_q[2]),
        .in_data_3_i(QAM64_wire_i[3]),
        .in_data_3_q(QAM64_wire_q[3]),
        .in_data_4_i(QAM64_wire_i[4]),
        .in_data_4_q(QAM64_wire_q[4]),
        .in_data_5_i(QAM64_wire_i[5]),
        .in_data_5_q(QAM64_wire_q[5]),
        .in_data_6_i(QAM64_wire_i[6]),
        .in_data_6_q(QAM64_wire_q[6]),
        .in_data_7_i(QAM64_wire_i[7]),
        .in_data_7_q(QAM64_wire_q[7]),
        .out_data({data_demod_QAM64_6, data_demod_QAM64_5, data_demod_QAM64_4, data_demod_QAM64_3, data_demod_QAM64_2, data_demod_QAM64})
    );
    
    wire [7:0] data_demod_QAM256;
    wire [7:0] data_demod_QAM256_2;
    wire [7:0] data_demod_QAM256_3;
    wire [7:0] data_demod_QAM256_4;
    wire [7:0] data_demod_QAM256_5;
    wire [7:0] data_demod_QAM256_6;
    wire [7:0] data_demod_QAM256_7;
    wire [7:0] data_demod_QAM256_8;
    
    demapModulations #(.DATA_SIZE(16), .MODULATION("QAM256") /*BPSK QPSK QAM16 QAM64 QAM256*/)
    QAM256_demodulation(
        .clk(clk),
        .en(1'b1),
        .in_data_0_i(QAM256_wire_i[0]),
        .in_data_0_q(QAM256_wire_q[0]),
        .in_data_1_i(QAM256_wire_i[1]),
        .in_data_1_q(QAM256_wire_q[1]),
        .in_data_2_i(QAM256_wire_i[2]),
        .in_data_2_q(QAM256_wire_q[2]),
        .in_data_3_i(QAM256_wire_i[3]),
        .in_data_3_q(QAM256_wire_q[3]),
        .in_data_4_i(QAM256_wire_i[4]),
        .in_data_4_q(QAM256_wire_q[4]),
        .in_data_5_i(QAM256_wire_i[5]),
        .in_data_5_q(QAM256_wire_q[5]),
        .in_data_6_i(QAM256_wire_i[6]),
        .in_data_6_q(QAM256_wire_q[6]),
        .in_data_7_i(QAM256_wire_i[7]),
        .in_data_7_q(QAM256_wire_q[7]),
        .out_data({data_demod_QAM256_8, data_demod_QAM256_7, data_demod_QAM256_6, data_demod_QAM256_5, data_demod_QAM256_4, data_demod_QAM256_3, data_demod_QAM256_2, data_demod_QAM256})
    );
    
    
endmodule
