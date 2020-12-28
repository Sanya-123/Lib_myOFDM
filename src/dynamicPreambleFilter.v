`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.12.2020 15:13:09
// Design Name: 
// Module Name: dynamicPreambleFilter
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


module dynamicPreambleFilter #( parameter DATA_SIZE = 16,
                                parameter MIN_POROG = 256,
                                parameter N_FILTR = 5/*log2(size)*/)(
    clk,
    en,
    in_data,
    out_porog
    );
    
    input clk;
    input en;
    input [DATA_SIZE-1:0] in_data;
    output reg [DATA_SIZE-1:0] out_porog;
    
    reg [DATA_SIZE-1:0] porog = MIN_POROG;
    
    always @(posedge clk)
    begin
        if(en)
            out_porog <= (porog << 2) < MIN_POROG ? MIN_POROG : (porog << 2); 
    end
    
//    always @(posedge clk)
//    begin
//        if(en)
//            porog <= ((porog << N_FILTR) - porog + in_data) >> N_FILTR;
//    end
    
    reg [DATA_SIZE-1:0] shift_reg [(1 << N_FILTR)-1:0];
    
    
    always @(posedge clk)
        porog <= shift_reg[(1 << N_FILTR)-1];
    
    genvar i;
    genvar j;
    generate
    
    for(j = 0; j < (1 << N_FILTR); j = j + 1)
    begin
        initial begin
            shift_reg[j] = MIN_POROG;
        end
    end
    
    for(i = 1; i < (1 << N_FILTR); i = i + 1)
    begin
        always @(posedge clk)
        begin
            if(en)  shift_reg[i] <= in_data + shift_reg[i-1];
        end
    end
    
    always @(posedge clk)
    begin
        if(en)  shift_reg[0] <= in_data;
    end

    endgenerate

    
endmodule
