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


module ofdm_frame_gen(
    clk,
    en,
    reset,
    in_data,
    out_data_i,
    out_data_q
    );
    
    input clk;
    input en;
    input reset;
    input [7:0] in_data;
    output reg [15:0] out_data_i;
    output reg [15:0] out_data_q; 
    
    wire [7:0] code_data;
    
    
    bypass_coder
    _coder(
    .clk(clk),
    .in_data(in_data),
    .out_data(code_data)
    );
    
    memForOFDM #(.MAX_SYMBOLS_FFT(64))
    _memForOFDM(
    .clk(),
    .write_en(),
    .addres_write(),
    .addres_read(),
    .write_data_i(),
    .write_data_q(),
    .read_data_i(),
    .read_data_q()
    );
    
    myFFT
    #(.SIZE_BUFFER(8),/*log2(NFFT)*/
      .DATA_FFT_SIZE(16),
      .FAST("slow"),/*slow fast ultrafast slow mult x1 fast mult x2 ultrafast mult x4*/
      .TYPE("invers"),/*forvard  invers*/
      .COMPENS_FP("add"),/*false true or add razrad*/
      .MIN_FFT_x4(1)
    )
    _fft_OFDM(
    .clk(),
    .valid(),
    .clk_i_data(),
    .data_in_i(),
    .data_in_q(),
    .clk_o_data(),
    .data_out_i(),
    .data_out_q(),
    .complete(),
    .stateFFT()
    );
    
    reg [7:0] preambleAddres = 0;
    wire [15:0] out_short_preamble_i;
    wire [15:0] out_short_preamble_q;
    
//    reg [64*10-1:0] longPreamble;
//    reg [64*2-1:0]  shortPreamble;
    
    reg [3:0] state_OFDM = 0;
    
    localparam state_IDLE = 0;
    localparam state_short_preamble = 1;
    localparam state_long_preamble = 2;
    
    reg beginTransmite = 1;
    
    
    //generate data
    always @(posedge clk)
    begin
        case(state_OFDM)
        state_IDLE :begin   if(beginTransmite)  state_OFDM <= state_short_preamble; end
        
        state_short_preamble:
            begin
                if(preambleAddres < 160)
                begin
                    preambleAddres <= preambleAddres + 1;
                    out_data_i <= out_short_preamble_i;
                    out_data_q <= out_short_preamble_q;
                end
                else
                begin 
                    preambleAddres <= 0;
                    state_OFDM <= state_long_preamble;
                end
            end
            
//        state_long_preamble:
//            begin
//                if(preambleAddres < 160)
//                begin
//                    preambleAddres <= preambleAddres + 1;
//                    out_data_i <= out_short_preamble_i;
//                    out_data_q <= out_short_preamble_q;
//                end
//                else
//                begin 
//                    preambleAddres <= 0;
//                    state_OFDM <= state_long_preamble;
//                end
//            end
            
        endcase
    end
    
    
    
    short_preamble_rom_my
    _short_preamble(
      .addr(preambleAddres[3:0]),
      .dout_i(out_short_preamble_i),
      .dout_q(out_short_preamble_q)
    );
    
    
endmodule
