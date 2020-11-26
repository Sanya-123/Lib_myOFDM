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
// mudole recursi use this module
// the longest state is stateSummFFT when data is mult
// in slow mode mult coplete CONSISTENTLY in fast mode mult complete PARAPERLITY
// NOTE при парарельном использовании данных если долго не считывать данные они могут затереться
// для быльшей точности от умножения тут добавляеться разряд если COMPENS_FP==add
//////////////////////////////////////////////////////////////////////////////////

/*
 * FFT2 : .SIZE_BUFFER(1) SIZE_BUFFER = 1
 * FFT4 : .SIZE_BUFFER(2) SIZE_BUFFER = 2
 * FFT8 : .SIZE_BUFFER(2) SIZE_BUFFER = 3
 * FFT16 : .SIZE_BUFFER(2) SIZE_BUFFER = 4
 * FFT32 : .SIZE_BUFFER(2) SIZE_BUFFER = 5
 * FFT64 : .SIZE_BUFFER(2) SIZE_BUFFER = 6
 * FFT128 : .SIZE_BUFFER(2) SIZE_BUFFER = 7
 * FFT256 : .SIZE_BUFFER(2) SIZE_BUFFER = 8
*/
module myFFT
    #(parameter SIZE_BUFFER = 1,/*log2(NFFT)*/
      parameter DATA_FFT_SIZE = 16,
      parameter FAST = "slow",/*slow fast ultrafast slow mult x1 fast mult x2 ultrafast mult x4*/
      parameter TYPE = "forvard",/*forvard invers*/
      parameter COMPENS_FP = "false", /*false true or add razrad*/
      parameter MIN_FFT_x4 = 1
    )
    (
    clk,
    reset,
    valid,
    clk_i_data,
    data_in_i,
    data_in_q,
    clk_o_data,
    data_out_i,
    data_out_q,
    complete,
    stateFFT,
    flag_ready_recive,/*input flags for output data*/
    flag_wayt_data/*flag can recive daat data*/
    //debug
    );
    
    localparam NFFT = 1 << SIZE_BUFFER;
    
    //начиная с fft8 увеличиваю по 1 разряду выходные данные
    localparam SIZE_OUT_DATA        = COMPENS_FP == "add" ? (DATA_FFT_SIZE + (SIZE_BUFFER > 2 ? SIZE_BUFFER - 2 : 0)) : DATA_FFT_SIZE;//на выходе модуля
    localparam SIZE_OUT_DATA_S_FFT  = COMPENS_FP == "add" ? (DATA_FFT_SIZE + (SIZE_BUFFER > 2 ? SIZE_BUFFER - 3 : 0)) : DATA_FFT_SIZE;//на выходе предыдущего модуля
    
//    localparam SIZE_OUT_DATA        = DATA_FFT_SIZE;//на выходе модуля
//    localparam SIZE_OUT_DATA_S_FFT  = DATA_FFT_SIZE;//на выходе предыдущего модуля

    
    input clk;
    input reset;
    input valid;//flag data is valid
    input clk_i_data;
    input [DATA_FFT_SIZE-1:0] data_in_i;
    input [DATA_FFT_SIZE-1:0] data_in_q;
    output clk_o_data;
    output /*reg*/ [SIZE_OUT_DATA-1:0] data_out_i;
    output /*reg*/ [SIZE_OUT_DATA-1:0] data_out_q;
    output reg complete;
    output [2:0] stateFFT;
    //debug
    
    input flag_ready_recive;
    output /*reg*/ flag_wayt_data;
    

    assign clk_o_data = clk;//NOTE возможно потребуеться давать клок только когда данные отправляюьбся
    
    //TODO размеры массивов   
    reg [SIZE_BUFFER:0] counterReciveDataFFT;
    reg [SIZE_BUFFER:0] counterSendData;
    reg [2:0] state;
    reg completeDone_r = 1'b0;
    
    assign stateFFT = state;
    
    localparam stateWaytData = 3'b000;
    localparam stateWriteData = 3'b001;
    localparam stateWaytFFT = 3'b010;
    
