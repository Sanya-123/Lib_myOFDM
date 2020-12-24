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
// module for generate 1 symbol OFDM for ifft data 
// main function map spector from data
// in data -> data_i+i*data_q -> spector
//////////////////////////////////////////////////////////////////////////////////

`include "commonOFDM.vh"

module ofdm_payload_gen #(parameter DATA_SIZE = 16)(
    clk,
    reset,
    in_data_en,
    in_data,
    modulation,
    flag_ready_recive,
    out_done,
    out_data_i,
    out_data_q,
    counter_data,
    wayt_recive_data
    );
    
    /* modulation   | byts input
     * BPSK         |   24
     * QPSK         |   48
     * QAM16        |   96
     * QAM64        |   144
     * QAM256       |   192
    */
    
    input clk;
    input reset;
    input in_data_en;
    input [7:0] in_data;
    input [2:0] modulation;
    output flag_ready_recive;
    output reg out_done = 1'b0;
    output reg [DATA_SIZE-1:0] out_data_i;
    output reg [DATA_SIZE-1:0] out_data_q;
    
    output reg [15:0] counter_data = 0;
    input wayt_recive_data;//flag от том что можно отправлять
    
    localparam N_DATA = 192;//количество гармоник с информццией
    localparam N_DATA_BYTS_MAX = 192;//максимальное число информации на 1 символ при максимаольной модуляции
    
    reg [15:0] counter_data_mod = 0;
    reg [15:0] counter_cobyBytes = 0;//reg for modulation symbols
    
    reg [DATA_SIZE-1:0] symbol_i [N_DATA-1:0];//
    reg [DATA_SIZE-1:0] symbol_q [N_DATA-1:0];//
    
    //example symbols in wi-fi 802.11a
//    // mask[0] is DC, mask[1:26] -> 1,..., 26
//// mask[38:63] -> -26,..., -1
//localparam SUBCARRIER_MASK =
//    64'b1111111111111111111111111100000000000111111111111111111111111110;

//localparam HT_SUBCARRIER_MASK =
//    64'b1111111111111111111111111111000000011111111111111111111111111110;

//// -7, -21, 21, 7
//localparam PILOT_MASK =
//    64'b0000001000000000000010000000000000000000001000000000000010000000;

//localparam DATA_SUBCARRIER_MASK =
//    SUBCARRIER_MASK ^ PILOT_MASK;

//localparam HT_DATA_SUBCARRIER_MASK = 
//    HT_SUBCARRIER_MASK ^ PILOT_MASK;

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
    
    
    //N_DATA data symbols
    
    reg [8*8-1:0] dataForModulations; 
    
    localparam modulationBPSK = `BPSK_MOD;
    localparam modulationQPSK = `QPSK_MOD;
    localparam modulationQAM16 = `QAM16_MOD;
    localparam modulationQAM64 = `QAM64_MOD;
    localparam modulationQAM256 = `QAM256_MOD;
    
    
    reg flag_read_on_next_tact = 1'b0;
    
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
    
    reg [2:0] modulation_use;
    
    assign flag_ready_recive = counter_data_mod < N_DATA & (out_done == 1'b0);
//    always @(posedge clk)
//    begin : flag_ready_recibe
//        if(reset)   flag_ready_recive <= 1'b0;
//        else        flag_ready_recive <= counter_data_mod < N_DATA;
        
//    end
    
    always @(posedge clk)
    begin : DEMULTIPLEX_DATA
        if(reset)   counter_data_mod <= 0;
        if(reset)   counter_data <= 0;
        if(reset)   counter_cobyBytes <= 0;
        else
        begin
//            if(in_data_en)  counter_cobyBytes <= counter_cobyBytes + 1;
            if(out_done)    begin  flag_read_on_next_tact <= 1'b0; end
            if(out_done)    counter_data_mod <= 0;//обнуляю таймер когда начинаю отправлять жданные чтобы после отправки он сразу по приему начал считыть
            else if(in_data_en)
            begin
                if(counter_data_mod < N_DATA/*flag_ready_recive*/)
                begin
                modulation_use <= modulation;
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
    reg [15:0] counter_data_mod_read = 0;
    reg flag_dataModComplete = 1'b0;
    
    always @(posedge clk)
    begin : MULTIPLEX_DATA
        //задержка на 1 такт
//        if(reset)   flag_dataModComplete <= 1'b0;
        if(reset)   counter_data_mod_read <= 0;
        else
        begin
            if(flag_read_on_next_tact)  flag_read_now <= 1'b1;
            else                        flag_read_now <= 1'b0;
            
            if(flag_read_now & (counter_data_mod_read < N_DATA))
            begin
//                flag_dataModComplete <= 1'b0;
                counter_data_mod_read <= counter_data_mod_read + 8;
                case(/*modulation*/modulation_use)
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
                    modulationQAM256://+
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
            else if(counter_data_mod_read == N_DATA)
            begin
//                flag_dataModComplete <= 1'b1;
                if(out_done) counter_data_mod_read <= 1'b0;
            end
        end
    end
    
    always @(posedge clk)
    begin : FLAG_DATA_COMPLETE
        //задержка на 1 такт
        if(reset)   flag_dataModComplete <= 1'b0;
        else
        begin
             if(counter_data_mod_read == N_DATA)    flag_dataModComplete <= 1'b1;
             else if(out_done == 1'b0)              flag_dataModComplete <= 1'b0;
        end
    end
    
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


    always @(posedge clk)
    begin : OUTPUT_DONE
        if(flag_dataModComplete)
        begin
            if(counter_data < 256)
            begin
                out_done <= 1'b1;
            end
            else
            begin
                out_done <= 1'b0; 
            end
        end
    end
    
    always @(posedge clk)
    begin : SEND_DATA
        if(flag_dataModComplete & wayt_recive_data)//TODO
        begin
            if(counter_data < 256)
            begin
//                out_done <= 1'b1;
                counter_data <= counter_data + 1;
                if(counter_data == 0)           out_data_i <= 0;
                else if(counter_data < 13)      out_data_i <= symbol_i[counter_data - 1];
                else if(counter_data < 14)      out_data_i <= `PILOT_P13_I;
                else if(counter_data < 38)      out_data_i <= symbol_i[counter_data - 2];
                else if(counter_data < 39)      out_data_i <= `PILOT_P38_I;
                else if(counter_data < 63)      out_data_i <= symbol_i[counter_data - 3];
                else if(counter_data < 64)      out_data_i <= `PILOT_P63_I;
                else if(counter_data < 88)      out_data_i <= symbol_i[counter_data - 4];
                else if(counter_data < 89)      out_data_i <= `PILOT_P88_I;
                else if(counter_data < 101)     out_data_i <= symbol_i[counter_data - 5];
                else if(counter_data < 156)     out_data_i <= 0;
                else if(counter_data < 168)     out_data_i <= symbol_i[counter_data - 60];
                else if(counter_data < 169)     out_data_i <= `PILOT_P_88_I;
                else if(counter_data < 193)     out_data_i <= symbol_i[counter_data - 61];
                else if(counter_data < 194)     out_data_i <= `PILOT_P_63_I;
                else if(counter_data < 218)     out_data_i <= symbol_i[counter_data - 62];
                else if(counter_data < 219)     out_data_i <= `PILOT_P_38_I;
                else if(counter_data < 243)     out_data_i <= symbol_i[counter_data - 63];
                else if(counter_data < 244)     out_data_i <= `PILOT_P_13_I;
                else if(counter_data < 256)     out_data_i <= symbol_i[counter_data - 64];
                
                
//                else if(counter_data < 11)      out_data_i <= symbol_i[counter_data - 2];
//                else if(counter_data < 12)      out_data_i <= 1024;
//                else if(counter_data < 25)      out_data_i <= symbol_i[counter_data - 7];
//                else if(counter_data < 26)      out_data_i <= 1024;
//                else if(counter_data < 32)      out_data_i <= symbol_i[counter_data - 8];
//                else if(counter_data < 33)      out_data_i <= 0;
//                else if(counter_data < 39)      out_data_i <= symbol_i[counter_data - 9];
//                else if(counter_data < 40)      out_data_i <= -1024;
//                else if(counter_data < 53)      out_data_i <= symbol_i[counter_data - 10];
//                else if(counter_data < 54)      out_data_i <= 1024;
//                else if(counter_data < 59)      out_data_i <= symbol_i[counter_data - 11];
//                else if(counter_data < 63)      out_data_i <= 0;
                
                
                
                
                if(counter_data == 0)           out_data_q <= 0;
                else if(counter_data < 13)      out_data_q <= symbol_q[counter_data - 1];
                else if(counter_data < 14)      out_data_q <= `PILOT_P13_Q;
                else if(counter_data < 38)      out_data_q <= symbol_q[counter_data - 2];
                else if(counter_data < 39)      out_data_q <= `PILOT_P38_Q;
                else if(counter_data < 63)      out_data_q <= symbol_q[counter_data - 3];
                else if(counter_data < 64)      out_data_q <= `PILOT_P63_Q;
                else if(counter_data < 88)      out_data_q <= symbol_q[counter_data - 4];
                else if(counter_data < 89)      out_data_q <= `PILOT_P88_Q;
                else if(counter_data < 101)     out_data_q <= symbol_q[counter_data - 5];
                else if(counter_data < 156)     out_data_q <= 0;
                else if(counter_data < 168)     out_data_q <= symbol_q[counter_data - 60];
                else if(counter_data < 169)     out_data_q <= `PILOT_P_88_Q;
                else if(counter_data < 193)     out_data_q <= symbol_q[counter_data - 61];
                else if(counter_data < 194)     out_data_q <= `PILOT_P_63_Q;
                else if(counter_data < 218)     out_data_q <= symbol_q[counter_data - 62];
                else if(counter_data < 219)     out_data_q <= `PILOT_P_38_Q;
                else if(counter_data < 243)     out_data_q <= symbol_q[counter_data - 63];
                else if(counter_data < 244)     out_data_q <= `PILOT_P_13_Q;
                else if(counter_data < 256)     out_data_q <= symbol_q[counter_data - 64];
            end
            else
            begin
//                out_done <= 1'b0; 
            end
        end
        else  if(out_done == 1'b0)  begin  counter_data <= 1'b0; /*out_done <= 1'b0; */end
    end
        
        
    //********************modulations********************
    mapModulations #(.DATA_SIZE(DATA_SIZE),.MODULATION("BPSK") /*BPSK QPSK QAM16 QAM64 QAM256*/)
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
        
    mapModulations #(.DATA_SIZE(DATA_SIZE),.MODULATION("QPSK") /*BPSK QPSK QAM16 QAM64 QAM256*/)
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
        
    mapModulations #(.DATA_SIZE(DATA_SIZE),.MODULATION("QAM16") /*BPSK QPSK QAM16 QAM64 QAM256*/)
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
        
    mapModulations #(.DATA_SIZE(DATA_SIZE),.MODULATION("QAM64") /*BPSK QPSK QAM16 QAM64 QAM256*/)
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
        
    mapModulations #(.DATA_SIZE(DATA_SIZE),.MODULATION("QAM256") /*BPSK QPSK QAM16 QAM64 QAM256*/)
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
