`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2021 15:08:15
// Design Name: 
// Module Name: ofdm_modulation
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

`include "commonOFDM.vh"

module ofdm_modulation #(parameter DATA_SIZE = 16)(
    i_clk,
    i_reset,
    i_valid,
    i_modulation,
    i_data,
    o_wayt_res_data,
    o_valid_data,
    i_wayt_data,
    o_data_i,
    o_data_q
    );
    
    input i_clk;
    input i_reset;
    input i_valid;
    input [2:0] i_modulation;
    input [7:0] i_data;
    output /*reg*/ o_wayt_res_data/* = 1'b1*/;
    output reg o_valid_data = 1'b0;
    input i_wayt_data;
    output reg [DATA_SIZE-1:0] o_data_i;
    output reg [DATA_SIZE-1:0] o_data_q;
    
    //fast
    function [DATA_SIZE-1:0] f_mapQAM256;
        input [3:0] data;
        
//        f_mapQAM256 =   0;
        f_mapQAM256 =   data[3:0] == 4'b0001 ? `QAM256__15 : 
                        data[3:0] == 4'b0101 ? `QAM256__13 : 
                        data[3:0] == 4'b0111 ? `QAM256__11 : 
                        data[3:0] == 4'b0011 ? `QAM256__9  : 
                        data[3:0] == 4'b0010 ? `QAM256__7  : 
                        data[3:0] == 4'b0110 ? `QAM256__5  : 
                        data[3:0] == 4'b0100 ? `QAM256__3  : 
                        data[3:0] == 4'b0000 ? `QAM256__1  : 
                        data[3:0] == 4'b1000 ? `QAM256_1   : 
                        data[3:0] == 4'b1100 ? `QAM256_3   :  
                        data[3:0] == 4'b1110 ? `QAM256_5   : 
                        data[3:0] == 4'b1010 ? `QAM256_7   : 
                        data[3:0] == 4'b1011 ? `QAM256_9   : 
                        data[3:0] == 4'b1111 ? `QAM256_11  : 
                        data[3:0] == 4'b1101 ? `QAM256_13  : 
                        data[3:0] == 4'b1001 ? `QAM256_15  : 0;
    endfunction
    
//    localparam state_resive_data = 0;
    
    reg [3:0] counter_output_data = 0;
    reg [23:0] r_in_data = 0;
    
