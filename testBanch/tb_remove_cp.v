`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.03.2021 14:50:31
// Design Name: 
// Module Name: tb_remove_cp
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


module tb_remove_cp();

reg clk = 1'b0;
always #5 clk = !clk;

reg [15:0] data_i = 0;
reg [15:0] data_q = 0;

always
begin
    data_i = $random();
    data_q = $random();
    #10;
end

    wire add_cp_output_en;
    wire [15:0] add_cp_out_data_i;
    wire [15:0] add_cp_out_data_q;
    
    ofdm_add_cp #(.DATA_SIZE(16),
                  .SYMBOLS_SIZE(256),
                  .CP_LENGHT(8))
    _ofdm_add_cp(
        .clk(clk),
        .reset(1'b0),
        .in_data_en(1'b1),
        .i_wayt_read_data(1'b1),
        .in_data_i(data_i),
        .in_data_q(data_q),
        .output_en(add_cp_output_en),
        .out_data_i(add_cp_out_data_i),
        .out_data_q(add_cp_out_data_q),
        .o_wayt_recive_data()
    );
    
    wire walid_output_remove_cp;
    wire [16-1:0 ] data_remove_cp_i;
    wire [16-1:0 ] data_remove_cp_q;
    reg frame_sync = 0;
    
    ofdm_remove_cp #(  .DATA_SIZE(16),
                       .SYMBOLS_SIZE(256),
                       .CP_LENGHT(8))
    _ofdm_remove_cp(
        .i_clk(clk),
        .i_reset(1'b0),
        .i_valid(add_cp_output_en),
        .in_data_i(add_cp_out_data_i),
        .in_data_q(add_cp_out_data_q),
        .i_frame_sync(frame_sync),
        .out_valid(walid_output_remove_cp),
        .out_data_i(data_remove_cp_i),
        .out_data_q(data_remove_cp_q)
    );


endmodule
