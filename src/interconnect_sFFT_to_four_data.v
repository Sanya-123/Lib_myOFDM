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


module interconnect_sFFT_to_four_data #( parameter SIZE_BUFFER = 1,/*log2(NFFT)*/
                                        parameter DATA_FFT_SIZE = 16
                                    )
    (
        clk,
        reset,
        fft_valid,
        data_from_fft_i,
        data_from_fft_q,
        
        flag_ready_recive_fft0,
        flag_ready_recive_fft1,
        flag_ready_recive_fft2,
        flag_ready_recive_fft3,
        
        data_fft0_i,
        data_fft0_q,
        data_fft1_i,
        data_fft1_q,
        data_fft2_i,
        data_fft2_q,
        data_fft3_i,
        data_fft3_q,
        
        complete_fft0,
        complete_fft1,
        complete_fft2,
        complete_fft3,
        resiveFromSecond
    );
    
    input clk;
    input reset;
    input fft_valid;
    input [DATA_FFT_SIZE-1:0]data_from_fft_i;
    input [DATA_FFT_SIZE-1:0]data_from_fft_q;
    
    input flag_ready_recive_fft0;
    input flag_ready_recive_fft1;
    input flag_ready_recive_fft2;
    input flag_ready_recive_fft3;
    
    output reg [DATA_FFT_SIZE-1:0] data_fft0_i;
    output reg [DATA_FFT_SIZE-1:0] data_fft0_q;
    output reg [DATA_FFT_SIZE-1:0] data_fft1_i;
    output reg [DATA_FFT_SIZE-1:0] data_fft1_q;
    output reg [DATA_FFT_SIZE-1:0] data_fft2_i;
    output reg [DATA_FFT_SIZE-1:0] data_fft2_q;
    output [DATA_FFT_SIZE-1:0] data_fft3_i;
    output [DATA_FFT_SIZE-1:0] data_fft3_q;
    
    output reg complete_fft0 = 0;
    output reg complete_fft1 = 0;
    output reg complete_fft2 = 0;
    output complete_fft3;
    output resiveFromSecond;
    
    
    localparam NFFT = 1 << SIZE_BUFFER;
    
    reg [DATA_FFT_SIZE-1:0] data_from_fft0_i[NFFT/4-1:0];
    reg [DATA_FFT_SIZE-1:0] data_from_fft0_q[NFFT/4-1:0];
    reg [DATA_FFT_SIZE-1:0] data_from_fft1_i[NFFT/4-1:0];
    reg [DATA_FFT_SIZE-1:0] data_from_fft1_q[NFFT/4-1:0];
    reg [DATA_FFT_SIZE-1:0] data_from_fft2_i[NFFT/4-1:0];
    reg [DATA_FFT_SIZE-1:0] data_from_fft2_q[NFFT/4-1:0];
    
//    reg left_data = 1'b1;
    reg [SIZE_BUFFER:0] counter_send0 = 0;
    reg [SIZE_BUFFER:0] counter_send1 = 0;
    reg [SIZE_BUFFER:0] counter_send2 = 0;
    reg [SIZE_BUFFER-1:0] counter_resive0 = 0;
    reg [SIZE_BUFFER-1:0] counter_resive1 = 0;
    reg [SIZE_BUFFER-1:0] counter_resive2 = 0;
    
    reg [1:0] path = 2'b00;
    
//    assign complete_Nchet = left_data ? 0 : fft_valid;
//    assign data_fft_Nchet_i = left_data ? 0 : data_from_fft_i;
//    assign data_fft_Nchet_q = left_data ? 0 : data_from_fft_q;

    assign complete_fft3 = path == 2'b11 ? fft_valid : 0;
    assign data_fft3_i = path == 2'b11 ? data_from_fft_i : 0;
    assign data_fft3_q = path == 2'b11 ? data_from_fft_q : 0;
    
