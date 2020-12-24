`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.12.2020 13:47:37
// Design Name: 
// Module Name: ofdm_find_preamble
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


module ofdm_find_preamble #(parameter DATA_SIZE = 16,
        parameter PREAMBLE_MEM_I = 256'b0111011000000011111111100000011111111100000011100100100110011111001101100110010011000000001111110000001100011000111111100001001100000110001100000001100110011001111110111001111001110110001000110010001110011100011001110111100000111001111000000111000000111000,
        parameter PREAMBLE_MEM_Q = 256'b0001110010001111111000101110001110010001100010011110001100100001111111111001111000010000111100110011111011000100110011111110000011111001100110010011000001000111100011111111111000000000110000111000111001110011000111011001110000001000011001001110100011100111
    )(
    clk,
    en,
    in_data_i,
    in_data_q,
    find,
    out_data_i,
    out_data_q,
    outPorog
    );
    
    input clk;
    input en;
    input signed [DATA_SIZE-1:0] in_data_i;
    input signed [DATA_SIZE-1:0] in_data_q;
    output find;
    output signed [DATA_SIZE+7:0] out_data_i;
    output signed [DATA_SIZE+7:0] out_data_q;
    
    
    reg [DATA_SIZE + 7: 0] res_preamble_i = 0;
    reg [DATA_SIZE + 7: 0] res_preamble_q = 0;
    
    reg [DATA_SIZE + 7: 0] shift_reg_i [255:0] ;
    reg [DATA_SIZE + 7: 0] shift_reg_q [255:0] ;
    
    reg [255:0] mem_i = PREAMBLE_MEM_I;
    reg [255:0] mem_q = PREAMBLE_MEM_Q;
    
    always @(posedge clk)
    begin
    
    end
    
    genvar i;
    generate
    
    for(i = 0; i < 255; i = i + 1)
    begin
        always @(posedge clk)
        begin
            if(en)
            begin
                shift_reg_i[i+1] <= $signed(shift_reg_i[i]) + (mem_i[254-i] ? $signed(in_data_i) : -$signed(in_data_i));
                shift_reg_q[i+1] <= $signed(shift_reg_q[i]) + (mem_q[254-i] ? $signed(in_data_q) : -$signed(in_data_q));
            end
        end
    end
    
    always @(posedge clk)
    begin
        if(en)
        begin
            shift_reg_i[0] <= mem_i[255] ? $signed(in_data_i) : -$signed(in_data_i);
            shift_reg_q[0] <= mem_i[255] ? $signed(in_data_i) : -$signed(in_data_i);
        end
    end
    
    endgenerate
    
    //output filter
    assign out_data_i = shift_reg_i[255];
    assign out_data_q = shift_reg_q[255];
    
    wire signed [(DATA_SIZE+DATA_SIZE+8+8-1):0] dataModule;
    output [(DATA_SIZE+DATA_SIZE+8+8-1):0] outPorog;
    
    assign dataModule = out_data_i*out_data_i + out_data_q*out_data_q;
    
    dynamicPreambleFilter #( .DATA_SIZE(DATA_SIZE + DATA_SIZE + 8 + 8),
                             .MIN_POROG(1024),
                             .N_FILTR(5)/*log2(size)*/)
     _filter(
        .clk(clk),
        .en(en),
        .in_data(dataModule),
        .out_porog(outPorog)
    );
    
    assign find = dataModule > outPorog ? 1 : 0;
    
    
endmodule
