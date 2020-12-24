`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.12.2020 17:19:40
// Design Name: 
// Module Name: ofdm_add_cp
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


module ofdm_add_cp #(parameter DATA_SIZE = 16,
                     parameter SYMBOLS_SIZE = 256,
                     parameter CP_LENGHT = 8)(
        clk,
        reset,
        in_data_en,
        in_data_i,
        in_data_q,
        output_en,
        out_data_i,
        out_data_q
    );
    
    input clk;
    input reset;
    input in_data_en;
    input [DATA_SIZE-1:0] in_data_i;
    input [DATA_SIZE-1:0] in_data_q;
    output reg output_en = 0;
    output reg [DATA_SIZE-1:0] out_data_i;
    output reg [DATA_SIZE-1:0] out_data_q;
    
    
    reg [15:0] counterData_in = 0;
    reg [15:0] counterData_out = 0;
    
    reg [DATA_SIZE-1:0] reg_data_i [SYMBOLS_SIZE-1:0];
    reg [DATA_SIZE-1:0] reg_data_q [SYMBOLS_SIZE-1:0];
    
    always @(posedge clk)
    begin : recive_data
        if(reset)
        begin
            counterData_in <= 0;
        end
        else
        begin
            if(in_data_en & (counterData_in < SYMBOLS_SIZE))//
            begin
                counterData_in <= counterData_in + 1;
                reg_data_i[counterData_in] <= in_data_i;
                reg_data_q[counterData_in] <= in_data_q;
            end
            else if(counterData_out > CP_LENGHT)//если преабулу уже отправил и начал отправлять основные данные значить можно принимать данные
            begin
                counterData_in <= 0;
            end
        end
    end
    
    reg flag_all_data_recive = 0;
    
    always @(posedge clk)
    begin : send_data
    
        if(reset)
        begin
            counterData_out <= 0;
            output_en <= 0;
            flag_all_data_recive <= 0;
        end
        else
        begin
            if(counterData_in == SYMBOLS_SIZE)                          flag_all_data_recive <= 1;
            else if(counterData_out == (SYMBOLS_SIZE + CP_LENGHT-1))    flag_all_data_recive <= 0;
            
            if(flag_all_data_recive)
            begin
                counterData_out <= counterData_out + 1;

                if(counterData_out < CP_LENGHT) out_data_i <= reg_data_i[SYMBOLS_SIZE - CP_LENGHT + counterData_out];
                else                            out_data_i <= reg_data_i[counterData_out - CP_LENGHT];
                
                if(counterData_out < CP_LENGHT) out_data_q <= reg_data_q[SYMBOLS_SIZE - CP_LENGHT + counterData_out];
                else                            out_data_q <= reg_data_q[counterData_out - CP_LENGHT];
                
            end
            else    counterData_out <= 0;
            
            output_en <= flag_all_data_recive;
        end
    end
    
endmodule
