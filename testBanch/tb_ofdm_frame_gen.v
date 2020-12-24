`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.12.2020 17:08:09
// Design Name: 
// Module Name: tb_ofdm_frame_gen
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


module tb_ofdm_frame_gen();

reg clk = 1'b0;
always #5 clk = !clk;

reg beginTX = 0;
reg valid = 0;
reg [7:0] in_data = 0;
wire flag_ready_read;
wire [15:0] out_data_i;
wire [15:0] out_data_q;
wire tx_valid;
wire done_transmit;
wire [3:0] o_state_OFDM;
wire [7:0] d_FCH_data;
wire [15:0] d_fft_data_i;
wire [15:0] d_fft_data_q;
wire [15:0] d_in_fft_data_i;
wire [15:0] d_in_fft_data_q;
wire d_complete_fft;

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
initial
begin
    f_i = $fopen("sim_res_data_i.txt", "w");
    f_q = $fopen("sim_res_data_q.txt", "w");
    
    #10;
    
    while(done_transmit == 1'b0)
    begin
        #10;
        if(tx_valid)    $fwrite(f_i, "%d\n", out_data_i);
        if(tx_valid)    $fwrite(f_q, "%d\n", out_data_q);
    end
    
    $fclose(f_i);
    $fclose(f_q);
    $stop;
end

initial #30 valid <= 1'b1;

initial 
begin
    #30 beginTX <= 1'b1;
    #10 beginTX <= 1'b0;
end

    ofdm_frame_gen #(.MEMORY_SYZE(16))
    _ofdm_frame_gen
    (
        .clk(clk),
        .en(1'b1),
        .reset(1'b0),
        .beginTX(beginTX),
        .valid(valid),
        .in_data(in_data),
        .data_frame_size(10),
        .modulation(4),
        .flag_ready_read(flag_ready_read),
        .out_data_i(out_data_i),
        .out_data_q(out_data_q),
        .tx_valid(tx_valid),
        .done_transmit(done_transmit),
        .o_state_OFDM(o_state_OFDM),
        .d_FCH_data(d_FCH_data),
        .d_fft_data_i(d_fft_data_i),
        .d_fft_data_q(d_fft_data_q),
        .d_in_fft_data_i(d_in_fft_data_i),
        .d_in_fft_data_q(d_in_fft_data_q),
        .d_complete_fft(d_complete_fft)
    );
    
    
    
endmodule
