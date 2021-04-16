`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.11.2020 14:04:11
// Design Name: 
// Module Name: mapModulations
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
`include "commonModulation.vh"

module mapModulations #(parameter DATA_SIZE = 16, parameter MODULATION = "BPSK" /*BPSK QPSK QAM16 QAM64 QAM256*/)(
    clk,
    en,
    in_data,
    out_data0_i,
    out_data1_i,
    out_data2_i,
    out_data3_i,
    out_data4_i,
    out_data5_i,
    out_data6_i,
    out_data7_i,
    out_data0_q,
    out_data1_q,
    out_data2_q,
    out_data3_q,
    out_data4_q,
    out_data5_q,
    out_data6_q,
    out_data7_q
    );
    
    //in BPSK 1 байта на входе в этом случае
    //in QPSK 2 байта на входе в этом случае
    //in QAM16 4 байта на входе в этом случае
    //in QAMP64 6 байта на входе в этом случае
    //in QAM256 8 байта на входе в этом случае
    
    input clk;
    input en;
    input [8*8-1:0] in_data;
    
    output [DATA_SIZE-1:0] out_data0_i;
    output [DATA_SIZE-1:0] out_data1_i;
    output [DATA_SIZE-1:0] out_data2_i;
    output [DATA_SIZE-1:0] out_data3_i;
    output [DATA_SIZE-1:0] out_data4_i;
    output [DATA_SIZE-1:0] out_data5_i;
    output [DATA_SIZE-1:0] out_data6_i;
    output [DATA_SIZE-1:0] out_data7_i;
    
    output [DATA_SIZE-1:0] out_data0_q;
    output [DATA_SIZE-1:0] out_data1_q;
    output [DATA_SIZE-1:0] out_data2_q;
    output [DATA_SIZE-1:0] out_data3_q;
    output [DATA_SIZE-1:0] out_data4_q;
    output [DATA_SIZE-1:0] out_data5_q;
    output [DATA_SIZE-1:0] out_data6_q;
    output [DATA_SIZE-1:0] out_data7_q;
    
    reg [DATA_SIZE-1:0] data_i [7:0];
    reg [DATA_SIZE-1:0] data_q [7:0];
    
    assign out_data0_i = data_i[0];
    assign out_data1_i = data_i[1];
    assign out_data2_i = data_i[2];
    assign out_data3_i = data_i[3];
    assign out_data4_i = data_i[4];
    assign out_data5_i = data_i[5];
    assign out_data6_i = data_i[6];
    assign out_data7_i = data_i[7];
    
    assign out_data0_q = data_q[0];
    assign out_data1_q = data_q[1];
    assign out_data2_q = data_q[2];
    assign out_data3_q = data_q[3];
    assign out_data4_q = data_q[4];
    assign out_data5_q = data_q[5];
    assign out_data6_q = data_q[6];
    assign out_data7_q = data_q[7];
    
    //TODO MAP VALUE
    
    genvar i;
    generate
    if(MODULATION == "BPSK")//+
    begin
        for(i = 0; i < 8; i = i + 1)
        begin
            always @(posedge clk)
            begin
                if(en)
                begin
                    data_q[i] <= 0;
                    data_i[i] <= in_data[i] ? `BPSK_1 : `BPSK__1;
                end
            end
        end
    end
    else if(MODULATION == "QPSK")//+
    begin
        for(i = 0; i < 8; i = i + 1)
        begin
            always @(posedge clk)
            begin
                if(en)
                begin
                    data_q[i] <= in_data[2*i+1] ? `QPSK_1 : `QPSK__1;
                    data_i[i] <= in_data[2*i]   ? `QPSK_1 : `QPSK__1;
                end
            end
        end
    end
    else if(MODULATION == "QAM16")//+
    begin
        for(i = 0; i < 8; i = i + 1)
        begin
            always @(posedge clk)
            begin
                if(en)
                begin   //00 -3; 01 -1; 11 1; 10 3;
                    data_q[i] <= in_data[4*i+3:4*i+2]==0 ? `QAM16__3 : in_data[4*i+3:4*i+2]==1 ? `QAM16__1 : in_data[4*i+3:4*i+2]==3 ? `QAM16_1 : `QAM16_3;
                    data_i[i] <= in_data[4*i+1:4*i+0]==0 ? `QAM16__3 : in_data[4*i+1:4*i+0]==1 ? `QAM16__1 : in_data[4*i+1:4*i+0]==3 ? `QAM16_1 : `QAM16_3;
                end
            end
        end
    end
    else if(MODULATION == "QAM64")//+
    begin
        for(i = 0; i < 8; i = i + 1)
        begin
            always @(posedge clk)
            begin
                if(en)
                begin //000 -7; 001 -5; 011 -3; 010 -1; 110 1; 111 3; 101 5; 100 7;
                    case (in_data[6*i+2:6*i+0])
                    3'b000: data_i[i] <= `QAM64__7;
                    3'b001: data_i[i] <= `QAM64__5;
                    3'b011: data_i[i] <= `QAM64__3;
                    3'b010: data_i[i] <= `QAM64__1;
                    3'b110: data_i[i] <=  `QAM64_1;
                    3'b111: data_i[i] <=  `QAM64_3;
                    3'b101: data_i[i] <=  `QAM64_5;
                    3'b100: data_i[i] <=  `QAM64_7;
                    endcase
                    
                    case (in_data[6*i+5:6*i+3])
                    3'b000: data_q[i] <= `QAM64__7;
                    3'b001: data_q[i] <= `QAM64__5;
                    3'b011: data_q[i] <= `QAM64__3;
                    3'b010: data_q[i] <= `QAM64__1;
                    3'b110: data_q[i] <=  `QAM64_1;
                    3'b111: data_q[i] <=  `QAM64_3;
                    3'b101: data_q[i] <=  `QAM64_5;
                    3'b100: data_q[i] <=  `QAM64_7;
                    endcase
                end
            end
        end
    end
    else if(MODULATION == "QAM256")//+
    begin
        for(i = 0; i < 8; i = i + 1)
        begin
            always @(posedge clk)
            begin
                if(en)
                begin //0001 -15; 0101 -13; 0111 -11; 0011 -9; 0010 -7; 0110 -5; 0100 -3; 0000 -1; 
                      //1000 1; 1100 3; 1110 5; 1010 7; 1011 9; 1111 11; 1101 13; 1001 15;
                    case (in_data[8*i+3:8*i+0])
                    4'b0001: data_i[i] <= `QAM256__15;
                    4'b0101: data_i[i] <= `QAM256__13;
                    4'b0111: data_i[i] <= `QAM256__11;
                    4'b0011: data_i[i] <= `QAM256__9;
                    4'b0010: data_i[i] <= `QAM256__7;
                    4'b0110: data_i[i] <= `QAM256__5;
                    4'b0100: data_i[i] <= `QAM256__3;
                    4'b0000: data_i[i] <= `QAM256__1;
                    4'b1000: data_i[i] <=  `QAM256_1;
                    4'b1100: data_i[i] <=  `QAM256_3;
                    4'b1110: data_i[i] <=  `QAM256_5;
                    4'b1010: data_i[i] <=  `QAM256_7;
                    4'b1011: data_i[i] <=  `QAM256_9;
                    4'b1111: data_i[i] <= `QAM256_11;
                    4'b1101: data_i[i] <= `QAM256_13;
                    4'b1001: data_i[i] <= `QAM256_15;
                    endcase
                    
                    case (in_data[8*i+7:8*i+4])
                    4'b0001: data_q[i] <= `QAM256__15;
                    4'b0101: data_q[i] <= `QAM256__13;
                    4'b0111: data_q[i] <= `QAM256__11;
                    4'b0011: data_q[i] <= `QAM256__9;
                    4'b0010: data_q[i] <= `QAM256__7;
                    4'b0110: data_q[i] <= `QAM256__5;
                    4'b0100: data_q[i] <= `QAM256__3;
                    4'b0000: data_q[i] <= `QAM256__1;
                    4'b1000: data_q[i] <=  `QAM256_1;
                    4'b1100: data_q[i] <=  `QAM256_3;
                    4'b1110: data_q[i] <=  `QAM256_5;
                    4'b1010: data_q[i] <=  `QAM256_7;
                    4'b1011: data_q[i] <=  `QAM256_9;
                    4'b1111: data_q[i] <= `QAM256_11;
                    4'b1101: data_q[i] <= `QAM256_13;
                    4'b1001: data_q[i] <= `QAM256_15;
                    endcase
                end
            end
        end
    end
    
    endgenerate
    
endmodule
