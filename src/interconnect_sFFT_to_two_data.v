`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.12.2020 15:03:40
// Design Name: 
// Module Name: interconnect_sFFT_to_two_data
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


module interconnect_sFFT_to_two_data #( parameter SIZE_BUFFER = 1,/*log2(NFFT)*/
                                        parameter DATA_FFT_SIZE = 16
                                    )
    (
        clk,
        reset,
        fft_valid,
        data_from_fft_i,
        data_from_fft_q,
        
        flag_ready_recive_chet,
        flag_ready_recive_Nchet,
        data_fft_chet_i,
        data_fft_chet_q,
        data_fft_Nchet_i,
        data_fft_Nchet_q,
        complete_chet,
        complete_Nchet,
        resiveFromSecond
    );
    
    input clk;
    input reset;
    input fft_valid;
    input [DATA_FFT_SIZE-1:0]data_from_fft_i;
    input [DATA_FFT_SIZE-1:0]data_from_fft_q;
    
    input flag_ready_recive_chet;
    input flag_ready_recive_Nchet;
    output reg [DATA_FFT_SIZE-1:0] data_fft_chet_i;
    output reg [DATA_FFT_SIZE-1:0] data_fft_chet_q;
    output [DATA_FFT_SIZE-1:0] data_fft_Nchet_i;
    output [DATA_FFT_SIZE-1:0] data_fft_Nchet_q;
    output reg complete_chet = 0;
    output complete_Nchet;
    output resiveFromSecond;
    
    
    localparam NFFT = 1 << SIZE_BUFFER;
    
    reg [DATA_FFT_SIZE-1:0] data_from_chet_i[NFFT/2-1:0];
    reg [DATA_FFT_SIZE-1:0] data_from_chet_q[NFFT/2-1:0];
    
    reg left_data = 1'b1;
    reg [SIZE_BUFFER:0] counter_send = 0;
    reg [SIZE_BUFFER-1:0] counter_resive_l = 0;
    
    assign complete_Nchet = left_data ? 0 : fft_valid;
    assign data_fft_Nchet_i = left_data ? 0 : data_from_fft_i;
    assign data_fft_Nchet_q = left_data ? 0 : data_from_fft_q;
    
    assign resiveFromSecond = left_data ? 1 : flag_ready_recive_Nchet;
    
    always @(posedge clk)
    begin : sendDataFFT_Chet
        if(reset)
        begin
            complete_chet <= 0;
            counter_send <= 0;
        end
        else
        begin
            if(((counter_resive_l == 1) | complete_chet) & flag_ready_recive_chet)
            begin
                if(counter_send < (NFFT/2))     counter_send <= counter_send + 1;
                else                            counter_send <= 0;
                if(counter_send < (NFFT/2))     data_fft_chet_i <= data_from_chet_i[counter_send];
                if(counter_send < (NFFT/2))     data_fft_chet_q <= data_from_chet_q[counter_send];
                
            end
            else
            begin
                //делаю так же  как и в FFT чтобы сразу когда был выставлен флаг были  выданны данные
                counter_send <= 1;
                data_fft_chet_i <= data_from_chet_i[0];
                data_fft_chet_q <= data_from_chet_q[0];
            end
            
            if(complete_chet == 1'b0)
            begin
                if(counter_resive_l == 1)    complete_chet <= 1;
            end
            else if((counter_send == (NFFT/2-1)) & flag_ready_recive_chet)  complete_chet <= 0;
            
        end
    end
    
    always @(posedge clk)
    begin
        if(reset)
        begin
            left_data <= 1'b1;
            counter_resive_l <= 0;
        end
        else if(fft_valid)
        begin
            if(left_data)
            begin
                data_from_chet_i[counter_resive_l] <= data_from_fft_i;
                data_from_chet_q[counter_resive_l] <= data_from_fft_q;
                counter_resive_l <= counter_resive_l + 1;
                if(counter_resive_l == (NFFT/2-1))
                begin
                    left_data <= 1'b0;
                    counter_resive_l <= 0;
                end
            end
            else
            begin
                if((counter_send == (NFFT/2)))   left_data <= 1'b1;
                counter_resive_l <= 0;
            end
        end
        else
        begin
            if((counter_send == (NFFT/2)))   left_data <= 1'b1;
            counter_resive_l <= 0;
        end
    end
    
    
endmodule