//    reg [2:0] state_modulation = state_resive_data;
    reg recive_data = 1'b1;
    reg [2:0] in_data_qam64_counter = 0;
    
    assign o_wayt_res_data = recive_data;
    
    always @(posedge i_clk)
    begin
        if(i_reset)
        begin   
            recive_data <= 1'b0;
        end
        else
        begin
            if(recive_data)
            begin
                if(i_modulation != `QAM64_MOD)
                begin
                   if(i_valid)  r_in_data[7:0] <= i_data;
                   if(i_valid)  recive_data <= 1'b0;
                end
            end
            else
            begin
                case(i_modulation)
                `BPSK_MOD:      begin if(i_wayt_data & (counter_output_data == 7)) recive_data <= 1'b1; end
                `QPSK_MOD:      begin end
                `QAM16_MOD:     begin end
                `QAM64_MOD:     begin end
                `QAM256_MOD:    begin if(i_wayt_data) recive_data <= 1'b1;   end
                endcase
            end
        end
    end
    
    always @(posedge i_clk)
    begin : a_send_data
        if(i_reset)
        begin
            counter_output_data <= 0;
        end
        else
        begin
            if(recive_data)     counter_output_data <= 0;
            if(recive_data)     o_valid_data <= 1'b0;
            else if(i_wayt_data)
            begin
                counter_output_data <= counter_output_data + 1;
//                if(i_wayt_data)

                case(i_modulation)
                `BPSK_MOD: begin o_data_i <= 0; o_data_q <= 0; end
                `QPSK_MOD: begin o_data_i <= 0; o_data_q <= 0; end
                `QAM16_MOD: begin o_data_i <= 0; o_data_q <= 0; end
                `QAM64_MOD: begin o_data_i <= 0; o_data_q <= 0; end
                `QAM256_MOD: 
                begin
                    o_data_i <= f_mapQAM256(r_in_data[3:0]);
                    o_data_q <= f_mapQAM256(r_in_data[7:4]);
                end
                default: 
                begin
                    o_data_i <= 0;
                    o_data_q <= 0; 
                end
                endcase
                o_valid_data <= 1'b1;
            end  
            else    o_valid_data <= 1'b0;
        end
    end
    
    //old
    
//    reg [8*8-1:0] data_for_mod = 0;
    
//    wire [DATA_SIZE-1:0] mod_data_i [7:0];
//    wire [DATA_SIZE-1:0] mod_data_q [7:0];
    
//    reg [3:0] counter_data_res = 0;
    
//    reg [3:0] counter_output_data = 0;
    
//    reg modulate_done = 0;
    
//    always @(posedge i_clk)
//    begin : a_counter_resive_data
//        if(i_reset)
//        begin
//            counter_data_res <= 0;
//        end
//        else
//        begin
//            if(o_valid_data)
//            begin
//                counter_data_res <= 0;
//            end
//            else if(o_wayt_res_data & i_valid)
//            begin
//                case(i_modulation)
//                    0: begin      if(counter_data_res < 1)  counter_data_res <= counter_data_res + 1;       end
//                    1: begin      if(counter_data_res < 2)  counter_data_res <= counter_data_res + 1;       end
//                    2: begin      if(counter_data_res < 4)  counter_data_res <= counter_data_res + 1;       end
//                    3: begin      if(counter_data_res < 6)  counter_data_res <= counter_data_res + 1;       end
//                    4: begin      if(counter_data_res < 8)  counter_data_res <= counter_data_res + 1;       end
//                default:                                    counter_data_res <= 0;
//                endcase
//            end
////            else    counter_data_res <= 0;
//        end
//    end
    
//    always @(posedge i_clk)
//    begin : a_resive_data
//        if(i_reset)
//        begin
//            data_for_mod <= 0;
//        end
//        else
//        begin
//            if(o_wayt_res_data & i_valid) 
//            begin
//                 case(counter_data_res)
//                 0: data_for_mod[ 7: 0] <= i_data;
//                 1: data_for_mod[15: 8] <= i_data;
//                 2: data_for_mod[23:16] <= i_data;
//                 3: data_for_mod[31:24] <= i_data;
//                 4: data_for_mod[39:32] <= i_data;
//                 5: data_for_mod[47:40] <= i_data;
//                 6: data_for_mod[55:48] <= i_data;
//                 7: data_for_mod[63:56] <= i_data;
//                 endcase
//            end
//        end
//    end
    
//    always @(posedge i_clk)
//    begin : a_output_wayt_res_data
//        if(i_reset)
//        begin
//            o_wayt_res_data <= 1'b1;
//        end
//        else if(o_valid_data)   o_wayt_res_data <= 1'b0;
//        else
//        begin
//            case(i_modulation)
//                0: begin      o_wayt_res_data <= counter_data_res < 1;          end
//                1: begin      o_wayt_res_data <= counter_data_res < 2;          end
//                2: begin      o_wayt_res_data <= counter_data_res < 4;          end
//                3: begin      o_wayt_res_data <= counter_data_res < 6;          end
//                4: begin      o_wayt_res_data <= counter_data_res < 8;          end
//            default:          o_wayt_res_data <= 1'b1;
//            endcase
//        end
//    end
    
//    always @(posedge i_clk)
//    begin : a_modulate_done
//        if(i_reset)
//        begin
//            modulate_done <= 1'b0;
//        end
//        else
//        begin
//            if(o_wayt_res_data == 1'b0)     modulate_done <= 1'b1;
//            else                            modulate_done <= 1'b0;
//        end
//    end
    
//    always @(posedge i_clk)
//    begin : a_output_data
//        if(i_reset)
//        begin
//            counter_output_data <= 0;
//            o_valid_data <= 0;
//        end
//        if(i_modulation > 4)
//        begin
//            o_valid_data <= 1;
//            o_data_i <= 0;
//            o_data_q <= 0;
//        end
//        else
//        begin
//            if(modulate_done | o_valid_data)
//            begin
//                o_valid_data <= counter_output_data < 8;
//                if(i_wayt_data)     counter_output_data <= counter_output_data + 1;
//                if(i_wayt_data)     o_data_i <= mod_data_i[counter_output_data[2:0]];
//                if(i_wayt_data)     o_data_q <= mod_data_q[counter_output_data[2:0]];
//            end
//            else
//            begin
//                o_valid_data <= 0;
//                counter_output_data <= 0;
//            end
//        end
//    end
    
//    modulation_array#(.DATA_SIZE(DATA_SIZE))
//    _modulation_array(
//        .i_clk(i_clk),
//        .i_en(1'b1),
//        .i_dataForModulations(data_for_mod),
//        .i_modulation(i_modulation),
//        .o_data_i(mod_data_i),
//        .o_data_q(mod_data_q)
//    );
    
    
endmodule
