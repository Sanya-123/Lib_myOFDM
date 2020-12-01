`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.11.2020 16:55:33
// Design Name: 
// Module Name: ofdm_payload_recive
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
// from OFDM frame after fft get data or ungen ofdm frame
// main function demap spector to data
// in spector -> data_i+i*data_q -> data
//////////////////////////////////////////////////////////////////////////////////

`include "commonOFDM.vh"


module ofdm_payload_recive #(parameter DATA_SIZE = 16)(
    clk,
    reset,
    in_data_en,
    in_data_i,
    in_data_q,
    modulation,
    out_done,
    out_data,
    counter_data,
    wayt_recive_data
    );
    
    input clk;
    input reset;
    input in_data_en;
    input [DATA_SIZE-1:0] in_data_i;
    input [DATA_SIZE-1:0] in_data_q;
    input [2:0] modulation;
    output reg out_done = 1'b0;
    output reg [7:0] out_data;
    
    output [15:0] counter_data;
    
    input wayt_recive_data;//flag от том что можно отправлять
    
    
    
    localparam N_DATA = 192;//количество гармоник с информццией
    //у меня QAM256 поэтому на 1 поднесушую максимум 1 бай
    localparam N_DATA_BYTS_MAX = 192;//максимальное число информации на 1 символ при максимаольной модуляции
    
//in my OFDM 802.16e 256point
//N data = 200-8
//N pilot 8
//1 DC
//N left=28
//N Right=27
//mask [1:100] -> 1,....,100
//mask [156:255] ->-100,...,-1

localparam SUBCARRIER_MASK_L =                                                                                                                                
    128'b11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110000000000000000000000000000;
//-1:-100         |10       |20       |30       |40       |50       |60       |70       |80       |90       |100                                                    
//N right                                                                                                    |1                         |28                         
//**     |-1                                              |-50                                              |-100                       |-128

localparam SUBCARRIER_MASK_R =
    128'b00000000000000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110;    
//N left |27                       |1 
//100:1                             |100     |90       |80       |70       |60       |50       |40       |30       |20       |10       |1
//DC                                                                                                                                    |0 
//*      |127                      |101      |90                                     |50                                     |10        |0 

localparam SUBCARRIER_MASK = {SUBCARRIER_MASK_L, SUBCARRIER_MASK_R};


//pilot -88 -63 -38 -13 13 38 63 88

localparam PILOT_MASK_L =                                                                               
    128'b00000000000010000000000000000000000001000000000000000000000000100000000000000000000000010000000000000000000000000000000000000000;
//**     |-1      |-10      |-20      |-30      |-40      |-50      |-60      |-70      |-80      |-90      |-100                       |-128
    
    
localparam PILOT_MASK_R =
    128'b00000000000000000000000000000000000000010000000000000000000000001000000000000000000000000100000000000000000000000010000000000000; 
//*      |127                       |101      |90       |80       |70       |60       |50       |40       |30       |20    |13          |0   

localparam PILOT_MASK = {PILOT_MASK_L, PILOT_MASK_R};

