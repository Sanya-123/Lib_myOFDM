`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2021 13:22:16
// Design Name: 
// Module Name: modulation_array
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


module modulation_array#(parameter DATA_SIZE = 16)(
    i_clk,
    i_en,
    i_dataForModulations,
    i_modulation,
    o_data_i,
    o_data_q
    );
    
    input i_clk;
    input i_en;
    input [8*8-1:0] i_dataForModulations;
    input [2:0] i_modulation;
    
    output reg [DATA_SIZE-1:0] o_data_i [7:0];
    output reg [DATA_SIZE-1:0] o_data_q [7:0];
    
    
    wire [DATA_SIZE-1:0] BPSK_wire_i [7:0];
    wire [DATA_SIZE-1:0] BPSK_wire_q [7:0];
    
    wire [DATA_SIZE-1:0] QPSK_wire_i [7:0];
    wire [DATA_SIZE-1:0] QPSK_wire_q [7:0];
    
    wire [DATA_SIZE-1:0] QAM16_wire_i [7:0];
    wire [DATA_SIZE-1:0] QAM16_wire_q [7:0];
        
    wire [DATA_SIZE-1:0] QAM64_wire_i [7:0];
    wire [DATA_SIZE-1:0] QAM64_wire_q [7:0];
    
    wire [DATA_SIZE-1:0] QAM256_wire_i [7:0];
    wire [DATA_SIZE-1:0] QAM256_wire_q [7:0];
    
    reg [8*8-1:0] dataForModulations;
    genvar i;
    generate
    for(i = 0; i < 8; i = i + 1)
    begin
    /***************************************DATA0***************************************/
    always @ *
        case (i_modulation)
            0: o_data_i[i] = BPSK_wire_i[i];
            1: o_data_i[i] = QPSK_wire_i[i];
            2: o_data_i[i] = QAM16_wire_i[i];
            3: o_data_i[i] = QAM64_wire_i[i];
            4: o_data_i[i] = QAM256_wire_i[i];
            default: o_data_i[i] = 0;
        endcase
        
    always @ *
        case (i_modulation)
            0: o_data_q[i] = BPSK_wire_q[i];
            1: o_data_q[i] = QPSK_wire_q[i];
            2: o_data_q[i] = QAM16_wire_q[i];
            3: o_data_q[i] = QAM64_wire_q[i];
            4: o_data_q[i] = QAM256_wire_q[i];
            default: o_data_q[i] = 0;
        endcase
    /******************************************************************************/
    end
    endgenerate
        
    
    
    //********************modulations********************
    mapModulations #(.DATA_SIZE(DATA_SIZE),.MODULATION("BPSK") /*BPSK QPSK QAM16 QAM64 QAM256*/)
    BPSK_modulation(
        .clk(i_clk),
        .en(i_en),
        .in_data(i_dataForModulations),
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
        
    mapModulations #(.DATA_SIZE(DATA_SIZE),.MODULATION("QPSK") /*BPSK QPSK QAM16 QAM64 QAM256*/)
    QPSK_modulation(
        .clk(i_clk),
        .en(i_en),
        .in_data(i_dataForModulations),
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
        
    mapModulations #(.DATA_SIZE(DATA_SIZE),.MODULATION("QAM16") /*BPSK QPSK QAM16 QAM64 QAM256*/)
    QAM16_modulation(
        .clk(i_clk),
        .en(i_en),
        .in_data(i_dataForModulations),
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
        
    mapModulations #(.DATA_SIZE(DATA_SIZE),.MODULATION("QAM64") /*BPSK QPSK QAM16 QAM64 QAM256*/)
    QAM64_modulation(
        .clk(i_clk),
        .en(i_en),
        .in_data(i_dataForModulations),
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
        
    mapModulations #(.DATA_SIZE(DATA_SIZE),.MODULATION("QAM256") /*BPSK QPSK QAM16 QAM64 QAM256*/)
    QAM256_modulation(
        .clk(i_clk),
        .en(i_en),
        .in_data(i_dataForModulations),
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
