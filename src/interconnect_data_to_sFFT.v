`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.12.2020 14:21:00
// Design Name: 
// Module Name: interconnect_data_to_sFFT
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


module interconnect_data_to_sFFT #( parameter SIZE_BUFFER = 1,/*log2(NFFT)*/
                                    parameter DATA_FFT_SIZE = 16
                                    )
                                                                    
    (
        clk,
        reset,
        in_data_i,
        in_data_q,
        valid,
        fft_wayt_data,
        out_data_i,
        out_data_q,
        outvalid,
        counter_data,
        wayt_data_second_NChet
    );
    
    input clk;
    input reset;
    input [DATA_FFT_SIZE-1:0] in_data_i;
    input [DATA_FFT_SIZE-1:0] in_data_q;
    input valid;
    input fft_wayt_data;
    output [DATA_FFT_SIZE-1:0] out_data_i;
    output [DATA_FFT_SIZE-1:0] out_data_q;
    output outvalid;
    input [SIZE_BUFFER:0] counter_data;
    output reg wayt_data_second_NChet = 1;//специальный флаг говоряший что данные были отправленны правая половина or flag_reset_counter
    
    
    localparam NFFT = 1 << SIZE_BUFFER;
    
    reg [DATA_FFT_SIZE-1:0] buff_in_data_i [NFFT/2-1:0];
    reg [DATA_FFT_SIZE-1:0] buff_in_data_q [NFFT/2-1:0];
    
    reg left_path = 1'b1;//FFT левой части
    reg valid_right = 1'b0;
    
    reg [DATA_FFT_SIZE-1:0] data_for_fft_i;
    reg [DATA_FFT_SIZE-1:0] data_for_fft_q;
    
    assign outvalid = left_path ? ((counter_data[0] == 1'b0) & valid) : valid_right;
    assign out_data_i = left_path ? in_data_i : data_for_fft_i;
    assign out_data_q = left_path ? in_data_q : data_for_fft_q;
    
    reg [SIZE_BUFFER:0] counter_resive = 0;
    reg [SIZE_BUFFER:0] counter_send = 0;
    
    always @(posedge clk)
    begin
        if(reset)
        begin
            counter_send <= 0;
            counter_resive <= 0;
            left_path <= 1'b1;
            valid_right <= 1'b0;
            wayt_data_second_NChet <= 1'b1;
        end
        else
        begin
            if(left_path & ((counter_data[0] == 1'b1) & valid))
            begin
                wayt_data_second_NChet <= 1'b1;
                buff_in_data_i[counter_resive] <= in_data_i;
                buff_in_data_q[counter_resive] <= in_data_q;
                counter_resive <= counter_resive + 1;
                if(counter_resive == (NFFT/2-1))
                begin
                    left_path <= 1'b0;
                    counter_send <= 0;
                end
                valid_right <= 1'b0;
            end
            else if((left_path == 1'b0) & (fft_wayt_data))
            begin
                
                data_for_fft_i <= buff_in_data_i[counter_send];
                data_for_fft_q <= buff_in_data_q[counter_send];
                if(counter_send < (NFFT/2)) counter_send <= counter_send + 1;
                
                if(counter_send == (NFFT/2))
                begin
                    wayt_data_second_NChet <= 1'b0;
                    left_path <= 1'b1;
//                    valid_right <= 1'b0;
                    counter_resive <= 0;
                end
                else
                begin
                    valid_right <= 1'b1;
                    wayt_data_second_NChet <= 1'b1;
                end
            end
            else
            begin
                wayt_data_second_NChet <= 1'b1;
                valid_right <= 1'b0;
            end
        end
    end
    
    
endmodule
