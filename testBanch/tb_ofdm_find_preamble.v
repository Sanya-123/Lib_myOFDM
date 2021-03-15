`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.12.2020 15:33:41
// Design Name: 
// Module Name: tb_ofdm_find_preamble
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


module tb_ofdm_find_preamble();


reg clk = 0;
always
    #5 clk = !clk;
    
    reg beginTX = 0;
reg valid = 0;
reg [7:0] in_data = 0;
wire flag_ready_read;
wire [15:0] out_data_i;
wire [15:0] out_data_q;
wire tx_valid;
wire done_transmit;
wire [3:0] o_state_OFDM;
reg wayt_read_data = 1'b1;
//wire [7:0] d_FCH_data;
//wire [15:0] d_fft_data_i;
//wire [15:0] d_fft_data_q;
//wire [15:0] d_in_fft_data_i;
//wire [15:0] d_in_fft_data_q;
//wire d_complete_fft;

//always
//begin
//    #30
//    in_data <= $urandom();
//end

localparam DATA_SIZE = 24*8*10;


integer f, i;
initial
begin
    f = $fopen("testDataOFDM.txt", "r");
    #30;
    for(i = 0; i < DATA_SIZE;)
    begin
        if(flag_ready_read)     $fscanf(f, "%d", in_data);
        if(flag_ready_read)     i = i + 1;
        
        #10;
    end
    $fclose(f);

end

integer f_i, f_q, j;
//initial
//begin
//    f_i = $fopen("sim_res_data_i.txt", "w");
//    f_q = $fopen("sim_res_data_q.txt", "w");
    
//    #10;
    
//    while(done_transmit == 1'b0)
//    begin
//        #10;
//        if(tx_valid)    $fwrite(f_i, "%d\n", out_data_i);
//        if(tx_valid)    $fwrite(f_q, "%d\n", out_data_q);
//    end
    
//    $fclose(f_i);
//    $fclose(f_q);
//    $stop;
//end

initial #30 valid <= 1'b1;

reg reset = 0;

initial 
begin
    #500 reset <= 1'b1;
    #500 reset <= 1'b0;
end

initial 
begin
    #2000 beginTX <= 1'b1;
    #500 beginTX <= 1'b0;
end

    ofdm_frame_gen #(.MEMORY_SYZE(16))
    _ofdm_frame_gen
    (
        .clk(clk),
        .en(1'b1),
        .reset(reset),
        .beginTX(beginTX),
        .valid(valid),
        .in_data(in_data),
        .data_frame_size(10),
        .modulation(4),
        .i_wayt_read_data(wayt_read_data/*din_valid_0*/),
        .flag_ready_read(flag_ready_read),
        .out_data_i(out_data_i),
        .out_data_q(out_data_q),
        .tx_valid(tx_valid),
        .done_transmit(done_transmit),
        .o_state_OFDM(o_state_OFDM)
//        .d_FCH_data(d_FCH_data),
//        .d_fft_data_i(d_fft_data_i),
//        .d_fft_data_q(d_fft_data_q),
//        .d_in_fft_data_i(d_in_fft_data_i),
//        .d_in_fft_data_q(d_in_fft_data_q),
//        .d_complete_fft(d_complete_fft)
    );
    
    wire signed [15+8:0] out_preamble_i;
    wire signed [15+8:0] out_preamble_q;
    
    wire [31+16:0] abs_preamble = out_preamble_i*out_preamble_i + out_preamble_q*out_preamble_q;
    
    wire findPA;
    
    wire [31+16:0] porogA;
    
    
    ofdm_find_preamble #(.DATA_SIZE(16),
            .PREAMBLE_MEM_I(256'b0111011000000011111111100000011111111100000011100100100110011111001101100110010011000000001111110000001100011000111111100001001100000110001100000001100110011001111110111001111001110110001000110010001110011100011001110111100000111001111000000111000000111000),
            .PREAMBLE_MEM_Q(256'b0001110010001111111000101110001110010001100010011110001100100001111111111001111000010000111100110011111011000100110011111110000011111001100110010011000001000111100011111111111000000000110000111000111001110011000111011001110000001000011001001110100011100111))
    _ofdm_find_preamble(
        .clk(clk),
        .en(1'b1),
        .in_data_i(out_data_i),
        .in_data_q(out_data_q),
        .find(findPA),
        .out_data_i(out_preamble_i),
        .out_data_q(out_preamble_q),
        .outPorog()
    );
    
    dynamicPreambleFilter #( .DATA_SIZE(48),
                             .MIN_POROG(1024),
                             .N_FILTR(5)/*log2(size)*/)
     _filter(
        .clk(clk),
        .en(1'b1),
        .in_data(abs_preamble),
        .out_porog(porogA)
    );
    
    
    wire signed [15+8:0] out_preambleB_i;
    wire signed [15+8:0] out_preambleB_q;
    
    wire [31+16:0] abs_preambleB = out_preambleB_i*out_preambleB_i + out_preambleB_q*out_preambleB_q;
    
    wire findPB;
    
    wire [31+16:0] porogB;
    
    
    ofdm_find_preamble #(.DATA_SIZE(16),
            .PREAMBLE_MEM_I(256'b1001100110000100001001100111000010000110010011110101111100000010010011110111111001110010001110001100100110010000000000100111000011001101111100010010010000110111100110011100011111110011111001000111110000011111100100001101111001011011000011111101000000110110),
            .PREAMBLE_MEM_Q(256'b1000011000101100111001001100011011000111111000110110110010110011011111001111001100000111001001011000011000011111110000110001111111000000011100001100100001000000001100111101101100111010011011001000011010111110000111101110000000100011011011010011110100110011))
    _ofdm_find_preambleB(
        .clk(clk),
        .en(1'b1),
        .in_data_i(out_data_i),
        .in_data_q(out_data_q),
        .find(findPB),
        .out_data_i(out_preambleB_i),
        .out_data_q(out_preambleB_q),
        .outPorog(porogB)
    );


endmodule