//    assign resiveFromSecond = left_data ? 1 : flag_ready_recive_Nchet;
    assign resiveFromSecond = path == 2'b11 ? flag_ready_recive_fft3 : 1;

    
    always @(posedge clk)
    begin : sendDataFFT_0
        if(reset)
        begin
            complete_fft0 <= 0;
            counter_send0 <= 0;
        end
        else
        begin
            if(((counter_resive0 == 1) | complete_fft0) & flag_ready_recive_fft0)
            begin
                if(counter_send0 < (NFFT/4))    counter_send0 <= counter_send0 + 1;
                else                            counter_send0 <= 0;
                if(counter_send0 < (NFFT/4))    data_fft0_i <= data_from_fft0_i[counter_send0];
                if(counter_send0 < (NFFT/4))    data_fft0_q <= data_from_fft0_q[counter_send0];
                
            end
            else
            begin
                //делаю так же  как и в FFT чтобы сразу когда был выставлен флаг были  выданны данные
                counter_send0 <= 1;
                data_fft0_i <= data_from_fft0_i[0];
                data_fft0_q <= data_from_fft0_q[0];
            end
            
            if(complete_fft0 == 1'b0)
            begin
                if(counter_resive0 == 1)    complete_fft0 <= 1;
            end
            else if((counter_send0 == (NFFT/4-1)) & flag_ready_recive_fft0)  complete_fft0 <= 0;
        end
    end
    
    always @(posedge clk)
    begin : sendDataFFT_1
        if(reset)
        begin
            complete_fft1 <= 0;
            counter_send1 <= 0;
        end
        else
        begin
            if(((counter_resive1 == 1) | complete_fft1) & flag_ready_recive_fft1)
            begin
                if(counter_send1 < (NFFT/4))    counter_send1 <= counter_send1 + 1;
                else                            counter_send1 <= 0;
                if(counter_send1 < (NFFT/4))    data_fft1_i <= data_from_fft1_i[counter_send1];
                if(counter_send1 < (NFFT/4))    data_fft1_q <= data_from_fft1_q[counter_send1];
                
            end
            else
            begin
                //делаю так же  как и в FFT чтобы сразу когда был выставлен флаг были  выданны данные
                counter_send1 <= 0;
                data_fft1_i <= data_from_fft1_i[0];
                data_fft1_q <= data_from_fft1_q[0];
            end
            
            if(complete_fft1 == 1'b0)
            begin
                if(counter_resive1 == 1)    complete_fft1 <= 1;
            end
            else if((counter_send1 == (NFFT/4-1)) & flag_ready_recive_fft1)  complete_fft1 <= 0;
        end
    end
    
    always @(posedge clk)
    begin : sendDataFFT_2
        if(reset)
        begin
            complete_fft2 <= 0;
            counter_send2 <= 0;
        end
        else
        begin
            if(((counter_resive2 == 1) | complete_fft2) & flag_ready_recive_fft2)
            begin
                if(counter_send2 < (NFFT/4))    counter_send2 <= counter_send2 + 1;
                else                            counter_send2 <= 0;
                if(counter_send2 < (NFFT/4))    data_fft2_i <= data_from_fft2_i[counter_send2];
                if(counter_send2 < (NFFT/4))    data_fft2_q <= data_from_fft2_q[counter_send2];
                
            end
            else
            begin
                //делаю так же  как и в FFT чтобы сразу когда был выставлен флаг были  выданны данные
                counter_send2 <= 0;
                data_fft2_i <= data_from_fft2_i[0];
                data_fft2_q <= data_from_fft2_q[0];
            end
            
            if(complete_fft2 == 1'b0)
            begin
                if(counter_resive2 == 1)    complete_fft2 <= 1;
            end
            else if((counter_send2 == (NFFT/4-1)) & flag_ready_recive_fft2)  complete_fft2 <= 0;
        end
    end
    
    always @(posedge clk)
    begin
        if(reset)
        begin
//            left_data <= 1'b1;
            path <= 2'b00;
            counter_resive0 <= 0;
            counter_resive1 <= 0;
            counter_resive2 <= 0;
        end
        else if(fft_valid)
        begin
            if(path == 2'b00)
            begin
                data_from_fft0_i[counter_resive0] <= data_from_fft_i;
                data_from_fft0_q[counter_resive0] <= data_from_fft_q;
                counter_resive0 <= counter_resive0 + 1;
                if(counter_resive0 == (NFFT/4-1))
                begin
                    path <= 2'b01;
                    counter_resive0 <= 0;
                end
            end
            else if(path == 2'b01)
            begin
                data_from_fft1_i[counter_resive1] <= data_from_fft_i;
                data_from_fft1_q[counter_resive1] <= data_from_fft_q;
                counter_resive1 <= counter_resive1 + 1;
                if(counter_resive1 == (NFFT/4-1))
                begin
                    path <= 2'b10;
                    counter_resive1 <= 0;
                end
            end
            else if(path == 2'b10)
            begin
                data_from_fft2_i[counter_resive2] <= data_from_fft_i;
                data_from_fft2_q[counter_resive2] <= data_from_fft_q;
                counter_resive2 <= counter_resive2 + 1;
                if(counter_resive2 == (NFFT/4-1))
                begin
                    path <= 2'b11;
                    counter_resive2 <= 0;
                end
            end
            
            
            else
            begin
                if((counter_send2 == (NFFT/4)))   path <= 2'b00;
                counter_resive0 <= 0;
                counter_resive1 <= 0;
                counter_resive2 <= 0;
            end
        end
        else
        begin
            if((counter_send2 == (NFFT/4)))   path <= 2'b00;
            counter_resive0 <= 0;
            counter_resive1 <= 0;
            counter_resive2 <= 0;
        end
    end
    
    
endmodule