//    localparam stateSummFFT = 4'b100;
    localparam stateSummFFT = 4'b100;
    localparam stateComplete = 4'b111;
    
    initial
    begin
        counterReciveDataFFT = 0;
        complete = 0;
        counterSendData = 0;
        state = stateWaytData;
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
        
        wire flag_summ;
        assign flag_summ = state == stateComplete;
        
        summComplex_x2 #(.DATA_FFT_SIZE(DATA_FFT_SIZE))
        _summ0(
            .clk(clk),
            .en(flag_summ),
            .data_in0_i(data_in_mas_i[0]),
            .data_in0_q(data_in_mas_q[0]),
            .data_in1_i(data_in_mas_i[1]),
            .data_in1_q(data_in_mas_q[1]),
            .data_out0_i(data_out_mas_i[0]),
            .data_out0_q(data_out_mas_q[0]),
            .data_out1_i(data_out_mas_i[1]),
            .data_out1_q(data_out_mas_q[1])
        );
        
        always @(posedge clk)//fms
        begin : FMS_FFT
            if(reset)   state <= stateWaytData;
            else 
            begin
                //машина конечных состоояние по состоянию данных
                case(state)
                stateWaytData : if(counterReciveDataFFT == 2) state <= stateComplete;//сдесь можно ускорить на 1 такт
                stateComplete : if((counterSendData == 1) & flag_ready_recive)   state <= stateWaytData;//when all data is send wayt anouther data
                endcase
            end
        end
        
        always @(posedge clk_i_data)//resiveData
        begin : reciveDataFFT
            if(reset)   counterReciveDataFFT <= 0;
            else 
            begin
                if(counterReciveDataFFT < NFFT)
                begin
                    if(valid == 1'b1)//flag data is valid
                    begin
                        data_in_mas_i[counterReciveDataFFT[1:0]] <= data_in_i;
                        data_in_mas_q[counterReciveDataFFT[1:0]] <= data_in_q;
                        counterReciveDataFFT <= counterReciveDataFFT + 1;
                    end
                end
                else if (/*state == stateSummFFT*/flag_summ) counterReciveDataFFT <= 0;//когда все математические операции выполнены можно заново принимать данные
            end
        end
        
//        reg [DATA_FFT_SIZE-1:0] reg_data_out_i;
//        reg [DATA_FFT_SIZE-1:0] reg_data_out_q;
        
//        assign data_out_i = reg_data_out_i;
//        assign data_out_q = reg_data_out_q;

        assign data_out_i = counterSendData[0] ? data_out_mas_i[0] : data_out_mas_i[1];
        assign data_out_q = counterSendData[0] ? data_out_mas_q[0] : data_out_mas_q[1];
        
        always @(posedge clk)//send data
        begin : sendDataFFT
            if(state == stateComplete/*completeDone_r*/)//когда вые выполнено отправляю даннеы
            begin
                if((counterSendData < NFFT) & flag_ready_recive)
                begin : FLAG_RECIVE_FFT
                    counterSendData <= counterSendData + 1;
//                    reg_data_out_i <= data_out_mas_i[counterSendData];
//                    reg_data_out_q <= data_out_mas_q[counterSendData];
                end
            end
            else counterSendData <= 0;//когда 
        end
        
        always @(posedge clk)//flag complete
        begin : flagComplete
            if(state == stateComplete/*completeDone_r*/)  complete <= 1'b1;
            else                        complete <= 1'b0;
        end
        
        //можно ускорить на 1 такт
        //flag can read data
        reg reg_flag_wayt_data = 1'b1;
        assign flag_wayt_data = reg_flag_wayt_data;
        always @ (posedge clk)
        begin
//            if(/*(counterReciveDataFFT < 2)*/(counterReciveDataFFT[1] == 1'b0))  reg_flag_wayt_data <= 1'b1;
//            else                            reg_flag_wayt_data <= 1'b0;

            reg_flag_wayt_data <= !counterReciveDataFFT[1];
        end
        
    end
    else if((MIN_FFT_x4==1) && (NFFT == 4))
    begin
    
        reg [DATA_FFT_SIZE-1:0] data_out_mas_i [3:0];
        reg [DATA_FFT_SIZE-1:0] data_out_mas_q [3:0];
        
        always @(posedge clk)//fms
        begin : FMS_FFT
            if(reset)   state <= stateWaytData;
            else 
            begin
                //машина конечных состоояние по состоянию данных
                case(state)
                stateWaytData : if(counterReciveDataFFT == 4) state <= stateComplete;//сдесь можно ускорить на 1 такт
                stateComplete : if((counterSendData == 3) & flag_ready_recive)   state <= stateWaytData;//when all data is send wayt anouther data
                endcase
            end
        end
        
        //TYPE = "forvard",/*forvard invers*/
        localparam numm_1 = TYPE=="forvard" ? 1 : TYPE=="invers" ? 3 : 1;
        localparam numm_3 = TYPE=="forvard" ? 3 : TYPE=="invers" ? 1 : 3;
        
        always @(posedge clk_i_data)//resiveData
        begin : reciveDataFFT
            if(reset)   counterReciveDataFFT <= 0;
            else if(stateWaytData == stateWaytData)
            begin
                if(counterReciveDataFFT < NFFT)
                begin
                    if(valid == 1'b1)//flag data is valid
                    begin
                        counterReciveDataFFT <= counterReciveDataFFT + 1;
                        case(counterReciveDataFFT)
                        0:
                        begin
                            data_out_mas_i[0] = data_in_i;
                            data_out_mas_q[0] = data_in_q;
                            
                            data_out_mas_i[numm_1] = data_in_i;
                            data_out_mas_q[numm_1] = data_in_q;
                            
                            data_out_mas_i[2] = data_in_i;
                            data_out_mas_q[2] = data_in_q;
                            
                            data_out_mas_i[numm_3] = data_in_i;
                            data_out_mas_q[numm_3] = data_in_q;
                        end
                        1:
                        begin
                            data_out_mas_i[0] = data_out_mas_i[0] + data_in_i;
                            data_out_mas_q[0] = data_out_mas_q[0] + data_in_q;
                            
                            data_out_mas_i[numm_1] = data_out_mas_i[numm_1] + data_in_q;
                            data_out_mas_q[numm_1] = data_out_mas_q[numm_1] - data_in_i;
                            
                            data_out_mas_i[2] = data_out_mas_i[2] - data_in_i;
                            data_out_mas_q[2] = data_out_mas_q[2] - data_in_q;
                            
                            data_out_mas_i[numm_3] = data_out_mas_i[numm_3] - data_in_q;
                            data_out_mas_q[numm_3] = data_out_mas_q[numm_3] + data_in_i;
                        end
                        2:
                        begin
                            data_out_mas_i[0] = data_out_mas_i[0] + data_in_i;
                            data_out_mas_q[0] = data_out_mas_q[0] + data_in_q;
                            
                            data_out_mas_i[numm_1] = data_out_mas_i[numm_1] - data_in_i;
                            data_out_mas_q[numm_1] = data_out_mas_q[numm_1] - data_in_q;
                            
                            data_out_mas_i[2] = data_out_mas_i[2] + data_in_i;
                            data_out_mas_q[2] = data_out_mas_q[2] + data_in_q;
                            
                            data_out_mas_i[numm_3] = data_out_mas_i[numm_3] - data_in_i;
                            data_out_mas_q[numm_3] = data_out_mas_q[numm_3] - data_in_q;
                        end
                        3:
                        begin
                            data_out_mas_i[0] = data_out_mas_i[0] + data_in_i;
                            data_out_mas_q[0] = data_out_mas_q[0] + data_in_q;
                            
                            data_out_mas_i[numm_1] = data_out_mas_i[numm_1] - data_in_q;
                            data_out_mas_q[numm_1] = data_out_mas_q[numm_1] + data_in_i;
                            
                            data_out_mas_i[2] = data_out_mas_i[2] - data_in_i;
                            data_out_mas_q[2] = data_out_mas_q[2] - data_in_q;
                            
                            data_out_mas_i[numm_3] = data_out_mas_i[numm_3] + data_in_q;
                            data_out_mas_q[numm_3] = data_out_mas_q[numm_3] - data_in_i;
                        end
                        
                        endcase
                        
                        
                    end
                end
                else counterReciveDataFFT <= 0;//когда все математические операции выполнены можно заново принимать данные
            end
        end
        
        reg [DATA_FFT_SIZE-1:0] reg_data_out_i;
        reg [DATA_FFT_SIZE-1:0] reg_data_out_q;
        
        assign data_out_i = reg_data_out_i;
        assign data_out_q = reg_data_out_q;
        
        always @(posedge clk)//send data
        begin : sendDataFFT
            if(state == stateComplete/*completeDone_r*/)//когда вые выполнено отправляю даннеы
            begin
                if((counterSendData < NFFT) & flag_ready_recive)
                begin : FLAG_RECIVE_FFT
                    counterSendData <= counterSendData + 1;
                    reg_data_out_i <= data_out_mas_i[counterSendData];
                    reg_data_out_q <= data_out_mas_q[counterSendData];
                end
            end
            else counterSendData <= 0;//когда 
        end

        
        reg reg_flag_wayt_data = 1'b1;
        assign flag_wayt_data = reg_flag_wayt_data;
        always @ (posedge clk)
        begin : FLAG_RECIVE_FFT
            if((counterReciveDataFFT < 4))  reg_flag_wayt_data <= 1'b1;
            else                            reg_flag_wayt_data <= 1'b0;

        end
        
        always @(posedge clk)//flag complete
        begin : flagComplete
            if(state == stateComplete)  complete <= 1'b1;
            else                        complete <= 1'b0;
        end
        
        
    end
    else
    begin
        
        wire [SIZE_OUT_DATA_S_FFT-1:0] data_from_secondFFT_chet_i;
        wire [SIZE_OUT_DATA_S_FFT-1:0] data_from_secondFFT_chet_q;
        wire [SIZE_OUT_DATA_S_FFT-1:0] data_from_secondFFT_Nchet_i;
        wire [SIZE_OUT_DATA_S_FFT-1:0] data_from_secondFFT_Nchet_q;
        wire flag_complete_chet;
        wire flag_complete_Nchet;

        
        //*****extern memory for massive data*****
        //after summing
//        (* ram_style="register" *) reg [DATA_FFT_SIZE-1:0] data_summ_out_mas_i_r [NFFT-1:0];
        //chet
        reg _data_summ_out_mas_i_r_writeEn_c = 1'b0;
        reg [SIZE_BUFFER-2:0] _data_summ_out_mas_i_r_addr_c/* = {(SIZE_BUFFER-1){1'b0}}*/;
        reg [SIZE_BUFFER-2:0] _data_summ_out_mas_i_r_addr_r_c/* = {(SIZE_BUFFER-1){1'b0}}*/;
        reg [SIZE_OUT_DATA-1:0] _data_summ_out_mas_i_r_writeData_c;
        wire [SIZE_OUT_DATA-1:0] _data_summ_out_mas_i_r_readData_c;
        
        //nchet
        reg _data_summ_out_mas_i_r_writeEn_Nc = 1'b0;
        reg [SIZE_BUFFER-2:0] _data_summ_out_mas_i_r_addr_Nc/* = {(SIZE_BUFFER-1){1'b0}}*/;
        reg [SIZE_BUFFER-2:0] _data_summ_out_mas_i_r_addr_r_Nc/* = {(SIZE_BUFFER-1){1'b0}}*/;
        reg [SIZE_OUT_DATA-1:0] _data_summ_out_mas_i_r_writeData_Nc;
        wire [SIZE_OUT_DATA-1:0] _data_summ_out_mas_i_r_readData_Nc;
        
        memForFFT #(.DATA_FFT_SIZE(SIZE_OUT_DATA), .SIZE_BITS_ADDRES(SIZE_BUFFER-1)/*, .name("123")*/)//? SIZE_BUFFER : SIZE_BUFFER-1
        data_summ_out_mas_i_r
        (
            .clk(clk),
            .writeEn(_data_summ_out_mas_i_r_writeEn_c),
            .readEn(flag_ready_recive),
            .addr(_data_summ_out_mas_i_r_addr_c),
            .addr_r(_data_summ_out_mas_i_r_addr_r_c),
            .inData(_data_summ_out_mas_i_r_writeData_c),
            .outData(_data_summ_out_mas_i_r_readData_c),
            .writeEn2(_data_summ_out_mas_i_r_writeEn_Nc),
            .readEn2(flag_ready_recive),
            .addr2(_data_summ_out_mas_i_r_addr_Nc),
            .addr_r2(_data_summ_out_mas_i_r_addr_r_Nc),
            .inData2(_data_summ_out_mas_i_r_writeData_Nc),
            .outData2(_data_summ_out_mas_i_r_readData_Nc)
        );
//        reg [DATA_FFT_SIZE-1:0] data_summ_out_mas_i_r [NFFT-1:0];
//        (* ram_style="register" *) reg [DATA_FFT_SIZE-1:0] data_summ_out_mas_q_r [NFFT-1:0];
        //chet
        reg _data_summ_out_mas_q_r_writeEn_c = 1'b0;
        reg [SIZE_BUFFER-2:0] _data_summ_out_mas_q_r_addr_c = {(SIZE_BUFFER-1){1'b0}};
        reg [SIZE_BUFFER-2:0] _data_summ_out_mas_q_r_addr_r_c = {(SIZE_BUFFER-1){1'b0}};
        reg [SIZE_OUT_DATA-1:0] _data_summ_out_mas_q_r_writeData_c;
        wire [SIZE_OUT_DATA-1:0] _data_summ_out_mas_q_r_readData_c;
        
        //nchet
        reg _data_summ_out_mas_q_r_writeEn_Nc = 1'b0;
        reg [SIZE_BUFFER-2:0] _data_summ_out_mas_q_r_addr_Nc = {(SIZE_BUFFER-1){1'b0}};
        reg [SIZE_BUFFER-2:0] _data_summ_out_mas_q_r_addr_r_Nc = {(SIZE_BUFFER-1){1'b0}};
        reg [SIZE_OUT_DATA-1:0] _data_summ_out_mas_q_r_writeData_Nc;
        wire [SIZE_OUT_DATA-1:0] _data_summ_out_mas_q_r_readData_Nc;
        memForFFT #(.DATA_FFT_SIZE(SIZE_OUT_DATA), .SIZE_BITS_ADDRES(SIZE_BUFFER-1))//? SIZE_BUFFER : SIZE_BUFFER-1
        data_summ_out_mas_q_r
        (
            .clk(clk),
            .writeEn(_data_summ_out_mas_q_r_writeEn_c),
            .readEn(flag_ready_recive),
            .addr(_data_summ_out_mas_q_r_addr_c),
            .addr_r(_data_summ_out_mas_q_r_addr_r_c),
            .inData(_data_summ_out_mas_q_r_writeData_c),
            .outData(_data_summ_out_mas_q_r_readData_c),
            .writeEn2(_data_summ_out_mas_q_r_writeEn_Nc),
            .readEn2(flag_ready_recive),
            .addr2(_data_summ_out_mas_q_r_addr_Nc),
            .addr_r2(_data_summ_out_mas_q_r_addr_r_Nc),
            .inData2(_data_summ_out_mas_q_r_writeData_Nc),
            .outData2(_data_summ_out_mas_q_r_readData_Nc)
        );
//        reg [DATA_FFT_SIZE-1:0] data_summ_out_mas_q_r [NFFT-1:0];
        
        reg valid_data_chet;
        reg valid_data_Nchet;
        
        wire [2:0] stateFFTChet;
        wire [2:0] stateFFTNChet;
        reg [SIZE_BUFFER-1:0] counterReadData_chet;
        reg [SIZE_BUFFER-1:0] counterReadData_Nchet;
        reg [SIZE_BUFFER-1:0] counterMultData = 0;
        reg [SIZE_BUFFER-1:0] counterMultData2 = 0;
        reg mutDone = 1'b0;
        
        reg validChet = 1'b1;
        reg validNChet = 1'b0;
        
        reg resiveFromChet = 1'b1;
        reg resiveFromNChet = 1'b1;
        
        
        wire flag_wayt_data_chet;
        wire flag_wayt_data_Nchet;
        
        
        
        initial
        begin
            valid_data_chet = 0;
            valid_data_Nchet = 0;
            counterReadData_chet = 0;
            counterReadData_Nchet = 0;
        end
        //recursi
        //0 2 4...
        myFFT #(.SIZE_BUFFER(SIZE_BUFFER-1),.DATA_FFT_SIZE(DATA_FFT_SIZE), .FAST(FAST), .TYPE(TYPE), .COMPENS_FP(COMPENS_FP), .MIN_FFT_x4(MIN_FFT_x4))
        dataChetn(
            .clk(clk),
            .reset(reset),
            .valid(/*validChet & valid*/(counterReciveDataFFT[0] == 1'b0) & (/*state == stateWaytData*//*flag_wayt_data*/1) & valid),
            .clk_i_data(clk_i_data),
            .data_in_i(data_in_i),
            .data_in_q(data_in_q),
            .clk_o_data(),
            .data_out_i(data_from_secondFFT_chet_i),
            .data_out_q(data_from_secondFFT_chet_q),
            .complete(flag_complete_chet),
            .stateFFT(stateFFTChet),
            .flag_ready_recive(resiveFromChet),/*input flags for output data*/
            .flag_wayt_data(flag_wayt_data_chet)/*flag can recive daat data*/
        );
        //1 3 5...
        myFFT #(.SIZE_BUFFER(SIZE_BUFFER-1),.DATA_FFT_SIZE(DATA_FFT_SIZE), .FAST(FAST), .TYPE(TYPE), .COMPENS_FP(COMPENS_FP), .MIN_FFT_x4(MIN_FFT_x4))
        dataNChetn(
            .clk(clk),
            .reset(reset),
            .valid(/*validNChet & valid*/(counterReciveDataFFT[0] == 1'b1) & (/*state == stateWaytData*//*flag_wayt_data*/1)  & valid),
            .clk_i_data(clk_i_data),
            .data_in_i(data_in_i),
            .data_in_q(data_in_q),
            .clk_o_data(),
            .data_out_i(data_from_secondFFT_Nchet_i),
            .data_out_q(data_from_secondFFT_Nchet_q),
            .complete(flag_complete_Nchet),
            .stateFFT(stateFFTNChet),
            .flag_ready_recive(resiveFromNChet),/*input flags for output data*/
            .flag_wayt_data(flag_wayt_data_Nchet)/*flag can recive daat data*/
        );
        
        //флаг о том что можно принимать данные изход из состояние нижних ффт и исходя из сумм ффт
//        assign flag_wayt_data = state == stateWaytData ? 1'b1 : 
//                counterReciveDataFFT[0] == 1'b0 ? flag_wayt_data_chet : flag_wayt_data_Nchet /*& (!(flag_complete_chet & flag_complete_Nchet))*/;

//        assign flag_wayt_data = state == stateWaytData ? 1'b1 
//                : (/*state == stateWaytFFT ? 1'b0 :*/ ((flag_wayt_data_chet & flag_wayt_data_Nchet & (!(flag_complete_chet | flag_complete_Nchet)))));

        reg reg_flag_wayt_data = 1'b1;
        
//        assign flag_wayt_data = state == stateWaytData ? 1'b1 
//                : (state == stateWaytFFT ? 1'b0 : (state == stateWriteData ? 1'b0 
//                : reg_flag_wayt_data));

        assign flag_wayt_data = reg_flag_wayt_data;
        
        always @(posedge clk)
        begin
//            if((counterMultData2 == /*NFFT/4*/1))   reg_flag_wayt_data <= 1'b1;//FFT64 + 0
//            if((counterMultData2 == /*NFFT/4*/1) | ((resiveFromNChet == 1'b0) & (counterMultData2 == 0)))   reg_flag_wayt_data <= 1'b1;//FFT64+5 //неболоьшое ускорении, но при FFT8 - 16 может криво работать
            if((counterMultData2 == /*NFFT/4*/1) | (flag_complete_Nchet & (counterMultData2 == 0)))   reg_flag_wayt_data <= 1'b1;//FFT64+6
            else if((/*flag_wayt_data_chet | */flag_wayt_data_Nchet) == 1'b0) reg_flag_wayt_data <= 1'b0;
//            reg_flag_wayt_data <= flag_wayt_data_chet & flag_wayt_data_Nchet & (!(flag_complete_chet | flag_complete_Nchet));
        end
        
        reg completeDoneChet = 1'b0;
        reg completeDoneNChet = 1'b0;
        
//        wire stateToComplete = mutDone;//флаг перехода в состояние отправки данных
        wire stateToComplete = counterMultData2 == (NFFT/2 - NFFT/12);//флаг перехода в состояние отправки данных
        //данные можно уже выкидывать когда досчитываються последнии 20%
        //т.е. при FFT 256 можно выкидывать данные когда посчиталось ~100 
        
        always @(posedge clk)//fms
        begin : FMS_FFT
            if(reset)   state <= stateWaytData;
            else
            begin
                //машина конечных состоояние по состоянию данных
                case(state)
                stateWaytData:  if(counterReciveDataFFT == NFFT)    state <= stateWaytFFT;  else if(stateToComplete)   state <= stateComplete; 
                stateWaytFFT:   if(completeDoneChet & completeDoneNChet)   state <= stateWriteData;/*считывания данных с FFT второго уровня*/ else if(stateToComplete)   state <= stateComplete; 
                stateWriteData: if({flag_complete_chet, flag_complete_Nchet} == 2'b00)  state <= stateSummFFT/*stateComplete*/; else if(stateToComplete)   state <= stateComplete; 
                stateSummFFT:   if(stateToComplete)     state <= stateComplete;
                stateComplete:  if((counterSendData == (NFFT-2))/*возможно 1*/ & flag_ready_recive)   state <= stateWaytData;//when all data is send wayt anouther data
                endcase
            end
        end
        
        always @(posedge clk)
        begin : waitCompleteSecondFFT
            if(reset)  
            begin
                completeDoneChet <= 1'b0;
                completeDoneNChet <= 1'b0;
            end
            else
            begin
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
            
        end
        
            /*****************************SLOW FFT*****************************/
            reg enMult = 1'b0;
            reg [SIZE_OUT_DATA_S_FFT-1:0] multData_i;
            reg [SIZE_OUT_DATA_S_FFT-1:0] multData_q;
            reg [15:0] phi = 16'd0;
            
            wire [SIZE_OUT_DATA-1:0] res_m_phi_i;
            wire [SIZE_OUT_DATA-1:0] res_m_phi_q;
            wire [SIZE_OUT_DATA-1:0] res_p_phi_i;
            wire [SIZE_OUT_DATA-1:0] res_p_phi_q;
            wire dataComplete;
            
            multComplexE #(.SIZE_DATA_FI(SIZE_BUFFER)/*LOG2(NFFT)*/, .DATA_FFT_SIZE(SIZE_OUT_DATA_S_FFT), .FAST(FAST), .TYPE(TYPE), .COMPENS_FP(COMPENS_FP))
            _multComplexE
                (
                .clk(clk),
                .en(enMult),
                .in_data_i(multData_i),
                .in_data_q(multData_q),
                .fi_deg(phi),
                .out_data_minus_i(res_m_phi_i),
                .out_data_minus_q(res_m_phi_q),
                .out_data_plus_i(res_p_phi_i),
                .out_data_plus_q(res_p_phi_q),
                .outValid(dataComplete)
                );
                
            wire [SIZE_OUT_DATA-1:0] out_summ_0__NFFT_2_i;
            wire [SIZE_OUT_DATA-1:0] out_summ_0__NFFT_2_q;
            wire [SIZE_OUT_DATA-1:0] out_summ_NFFT_2__NFFT_i;
            wire [SIZE_OUT_DATA-1:0] out_summ_NFFT_2__NFFT_q;
            
            reg [SIZE_OUT_DATA_S_FFT-1:0] data_summ_chet_i = 0;
            reg [SIZE_OUT_DATA_S_FFT-1:0] data_summ_chet_q = 0;
            
            wire [SIZE_OUT_DATA-1:0] w_data_summ_chet_i;
            wire [SIZE_OUT_DATA-1:0] w_data_summ_chet_q;
            
            if((COMPENS_FP == "add") && (SIZE_OUT_DATA > SIZE_OUT_DATA_S_FFT))//если разная разрядность то должен учитывать знак
            begin
                assign w_data_summ_chet_i[SIZE_OUT_DATA-1:1] = data_summ_chet_i[SIZE_OUT_DATA_S_FFT-1:0];
                assign w_data_summ_chet_q[SIZE_OUT_DATA-1:1] = data_summ_chet_q[SIZE_OUT_DATA_S_FFT-1:0];
                
                assign w_data_summ_chet_i[0] = 0;
                assign w_data_summ_chet_q[0] = 0;  
            end
            else
            begin
                assign w_data_summ_chet_i = data_summ_chet_i;
                assign w_data_summ_chet_q = data_summ_chet_q;
            end
                
            summComplex #(.DATA_FFT_SIZE(SIZE_OUT_DATA)) 
            _summ0__NFFT_2(
                .clk(clk),
                .en(/*state == stateSummFFT*/1'b1),
                .data_in0_i(w_data_summ_chet_i),
                .data_in0_q(w_data_summ_chet_q),
                .data_in1_i(res_m_phi_i),
                .data_in1_q(res_m_phi_q),
                .data_out0_i(out_summ_0__NFFT_2_i),
                .data_out0_q(out_summ_0__NFFT_2_q)
            );
            summComplex #(.DATA_FFT_SIZE(SIZE_OUT_DATA)) 
            _summNFFT_2__NFFT(
                .clk(clk),
                .en(/*state == stateSummFFT*/1'b1),
                .data_in0_i(w_data_summ_chet_i),
                .data_in0_q(w_data_summ_chet_q),
                .data_in1_i(res_p_phi_i),
                .data_in1_q(res_p_phi_q),
                .data_out0_i(out_summ_NFFT_2__NFFT_i),
                .data_out0_q(out_summ_NFFT_2__NFFT_q)
            );
            

            
            reg beginReadSummData = 1'b0;
            reg flagWayt = 1'b1;//flag ожидать пока начнеться умножения
            
            reg old_flag_complete_chet = 1'b0;
            reg old_flag_complete_Nchet = 1'b0;
            
                
            always @(posedge clk)//summ FFT
            begin : summFFT
                
                if(reset)
                begin
                    resiveFromChet <= 1'b1;
                    resiveFromNChet <= 1'b1;
                    enMult <= 1'b0;
                    counterMultData2 <= 0;
                end
                else
                begin
                    if(flag_complete_chet | old_flag_complete_chet)
                    begin
                        if(resiveFromChet) 
                        begin 
                            if(flag_complete_chet)   old_flag_complete_chet <= 1'b1;
                        end
                        else
                        begin
                            if({dataComplete, enMult, flagWayt, flag_complete_chet} == 4'b1000)
                            begin
                                if(counterMultData2 == (NFFT/2 - 1)) old_flag_complete_chet <= 0;
                            end
                        end
                        
                        
                        if(resiveFromChet) data_summ_chet_i <= data_from_secondFFT_chet_i;
                        if(resiveFromChet) data_summ_chet_q <= data_from_secondFFT_chet_q;
                        
                        if(resiveFromChet) flagWayt <= 1'b1;
                        
                        if(resiveFromChet) resiveFromChet <= 1'b0;
                        
//                        if(resiveFromChet) 
//                        begin
//                            if(delay_resiveFromChet) resiveFromChet <= 1'b0;
//                            else if(delay_flag_complete_chet) resiveFromChet <= 1'b0;
//                        end
                        else
                        begin
                            if(flagWayt)    flagWayt <= /*dataComplete*//*0*/resiveFromNChet;//сначало жду пока опуститься флаг что умножения началось
                            else if({dataComplete, enMult} == 2'b10)
                            begin
                                resiveFromChet <= 1'b1;
                            end
                        end
                    end
                    
                    if(flag_complete_Nchet | old_flag_complete_Nchet)
                    begin
                    
                        if(resiveFromNChet) 
                        begin 
                            if(flag_complete_Nchet)   old_flag_complete_Nchet <= 1'b1;
                        end
                        else
                        begin
                            if({dataComplete, enMult, flag_complete_Nchet} == 3'b100)
                            begin
                                if(counterMultData2 == (NFFT/2 - 1)) old_flag_complete_Nchet <= 0;
                            end
                        end
//                        if(flag_complete_Nchet)                 old_flag_complete_Nchet <= 1'b1;
//                        else if(counterMultData2 >= (NFFT/2))                 old_flag_complete_Nchet <= 1'b0;
                        
                        if(resiveFromNChet) multData_i <= data_from_secondFFT_Nchet_i;
                        if(resiveFromNChet) multData_q <= data_from_secondFFT_Nchet_q;
                        
                        if(resiveFromNChet) enMult <= 1'b1;
                        
                        if(resiveFromNChet) if(mutDone)    counterMultData2 <= counterMultData2 - NFFT/2;
                        
                        if(resiveFromNChet) resiveFromNChet <= 1'b0;
                        else
                        begin
                            enMult <= 1'b0;
                            if({dataComplete, enMult} == 2'b10)
                            begin
                                resiveFromNChet <= 1'b1;
                                if(mutDone)     counterMultData2 <= counterMultData2 - NFFT/2 + 1;
                                else            counterMultData2 <= counterMultData2 + 1;
                            end
                            else if(mutDone)    counterMultData2 <= counterMultData2 - NFFT/2;//TODO возможно обнулить
                        end
                    end
                    else if(mutDone)    counterMultData2 <= counterMultData2 - NFFT/2;//TODO возможно обнулить
                end
            
                
                if(mutDone | reset)
                begin
                    mutDone <= 1'b0;
                    counterMultData <= 0;
                    _data_summ_out_mas_i_r_writeEn_c <= 1'b0; 
                    _data_summ_out_mas_i_r_writeEn_Nc <= 1'b0; 
                    _data_summ_out_mas_q_r_writeEn_c <= 1'b0; 
                    _data_summ_out_mas_q_r_writeEn_Nc <= 1'b0;
                end
                else
                begin
                    if(counterMultData2 > counterMultData) 
                    begin
                        phi <= phi + 1;
                        counterMultData <= counterMultData + 1;
    //                            data_summ_out_mas_i_r[counterMultData2] <= out_summ_0__NFFT_2_i;
                        _data_summ_out_mas_i_r_addr_c <= counterMultData[SIZE_BUFFER-2:0];
                        _data_summ_out_mas_i_r_writeData_c <= out_summ_0__NFFT_2_i;
                        _data_summ_out_mas_i_r_writeEn_c <= 1'b1;
                        
    //                            data_summ_out_mas_q_r[counterMultData2] <= out_summ_0__NFFT_2_q;
                        _data_summ_out_mas_q_r_addr_c <= counterMultData[SIZE_BUFFER-2:0];
                        _data_summ_out_mas_q_r_writeData_c <= out_summ_0__NFFT_2_q;
                        _data_summ_out_mas_q_r_writeEn_c <= 1'b1;
                        
    //                            data_summ_out_mas_i_r[counterMultData2 + NFFT/2] <= out_summ_NFFT_2__NFFT_i;
                        _data_summ_out_mas_i_r_addr_Nc <= counterMultData[SIZE_BUFFER-2:0];
                        _data_summ_out_mas_i_r_writeData_Nc <= out_summ_NFFT_2__NFFT_i;
                        _data_summ_out_mas_i_r_writeEn_Nc <= 1'b1;
                        
    //                            data_summ_out_mas_q_r[counterMultData2 + NFFT/2] <= out_summ_NFFT_2__NFFT_q;
                        _data_summ_out_mas_q_r_addr_Nc <= counterMultData[SIZE_BUFFER-2:0];
                        _data_summ_out_mas_q_r_writeData_Nc <= out_summ_NFFT_2__NFFT_q;
                        _data_summ_out_mas_q_r_writeEn_Nc <= 1'b1;
                    end
                    else
                    begin
                        _data_summ_out_mas_i_r_writeEn_c <= 1'b0; 
                        _data_summ_out_mas_i_r_writeEn_Nc <= 1'b0; 
                        _data_summ_out_mas_q_r_writeEn_c <= 1'b0; 
                        _data_summ_out_mas_q_r_writeEn_Nc <= 1'b0;
                    end
                    
                    
                    if(counterMultData == NFFT/2)  mutDone <= 1'b1; 
                end
            end
            /*****************************END SLOW FFT*****************************/
        

        always @ (posedge clk_i_data)//resiveData counter
        begin : reciveFFT
            if(reset)  
            begin
                counterReciveDataFFT <= 1'b0;
            end
            else
            begin
                if ((/*flag_wayt_data_chet | */flag_wayt_data_Nchet) == 1'b0) counterReciveDataFFT <= 0;
                else if(counterReciveDataFFT < NFFT)
                begin
                    if(valid & flag_wayt_data)//flag data is valid
                    begin
                        counterReciveDataFFT <= counterReciveDataFFT + 1;
                    end
                end
            end
        end
        
        
        reg [SIZE_BUFFER:0] counterSendData2;
        reg flagTimerWrite = 1'b0;//delay timer
        
                            
        assign data_out_i = counterSendData[SIZE_BUFFER-1] ? _data_summ_out_mas_i_r_readData_Nc : _data_summ_out_mas_i_r_readData_c;
                    
        assign data_out_q = counterSendData[SIZE_BUFFER-1] ? _data_summ_out_mas_q_r_readData_Nc : _data_summ_out_mas_q_r_readData_c;
        
//        assign _counterOutData = counterSendData2;
        always @(posedge clk)//send data
        begin : sendDataFFT
            if((state == stateComplete) /*| completeDone_r*/ & flag_ready_recive)//когда вые выполнено отправляю даннеы
            begin
//                if(counterSendData2 <= NFFT)
//                    counterSendData2 <= counterSendData2 + 1;
                if(counterSendData < NFFT)
                begin
                    flagTimerWrite <= 1'b1;
                    if(counterSendData2 < NFFT) counterSendData2 <= counterSendData2 + 1;
                    if(flagTimerWrite)  counterSendData <= counterSendData + 1;
                   
                    _data_summ_out_mas_i_r_addr_r_c <= counterSendData2[SIZE_BUFFER-2:0];//на такте 0 выставляеться таймер
                    _data_summ_out_mas_i_r_addr_r_Nc <= counterSendData2[SIZE_BUFFER-2:0];//на такте 0 выставляеться таймер
                    _data_summ_out_mas_q_r_addr_r_c <= counterSendData2[SIZE_BUFFER-2:0];//на такте 0 выставляеться таймер
                    _data_summ_out_mas_q_r_addr_r_Nc <= counterSendData2[SIZE_BUFFER-2:0];//на такте 0 выставляеться таймер
                end
            end
            else if(state != stateComplete) begin
                //чтобы по началу считывания я уже считывал с первого аддреса
                counterSendData2 <= 1;//когда 
                if(flag_ready_recive)   counterSendData <= 0;
                _data_summ_out_mas_i_r_addr_r_c <= 0;
                _data_summ_out_mas_i_r_addr_r_Nc <= 0;
                _data_summ_out_mas_q_r_addr_r_c <= 0;
                _data_summ_out_mas_q_r_addr_r_Nc <= 0;
                flagTimerWrite <= 1'b0;
            end
            else 
            begin
//                flagTimerWrite <= 1'b0;
            end
        end
        
        always @(posedge clk)//flag complete
        begin : flagComplete
            if(state == stateComplete/*completeDone_r*/ /*& (flagTimerWrite)*/)  complete <= 1'b1;
            else                        complete <= 1'b0;
        end
    end
    endgenerate 
    
endmodule