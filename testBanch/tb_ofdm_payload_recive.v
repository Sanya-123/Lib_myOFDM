`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.11.2020 19:51:58
// Design Name: 
// Module Name: tb_ofdm_payload_recive
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


module tb_ofdm_payload_recive();

reg clk = 1'b0;
reg in_data_en = 0;
wire out_done;
wire [15:0] out_data_i;
wire [15:0] out_data_q;
wire [15:0] counter_data;

reg [7:0] in_data;
reg [7:0] in_data_mas [199:0];
reg wayt_recive = 1'b1;
wire [15:0] counterReciveData;
wire recive_out_done;
wire [7:0] recive_data;
wire [7:0] test_sunbols;

reg [15:0] counter_test_data = 0;
assign test_sunbols = in_data_mas[counter_test_data];


initial
    $readmemh("test_ofdm_payload_gen.mem",in_data_mas);

    always
        #5 clk = !clk;
        
    always @(posedge clk)
        counter_test_data <= counterReciveData;
        
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


    localparam modulation = 3;
        
    ofdm_payload_gen #(.DATA_SIZE(16))
    _ofdm_payload_gen(
        .clk(clk),
        .reset(1'b0),
        .in_data_en(in_data_en),
        .in_data(in_data),
        .modulation(modulation),
        .out_done(out_done),
        .out_data_i(out_data_i),
        .out_data_q(out_data_q),
        .counter_data(counter_data),
        .wayt_recive_data(wayt_recive)
    );
    
    ofdm_payload_recive #(.DATA_SIZE(16))
    _ofdm_payload_recive(
        .clk(clk),
        .reset(1'b0),
        .in_data_en(out_done),
        .in_data_i(out_data_i),
        .in_data_q(out_data_q),
        .modulation(modulation),
        .out_done(recive_out_done),
        .out_data(recive_data),
        .counter_data(counterReciveData),
        .wayt_recive_data(1'b1)
    );
    
    
endmodule
