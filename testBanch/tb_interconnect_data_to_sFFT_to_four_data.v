`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.12.2020 15:32:35
// Design Name: 
// Module Name: tb_interconnect_data_to_sFFT_to_two_data
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


module tb_interconnect_data_to_sFFT_to_four_data();

reg clk = 0;
always
    #5 clk = !clk;

parameter SIZE_BUFFER = 4;    
parameter SIZE_DATA  =  16;
parameter NFFT = 2**SIZE_BUFFER;
parameter SIZE_DATA_OUT  =  16 + SIZE_BUFFER - 4;
parameter COMPENS_PF = "add";


reg [SIZE_DATA-1:0] data_i = 0;
reg [SIZE_DATA-1:0] data_q = 0;
wire [SIZE_DATA_OUT-1:0] res_data_i;
wire [SIZE_DATA_OUT-1:0] res_data_q; 

wire complete;
wire [2:0] stateFFT;

reg vakidData = 1'b0;

wire flag_wayt_data;
reg  flag_ready_read = 1'b1;

reg [15:0] data_i_mas [255:0];
reg [15:0] data_q_mas [255:0];
initial
begin
    $readmemh("data_i.mem",data_i_mas);
    $readmemh("data_q.mem",data_q_mas);
end

integer i;

    always
    begin
        #10
        
        vakidData = 1'b1;
        for(i = 0; i < NFFT; i = i + 1)
        begin
            data_i = data_i_mas[i];
            data_q = data_q_mas[i];
            #10;
        end
        
        vakidData = 1'b0;
        
//        #400;
        
        #40
        #300
        vakidData = 1'b1;
        for(i = NFFT; i < NFFT*2; i = i + 1)
        begin
            data_i = data_i_mas[i];
            data_q = data_q_mas[i];
            #10;
        end
        vakidData = 1'b0;
        
        #700;
    end
    
        wire flag_wayt_data_second;
        wire flag_second_fft_valid;
        wire [SIZE_DATA-1:0] data_for_secondFFT_i;
        wire [SIZE_DATA-1:0] data_for_secondFFT_q;
        wire [SIZE_DATA_OUT-1-1:0] data_from_secondFFT_i;
        wire [SIZE_DATA_OUT-1-1:0] data_from_secondFFT_q;
        wire resiveFromSecond;
    
    myFFT_R4
#(.SIZE_BUFFER(SIZE_BUFFER-2), .DATA_FFT_SIZE(SIZE_DATA), .TYPE("invers")/*forvard invers*/, .FAST("ultrafast")/*slow fast ultrafast*/, 
  .COMPENS_FP(COMPENS_PF)/*false true or add razrad*/, .MIN_FFT_x4(1), .USE_ROUND(1), .USE_DSP(1))
_myFFT
(
    .clk(clk),
    .reset(1'b0),
    .valid(flag_second_fft_valid),
    .clk_i_data(clk),
    .data_in_i(data_for_secondFFT_i),
    .data_in_q(data_for_secondFFT_q),
    .clk_o_data(),
    .data_out_i(res_data_i),
    .data_out_q(res_data_q),
    .complete(complete),
    .stateFFT(stateFFT),
    .flag_ready_recive(resiveFromSecond),
    .flag_wayt_data(flag_wayt_data_second)
    );
    
    
reg [SIZE_BUFFER:0] counterReciveDataFFT = 0;
always @(posedge clk)
begin
    if(vakidData)   counterReciveDataFFT <= counterReciveDataFFT + 1;
    else            counterReciveDataFFT <= 0;
end

    interconnect_data_to_sFFT_R4 #(.SIZE_BUFFER(SIZE_BUFFER),/*log2(NFFT)*/
                                        .DATA_FFT_SIZE(SIZE_DATA))                            
        _interconnect_data_to_sFFT(
            .clk(clk),
            .reset(1'b0),
            .in_data_i(data_i),
            .in_data_q(data_q),
            .valid(vakidData),
            .fft_wayt_data(flag_wayt_data_second),
            .out_data_i(data_for_secondFFT_i),
            .out_data_q(data_for_secondFFT_q),
            .outvalid(flag_second_fft_valid),
            .counter_data(counterReciveDataFFT)
        );
        
        wire complete_fft0;
        wire complete_fft1;
        wire complete_fft2;
        wire complete_fft3;
        
        wire [SIZE_DATA_OUT-1:0]data_from_secondFFT0_i;
        wire [SIZE_DATA_OUT-1:0]data_from_secondFFT0_q;
        wire [SIZE_DATA_OUT-1:0]data_from_secondFFT1_i;
        wire [SIZE_DATA_OUT-1:0]data_from_secondFFT1_q;
        wire [SIZE_DATA_OUT-1:0]data_from_secondFFT2_i;
        wire [SIZE_DATA_OUT-1:0]data_from_secondFFT2_q;
        wire [SIZE_DATA_OUT-1:0]data_from_secondFFT3_i;
        wire [SIZE_DATA_OUT-1:0]data_from_secondFFT3_q;
        
//        reg flag_ready_recive_fft0 = 1'b1;
//        reg flag_ready_recive_fft1 = 1'b1;
//        reg flag_ready_recive_fft2 = 1'b1;
//        reg flag_ready_recive_fft3 = 1'b1;
        
//        initial begin
//            #01;
//            flag_ready_recive_fft0 = 0;
//            flag_ready_recive_fft1 = 0;
//            flag_ready_recive_fft2 = 0;
//            flag_ready_recive_fft3 = 0;
//            #460;
//            flag_ready_recive_fft0 = 1;
//            flag_ready_recive_fft1 = 1;
//            flag_ready_recive_fft2 = 1;
//            flag_ready_recive_fft3 = 1;
//        end

        wire flag_ready_recive_fft0;
        wire flag_ready_recive_fft1;
        wire flag_ready_recive_fft2;
        wire flag_ready_recive_fft3;
        
        assign flag_ready_recive_fft0 = complete_fft3;
        assign flag_ready_recive_fft1 = complete_fft3;
        assign flag_ready_recive_fft2 = complete_fft3;
        assign flag_ready_recive_fft3 = complete_fft3;
        
         interconnect_sFFT_to_four_data #(.SIZE_BUFFER(SIZE_BUFFER),/*log2(NFFT)*/
                                        .DATA_FFT_SIZE(SIZE_DATA_OUT)
                                        )
        _interconnect_sFFT_to_two_data(
            .clk(clk),
            .reset(1'b0),
            .fft_valid(complete),
            .data_from_fft_i(res_data_i),
            .data_from_fft_q(res_data_q),
            
            .flag_ready_recive_fft0(flag_ready_recive_fft0),
            .flag_ready_recive_fft1(flag_ready_recive_fft1),
            .flag_ready_recive_fft2(flag_ready_recive_fft2),
            .flag_ready_recive_fft3(flag_ready_recive_fft3),
            
            .data_fft0_i(data_from_secondFFT0_i),
            .data_fft0_q(data_from_secondFFT0_q),
            .data_fft1_i(data_from_secondFFT1_i),
            .data_fft1_q(data_from_secondFFT1_q),
            .data_fft2_i(data_from_secondFFT2_i),
            .data_fft2_q(data_from_secondFFT2_q),
            .data_fft3_i(data_from_secondFFT3_i),
            .data_fft3_q(data_from_secondFFT3_q),
            
            .complete_fft0(complete_fft0),
            .complete_fft1(complete_fft1),
            .complete_fft2(complete_fft2),
            .complete_fft3(complete_fft3),
            .resiveFromSecond(resiveFromSecond)
        );

endmodule