//DATA
localparam DATA_SUBCARRIER_MASK =
    SUBCARRIER_MASK ^ PILOT_MASK;


    //0 -> 0
    //1-12 -> DATA********
    //13 -> pilot x             13
    //14-37 -> DATA********
    //38 -> pilot x             38
    //39-62 -> DATA********
    //63 -> pilot x             63
    //64-87 -> DATA********
    //88 -> pilot x             88
    //89-100 -> DATA********
    //101-155 -> 0
    //156-167 -> DATA********
    //168 -> pilot x            -88
    //169-192 -> DATA********
    //193 -> pilot x            -63
    //169-217 -> DATA********
    //218 -> pilot x            -38
    //219-242 -> DATA********
    //243 -> pilot x            -13
    //244-255 -> DATA********
    
    wire [8*8-1:0] data_from_demodulations_BPSK;
    wire [8*8-1:0] data_from_demodulations_QPSK;
    wire [8*8-1:0] data_from_demodulations_QAM16;
    wire [8*8-1:0] data_from_demodulations_QAM64;
    wire [8*8-1:0] data_from_demodulations_QAM256;    

    
    localparam modulationBPSK = 3'd0;
    localparam modulationQPSK = 3'd1;
    localparam modulationQAM16 = 3'd2;
    localparam modulationQAM64 = 3'd3;
    localparam modulationQAM256 = 3'd4;
    
    reg flag_read_on_next_tact = 1'b0;
    
    reg [DATA_SIZE-1:0] _reg_i [7:0];
    reg [DATA_SIZE-1:0] _reg_q [7:0];
    
    reg [3:0] counter_simbol_reg = 0;
    reg [15:0] counter_symbols = 0;
    
    
    always @(posedge clk)
    begin : DEMULTIPLEX_DATA
        if(reset)   counter_simbol_reg <= 0;
        if(reset)   counter_symbols <= 0;
        if(reset)   flag_read_on_next_tact <= 0;
        else
        begin
            if(out_done)    counter_symbols <= 0;
            else if(in_data_en)
            begin
                if(counter_symbols < 256)
                begin
                    counter_symbols <= counter_symbols + 1;
                    if(DATA_SUBCARRIER_MASK[counter_symbols])//если на этом месте маски стоит 1 то на этой поднесуйщей данные
                    begin
                        _reg_i[counter_simbol_reg] <= in_data_i;
                        _reg_q[counter_simbol_reg] <= in_data_q;
                        if(counter_simbol_reg == 7)
                        begin
                            counter_simbol_reg <= 0;
                            flag_read_on_next_tact <= 1'b1;
                        end
                        else
                        begin
                            counter_simbol_reg <= counter_simbol_reg + 1;
                            flag_read_on_next_tact <= 1'b0;
                        end
                    end
                    else    flag_read_on_next_tact <= 1'b0;
                end
            end //if(in_data_en)
            else    flag_read_on_next_tact <= 1'b0;
        end //else reset
    end
    
        
    localparam OBinMM = 8;//максимальное количество байт на выходе демодулятора при макиимально позиционной модуляции
    
//    reg [7:0] rx_bytes [N_DATA_BYTS_MAX-1:0];
    reg [8*OBinMM:0] rx_bytes [N_DATA_BYTS_MAX/OBinMM-1:0];
    reg [15:0] counte_rx_bytes = 0;
    
    reg flag_read_now = 1'b0;
    //24 байта при BPSK
    wire [15:0] maximim_data_rx =   modulation == modulationBPSK ?   24 : 
                                    modulation == modulationQPSK ?   48 : 
                                    modulation == modulationQAM16 ?  96 :
                                    modulation == modulationQAM64 ? 144 :
                                    modulation == modulationQAM256 ? 192 : 24;
    
    wire [12:0] bpsk_sworlds = counte_rx_bytes[15:3];
    wire [13:0] qpsk_sworlds = counte_rx_bytes[15:2];
    wire [14:0] qam16_sworlds = counte_rx_bytes[15:1];
    wire [13:0] qam64_sworlds = counte_rx_bytes[15:2];
    
    localparam N_SYMBOLS_FROM_MODYLATIONS = 24;
    
    reg [15:0] counter_symbols_QAM64 = 0;
    reg [47:0] QAM_64_TMP = 0;
    
    
    always @(posedge clk)
    begin : MULTIPLEX_DATA
        if(reset)   counte_rx_bytes <= 0;
        else
        begin
            if(flag_read_on_next_tact)  flag_read_now <= 1'b1;
            else                        flag_read_now <= 1'b0;
            
            if(flag_read_now & (counte_rx_bytes < N_SYMBOLS_FROM_MODYLATIONS))
            begin
