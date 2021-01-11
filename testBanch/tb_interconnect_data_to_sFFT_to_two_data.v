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


module tb_interconnect_data_to_sFFT_to_two_data();

reg clk = 0;
always
    #5 clk = !clk;

parameter SIZE_BUFFER = 3;    
parameter SIZE_DATA  =  16;
parameter NFFT = 2**SIZE_BUFFER;
parameter SIZE_DATA_OUT  =  16 + SIZE_BUFFER - 2 - 1;
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
        
        #400;
    end
    
        wire flag_wayt_data_second;
        wire flag_second_fft_valid;
        wire [SIZE_DATA-1:0] data_for_secondFFT_i;
        wire [SIZE_DATA-1:0] data_for_secondFFT_q;
        wire [SIZE_DATA_OUT-1-1:0] data_from_secondFFT_i;
        wire [SIZE_DATA_OUT-1-1:0] data_from_secondFFT_q;
        wire resiveFromSecond;
    
    myFFT
#(.SIZE_BUFFER(SIZE_BUFFER-1), .DATA_FFT_SIZE(SIZE_DATA), .TYPE("forvard")/*forvard invers*/, .FAST("ultrafast")/*slow fast ultrafast*/, 
  .COMPENS_FP(COMPENS_PF)/*false true or add razrad*/, .MIN_FFT_x4(1), .USE_ROUND(1), .USE_DSP(0))
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

    interconnect_data_to_sFFT #(.SIZE_BUFFER(SIZE_BUFFER),/*log2(NFFT)*/
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
        
        wire flag_complete_chet;
        wire flag_complete_Nchet;
        
        wire [SIZE_DATA_OUT-1:0]data_from_secondFFT_chet_i;
        wire [SIZE_DATA_OUT-1:0]data_from_secondFFT_chet_q;
        wire [SIZE_DATA_OUT-1:0]data_from_secondFFT_Nchet_i;
        wire [SIZE_DATA_OUT-1:0]data_from_secondFFT_Nchet_q;
        
        reg flag_ready_recive_chet = 1'b1;
        reg flag_ready_recive_Nchet = 1'b1;
        
        initial begin
            #120;
            flag_ready_recive_chet = 0;
            flag_ready_recive_Nchet = 0;
            #120;
            flag_ready_recive_chet = 1;
            flag_ready_recive_Nchet = 1;
        end
        
         interconnect_sFFT_to_two_data #(.SIZE_BUFFER(SIZE_BUFFER),/*log2(NFFT)*/
                                        .DATA_FFT_SIZE(SIZE_DATA_OUT)
                                        )
        _interconnect_sFFT_to_two_data(
            .clk(clk),
            .reset(1'b0),
            .fft_valid(complete),
            .data_from_fft_i(res_data_i),
            .data_from_fft_q(res_data_q),
            
            .flag_ready_recive_chet(flag_ready_recive_chet),
            .flag_ready_recive_Nchet(flag_ready_recive_Nchet),
            .data_fft_chet_i(data_from_secondFFT_chet_i),
            .data_fft_chet_q(data_from_secondFFT_chet_q),
            .data_fft_Nchet_i(data_from_secondFFT_Nchet_i),
            .data_fft_Nchet_q(data_from_secondFFT_Nchet_q),
            .complete_chet(flag_complete_chet),
            .complete_Nchet(flag_complete_Nchet),
            .resiveFromSecond(resiveFromSecond)
        );

endmodule
