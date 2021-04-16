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
    i_clk,
    i_reset,
    in_data_en,
    in_data_i,
    in_data_q,
//    modulation,
    o_flag_ready_recive,
    out_done,
    out_data_i,
    out_data_q,
    o_counter_data,
    i_wayt_recive_data
    );
    
    /* modulation   | byts input
     * BPSK         |   24
     * QPSK         |   48
     * QAM16        |   96
     * QAM64        |   144
     * QAM256       |   192
    */
    
    input i_clk;
    input i_reset;
    input in_data_en;
    input [DATA_SIZE-1:0] in_data_i;
    input [DATA_SIZE-1:0] in_data_q;
//    input [2:0] modulation;
    output o_flag_ready_recive;
    output reg out_done = 1'b0;
    output reg [DATA_SIZE-1:0] out_data_i;
    output reg [DATA_SIZE-1:0] out_data_q;
    
    output [15:0] o_counter_data;
    input i_wayt_recive_data;//flag от том что можно отправлять
    
    localparam N_DATA = 192;//количество гармоник с информццией
    localparam N_DATA_BYTS_MAX = 192;//максимальное число информации на 1 символ при максимаольной модуляции
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
   
    
    reg [3:0] counter_pilot = 0;
    
    reg [DATA_SIZE-1:0] pilot_i;
    reg [DATA_SIZE-1:0] pilot_q;
    
    reg [15:0] counter_data = 0;
    
    assign o_flag_ready_recive = DATA_SUBCARRIER_MASK[counter_data] & i_wayt_recive_data;
    assign o_counter_data = counter_data;
    
    always @(posedge i_clk)
    begin
        case(counter_pilot)
            0:pilot_i <= `PILOT_P13_I;
            1:pilot_i <= `PILOT_P38_I;
            2:pilot_i <= `PILOT_P63_I;
            3:pilot_i <= `PILOT_P88_I;
            4:pilot_i <= `PILOT_P_88_I;
            5:pilot_i <= `PILOT_P_63_I;
            6:pilot_i <= `PILOT_P_38_I;
            7:pilot_i <= `PILOT_P_13_I;
        endcase
        
        case(counter_pilot)
            0:pilot_q <= `PILOT_P13_Q;
            1:pilot_q <= `PILOT_P38_Q;
            2:pilot_q <= `PILOT_P63_Q;
            3:pilot_q <= `PILOT_P88_Q;
            4:pilot_q <= `PILOT_P_88_Q;
            5:pilot_q <= `PILOT_P_63_Q;
            6:pilot_q <= `PILOT_P_38_Q;
            7:pilot_q <= `PILOT_P_13_Q;
        endcase
    end
    
    always @(posedge i_clk)
    begin : SEND_DATA
        if(i_reset)   counter_data <= 0;
        if(i_reset)   counter_pilot <= 0;
        if(i_reset)   out_done <= 0;
//        if(i_reset)   wayr_res <= 0;
        else
        begin
            if((counter_data < 256) & i_wayt_recive_data)
            begin
                if(PILOT_MASK[counter_data])                                counter_pilot <= counter_pilot + 1;
                
                
                if(PILOT_MASK[counter_data])                                counter_data <= counter_data + 1;
                else if(DATA_SUBCARRIER_MASK[counter_data] & in_data_en)    counter_data <= counter_data + 1;
                else if(DATA_SUBCARRIER_MASK[counter_data] == 1'b0)         counter_data <= counter_data + 1;
                
                if(PILOT_MASK[counter_data])                                out_data_i <= pilot_i;
                else if(DATA_SUBCARRIER_MASK[counter_data] & in_data_en)    out_data_i <= in_data_i;
                else if(DATA_SUBCARRIER_MASK[counter_data] == 1'b0)         out_data_i <= 0;
                
                if(PILOT_MASK[counter_data])                                out_data_q <= pilot_q;
                else if(DATA_SUBCARRIER_MASK[counter_data] & in_data_en)    out_data_q <= in_data_q;
                else if(DATA_SUBCARRIER_MASK[counter_data] == 1'b0)         out_data_q <= 0;
                
                if(PILOT_MASK[counter_data])                                out_done <= 1;
                else if(DATA_SUBCARRIER_MASK[counter_data] & in_data_en)    out_done <= 1;
                else if(DATA_SUBCARRIER_MASK[counter_data] == 1'b0)         out_done <= 1;
                else                                                        out_done <= 0;
                
            end
            else if(counter_data == 256)
            begin
                counter_data <= 0;
                out_done <= 0;
                counter_pilot <= 0;
            end
        end
    end
        
        

endmodule
