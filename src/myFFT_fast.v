`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.10.2020 17:33:18
// Design Name: 
// Module Name: myFFT
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


module myFFT_fast
    #(parameter SIZE_BUFFER = 1/*log2(NFFT)*/,
      parameter DATA_FFT_SIZE = 16)
    (
    clk,
    valid,
    clk_i_data,
    data_in_i,
    data_in_q,
    clk_o_data,
    data_out_i,
    data_out_q,
    complete,
    stateFFT
//    _counterMultData
//    _flag_complete_chet,
//    _flag_complete_Nchet,
//    _flag_valid_chet,
//    _flag_valid_Nchet,
//    _flag_valid_chet2,
//    _flag_valid_Nchet2,
//    _flag_valid_NNchet2,
//    _flag_valid_NNNchet2,
//    stateFFT_chet,
//    stateFFT_Nchet,
//    stateFFT_chet2,
//    stateFFT_Nchet2,
//    stateFFT_NNchet2,
//    stateFFT_NNNchet2
    );
    
    parameter NFFT = 1 << SIZE_BUFFER;
    
//`include "common.vh"
    
    input clk;
    input valid;//flag data is valid
    input clk_i_data;
    input [DATA_FFT_SIZE-1:0] data_in_i;
    input [DATA_FFT_SIZE-1:0] data_in_q;
    output clk_o_data;
    output reg [DATA_FFT_SIZE-1:0] data_out_i;
    output reg [DATA_FFT_SIZE-1:0] data_out_q;
    output reg complete;
    output [2:0] stateFFT;
    
//    output _flag_complete_chet;
//    output _flag_complete_Nchet;
//    output _flag_valid_chet;
//    output _flag_valid_Nchet;
//    output _flag_valid_chet2;
//    output _flag_valid_Nchet2;
//    output _flag_valid_NNchet2;
//    output _flag_valid_NNNchet2;
//    output [2:0] stateFFT_chet;
//    output [2:0] stateFFT_Nchet;
//    output [2:0] stateFFT_chet2;
//    output [2:0] stateFFT_Nchet2;
//    output [2:0] stateFFT_NNchet2;
//    output [2:0] stateFFT_NNNchet2;

//    output [SIZE_BUFFER:0] _counterMultData;

    assign clk_o_data = clk;//NOTE возможно потребуеться давать клок только когда данные отправляюьбся
    
    //TODO размеры массивов   
    reg [SIZE_BUFFER+1:0] counterReciveDataFFT;
    reg [SIZE_BUFFER+1:0] counterSendData;
    reg [2:0] state;
    
    assign stateFFT = state;
    
    parameter stateWaytData = 3'b000;
    parameter stateWriteData = 3'b001;
    parameter stateWaytFFT = 3'b010;
    
//    parameter stateSummFFT = 4'b100;
    parameter stateSummFFT = 4'b100;
    parameter stateComplete = 4'b111;
    
    initial
    begin
        counterReciveDataFFT = 0;
        complete = 0;
        counterSendData = 0;
        state = stateWaytData;
