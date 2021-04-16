`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.11.2020 18:00:17
// Design Name: 
// Module Name: ofdm_payload_gen_tb
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


module ofdm_payload_gen_tb();

reg clk = 1'b0;
reg in_data_en = 0;
wire out_done;
wire [15:0] out_data_i;
wire [15:0] out_data_q;
wire [15:0] counter_data;

reg [7:0] in_data;
reg [7:0] in_data_mas [199:0];
reg wayt_recive = 1'b1;

wire walid_data_mod;
wire wayt_res_data;

initial
    $readmemh("test_ofdm_payload_gen.mem",in_data_mas);

    always
        #5 clk = !clk;
        
//    integer counterData = 0;
    
    integer i = 0;
        
    initial
    begin
        #40
        in_data_en = 1'b1;
        for(i = 0; i < 200; )
        begin
            if(wayt_res_data)   in_data = in_data_mas[i];
            if(wayt_res_data)   i = i + 1;   
            #10;
        end
        #40
        in_data_en = 1'b0;
    end
    
//    initial
//    begin
//        #6000;
//        wayt_recive = 1'b1;
//        #1000;
//        wayt_recive = 1'b0;
//        #1000;
//        wayt_recive = 1'b1;
//    end
    
localparam SUBCARRIER_MASK_R =                                                                               
    128'b11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110000000000000000000000000000;
//-1:-100         |10       |20       |30       |40       |50       |60       |70       |80       |90       |100                                                    
//N right                                                                                                    |1                         |28                         
//**     |-1                                              |-50                                              |-100                       |-128

localparam SUBCARRIER_MASK_L =
    128'b00000000000000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110;    
//N left |27                       |1 
//100:1                             |100     |90       |80       |70       |60       |50       |40       |30       |20       |10       |1
//DC                                                                                                                                    |0 
//*      |127                      |101      |90                                     |50                                     |10        |0 

localparam SUBCARRIER_MASK = {SUBCARRIER_MASK_R, SUBCARRIER_MASK_L};

    wire [15:0] mod_data_i;
    wire [15:0] mod_data_q;
    wire o_flag_ready_recive;
    
    ofdm_modulation #(.DATA_SIZE(16))
    _ofdm_modulation(
        .i_clk(clk),
        .i_reset(1'b0),
        .i_valid(in_data_en),
        .i_modulation(3'b100),
        .i_data(in_data),
        .o_wayt_res_data(wayt_res_data),
        .o_valid_data(walid_data_mod),
        .i_wayt_data(o_flag_ready_recive),
        .o_data_i(mod_data_i),
        .o_data_q(mod_data_q)
    );

        
    ofdm_payload_gen #(.DATA_SIZE(16))
    _ofdm_payload_gen(
        .i_clk(clk),
        .i_reset(1'b0),
        .in_data_en(walid_data_mod),
        .in_data_i(mod_data_i),
        .in_data_q(mod_data_q),
        .o_flag_ready_recive(o_flag_ready_recive),
        .out_done(out_done),
        .out_data_i(out_data_i),
        .out_data_q(out_data_q),
        .o_counter_data(counter_data),
        .i_wayt_recive_data(wayt_recive)
    );

endmodule
