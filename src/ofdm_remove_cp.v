`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.03.2021 14:38:12
// Design Name: 
// Module Name: remove_cp
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


module ofdm_remove_cp #(  parameter DATA_SIZE = 16,
                        parameter SYMBOLS_SIZE = 256,
                        parameter CP_LENGHT = 8)
(
    i_clk,
    i_reset,
    i_valid,
    in_data_i,
    in_data_q,
    i_frame_sync,
    out_valid,
    out_data_i,
    out_data_q,
    o_cp_removed
);

input i_clk;
input i_reset;
input i_valid;
input [DATA_SIZE-1:0] in_data_i;
input [DATA_SIZE-1:0] in_data_q;
input i_frame_sync;

output out_valid;
output [DATA_SIZE-1:0] out_data_i;
output [DATA_SIZE-1:0] out_data_q;
output o_cp_removed;

reg [15:0] counter = 0;

assign out_valid = counter >= CP_LENGHT ? i_valid : 0;
assign out_data_i = out_valid ? in_data_i : 0;
assign out_data_q = out_valid ? in_data_q : 0;
assign o_cp_removed = counter >= CP_LENGHT;

always @(posedge i_clk)
begin
    if(i_reset)
    begin
        counter <= 0;
    end
    else
    begin
        if(i_frame_sync)  counter <= 0;
        else if(i_valid)
        begin  
            if(counter == (SYMBOLS_SIZE + CP_LENGHT - 1))   counter <= 0;
            else                                            counter <= counter + 1;
        end
    end
end

endmodule
