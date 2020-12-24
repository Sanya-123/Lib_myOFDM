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
        for(i = 0; i < 200; i = i + 1)
        begin
            in_data = in_data_mas[i];
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



        
    ofdm_payload_gen #(.DATA_SIZE(16))
    _ofdm_payload_gen(
    .clk(clk),
    .reset(1'b0),
    .in_data_en(in_data_en),
    .in_data(in_data),
    .modulation(3'd0),
    .out_done(out_done),
    .out_data_i(out_data_i),
    .out_data_q(out_data_q),
    .counter_data(counter_data),
    .wayt_recive_data(wayt_recive)
    );

endmodule
