`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.11.2020 13:16:11
// Design Name: 
// Module Name: ofdm_payload_gen
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
// module for generate 1 symbol
//////////////////////////////////////////////////////////////////////////////////


module ofdm_payload_gen #(parameter DATA_SIZE = 16/*, parameter NFFT = 64 TODO*/)(
    clk,
    reset,
    in_data_en,
    in_data,
    modulation,
    out_done,
    out_data_i,
    out_data_q,
    counter_data
    );
    
    input clk;
    input reset;
    input in_data_en;
    input [7:0] in_data;
    input [2:0] modulation;
    output reg out_done = 1'b0;
    output reg [DATA_SIZE-1:0] out_data_i;
    output reg [DATA_SIZE-1:0] out_data_q;
    
    output reg [7:0] counter_data = 8'b0;
    
    reg [7:0] counter_data_mod = 8'b0;
    reg [7:0] counter_cobyBytes = 8'b0;//reg for modulation symbols
    
    reg [DATA_SIZE-1:0] symbol_i [48-1:0];//
    reg [DATA_SIZE-1:0] symbol_q [48-1:0];//
    //0-5 -> 0
    //6-10 -> DATA********
    //11 -> pilot 1
    //12-24 -> DATA********
    //25 -> pilot 1
    //26-31 -> DATA********
    //32 -> 0
    //33-38 -> DATA********
    //39 -> pilot -1
    //40-52 -> DATA********
    //53 -> pilot 1
    //54-58 -> DATA********
    //59-63 -> 0
    
    //48 data symbols
    
    reg [8*8-1:0] dataForModulations; 
    
    localparam modulationBPSK = 3'd0;
    localparam modulationQPSK = 3'd1;
    localparam modulationQAM16 = 3'd2;
    localparam modulationQAM64 = 3'd3;
    localparam modulationQAM256 = 3'd4;
    
    
    reg flag_read_on_next_tact = 1'b0;
    
    wire [15:0] BPSK_wire_i [7:0];
    wire [15:0] BPSK_wire_q [7:0];
    
    wire [15:0] QPSK_wire_i [7:0];
    wire [15:0] QPSK_wire_q [7:0];
    
    wire [15:0] QAM16_wire_i [7:0];
    wire [15:0] QAM16_wire_q [7:0];
        
    wire [15:0] QAM64_wire_i [7:0];
    wire [15:0] QAM64_wire_q [7:0];
    
    wire [15:0] QAM256_wire_i [7:0];
    wire [15:0] QAM256_wire_q [7:0];
    
    always @(posedge clk)
    begin : demultiplex_data
        if(reset)   counter_data_mod <= 8'b0;
        if(reset)   counter_data <= 8'b0;
        if(reset)   counter_cobyBytes <= 8'b0;
        else
        begin
//            if(in_data_en)  counter_cobyBytes <= counter_cobyBytes + 1;
            if(out_done)    counter_data_mod <= 0;//обнуляю таймер когда начинаю отправлять жданные чтобы после отправки он сразу по приему начал считыть
            else if(in_data_en)
            begin
                if(counter_data_mod < 48)
                begin
                case(modulation)
                    modulationBPSK://+
                    begin
                        dataForModulations[7:0] <= in_data;
                        counter_data_mod <= counter_data_mod + 8;
                        flag_read_on_next_tact <= 1'b1;
                    end
                    modulationQPSK://+
                    begin
                        case(counter_cobyBytes)
                            0:
                            begin
                                counter_cobyBytes <= counter_cobyBytes + 1;
                                dataForModulations[7:0] <= in_data;
                                flag_read_on_next_tact <= 1'b0;
                            end
                            1:
                            begin
                                counter_cobyBytes <= 0;
                                dataForModulations[15:8] <= in_data;
                                flag_read_on_next_tact <= 1'b1;
                                counter_data_mod <= counter_data_mod + 8;
                            end
                        endcase                            
                    end
                    modulationQAM16://+
                    begin
                        case(counter_cobyBytes)
                            0:
                            begin
                                counter_cobyBytes <= 1;
                                dataForModulations[7:0] <= in_data;
                                flag_read_on_next_tact <= 1'b0;
                            end
                            1:
                            begin
                                counter_cobyBytes <= 2;
                                dataForModulations[15:8] <= in_data;
                            end
                            2:
                            begin
                                counter_cobyBytes <= 3;
                                dataForModulations[23:16] <= in_data;
                            end
                            3:
                            begin
                                counter_cobyBytes <= 0;
                                dataForModulations[31:24] <= in_data;
                                flag_read_on_next_tact <= 1'b1;
                                counter_data_mod <= counter_data_mod + 8;
                            end
                        endcase                            
                    end
                    modulationQAM64://+
                    begin
                        case(counter_cobyBytes)
                            0:
                            begin
                                counter_cobyBytes <= 1;
                                dataForModulations[7:0] <= in_data;
                                flag_read_on_next_tact <= 1'b0;
                            end
                            1:
                            begin
                                counter_cobyBytes <= 2;
                                dataForModulations[15:8] <= in_data;
                            end
                            2:
                            begin
                                counter_cobyBytes <= 3;
                                dataForModulations[23:16] <= in_data;
                            end
                            3:
                            begin
                                counter_cobyBytes <= 4;
                                dataForModulations[31:24] <= in_data;
                            end
                            4:
                            begin
                                counter_cobyBytes <= 5;
                                dataForModulations[39:32] <= in_data;
                            end
                            5:
                            begin
                                counter_cobyBytes <= 0;
                                dataForModulations[47:40] <= in_data;
                                flag_read_on_next_tact <= 1'b1;
                                counter_data_mod <= counter_data_mod + 8;
                            end
                        endcase                            
                    end
                    modulationQAM256:
                    begin
                        case(counter_cobyBytes)
                            0:
                            begin
                                counter_cobyBytes <= 1;
                                dataForModulations[7:0] <= in_data;
                                flag_read_on_next_tact <= 1'b0;
                            end
                            1:
                            begin
                                counter_cobyBytes <= 2;
                                dataForModulations[15:8] <= in_data;
                            end
                            2:
                            begin
                                counter_cobyBytes <= 3;
                                dataForModulations[23:16] <= in_data;
                            end
                            3:
                            begin
                                counter_cobyBytes <= 4;
                                dataForModulations[31:24] <= in_data;
                            end
                            4:
                            begin
                                counter_cobyBytes <= 5;
                                dataForModulations[39:32] <= in_data;
                            end
                            5:
                            begin
                                counter_cobyBytes <= 6;
                                dataForModulations[47:40] <= in_data;
                            end
                            6:
                            begin
                                counter_cobyBytes <= 7;
                                dataForModulations[55:48] <= in_data;
                            end
                            7:
                            begin
                                counter_cobyBytes <= 0;
                                dataForModulations[63:56] <= in_data;
                                flag_read_on_next_tact <= 1'b1;
                                counter_data_mod <= counter_data_mod + 8;
                            end
                        endcase                            
                    end
                endcase
                end
                else
                begin
//                    counter_data_mod <= 0;
                    flag_read_on_next_tact <= 1'b0;
                end
            end
            else  begin  flag_read_on_next_tact <= 1'b0; end
        end
    end
    
    reg flag_read_now = 1'b0;
    reg [5:0] counter_data_mod_read = 8'b0;
    reg flag_dataModComplete = 1'b0;
    
    always @(posedge clk)
    begin : multiplex_data
        //задержка на 1 такт
        if(reset)   flag_dataModComplete <= 1'b0;
        if(reset)   counter_data_mod_read <= 8'b0;
        else
        begin
            if(flag_read_on_next_tact)  flag_read_now <= 1'b1;
            else                        flag_read_now <= 1'b0;
            
            if(flag_read_now & (counter_data_mod_read < 48))
            begin
                flag_dataModComplete <= 1'b0;
                counter_data_mod_read <= counter_data_mod_read + 8;
                case(modulation)
                    modulationBPSK://+
                    begin
                        symbol_i[counter_data_mod_read + 0] <= BPSK_wire_i[0];
                        symbol_i[counter_data_mod_read + 1] <= BPSK_wire_i[1];
                        symbol_i[counter_data_mod_read + 2] <= BPSK_wire_i[2];
                        symbol_i[counter_data_mod_read + 3] <= BPSK_wire_i[3];
                        symbol_i[counter_data_mod_read + 4] <= BPSK_wire_i[4];
                        symbol_i[counter_data_mod_read + 5] <= BPSK_wire_i[5];
                        symbol_i[counter_data_mod_read + 6] <= BPSK_wire_i[6];
                        symbol_i[counter_data_mod_read + 7] <= BPSK_wire_i[7];
                        symbol_q[counter_data_mod_read + 0] <= BPSK_wire_q[0];
                        symbol_q[counter_data_mod_read + 1] <= BPSK_wire_q[1];
                        symbol_q[counter_data_mod_read + 2] <= BPSK_wire_q[2];
                        symbol_q[counter_data_mod_read + 3] <= BPSK_wire_q[3];
                        symbol_q[counter_data_mod_read + 4] <= BPSK_wire_q[4];
                        symbol_q[counter_data_mod_read + 5] <= BPSK_wire_q[5];
                        symbol_q[counter_data_mod_read + 6] <= BPSK_wire_q[6];
                        symbol_q[counter_data_mod_read + 7] <= BPSK_wire_q[7];
                    end
                    modulationQPSK://+
                    begin
                        symbol_i[counter_data_mod_read + 0] <= QPSK_wire_i[0];
                        symbol_i[counter_data_mod_read + 1] <= QPSK_wire_i[1];
                        symbol_i[counter_data_mod_read + 2] <= QPSK_wire_i[2];
                        symbol_i[counter_data_mod_read + 3] <= QPSK_wire_i[3];
                        symbol_i[counter_data_mod_read + 4] <= QPSK_wire_i[4];
                        symbol_i[counter_data_mod_read + 5] <= QPSK_wire_i[5];
                        symbol_i[counter_data_mod_read + 6] <= QPSK_wire_i[6];
                        symbol_i[counter_data_mod_read + 7] <= QPSK_wire_i[7];
                        symbol_q[counter_data_mod_read + 0] <= QPSK_wire_q[0];
                        symbol_q[counter_data_mod_read + 1] <= QPSK_wire_q[1];
                        symbol_q[counter_data_mod_read + 2] <= QPSK_wire_q[2];
                        symbol_q[counter_data_mod_read + 3] <= QPSK_wire_q[3];
                        symbol_q[counter_data_mod_read + 4] <= QPSK_wire_q[4];
                        symbol_q[counter_data_mod_read + 5] <= QPSK_wire_q[5];
                        symbol_q[counter_data_mod_read + 6] <= QPSK_wire_q[6];
                        symbol_q[counter_data_mod_read + 7] <= QPSK_wire_q[7];
                    end
                    modulationQAM16://+
                    begin
                        symbol_i[counter_data_mod_read + 0] <= QAM16_wire_i[0];
                        symbol_i[counter_data_mod_read + 1] <= QAM16_wire_i[1];
                        symbol_i[counter_data_mod_read + 2] <= QAM16_wire_i[2];
                        symbol_i[counter_data_mod_read + 3] <= QAM16_wire_i[3];
                        symbol_i[counter_data_mod_read + 4] <= QAM16_wire_i[4];
                        symbol_i[counter_data_mod_read + 5] <= QAM16_wire_i[5];
                        symbol_i[counter_data_mod_read + 6] <= QAM16_wire_i[6];
                        symbol_i[counter_data_mod_read + 7] <= QAM16_wire_i[7];
                        symbol_q[counter_data_mod_read + 0] <= QAM16_wire_q[0];
                        symbol_q[counter_data_mod_read + 1] <= QAM16_wire_q[1];
                        symbol_q[counter_data_mod_read + 2] <= QAM16_wire_q[2];
                        symbol_q[counter_data_mod_read + 3] <= QAM16_wire_q[3];
                        symbol_q[counter_data_mod_read + 4] <= QAM16_wire_q[4];
                        symbol_q[counter_data_mod_read + 5] <= QAM16_wire_q[5];
                        symbol_q[counter_data_mod_read + 6] <= QAM16_wire_q[6];
                        symbol_q[counter_data_mod_read + 7] <= QAM16_wire_q[7];
                    end
                    modulationQAM64://+
                    begin
                        symbol_i[counter_data_mod_read + 0] <= QAM64_wire_i[0];
                        symbol_i[counter_data_mod_read + 1] <= QAM64_wire_i[1];
                        symbol_i[counter_data_mod_read + 2] <= QAM64_wire_i[2];
                        symbol_i[counter_data_mod_read + 3] <= QAM64_wire_i[3];
                        symbol_i[counter_data_mod_read + 4] <= QAM64_wire_i[4];
                        symbol_i[counter_data_mod_read + 5] <= QAM64_wire_i[5];
                        symbol_i[counter_data_mod_read + 6] <= QAM64_wire_i[6];
                        symbol_i[counter_data_mod_read + 7] <= QAM64_wire_i[7];
                        symbol_q[counter_data_mod_read + 0] <= QAM64_wire_q[0];
                        symbol_q[counter_data_mod_read + 1] <= QAM64_wire_q[1];
                        symbol_q[counter_data_mod_read + 2] <= QAM64_wire_q[2];
                        symbol_q[counter_data_mod_read + 3] <= QAM64_wire_q[3];
                        symbol_q[counter_data_mod_read + 4] <= QAM64_wire_q[4];
                        symbol_q[counter_data_mod_read + 5] <= QAM64_wire_q[5];
                        symbol_q[counter_data_mod_read + 6] <= QAM64_wire_q[6];
                        symbol_q[counter_data_mod_read + 7] <= QAM64_wire_q[7];
                    end
                    modulationQAM256:
                    begin
                        symbol_i[counter_data_mod_read + 0] <= QAM256_wire_i[0];
                        symbol_i[counter_data_mod_read + 1] <= QAM256_wire_i[1];
                        symbol_i[counter_data_mod_read + 2] <= QAM256_wire_i[2];
                        symbol_i[counter_data_mod_read + 3] <= QAM256_wire_i[3];
                        symbol_i[counter_data_mod_read + 4] <= QAM256_wire_i[4];
                        symbol_i[counter_data_mod_read + 5] <= QAM256_wire_i[5];
                        symbol_i[counter_data_mod_read + 6] <= QAM256_wire_i[6];
                        symbol_i[counter_data_mod_read + 7] <= QAM256_wire_i[7];
                        symbol_q[counter_data_mod_read + 0] <= QAM256_wire_q[0];
                        symbol_q[counter_data_mod_read + 1] <= QAM256_wire_q[1];
                        symbol_q[counter_data_mod_read + 2] <= QAM256_wire_q[2];
                        symbol_q[counter_data_mod_read + 3] <= QAM256_wire_q[3];
                        symbol_q[counter_data_mod_read + 4] <= QAM256_wire_q[4];
                        symbol_q[counter_data_mod_read + 5] <= QAM256_wire_q[5];
                        symbol_q[counter_data_mod_read + 6] <= QAM256_wire_q[6];
                        symbol_q[counter_data_mod_read + 7] <= QAM256_wire_q[7];
                    end
                endcase
            end
            else if(counter_data_mod_read == 48)
            begin
                flag_dataModComplete <= 1'b1;
                if(out_done) counter_data_mod_read <= 1'b0;
            end
        end
    end
    
    //0-5 -> 0
    //6-10 -> DATA********
    //11 -> pilot 1
    //12-24 -> DATA********
    //25 -> pilot 1
    //26-31 -> DATA********
    //32 -> 0
    //33-38 -> DATA********
    //39 -> pilot -1
    //40-52 -> DATA********
    //53 -> pilot 1
    //54-58 -> DA
    //59-63 -> 0
    
    always @(posedge clk)
    begin : send_data
        if(flag_dataModComplete)
        begin
            if(counter_data < 64)
            begin
                out_done <= 1'b1;
                counter_data <= counter_data + 1;
                if(counter_data < 6)            out_data_i <= 0;
                else if(counter_data < 11)      out_data_i <= symbol_i[counter_data - 6];
                else if(counter_data < 12)      out_data_i <= 1024;
                else if(counter_data < 25)      out_data_i <= symbol_i[counter_data - 7];
                else if(counter_data < 26)      out_data_i <= 1024;
                else if(counter_data < 32)      out_data_i <= symbol_i[counter_data - 8];
                else if(counter_data < 33)      out_data_i <= 0;
                else if(counter_data < 39)      out_data_i <= symbol_i[counter_data - 9];
                else if(counter_data < 40)      out_data_i <= -1024;
                else if(counter_data < 53)      out_data_i <= symbol_i[counter_data - 10];
                else if(counter_data < 54)      out_data_i <= 1024;
                else if(counter_data < 59)      out_data_i <= symbol_i[counter_data - 11];
                else if(counter_data < 63)      out_data_i <= 0;
                
                if(counter_data < 6)            out_data_q <= 0;
                else if(counter_data < 11)      out_data_q <= symbol_q[counter_data - 6];
                else if(counter_data < 12)      out_data_q <= /*1024*/0;
                else if(counter_data < 25)      out_data_q <= symbol_q[counter_data - 7];
                else if(counter_data < 26)      out_data_q <= /*1024*/0;
                else if(counter_data < 32)      out_data_q <= symbol_q[counter_data - 8];
                else if(counter_data < 33)      out_data_q <= 0;
                else if(counter_data < 39)      out_data_q <= symbol_q[counter_data - 9];
                else if(counter_data < 40)      out_data_q <= /*-1024*/0;
                else if(counter_data < 53)      out_data_q <= symbol_q[counter_data - 10];
                else if(counter_data < 54)      out_data_q <= /*1024*/0;
                else if(counter_data < 59)      out_data_q <= symbol_q[counter_data - 11];
                else if(counter_data < 63)      out_data_q <= 0;
            end
            else
            begin
                out_done <= 1'b0; 
            end
        end
        else  begin  counter_data <= 1'b0; out_done <= 1'b0; end
    end
        
    mapModulations #(.DATA_SIZE(16),.MODULATION("BPSK") /*BPSK QPSK QAM16 QAM64 QAM256*/)
    BPSK_modulation(
        .clk(clk),
        .en(1'b1),
        .in_data(dataForModulations),
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
        
    mapModulations #(.DATA_SIZE(16),.MODULATION("QPSK") /*BPSK QPSK QAM16 QAM64 QAM256*/)
    QPSK_modulation(
        .clk(clk),
        .en(1'b1),
        .in_data(dataForModulations),
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
        
    mapModulations #(.DATA_SIZE(16),.MODULATION("QAM16") /*BPSK QPSK QAM16 QAM64 QAM256*/)
    QAM16_modulation(
        .clk(clk),
        .en(1'b1),
        .in_data(dataForModulations),
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
        
    mapModulations #(.DATA_SIZE(16),.MODULATION("QAM64") /*BPSK QPSK QAM16 QAM64 QAM256*/)
    QAM64_modulation(
        .clk(clk),
        .en(1'b1),
        .in_data(dataForModulations),
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
        
    mapModulations #(.DATA_SIZE(16),.MODULATION("QAM256") /*BPSK QPSK QAM16 QAM64 QAM256*/)
    QAM256_modulation(
        .clk(clk),
        .en(1'b1),
        .in_data(dataForModulations),
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