//        data_for_secondFFT_chet_i = 0;
//        data_for_secondFFT_chet_q = 0;
//        data_for_secondFFT_Nchet_i = 0;
//        data_for_secondFFT_Nchet_q = 0;
    end
    
    genvar i;
    generate
    //********это конечная часть рекурсии********
    if(NFFT < 2) begin end
    else if(NFFT == 2) begin : FFT_2 //+
    
        reg [DATA_FFT_SIZE-1:0] data_in_mas_i [1:0];
        reg [DATA_FFT_SIZE-1:0] data_in_mas_q [1:0];
        wire [DATA_FFT_SIZE-1:0] data_out_mas_i [1:0];
        wire [DATA_FFT_SIZE-1:0] data_out_mas_q [1:0];
        
        reg [DATA_FFT_SIZE-1:0] x_i;
        reg [DATA_FFT_SIZE-1:0] x_q;
        
        summComplex _summ0(
            .clk(clk),
            .en(state == stateSummFFT),
            .data_in0_i(data_in_mas_i[0]),
            .data_in0_q(data_in_mas_q[0]),
            .data_in1_i(data_in_mas_i[1]),
            .data_in1_q(data_in_mas_q[1]),
            .data_out0_i(data_out_mas_i[0]),
            .data_out0_q(data_out_mas_q[0])
        );
        summComplex _summ1(
            .clk(clk),
            .en(state == stateSummFFT),
            .data_in0_i(data_in_mas_i[0]),
            .data_in0_q(data_in_mas_q[0]),
            .data_in1_i(x_i),
            .data_in1_q(x_q),
            .data_out0_i(data_out_mas_i[1]),
            .data_out0_q(data_out_mas_q[1])
        );
        
        always @(posedge clk)//fms
        begin : FMS_FFT
            //машина конечных состоояние по состоянию данных
            if(state == stateWaytData)
            begin
                if(counterReciveDataFFT == 2)
                begin
                    state <= stateSummFFT;
                end
            end
            else if(state == stateSummFFT)
            begin
                state <= stateComplete;//1 такт на сумирование
            end
            else if(state == stateComplete)
            begin
                if(counterSendData == 2/*возможно 1*/)   state <= stateWaytData;//when all data is send wayt anouther data
            end
        end
        
        always @(posedge clk)//data for second dot
        begin : secondDotFFT
            if(state == stateWaytData)
            begin
                if(counterReciveDataFFT == 2)
                begin
                    x_i <= -data_in_mas_i[1];
                    x_q <= -data_in_mas_q[1];
                end
            end
        end
        
        always @(posedge clk_i_data)//resiveData
        begin : reciveDataFFT
            if(counterReciveDataFFT < NFFT)
            begin
                if(valid == 1'b1)//flag data is valid
                begin
                    data_in_mas_i[counterReciveDataFFT[1:0]] <= data_in_i;
                    data_in_mas_q[counterReciveDataFFT[1:0]] <= data_in_q;
                    counterReciveDataFFT <= counterReciveDataFFT + 1;
                end
            end
            else if (state == stateComplete) counterReciveDataFFT <= 0;//когда все математические операции выполнены можно заново принимать данные
        end
        
        always @(negedge clk)//send data
        begin : sendDataFFT
            if(state == stateComplete)//когда вые выполнено отправляю даннеы
            begin
                if(counterSendData < NFFT)
                begin
                    counterSendData <= counterSendData + 1;
                    data_out_i <= data_out_mas_i[counterSendData];
                    data_out_q <= data_out_mas_q[counterSendData];
                end
            end
            else counterSendData <= 0;//когда 
        end
        
    end
    else//тут выполняеться рекурсия и дальнейшее вычисления
    begin
        
        wire [DATA_FFT_SIZE-1:0] data_from_secondFFT_chet_i;
        wire [DATA_FFT_SIZE-1:0] data_from_secondFFT_chet_q;
        wire [DATA_FFT_SIZE-1:0] data_from_secondFFT_Nchet_i;
        wire [DATA_FFT_SIZE-1:0] data_from_secondFFT_Nchet_q;
        wire flag_complete_chet;
        wire flag_complete_Nchet;
        
//        assign _flag_complete_chet = flag_complete_chet;
//        assign _flag_complete_Nchet = flag_complete_Nchet;
//        assign _flag_valid_chet = (counterReciveDataFFT[0] == 1'b0) & (state == stateWaytData) & valid;
//        assign _flag_valid_Nchet = (counterReciveDataFFT[0] == 1'b1) & (state == stateWaytData) & valid;
        
        //after second fft before summing
        reg [DATA_FFT_SIZE-1:0] data_s_fft_out_mas_i_r [NFFT-1:0];
        reg [DATA_FFT_SIZE-1:0] data_s_fft_out_mas_q_r [NFFT-1:0];
        
        //after summing
        reg [DATA_FFT_SIZE-1:0] data_summ_out_mas_i_r [NFFT-1:0];
        reg [DATA_FFT_SIZE-1:0] data_summ_out_mas_q_r [NFFT-1:0];
        
        reg valid_data_chet;
        reg valid_data_Nchet;
        
        wire [2:0] stateFFTChet;
        wire [2:0] stateFFTNChet;
        reg [SIZE_BUFFER:0] counterReadData_chet;
        reg [SIZE_BUFFER:0] counterReadData_Nchet;
//        reg [SIZE_BUFFER:0] counterMultData;
        reg mutDone = 1'b0;
        
        reg validChet = 1'b1;
        reg validNChet = 1'b0;
        
//        assign stateFFT_chet = stateFFTChet;
//        assign stateFFT_Nchet = stateFFTNChet;
//        assign _counterMultData = counterMultData;
        
        
        initial
        begin
            valid_data_chet = 0;
            valid_data_Nchet = 0;
            counterReadData_chet = 0;
            counterReadData_Nchet = 0;
        end
        //recursi
        //0 2 4...
        myFFT #(.SIZE_BUFFER(SIZE_BUFFER-1))
        dataChetn(
            .clk(clk),
            .valid(validChet & valid/*(counterReciveDataFFT[0] == 1'b0) & (state == stateWaytData) & valid*/),
            .clk_i_data(clk_i_data),
            .data_in_i(data_in_i),
            .data_in_q(data_in_q),
            .clk_o_data(),
            .data_out_i(data_from_secondFFT_chet_i),
            .data_out_q(data_from_secondFFT_chet_q),
            .complete(flag_complete_chet),
            .stateFFT(stateFFTChet)
//            .stateFFT_chet(stateFFT_chet2),
//            .stateFFT_Nchet(stateFFT_Nchet2),
//            ._flag_valid_chet(_flag_valid_chet2),
//            ._flag_valid_Nchet(_flag_valid_Nchet2)
        );
        //1 3 5...
        myFFT #(.SIZE_BUFFER(SIZE_BUFFER-1))
        dataNChetn(
            .clk(clk),
            .valid(validNChet & valid/*(counterReciveDataFFT[0] == 1'b1) & (state == stateWaytData)  & valid*/),
            .clk_i_data(clk_i_data),
            .data_in_i(data_in_i),
            .data_in_q(data_in_q),
            .clk_o_data(),
            .data_out_i(data_from_secondFFT_Nchet_i),
            .data_out_q(data_from_secondFFT_Nchet_q),
            .complete(flag_complete_Nchet),
            .stateFFT(stateFFTNChet)
//            .stateFFT_chet(stateFFT_NNchet2),
//            .stateFFT_Nchet(stateFFT_NNNchet2),
//            ._flag_valid_chet(_flag_valid_NNchet2),
//            ._flag_valid_Nchet(_flag_valid_NNNchet2)
        );
        
        
        reg completeDoneChet = 1'b0;
        reg completeDoneNChet = 1'b0;
        
        always @(posedge clk)//fsm
        begin : FMS_FFT
            //машина конечных состоояние по состоянию данных
            if(state == stateWaytData)
            begin
                if(counterReciveDataFFT == NFFT)    state <= stateWaytFFT;
            end
            else if(state == stateWaytFFT)
            begin
                if(completeDoneChet & completeDoneNChet)   state <= stateWriteData;/*считывания данных с FFT второго уровня*/
            end
            else if(state == stateWriteData)
            begin
                if({flag_complete_chet, flag_complete_Nchet} == 2'b00)  state <= stateSummFFT/*stateComplete*/;                
            end
            else if(state == stateSummFFT)
            begin
                if(mutDone) state <= stateComplete;
            end
            else if(state == stateComplete)
            begin
                if(counterSendData == NFFT/*возможно 1*/)   state <= stateWaytData;//when all data is send wayt anouther data
            end
        end
        
        always @(posedge clk)
        begin : waitCompleteSecondFFT
            if(state == stateSummFFT)
            begin
                completeDoneChet <= 1'b0;
                completeDoneNChet <= 1'b0;
            end
            else
            begin
                if(flag_complete_chet)
                    completeDoneChet <= 1'b1;
                if(flag_complete_Nchet)
                    completeDoneNChet <= 1'b1;
            end
            
        end
        
        always @(posedge clk)//resive from second FFT chet
        begin : reciveFromSecondFFTchet
            if(flag_complete_chet)
            begin
                if(counterReadData_chet < NFFT/2)
                begin
                    counterReadData_chet <= counterReadData_chet + 1;
                    /*записываю в буфер через 1*/
//                    data_s_fft_out_mas_i_r[{counterReadData_chet[SIZE_BUFFER-1:0], 1'b0}] <= data_from_secondFFT_chet_i;
//                    data_s_fft_out_mas_q_r[{counterReadData_chet[SIZE_BUFFER-1:0], 1'b0}] <= data_from_secondFFT_chet_q;
                    /*записываю в первую половину буфера*/
                    data_s_fft_out_mas_i_r[counterReadData_chet] <= data_from_secondFFT_chet_i;
                    data_s_fft_out_mas_q_r[counterReadData_chet] <= data_from_secondFFT_chet_q;
                end
            end
            else counterReadData_chet <= 0;
        end
        
        always @(posedge clk)//resive from second FFT Nchet
        begin : reciveFromSecondFFTNchet
            if(flag_complete_Nchet)
            begin     
                if(counterReadData_Nchet < NFFT/2)
                begin
                    counterReadData_Nchet <= counterReadData_Nchet + 1;
                    /*записываю в буфер через 1*/         
//                    data_s_fft_out_mas_i_r[{counterReadData_Nchet[SIZE_BUFFER-1:0], 1'b1}] <= data_from_secondFFT_Nchet_i;
//                    data_s_fft_out_mas_q_r[{counterReadData_Nchet[SIZE_BUFFER-1:0], 1'b1}] <= data_from_secondFFT_Nchet_q;
                    /*записываю в вторую половину буфера*/
                    data_s_fft_out_mas_i_r[counterReadData_Nchet + NFFT/2] <= data_from_secondFFT_Nchet_i;
                    data_s_fft_out_mas_q_r[counterReadData_Nchet + NFFT/2] <= data_from_secondFFT_Nchet_q;
                end
            end
            else counterReadData_Nchet <= 0;
        end
        
        reg enMult = 1'b0;
        reg flagBeginMult = 1'b0;
        wire [DATA_FFT_SIZE-1:0] multData_i [NFFT/2-1:0];
        wire [DATA_FFT_SIZE-1:0] multData_q [NFFT/2-1:0];
        reg [15:0] phi [NFFT/2-1:0]/*= 16'd0*/;
        
        wire [DATA_FFT_SIZE-1:0] res_m_phi_i [NFFT/2-1:0];
        wire [DATA_FFT_SIZE-1:0] res_m_phi_q [NFFT/2-1:0];
        wire [DATA_FFT_SIZE-1:0] res_p_phi_i [NFFT/2-1:0];
        wire [DATA_FFT_SIZE-1:0] res_p_phi_q [NFFT/2-1:0];
        wire [NFFT/2-1:0] dataComplete;
        parameter waytAllDataRes = {(NFFT/2){1'b1}};//все флаги о завершении выставлены
        
        wire [DATA_FFT_SIZE-1:0] out_summ_0__NFFT_2_i [NFFT/2-1:0];
        wire [DATA_FFT_SIZE-1:0] out_summ_0__NFFT_2_q [NFFT/2-1:0];
        wire [DATA_FFT_SIZE-1:0] out_summ_NFFT_2__NFFT_i [NFFT/2-1:0];
        wire [DATA_FFT_SIZE-1:0] out_summ_NFFT_2__NFFT_q [NFFT/2-1:0];
        
//        reg [DATA_FFT_SIZE-1:0] data_summ_chet_i;
//        reg [DATA_FFT_SIZE-1:0] data_summ_chet_q;
        
        for(i = 0; i < NFFT/2; i = i + 1)
        begin : summFFT
            assign multData_i[i] = data_s_fft_out_mas_i_r[NFFT/2 + i];
            assign multData_q[i] = data_s_fft_out_mas_q_r[NFFT/2 + i];
            multComplexE #(.SIZE_DATA_FI(SIZE_BUFFER)/*LOG2(NFFT)*/)
            _multComplexE
                (
                .clk(clk),
                .en(enMult),
                .in_data_i(multData_i[i]),
                .in_data_q(multData_q[i]),
                .fi_deg(/*phi[i]*/i),
                .out_data_minus_i(res_m_phi_i[i]),
                .out_data_minus_q(res_m_phi_q[i]),
                .out_data_plus_i(res_p_phi_i[i]),
                .out_data_plus_q(res_p_phi_q[i]),
                .outValid(dataComplete[i]),
                .minusReady(),
                .plusReady(),
                .module_en()
                );
                

                
            summComplex _summ0__NFFT_2(
                .clk(clk),
                .en(state == stateSummFFT),
                .data_in0_i(data_s_fft_out_mas_i_r[i]),
                .data_in0_q(data_s_fft_out_mas_q_r[i]),
                .data_in1_i(res_m_phi_i[i]),
                .data_in1_q(res_m_phi_q[i]),
                .data_out0_i(out_summ_0__NFFT_2_i[i]),
                .data_out0_q(out_summ_0__NFFT_2_q[i])
            );
            summComplex _summNFFT_2__NFFT(
                .clk(clk),
                .en(state == stateSummFFT),
                .data_in0_i(data_s_fft_out_mas_i_r[i]),
                .data_in0_q(data_s_fft_out_mas_q_r[i]),
                .data_in1_i(res_p_phi_i[i]),
                .data_in1_q(res_p_phi_q[i]),
                .data_out0_i(out_summ_NFFT_2__NFFT_i[i]),
                .data_out0_q(out_summ_NFFT_2__NFFT_q[i])
            );
            
            always @(posedge clk)//output data
            begin : outputDataSummFFT
                if(state == stateSummFFT)
                begin
                    if(dataComplete[i] & flagBeginMult)
                    begin
                        data_summ_out_mas_i_r[i] <= out_summ_0__NFFT_2_i[i];
                        data_summ_out_mas_q_r[i] <= out_summ_0__NFFT_2_q[i];
                        
                        data_summ_out_mas_i_r[i + NFFT/2] <= out_summ_NFFT_2__NFFT_i[i];
                        data_summ_out_mas_q_r[i + NFFT/2] <= out_summ_NFFT_2__NFFT_q[i];
                    end
                end
            end
        end
        
//        reg [SIZE_BUFFER:0] counterMultData2 = 0;
            
        always @(posedge clk)//summ FFT
        begin : waitSummFFT
            if(state == stateSummFFT)
            begin
                if(dataComplete == waytAllDataRes)
                begin
                    if(flagBeginMult == 1'b0)   flagBeginMult <= 1'b1;
                    if(flagBeginMult == 1'b0)   enMult <= 1'b1;
                    if(flagBeginMult == 1'b1)   mutDone <= 1'b1;
                end
                else enMult <= 1'b0;
            end
            else begin mutDone <= 1'b0; enMult <= 1'b0; flagBeginMult <= 1'b0; end
        end
        
        always @(posedge clk_i_data)//resiveData counter
        begin : reciveFFT
            if (state != stateWaytData) counterReciveDataFFT <= 0;
            else if(counterReciveDataFFT < NFFT)
            begin
                if(valid == 1'b1)//flag data is valid
                begin
                    counterReciveDataFFT <= counterReciveDataFFT + 1;
                end
            end
        end
        
        always @(negedge clk)//выставляю бит флага valid по  нижниму фронту потомучто 
        begin : setValidFFT
            if((counterReciveDataFFT[0] == 1'b0) & (state == stateWaytData))        begin validChet <= 1'b1; validNChet <= 1'b0; end
            else if((counterReciveDataFFT[0] == 1'b1) & (state == stateWaytData))   begin validChet <= 1'b0; validNChet <= 1'b1; end
            else begin validChet <= /*valid & (state == stateWaytData)*/1'b0; validNChet <= 1'b0; end
        end
        
        always @(negedge clk)//send data
        begin : sendDataFFT
            if(state == stateComplete)//когда вые выполнено отправляю даннеы
            begin
                if(counterSendData < NFFT)
                begin
                    counterSendData <= counterSendData + 1;
//                    data_out_i <= data_s_fft_out_mas_i_r[counterSendData];
//                    data_out_q <= data_s_fft_out_mas_q_r[counterSendData];
                    data_out_i <= data_summ_out_mas_i_r[counterSendData];
                    data_out_q <= data_summ_out_mas_q_r[counterSendData];
                end
            end
            else counterSendData <= 0;//когда 
        end

    end
    endgenerate
    
    always @(negedge clk)//flag complete
    begin : flagComplete
        if(state == stateComplete)  complete <= 1'b1;
        else                        complete <= 1'b0;
    end
    
    
endmodule