//                counte_rx_bytes <= counte_rx_bytes + 1;
                case(modulation)
                modulationBPSK: //+
                begin//NODE это при OBinMM==8
                    counte_rx_bytes <= counte_rx_bytes + 1;
                    case(counte_rx_bytes[2:0])
                    0:rx_bytes[bpsk_sworlds][ 7:0 ] <= data_from_demodulations_BPSK[7:0];
                    1:rx_bytes[bpsk_sworlds][15:8 ] <= data_from_demodulations_BPSK[7:0];
                    2:rx_bytes[bpsk_sworlds][23:16] <= data_from_demodulations_BPSK[7:0];
                    3:rx_bytes[bpsk_sworlds][31:24] <= data_from_demodulations_BPSK[7:0];
                    4:rx_bytes[bpsk_sworlds][39:32] <= data_from_demodulations_BPSK[7:0];
                    5:rx_bytes[bpsk_sworlds][47:40] <= data_from_demodulations_BPSK[7:0];
                    6:rx_bytes[bpsk_sworlds][55:48] <= data_from_demodulations_BPSK[7:0];
                    7:rx_bytes[bpsk_sworlds][63:56] <= data_from_demodulations_BPSK[7:0];
                    endcase
                end
                modulationQPSK: //+
                begin//NODE это при OBinMM==8
                    counte_rx_bytes <= counte_rx_bytes + 1;
                    case(counte_rx_bytes[1:0])
                    0:rx_bytes[qpsk_sworlds][15:0 ] <= data_from_demodulations_QPSK[15:0];
                    1:rx_bytes[qpsk_sworlds][31:16] <= data_from_demodulations_QPSK[15:0];
                    2:rx_bytes[qpsk_sworlds][47:32] <= data_from_demodulations_QPSK[15:0];
                    3:rx_bytes[qpsk_sworlds][63:48] <= data_from_demodulations_QPSK[15:0];
                    endcase
                end
                modulationQAM16: //+
                begin//NODE это при OBinMM==8
                    counte_rx_bytes <= counte_rx_bytes + 1;
                    case(counte_rx_bytes[0])
                    0:rx_bytes[qam16_sworlds][31:0 ] <= data_from_demodulations_QAM16[31:0];
                    1:rx_bytes[qam16_sworlds][63:32] <= data_from_demodulations_QAM16[31:0];
                    endcase
                end
                modulationQAM64: 
                begin//NODE это при OBinMM==8
                    counte_rx_bytes <= counte_rx_bytes + 1;
                    case(counte_rx_bytes[1:0])
                    0:rx_bytes[counter_symbols_QAM64][47:0 ] <= data_from_demodulations_QAM64[47:0];
                    1:
                    begin 
                        rx_bytes[counter_symbols_QAM64][63:48] <= data_from_demodulations_QAM64[15:0];   
                        QAM_64_TMP [31:0] <= data_from_demodulations_QAM64[47:16];
                        counter_symbols_QAM64 <= counter_symbols_QAM64 + 1;
                    end
                    2:
                    begin 
                        rx_bytes[counter_symbols_QAM64][63:0] <= {data_from_demodulations_QAM64[31:0],QAM_64_TMP [31:0] };
                        QAM_64_TMP [47:32] <= data_from_demodulations_QAM64[47:32];
                        counter_symbols_QAM64 <= counter_symbols_QAM64 + 1;
                    end
                    3:
                    begin 
                        rx_bytes[counter_symbols_QAM64][63:0] <= {data_from_demodulations_QAM64[47:0], QAM_64_TMP[47:32] };
                        counter_symbols_QAM64 <= counter_symbols_QAM64 + 1;
                    end
                    endcase
                end
                modulationQAM256: //+
                begin//NODE это при OBinMM==8
                    counte_rx_bytes <= counte_rx_bytes + 1;
                    rx_bytes[counte_rx_bytes][63:0 ] <= data_from_demodulations_QAM256[63:0];
                end
                endcase
            end
            
            if(counte_rx_bytes == N_SYMBOLS_FROM_MODYLATIONS)
            begin
                if(out_done) counte_rx_bytes <= 1'b0;
                
                if(out_done) counter_symbols_QAM64 <= 1'b0;
            end
            
        end
    end
    
    reg flag_dataModComplete = 1'b0;
    
    always @(posedge clk)
    begin : FLAG_DATA_COMPLETE
        //задержка на 1 такт
        if(reset)   flag_dataModComplete <= 1'b0;
        else
        begin
             if(counte_rx_bytes == N_SYMBOLS_FROM_MODYLATIONS)     flag_dataModComplete <= 1'b1;
             else if(out_done == 1'b0)                  flag_dataModComplete <= 1'b0;
        end
    end
    
    reg [15:0] counter_send = 0;
    
    always @(posedge clk)
    begin : OUTPUT_DONE
        if(flag_dataModComplete)
        begin
            if(counter_send < maximim_data_rx)
            begin
                out_done <= 1'b1;
            end
            else
            begin
                out_done <= 1'b0; 
            end
        end
    end
    
    assign counter_data = counter_send;

    always @(posedge clk)
    begin : SEND_DATA
        if(reset)   counter_send <= 0;
        else
        begin
            if(flag_dataModComplete == 1'b0)    counter_send <= 0;
            else if(flag_dataModComplete & wayt_recive_data)
            begin
                counter_send <= counter_send + 1;
                case (counter_send[2:0])
                0:  out_data <= rx_bytes[counter_send[15:3]][ 7:0 ];
                1:  out_data <= rx_bytes[counter_send[15:3]][15:8 ];
                2:  out_data <= rx_bytes[counter_send[15:3]][23:16];
                3:  out_data <= rx_bytes[counter_send[15:3]][31:24];
                4:  out_data <= rx_bytes[counter_send[15:3]][39:32];
                5:  out_data <= rx_bytes[counter_send[15:3]][47:40];
                6:  out_data <= rx_bytes[counter_send[15:3]][55:48];
                7:  out_data <= rx_bytes[counter_send[15:3]][63:56];
                endcase
            end
        end   
    end
    
    
    
    //********************demodulations********************
    demapModulations #(.DATA_SIZE(DATA_SIZE), .MODULATION("BPSK") /*BPSK QPSK QAM16 QAM64 QAM256*/)
    BPSK_demodulation(
        .clk(clk),
        .en(1'b1),
        .in_data_0_i(_reg_i[0]),
        .in_data_0_q(_reg_q[0]),
        .in_data_1_i(_reg_i[1]),
        .in_data_1_q(_reg_q[1]),
        .in_data_2_i(_reg_i[2]),
        .in_data_2_q(_reg_q[2]),
        .in_data_3_i(_reg_i[3]),
        .in_data_3_q(_reg_q[3]),
        .in_data_4_i(_reg_i[4]),
        .in_data_4_q(_reg_q[4]),
        .in_data_5_i(_reg_i[5]),
        .in_data_5_q(_reg_q[5]),
        .in_data_6_i(_reg_i[6]),
        .in_data_6_q(_reg_q[6]),
        .in_data_7_i(_reg_i[7]),
        .in_data_7_q(_reg_q[7]),
        .out_data(data_from_demodulations_BPSK)
    );
    
    demapModulations #(.DATA_SIZE(DATA_SIZE), .MODULATION("QPSK") /*BPSK QPSK QAM16 QAM64 QAM256*/)
    QPSK_demodulation(
        .clk(clk),
        .en(1'b1),
        .in_data_0_i(_reg_i[0]),
        .in_data_0_q(_reg_q[0]),
        .in_data_1_i(_reg_i[1]),
        .in_data_1_q(_reg_q[1]),
        .in_data_2_i(_reg_i[2]),
        .in_data_2_q(_reg_q[2]),
        .in_data_3_i(_reg_i[3]),
        .in_data_3_q(_reg_q[3]),
        .in_data_4_i(_reg_i[4]),
        .in_data_4_q(_reg_q[4]),
        .in_data_5_i(_reg_i[5]),
        .in_data_5_q(_reg_q[5]),
        .in_data_6_i(_reg_i[6]),
        .in_data_6_q(_reg_q[6]),
        .in_data_7_i(_reg_i[7]),
        .in_data_7_q(_reg_q[7]),
        .out_data(data_from_demodulations_QPSK)
    );
    
    demapModulations #(.DATA_SIZE(DATA_SIZE), .MODULATION("QAM16") /*BPSK QPSK QAM16 QAM64 QAM256*/)
    QAM16_demodulation(
        .clk(clk),
        .en(1'b1),
        .in_data_0_i(_reg_i[0]),
        .in_data_0_q(_reg_q[0]),
        .in_data_1_i(_reg_i[1]),
        .in_data_1_q(_reg_q[1]),
        .in_data_2_i(_reg_i[2]),
        .in_data_2_q(_reg_q[2]),
        .in_data_3_i(_reg_i[3]),
        .in_data_3_q(_reg_q[3]),
        .in_data_4_i(_reg_i[4]),
        .in_data_4_q(_reg_q[4]),
        .in_data_5_i(_reg_i[5]),
        .in_data_5_q(_reg_q[5]),
        .in_data_6_i(_reg_i[6]),
        .in_data_6_q(_reg_q[6]),
        .in_data_7_i(_reg_i[7]),
        .in_data_7_q(_reg_q[7]),
        .out_data(data_from_demodulations_QAM16)
    );
    
    demapModulations #(.DATA_SIZE(DATA_SIZE), .MODULATION("QAM64") /*BPSK QPSK QAM16 QAM64 QAM256*/)
    QAM64_demodulation(
        .clk(clk),
        .en(1'b1),
        .in_data_0_i(_reg_i[0]),
        .in_data_0_q(_reg_q[0]),
        .in_data_1_i(_reg_i[1]),
        .in_data_1_q(_reg_q[1]),
        .in_data_2_i(_reg_i[2]),
        .in_data_2_q(_reg_q[2]),
        .in_data_3_i(_reg_i[3]),
        .in_data_3_q(_reg_q[3]),
        .in_data_4_i(_reg_i[4]),
        .in_data_4_q(_reg_q[4]),
        .in_data_5_i(_reg_i[5]),
        .in_data_5_q(_reg_q[5]),
        .in_data_6_i(_reg_i[6]),
        .in_data_6_q(_reg_q[6]),
        .in_data_7_i(_reg_i[7]),
        .in_data_7_q(_reg_q[7]),
        .out_data(data_from_demodulations_QAM64)
    );
    
    demapModulations #(.DATA_SIZE(DATA_SIZE), .MODULATION("QAM256") /*BPSK QPSK QAM16 QAM64 QAM256*/)
    QAM256_demodulation(
        .clk(clk),
        .en(1'b1),
        .in_data_0_i(_reg_i[0]),
        .in_data_0_q(_reg_q[0]),
        .in_data_1_i(_reg_i[1]),
        .in_data_1_q(_reg_q[1]),
        .in_data_2_i(_reg_i[2]),
        .in_data_2_q(_reg_q[2]),
        .in_data_3_i(_reg_i[3]),
        .in_data_3_q(_reg_q[3]),
        .in_data_4_i(_reg_i[4]),
        .in_data_4_q(_reg_q[4]),
        .in_data_5_i(_reg_i[5]),
        .in_data_5_q(_reg_q[5]),
        .in_data_6_i(_reg_i[6]),
        .in_data_6_q(_reg_q[6]),
        .in_data_7_i(_reg_i[7]),
        .in_data_7_q(_reg_q[7]),
        .out_data(data_from_demodulations_QAM256)
    );
    
    
endmodule
