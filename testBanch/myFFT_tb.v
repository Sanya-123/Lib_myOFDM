`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.10.2020 19:08:24
// Design Name: 
// Module Name: myFFT_tb
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
// in slow mode mult coplete CONSISTENTLY in fast mode mult complete PARAPERLITY 
//////////////////////////////////////////////////////////////////////////////////


module myFFT_tb();

parameter SIZE_BUFFER = 8;
parameter NFFT = 2**SIZE_BUFFER;

parameter SIZE_DATA  =  16;
parameter SIZE_DATA_OUT  =  16 + SIZE_BUFFER - 2;
parameter COMPENS_PF = "add";

reg clk = 0;
reg [SIZE_DATA-1:0] data_i = 0;
reg [SIZE_DATA-1:0] data_q = 0;
wire [SIZE_DATA_OUT-1:0] res_data_i;
wire [SIZE_DATA_OUT-1:0] res_data_q; 

wire [SIZE_DATA-1:0] res_data_i_div;
wire [SIZE_DATA-1:0] res_data_q_div; 
assign res_data_i_div = res_data_i[SIZE_DATA_OUT-1:SIZE_BUFFER - 2];
assign res_data_q_div = res_data_q[SIZE_DATA_OUT-1:SIZE_BUFFER - 2];

wire complete;
wire [2:0] stateFFT;

reg vakidData = 1'b0;

wire flag_wayt_data;
reg  flag_ready_read = 1'b1;

//reg [15:0] data_i_mas [3:0];
//initial
//    data_i_mas = {{{16'b0}}, {{16'b0}}, {{16'b0}}, {{16'b0}}};

reg [15:0] data_i_mas [255:0];
reg [15:0] data_q_mas [255:0];
initial
begin
$readmemh("data_i.mem",data_i_mas);
$readmemh("data_q.mem",data_q_mas);
end

    always
        #5 clk = !clk;
        
    integer i;
        
    always
    begin
        #10
        
        vakidData = 1'b1;
        for(i = 0; i < NFFT; i = i + 1)
        begin
            data_i = data_i_mas[i];
            data_q = data_q_mas[i];
//            data_i[16] = data_i[15];
//            data_q[16] = data_q[15]; 
            #10;
        end
        
        vakidData = 1'b0;
        
//        #400;
        
//        #40
//        #150
//        vakidData = 1'b1;
//        for(i = NFFT; i < NFFT*2; i = i + 1)
//        begin
//            data_i = data_i_mas[i];
//            data_q = data_q_mas[i];
//            #10;
//        end
//        vakidData = 1'b0;
        
//        #40
//        vakidData = 1'b1;
//        for(i = NFFT*2; i < NFFT*3; i = i + 1)
//        begin
//            data_i = data_i_mas[i];
//            data_q = data_q_mas[i];
//            #10;
//        end
//        vakidData = 1'b0;
        
//        #3490;
//        #10000;

//        #1740   
     
        #1450
        vakidData = 1'b1;
        for(i = 0; i < NFFT; i = i + 1)
        begin
            data_i = data_i_mas[i];
            data_q = data_q_mas[i];
            #10;
        end
        vakidData = 1'b0;
        #1440;
        
//        #1740;
        
//        #3490
        
//        #90
//        vakidData = 1'b1;
//        for(i = NFFT*3; i < NFFT*4; i = i + 1)
//        begin
//            data_i = data_i_mas[i];
//            data_q = data_q_mas[i];
//            #10;
//        end
//        vakidData = 1'b0;

        
//        #20
//        vakidData = 1'b0;
//        #2300;

//        #5600;
    end
    
//    initial
//    begin
//        flag_ready_read <= 1'b0;
//        #80
//        flag_ready_read <= 1'b1;
//        #20
//        flag_ready_read <= 1'b0;
//        #360
//        flag_ready_read <= 1'b1;
////        #40
////        flag_ready_read <= 1'b0;
////        #50
////        flag_ready_read <= 1'b1;
//    end

    integer f_i, f_q, j;
    
    
//    //write fft data fo file
//    initial
//    begin
//        f_i = $fopen("sim_res_data_i.txt", "w");
//        f_q = $fopen("sim_res_data_q.txt", "w");
        
//        #20
        
//        while(complete == 1'b0)
//        begin
//            #10;
//        end

////        #16060;
//        for(j = 0; j < NFFT; j = j + 1)
//        begin
//            $fwrite(f_i, "%d\n", res_data_i_div);
//            $fwrite(f_q, "%d\n", res_data_q_div);
//            #10;
//        end
        
//        #20
//        $fclose(f_i);
//        $fclose(f_q);
//        $stop;
////    $finish;
//    end
    
    wire _flag_complete_chet;
    wire _flag_complete_Nchet;
//    wire _flag_valid_chet;
//    wire _flag_valid_Nchet;
    wire [2:0] stateFFT_chet;
    wire [2:0] stateFFT_Nchet;
//    wire [2:0] stateFFT_chet2;
//    wire [2:0] stateFFT_Nchet2;
//    wire [2:0] stateFFT_NNchet2;
//    wire [2:0] stateFFT_NNNchet2;
    
//    wire _flag_valid_chet2;
//    wire _flag_valid_Nchet2;
//    wire _flag_valid_NNchet2;
//    wire _flag_valid_NNNchet2;
//wire [2:0] _counterMultData;

//    wire [SIZE_DATA-1:0] _out_summ_0__NFFT_2_i;
//    wire [SIZE_DATA-1:0] _out_summ_0__NFFT_2_q;
//    wire [SIZE_DATA-1:0] _out_summ_NFFT_2__NFFT_i;
//    wire [SIZE_DATA-1:0] _out_summ_NFFT_2__NFFT_q;
    
//    wire _resiveFromChet;
//    wire _resiveFromNChet;

//    wire __data_summ_out_mas_i_r_writeEn_c;
//    wire [SIZE_BUFFER-2:0] __data_summ_out_mas_i_r_addr_c;
//    wire [SIZE_BUFFER-2:0] __data_summ_out_mas_i_r_addr_r_c;
//    wire [16-1:0] __data_summ_out_mas_i_r_writeData_c;
//    wire [16-1:0] __data_summ_out_mas_i_r_readData_c;
    
//    //nchet
//    wire __data_summ_out_mas_i_r_writeEn_Nc;
//    wire [SIZE_BUFFER-2:0] __data_summ_out_mas_i_r_addr_Nc;
//    wire [SIZE_BUFFER-2:0] __data_summ_out_mas_i_r_addr_r_Nc;
//    wire [16-1:0] __data_summ_out_mas_i_r_writeData_Nc;
//    wire [16-1:0] __data_summ_out_mas_i_r_readData_Nc;

//wire [2:0] _counterOutData;

wire [SIZE_BUFFER:0] _counterMultData;
//wire [SIZE_BUFFER-1:0] _counterMultData_chet;
//wire [SIZE_BUFFER-1:0] _counterMultData_Nchet;

//wire _enMult;
//wire _dataComplete;

    wire [17-1:0] d_out_summ_0__NFFT_2_i;
    wire [17-1:0] d_out_summ_0__NFFT_2_q;
    wire [17-1:0] d_out_summ_NFFT_2__NFFT_i;
    wire [17-1:0] d_out_summ_NFFT_2__NFFT_q;
    wire d_dataComplete;

myFFT
#(.SIZE_BUFFER(SIZE_BUFFER), .DATA_FFT_SIZE(SIZE_DATA), .TYPE("forvard")/*forvard invers*/, .FAST("ultrafast")/*slow fast ultrafast*/, 
  .COMPENS_FP(COMPENS_PF)/*false true or add razrad*/, .MIN_FFT_x4(1))
_myFFT
(
    .clk(clk),
    .reset(1'b0),
    .valid(vakidData),
    .clk_i_data(clk),
    .data_in_i(data_i),
    .data_in_q(data_q),
    .clk_o_data(),
    .data_out_i(res_data_i),
    .data_out_q(res_data_q),
    .complete(complete),
    .stateFFT(stateFFT),
    .flag_wayt_data(flag_wayt_data),
    .flag_ready_recive(flag_ready_read)
//    ._counterMultData(_counterMultData)
////    ._counterOutData(_counterOutData)
//    ._out_summ_0__NFFT_2_i(_out_summ_0__NFFT_2_i),
//    ._out_summ_0__NFFT_2_q(_out_summ_0__NFFT_2_q),
//    ._out_summ_NFFT_2__NFFT_i(_out_summ_NFFT_2__NFFT_i),
//    ._out_summ_NFFT_2__NFFT_q(_out_summ_NFFT_2__NFFT_q),
////    ._counterMultData(_counterMultData)
//    ._flag_complete_chet(_flag_complete_chet),
//    ._flag_complete_Nchet(_flag_complete_Nchet),
//    ._resiveFromChet(_resiveFromChet),
//    ._resiveFromNChet(_resiveFromNChet),
//    ._flag_valid_chet(_flag_valid_chet),
//    ._flag_valid_Nchet(_flag_valid_Nchet),
//    .stateFFT_chet(stateFFT_chet),
//    .stateFFT_Nchet(stateFFT_Nchet)
//    ._counterMultData_chet(_counterMultData_chet),
//    ._counterMultData_Nchet(_counterMultData_Nchet),
//    ._enMult(_enMult),
//    ._dataComplete(_dataComplete)
//    .stateFFT_chet2(stateFFT_chet2),
//    .stateFFT_Nchet2(stateFFT_Nchet2),
//    .stateFFT_NNchet2(stateFFT_NNchet2),
//    .stateFFT_NNNchet2(stateFFT_NNNchet2),
//    ._flag_valid_chet2(_flag_valid_chet2),
//    ._flag_valid_Nchet2(_flag_valid_Nchet2),
//    ._flag_valid_NNchet2(_flag_valid_NNchet2),
//    ._flag_valid_NNNchet2(_flag_valid_NNNchet2)
//    .__data_summ_out_mas_i_r_writeEn_c(__data_summ_out_mas_i_r_writeEn_c),
//    .__data_summ_out_mas_i_r_addr_c(__data_summ_out_mas_i_r_addr_c),
//    .__data_summ_out_mas_i_r_addr_r_c(__data_summ_out_mas_i_r_addr_r_c),
//    .__data_summ_out_mas_i_r_writeData_c(__data_summ_out_mas_i_r_writeData_c),
//    .__data_summ_out_mas_i_r_readData_c(__data_summ_out_mas_i_r_readData_c),
//    .__data_summ_out_mas_i_r_writeEn_Nc(__data_summ_out_mas_i_r_writeEn_Nc),
//    .__data_summ_out_mas_i_r_addr_Nc(__data_summ_out_mas_i_r_addr_Nc),
//    .__data_summ_out_mas_i_r_addr_r_Nc(__data_summ_out_mas_i_r_addr_r_Nc),
//    .__data_summ_out_mas_i_r_writeData_Nc(__data_summ_out_mas_i_r_writeData_Nc),
//    .__data_summ_out_mas_i_r_readData_Nc(__data_summ_out_mas_i_r_readData_Nc)
    ,.d_out_summ_0__NFFT_2_i(d_out_summ_0__NFFT_2_i)
    ,.d_out_summ_0__NFFT_2_q(d_out_summ_0__NFFT_2_q)
    ,.d_out_summ_NFFT_2__NFFT_i(d_out_summ_NFFT_2__NFFT_i)
    ,.d_out_summ_NFFT_2__NFFT_q(d_out_summ_NFFT_2__NFFT_q)
    ,.d_dataComplete(d_dataComplete)
    ,.d__counterMultData(_counterMultData)
);

//myFFT
//#(.SIZE_BUFFER(4), .FAST("true"), .FORVARD("false"))
//_myFFT_fase
//(
//    .clk(clk),
//    .valid(1'b1),
//    .clk_i_data(clk),
//    .data_in_i(data_i),
//    .data_in_q(data_q),
//    .clk_o_data(),
//    .data_out_i(res_data_i_f),
//    .data_out_q(res_data_q_f),
//    .complete(complete_f),
//    .stateFFT(stateFFT_f)
//    );

endmodule
