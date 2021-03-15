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


module interconnect_data_to_sFFT_R4 #( parameter SIZE_BUFFER = 1,/*log2(NFFT)*/
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
        wayt_data_fft3
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
    output reg wayt_data_fft3 = 1;//специальный флаг говоряший что данные были отправленны правая половина or flag_reset_counter
    
    
    localparam NFFT = 1 << SIZE_BUFFER;
    
    reg [DATA_FFT_SIZE-1:0] buff1_in_data_i [NFFT/4-1:0];
    reg [DATA_FFT_SIZE-1:0] buff1_in_data_q [NFFT/4-1:0];
    
    reg [DATA_FFT_SIZE-1:0] buff2_in_data_i [NFFT/4-1:0];
    reg [DATA_FFT_SIZE-1:0] buff2_in_data_q [NFFT/4-1:0];
    
    reg [DATA_FFT_SIZE-1:0] buff3_in_data_i [NFFT/4-1:0];
    reg [DATA_FFT_SIZE-1:0] buff3_in_data_q [NFFT/4-1:0];
    
//    reg left_path = 1'b1;//FFT левой части
//    reg valid_right = 1'b0;
    
    reg [1:0] path = 2'b00;
    reg valid_outher_path = 1'b0;
    
    reg [DATA_FFT_SIZE-1:0] data_for_fft_i;
    reg [DATA_FFT_SIZE-1:0] data_for_fft_q;
    
    assign outvalid = path == 2'b00 ? ((counter_data[1:0] == 2'b00) & valid) : valid_outher_path;
    assign out_data_i = path == 2'b00 ? in_data_i : data_for_fft_i;
    assign out_data_q = path == 2'b00 ? in_data_q : data_for_fft_q;
    
    reg [SIZE_BUFFER:0] counter_resive1 = 0;
    reg [SIZE_BUFFER:0] counter_resive2 = 0;
    reg [SIZE_BUFFER:0] counter_resive3 = 0;
    reg [SIZE_BUFFER:0] counter_send1 = 0;
    reg [SIZE_BUFFER:0] counter_send2 = 0;
    reg [SIZE_BUFFER:0] counter_send3 = 0;
    
    always @(posedge clk)
    begin
        if(reset)
        begin
            counter_send1 <= 0;
            counter_send2 <= 0;
            counter_send3 <= 0;
            counter_resive1 <= 0;
            counter_resive2 <= 0;
            counter_resive3 <= 0;
            path <= 2'b00;
            valid_outher_path <= 1'b0;
            wayt_data_fft3 <= 1'b1;
        end
        else
        begin
            if((path == 2'b00) & valid)
            begin
                wayt_data_fft3 <= 1'b1;
                case(counter_data[1:0])
                    2'b01 : begin
                        buff1_in_data_i[counter_resive1] <= in_data_i;
                        buff1_in_data_q[counter_resive1] <= in_data_q;
                        counter_resive1 <= counter_resive1 + 1;
                    end
                    2'b10 : begin
                        buff2_in_data_i[counter_resive2] <= in_data_i;
                        buff2_in_data_q[counter_resive2] <= in_data_q;
                        counter_resive2 <= counter_resive2 + 1;
                    end
                    2'b11 : begin
                        buff3_in_data_i[counter_resive3] <= in_data_i;
                        buff3_in_data_q[counter_resive3] <= in_data_q;
                        counter_resive3 <= counter_resive3 + 1;
                    end
                
                endcase
                
                if((counter_resive3 == (NFFT/4-1)) && (counter_data[1:0] == 2'b11))
                begin
                    path <= 2'b01;
                    counter_send1 <= 0;
                    counter_send2 <= 0;
                    counter_send3 <= 0;
                end
                
                valid_outher_path <= 1'b0;
                
            end
            else if((path == 2'b01) & (fft_wayt_data))
            begin
                
                data_for_fft_i <= buff1_in_data_i[counter_send1];
                data_for_fft_q <= buff1_in_data_q[counter_send1];
                if(counter_send1 < (NFFT/4)) counter_send1 <= counter_send1 + 1;
                
                if(counter_send1 == (NFFT/4))
                begin
//                    wayt_data_second_NChet <= 1'b0;
                    path <= 2'b10;
//                    valid_outher_path <= 1'b0;
                    counter_resive1 <= 0;
                end
                else
                begin
                    valid_outher_path <= 1'b1;
                    wayt_data_fft3 <= 1'b1;
                end
            end
            else if((path == 2'b10) & (fft_wayt_data))
            begin
                
                data_for_fft_i <= buff2_in_data_i[counter_send2];
                data_for_fft_q <= buff2_in_data_q[counter_send2];
                if(counter_send2 < (NFFT/4)) counter_send2 <= counter_send2 + 1;
                
                if(counter_send2 == (NFFT/4))
                begin
//                    wayt_data_second_NChet <= 1'b0;
                    path <= 2'b11;
//                    valid_outher_path <= 1'b0;
                    counter_resive2 <= 0;
                end
                else
                begin
                    valid_outher_path <= 1'b1;
                    wayt_data_fft3 <= 1'b1;
                end
            end
            else if((path == 2'b11) & (fft_wayt_data))
            begin
                
                data_for_fft_i <= buff3_in_data_i[counter_send3];
                data_for_fft_q <= buff3_in_data_q[counter_send3];
                if(counter_send3 < (NFFT/4)) counter_send3 <= counter_send3 + 1;
                
                if(counter_send3 == (NFFT/4))
                begin
                    wayt_data_fft3 <= 1'b0;
                    path <= 2'b00;
//                    valid_outher_path <= 1'b0;
                    counter_resive3 <= 0;
                end
                else
                begin
                    valid_outher_path <= 1'b1;
                    wayt_data_fft3 <= 1'b1;
                end
            end
            
            else
            begin
                wayt_data_fft3 <= 1'b1;
                valid_outher_path <= 1'b0;
            end
        end
    end
    
    
endmodule
