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
wire [7:0] counter_data;

reg [7:0] in_data;
reg [7:0] in_data_mas [48:0];

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
        for(i = 0; i < 48; i = i + 1)
        begin
            in_data = in_data_mas[i];
            #10;
        end
    end
        
    ofdm_payload_gen #(.DATA_SIZE(16)/*, parameter NFFT = 64 TODO*/)
    _ofdm_payload_gen(
    .clk(clk),
    .reset(1'b0),
    .in_data_en(in_data_en),
    .in_data(in_data),
    .modulation(3'd4),
    .out_done(out_done),
    .out_data_i(out_data_i),
    .out_data_q(out_data_q),
    .counter_data(counter_data)
    );

endmodule
