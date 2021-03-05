`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.11.2020 14:08:08
// Design Name: 
// Module Name: ofdm_frame_gen
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
//TODO add flag_wayt_data
module ofdm_frame_gen #(parameter MEMORY_SYZE = 16/*log2(mem size) or number of bits*/)(
        clk,
        en,
        reset,
        beginTX,
        valid,
        in_data,
        data_frame_size,
        modulation,
        i_wayt_read_data,
        flag_ready_read,
        out_data_i,
        out_data_q,
        tx_valid,
        done_transmit,
        o_state_OFDM,
        //debug
        d_FCH_data,
        d_fft_data_i,
        d_fft_data_q,
        d_in_fft_data_i,
        d_in_fft_data_q,
        d_complete_fft,
        d_ofdm_payload_valid
    );
    
    input clk;
    input en;
    input reset;
    input beginTX;
    input valid;
    input [7:0] in_data;
    input [7:0] data_frame_size;//количество отправляемых кадров с информауией
    input [2:0] modulation;//тип модуляции для данных
    input i_wayt_read_data;
    
    output flag_ready_read;//алаг о том что можно писать данные
    //отсчеты на выходк
    output [15:0] out_data_i;
    output [15:0] out_data_q; 
    output tx_valid;
    output reg done_transmit = 1'b0;
    output [3:0] o_state_OFDM;
    //debug
    output [7:0] d_FCH_data;
    output [15:0] d_fft_data_i;
    output [15:0] d_fft_data_q;
    output [15:0] d_in_fft_data_i;
    output [15:0] d_in_fft_data_q;
    output d_complete_fft;
    output d_ofdm_payload_valid;
    
    
    localparam SYMBOL_SIZE = 264;
    
    reg [3:0] state_OFDM = 0;
    assign o_state_OFDM = state_OFDM;
    
    localparam state_IDLE = 0;
    localparam state_short_preamble = 1;
    localparam state_long_preamble = 2;
//    localparam state_frame_FCH = 3;
    localparam state_frame_data = 4;//FCH and data in this state

    
    reg [15:0] data_symbols_counter = 0;
    
    wire [7:0] code_data;
    
    bypass_coder
    _coder(
        .clk(clk),
        .in_data(in_data),
        .out_data(code_data)
    );
    
    reg FCH_valid = 0;
    reg [7:0] FCH_data = 0;
    
    localparam FCH_modulation = `BPSK_MOD;
    reg [15:0] counter_FCH = 0;
    
    localparam subchanale_bitmap_used = 6'b000000;
    localparam repition_coding_indicator = 2'b00;
    localparam coding_indicator = 3'b000;
    
    wire ofdm_payload_gen_flag_ready_recive;
    reg old_ofdm_payload_gen_flag_ready_recive = 0;
    
    always @(posedge clk)
    begin
        if(reset)
        begin
            data_symbols_counter <= 0;
        end
        else if(state_OFDM == state_IDLE) begin end
        else
        begin
            old_ofdm_payload_gen_flag_ready_recive <= ofdm_payload_gen_flag_ready_recive;
            if({old_ofdm_payload_gen_flag_ready_recive,ofdm_payload_gen_flag_ready_recive} == 2'b10)//по изменению стостояния внизу был сформирован 1 пакет символов для fft
            begin
                if(data_symbols_counter < (data_frame_size + 1/*FCH symbols*/))  data_symbols_counter <= data_symbols_counter + 1; 
                else if(done_transmit)  data_symbols_counter <= 0;
            end
            else if(done_transmit)  data_symbols_counter <= 0;
        end
    end
    
    
    
    always @(posedge clk)
    begin : FCH_data_gen
        if(reset)
        begin
            counter_FCH <= 0;
            FCH_valid <= 1'b0;
        end
        else if(state_OFDM == state_IDLE) begin end
        else
        begin
            if(data_symbols_counter == 0)
            begin
                if(ofdm_payload_gen_flag_ready_recive)
                begin
                    FCH_valid <= 1'b1;
                    counter_FCH <= counter_FCH + 1;
                    case (counter_FCH)
                        0:FCH_data <= {repition_coding_indicator[0], 1'b0, subchanale_bitmap_used[5:0]};
                        1:FCH_data <= {data_frame_size[3:0], coding_indicator[2:0], repition_coding_indicator[1]};
                        2:FCH_data <= {4'b0000, data_frame_size[7:4]};
                        default:FCH_data <= 8'd0;
                    endcase
                end
                else    FCH_valid <= 1'b0;
            end
            else
            begin
                FCH_valid <= 1'b0;
                counter_FCH <= 0;
            end
        end
    end
    
    assign d_FCH_data = FCH_data;
    assign d_ofdm_payload_valid = data_symbols_counter == 0 ? FCH_valid : valid;
    
    wire symbol_out_done;
    (* dont_touch = "true", MARK_DEBUG="true" *)  wire [15:0] symbol_for_ifft_i;
    (* dont_touch = "true", MARK_DEBUG="true" *)  wire [15:0] symbol_for_ifft_q;
    wire fft_flag_wayt_data;
    wire ad_cp_wayt_recive_data;
    
    wire ofdm_payload_valid = data_symbols_counter == 0 ? FCH_valid : valid /*& flag_ready_read*/;
    wire [7:0] ofdm_payload_in_data = data_symbols_counter == 0 ? FCH_data : code_data;
    wire [2:0] ofdm_payload_modulation = data_symbols_counter == 0 ? FCH_modulation : modulation;
    
    assign flag_ready_read = data_symbols_counter == 0 ? 0 : data_symbols_counter < (data_frame_size + 1/*FCH symbols*/) ? ofdm_payload_gen_flag_ready_recive : 0;
    
    ofdm_payload_gen #(.DATA_SIZE(16))
    _ofdm_payload(
        .clk(clk),
        .reset(reset),
        .in_data_en(ofdm_payload_valid),
        .in_data(ofdm_payload_in_data),
        .modulation(ofdm_payload_modulation),
        .flag_ready_recive(ofdm_payload_gen_flag_ready_recive),
        .out_done(symbol_out_done),
        .out_data_i(symbol_for_ifft_i),
        .out_data_q(symbol_for_ifft_q),
        .counter_data(),
        .wayt_recive_data(fft_flag_wayt_data)
    );
    
    (* dont_touch = "true", MARK_DEBUG="true" *) wire [21:0] symbol_OFDM_i;
    (* dont_touch = "true", MARK_DEBUG="true" *) wire [21:0] symbol_OFDM_q;
    wire complete_fft;
    
    myFFT_R4
    #(.SIZE_BUFFER(8),/*log2(NFFT)*/
      .DATA_FFT_SIZE(16),
      .FAST("ultrafast"),/*slow fast ultrafast slow mult x1 fast mult x2 ultrafast mult x4*/
      .TYPE("invers"),/*forvard  invers*/
      .COMPENS_FP("add"),/*false true or add razrad*/
      .MIN_FFT_x4(1),
      .USE_ROUND(1),/*0 or 1*/
      .USE_DSP(1),/*0 or 1*/
      .PARAREL_FFT(9'b111111111)/*example 9'b 111000000 fft 256,128,64 matht pararel anaouther fft math conv; FFT 256 optimal time/resource 111100000 in OFDM systeam optimum 111000000*/
    )
    _fft_OFDM(
        .clk(clk),
        .reset(reset),
        .valid(symbol_out_done),
        .clk_i_data(clk),
        .data_in_i(symbol_for_ifft_i),
        .data_in_q(symbol_for_ifft_q),
        .clk_o_data(),
        .data_out_i(symbol_OFDM_i),
        .data_out_q(symbol_OFDM_q),
        .complete(complete_fft),
        .stateFFT(),
        .flag_wayt_data(fft_flag_wayt_data),
        .flag_ready_recive(ad_cp_wayt_recive_data)
    );
    
    wire add_cp_output_en;
    (* dont_touch = "true", MARK_DEBUG="true" *) wire [15:0] add_cp_out_data_i;
    (* dont_touch = "true", MARK_DEBUG="true" *) wire [15:0] add_cp_out_data_q;
    
    ofdm_add_cp #(.DATA_SIZE(16),
                  .SYMBOLS_SIZE(256),
                  .CP_LENGHT(8))
    _ofdm_add_cp(
        .clk(clk),
        .reset(reset),
        .in_data_en(complete_fft),
        .i_wayt_read_data(i_wayt_read_data),
        .in_data_i(symbol_OFDM_i[21:6]),
        .in_data_q(symbol_OFDM_q[21:6]),
        .output_en(add_cp_output_en),
        .out_data_i(add_cp_out_data_i),
        .out_data_q(add_cp_out_data_q),
        .o_wayt_recive_data(ad_cp_wayt_recive_data)
    );
    
    assign d_fft_data_i = symbol_OFDM_i[21:6];
    assign d_fft_data_q = symbol_OFDM_q[21:6];
    
    assign d_in_fft_data_i = symbol_for_ifft_i;
    assign d_in_fft_data_q = symbol_for_ifft_q;
    assign d_complete_fft = complete_fft;
    
    reg [8:0] preambleAddres = 0;
    wire [15:0] out_short_preamble_i;
    wire [15:0] out_short_preamble_q;
    
//    short_preamble_rom_my
//    _short_preamble(
//        .addr(preambleAddres[3:0]),
//        .dout_i(out_short_preamble_i),
//        .dout_q(out_short_preamble_q)
//    );
    ofdm_preamble #(.FILE_DATA_I("PA_I.mem"), .FILE_DATA_Q("PA_Q.mem"))
    _short_preamble(
        .clk(clk),
        .addr(preambleAddres),
        .en(i_wayt_read_data),
        .dout_i(out_short_preamble_i),
        .dout_q(out_short_preamble_q)
    );
    
    
    wire [15:0] out_long_preamble_i;
    wire [15:0] out_long_preamble_q;
    
//    long_preamble_rom_my
//    _long_preamble
//    (
//        .addr(preambleAddres),
//        .dout_i(out_long_preamble_i),
//        .dout_q(out_long_preamble_q)
//    );
    ofdm_preamble #(.FILE_DATA_I("PB_I.mem"), .FILE_DATA_Q("PB_Q.mem"))
    _long_preamble(
        .clk(clk),
        .addr(preambleAddres),
        .en(i_wayt_read_data),
        .dout_i(out_long_preamble_i),
        .dout_q(out_long_preamble_q)
    );
    
//    reg [64*10-1:0] longPreamble;
//    reg [64*2-1:0]  shortPreamble;
    
//    reg beginTransmite = 1;
    
        
    reg out_valid_reg = 1'b0;
    assign tx_valid = out_valid_reg & i_wayt_read_data;
    
    always @(posedge clk)
    begin
        if((state_OFDM == state_IDLE) | reset)   
        begin
//            addres_write_mem <= 0;
//            write_en_mem <= 1'b0;
//            out_valid_reg <= 1'b0;
//            preambleAddres <= 0;
        end
    end
    
    //TX
    reg [15:0] symbols_counter = 0;
    reg [15:0] counter_sample = 0;
    reg flag_reset_counters = 1'b0;
    
    
    
    //TX
    always @(posedge clk)
    begin
        if(flag_reset_counters | reset)
        begin
            counter_sample <= 0;
            symbols_counter <= 0;
            flag_reset_counters <= 1'b0;
            done_transmit <= 1'b0;
        end
        else
        begin
        if(i_wayt_read_data)
        begin
            if(state_OFDM == state_frame_data)
            begin
                if(counter_sample < SYMBOL_SIZE)    begin  if(add_cp_output_en) counter_sample <= counter_sample + 1;end
                else                                counter_sample <= 0;
                
                
                if(counter_sample == SYMBOL_SIZE)       symbols_counter <= symbols_counter + 1;
                
                if(symbols_counter == (data_frame_size + 1/*FCH symbols*/))  flag_reset_counters <= 1'b1;
                if(symbols_counter == (data_frame_size + 1/*FCH symbols*/))  done_transmit <= 1'b1;
            end
            else
            begin
                counter_sample <= 0;
                symbols_counter <= 0;
                flag_reset_counters <= 1'b0;
                done_transmit <= 1'b0;
            end
        end
        end
    end
    
    reg [15:0] add_cp_out_data_i_d1;
    reg [15:0] add_cp_out_data_q_d1;
    always @(posedge clk)
    begin
        if(i_wayt_read_data) begin
        add_cp_out_data_i_d1 <= add_cp_out_data_i;
        add_cp_out_data_q_d1 <= add_cp_out_data_q;
        end
    end
    
    assign out_data_i = state_OFDM == state_short_preamble ? out_short_preamble_i : state_OFDM == state_long_preamble ? out_long_preamble_i : state_OFDM == state_frame_data ? add_cp_out_data_i_d1 : 0;
    assign out_data_q = state_OFDM == state_short_preamble ? out_short_preamble_q : state_OFDM == state_long_preamble ? out_long_preamble_q : state_OFDM == state_frame_data ? add_cp_out_data_q_d1 : 0;
    
    //generate data
    always @(posedge clk)
    begin
        if(reset)   
        begin
            state_OFDM <= state_IDLE;
            out_valid_reg <= 1'b0; 
            preambleAddres <= 0; 
        end
        else
        begin
        if(i_wayt_read_data)
        begin
            case(state_OFDM)
            state_IDLE :
                begin
                    out_valid_reg <= 1'b0; 
                    preambleAddres <= 0;   
                    if(beginTX)  state_OFDM <= state_short_preamble; 
                end
            
            state_short_preamble:
                begin
                    if(preambleAddres < 256)
                    begin
                        preambleAddres <= preambleAddres + 1;
//                        out_data_i <= out_short_preamble_i;
//                        out_data_q <= out_short_preamble_q;
                        out_valid_reg <= 1'b1;
                    end
                    else
                    begin 
                        preambleAddres <= 0;
                        state_OFDM <= state_long_preamble;
                        out_valid_reg <= 1'b0;
                    end
                end
                
            state_long_preamble:
                begin
                    if(preambleAddres < 256)
                    begin
                        preambleAddres <= preambleAddres + 1;
//                        out_data_i <= out_long_preamble_i;
//                        out_data_q <= out_long_preamble_q;
                        out_valid_reg <= 1'b1;
                    end
                    else
                    begin 
                        preambleAddres <= 0;
                        state_OFDM <= state_frame_data;
                        out_valid_reg <= 1'b0;
                    end
                end
            state_frame_data:
                begin
                    if(add_cp_output_en)
                    begin
//                        out_data_i <= add_cp_out_data_i;
//                        out_data_q <= add_cp_out_data_q;
                        out_valid_reg <= 1'b1;
                    end
                    else
                    begin
                        out_valid_reg <= 1'b0;
                    end
                    
                    if(flag_reset_counters) state_OFDM <= state_IDLE;
                end
            endcase
        end
        end
    end
    
    
endmodule
