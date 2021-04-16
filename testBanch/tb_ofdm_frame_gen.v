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
//wire [7:0] d_FCH_data;
//wire [15:0] d_fft_data_i;
//wire [15:0] d_fft_data_q;
//wire [15:0] d_in_fft_data_i;
//wire [15:0] d_in_fft_data_q;
//wire d_complete_fft;
reg wayt_read_data = 1'b1;

wire din_valid_0;

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

//initial 
//begin 
//    #5;
//    #3200   wayt_read_data <= 1'b0;
//    #400    wayt_read_data <= 1'b1;
//end

//    always #10 wayt_read_data = !wayt_read_data;

initial 
begin
    #500
    #30 beginTX <= 1'b1;
    #50 beginTX <= 1'b0;
end

    wire [15:0] mod_data_i;
    wire [15:0] mod_data_q;
    wire flag_ready_recive;
    wire walid_data_mod;
    
    wire [15:0] d_data_symbols_counter;
    wire [15:0] d_counter_sample;
    
    wire [15:0] d_in_fft_data_i;
    wire [15:0] d_in_fft_data_q;
    wire d_fft_valid;
//    
    
    ofdm_modulation #(.DATA_SIZE(16))
    _ofdm_modulation(
        .i_clk(clk),
        .i_reset(1'b0),
        .i_valid(valid),
        .i_modulation(3'd4),
        .i_data(in_data),
        .o_wayt_res_data(flag_ready_read),
        .o_valid_data(walid_data_mod),
        .i_wayt_data(flag_ready_recive),
        .o_data_i(mod_data_i),
        .o_data_q(mod_data_q)
    );

    ofdm_frame_gen #(.MEMORY_SYZE(16))
    _ofdm_frame_gen
    (
        .clk(clk),
        .en(1'b1),
        .reset(1'b0),
        .beginTX(beginTX),
        .valid(walid_data_mod),
//        .in_data(in_data),
        .i_mod_data_i(mod_data_i),
        .i_mod_data_q(mod_data_q),
        .data_frame_size(10),
        .modulation(4),
        .i_wayt_read_data(1'b1/*flag_ready_recive*//*din_valid_0*/),
        
        .flag_ready_read(flag_ready_recive),
        .out_data_i(out_data_i),
        .out_data_q(out_data_q),
        .tx_valid(tx_valid),
        .done_transmit(done_transmit),
        .o_state_OFDM(o_state_OFDM)
        ,
        .d_data_symbols_counter(d_data_symbols_counter),
        .d_counter_sample(d_counter_sample),
        .d_in_fft_data_i(d_in_fft_data_i),
        .d_in_fft_data_q(d_in_fft_data_q),
        .d_fft_valid(d_fft_valid)
    );
    
    reg cld_data_out = 1'b0;
    always #4 cld_data_out = !cld_data_out;
    reg valid_data_out = 1'b0;
    always #8 valid_data_out = !valid_data_out;
    
    wire dout_unf;
    wire dout_valid_out_0;
    wire [15:0] fifo_data_i;
    wire [15:0] fifo_data_q;
    wire din_enable_0;
//    wire din_valid_0;
    
    
//util_rfifo_0 fifi_ofdm (
//      .din_rstn(1'b1),                  // input wire din_rstn
//      .din_clk(clk),                    // input wire din_clk
//      .din_enable_0(din_enable_0),          // output wire din_enable_0
//      .din_valid_0(din_valid_0),            // output wire din_valid_0
//      .din_valid_in_0(tx_valid),      // input wire din_valid_in_0
      
//      .din_data_0({out_data_q, out_data_i}),              // input wire [31 : 0] din_data_0
//      .din_unf(1'b0),                    // input wire din_unf
//      .dout_rst(1'b0),                  // input wire dout_rst
//      .dout_clk(cld_data_out),                  // input wire dout_clk
//      .dout_enable_0(1'b1),        // input wire dout_enable_0
//      .dout_valid_0(valid_data_out),          // input wire dout_valid_0
      
//      .dout_valid_out_0(dout_valid_out_0),  // output wire dout_valid_out_0
//      .dout_data_0({fifo_data_q, fifo_data_i}),            // output wire [31 : 0] dout_data_0
//      .dout_unf(dout_unf)                  // output wire dout_unf
//);

//wire wrfull;
//wire wrempty;
////wire wrusedw;

//wire rdempty;
//wire rdfull;

//afifo #(
//  .pDATA_W(32),
//  .pADDR_W(16),
//  .pPIPE(0)
//)
//ofdm_fifi(
//    .reset(1'b0)   ,
//    .wrclk(clk)   ,
//    .wrreq(tx_valid)   ,
//    .wrdata({out_data_q, out_data_i})  ,
//    .wrfull(wrfull)  ,
//    .wrempty(wrempty) ,
//    .wrusedw() ,
//    //
//    .rdclk(cld_data_out)   ,
//    .rdreq(valid_data_out)   ,
//    .rddata({fifo_data_q, fifo_data_i})  ,
//    .rdempty(rdempty) ,
//    .rdfull(rdfull)  ,
//    .rdusedw()
//);

wire empty;
wire full;

xpm_fifo_async #(
      .CDC_SYNC_STAGES(2),       // DECIMAL
      .DOUT_RESET_VALUE("0"),    // String
      .ECC_MODE("no_ecc"),       // String
      .FIFO_MEMORY_TYPE("auto"), // String
      .FIFO_READ_LATENCY(1),     // DECIMAL
      .FIFO_WRITE_DEPTH(2048),   // DECIMAL
      .FULL_RESET_VALUE(0),      // DECIMAL
      .PROG_EMPTY_THRESH(10),    // DECIMAL
      .PROG_FULL_THRESH(10),     // DECIMAL
      .RD_DATA_COUNT_WIDTH(1),   // DECIMAL
      .READ_DATA_WIDTH(32),      // DECIMAL
      .READ_MODE("std"),         // String
      .RELATED_CLOCKS(0),        // DECIMAL
      .SIM_ASSERT_CHK(0),        // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .USE_ADV_FEATURES("0707"), // String
      .WAKEUP_TIME(0),           // DECIMAL
      .WRITE_DATA_WIDTH(32),     // DECIMAL
      .WR_DATA_COUNT_WIDTH(1)    // DECIMAL
   )
   xpm_fifo_async_inst (
      .almost_empty(/*almost_empty*/),   // 1-bit output: Almost Empty : When asserted, this signal indicates that
                                     // only one more read can be performed before the FIFO goes to empty.

      .almost_full(/*almost_full*/),     // 1-bit output: Almost Full: When asserted, this signal indicates that
                                     // only one more write can be performed before the FIFO is full.

      .data_valid(/*data_valid*/),       // 1-bit output: Read Data Valid: When asserted, this signal indicates
                                     // that valid data is available on the output bus (dout).

      .dbiterr(/*dbiterr*/),             // 1-bit output: Double Bit Error: Indicates that the ECC decoder detected
                                     // a double-bit error and data in the FIFO core is corrupted.

      .dout({fifo_data_q, fifo_data_i}),                   // READ_DATA_WIDTH-bit output: Read Data: The output data bus is driven
                                     // when reading the FIFO.

      .empty(empty),                 // 1-bit output: Empty Flag: When asserted, this signal indicates that the
                                     // FIFO is empty. Read requests are ignored when the FIFO is empty,
                                     // initiating a read while empty is not destructive to the FIFO.

      .full(full),                   // 1-bit output: Full Flag: When asserted, this signal indicates that the
                                     // FIFO is full. Write requests are ignored when the FIFO is full,
                                     // initiating a write when the FIFO is full is not destructive to the
                                     // contents of the FIFO.

      .overflow(/*overflow*/),           // 1-bit output: Overflow: This signal indicates that a write request
                                     // (wren) during the prior clock cycle was rejected, because the FIFO is
                                     // full. Overflowing the FIFO is not destructive to the contents of the
                                     // FIFO.

      .prog_empty(/*prog_empty*/),       // 1-bit output: Programmable Empty: This signal is asserted when the
                                     // number of words in the FIFO is less than or equal to the programmable
                                     // empty threshold value. It is de-asserted when the number of words in
                                     // the FIFO exceeds the programmable empty threshold value.

      .prog_full(/*prog_full*/),         // 1-bit output: Programmable Full: This signal is asserted when the
                                     // number of words in the FIFO is greater than or equal to the
                                     // programmable full threshold value. It is de-asserted when the number of
                                     // words in the FIFO is less than the programmable full threshold value.

      .rd_data_count(/*rd_data_count*/), // RD_DATA_COUNT_WIDTH-bit output: Read Data Count: This bus indicates the
                                     // number of words read from the FIFO.

      .rd_rst_busy(/*rd_rst_busy*/),     // 1-bit output: Read Reset Busy: Active-High indicator that the FIFO read
                                     // domain is currently in a reset state.

      .sbiterr(/*sbiterr*/),             // 1-bit output: Single Bit Error: Indicates that the ECC decoder detected
                                     // and fixed a single-bit error.

      .underflow(/*underflow*/),         // 1-bit output: Underflow: Indicates that the read request (rd_en) during
                                     // the previous clock cycle was rejected because the FIFO is empty. Under
                                     // flowing the FIFO is not destructive to the FIFO.

      .wr_ack(/*wr_ack*/),               // 1-bit output: Write Acknowledge: This signal indicates that a write
                                     // request (wr_en) during the prior clock cycle is succeeded.

      .wr_data_count(/*wr_data_count*/), // WR_DATA_COUNT_WIDTH-bit output: Write Data Count: This bus indicates
                                     // the number of words written into the FIFO.

      .wr_rst_busy(/*wr_rst_busy*/),     // 1-bit output: Write Reset Busy: Active-High indicator that the FIFO
                                     // write domain is currently in a reset state.

      .din({out_data_q, out_data_i}),                     // WRITE_DATA_WIDTH-bit input: Write Data: The input data bus used when
                                     // writing the FIFO.

      .injectdbiterr(/*injectdbiterr*/), // 1-bit input: Double Bit Error Injection: Injects a double bit error if
                                     // the ECC feature is used on block RAMs or UltraRAM macros.

      .injectsbiterr(/*injectsbiterr*/), // 1-bit input: Single Bit Error Injection: Injects a single bit error if
                                     // the ECC feature is used on block RAMs or UltraRAM macros.

      .rd_clk(cld_data_out),               // 1-bit input: Read clock: Used for read operation. rd_clk must be a free
                                     // running clock.

      .rd_en(valid_data_out),                 // 1-bit input: Read Enable: If the FIFO is not empty, asserting this
                                     // signal causes data (on dout) to be read from the FIFO. Must be held
                                     // active-low when rd_rst_busy is active high.

      .rst(1'b0),                     // 1-bit input: Reset: Must be synchronous to wr_clk. The clock(s) can be
                                     // unstable at the time of applying reset, but reset must be released only
                                     // after the clock(s) is/are stable.

      .sleep(/*sleep*/1'b0),                 // 1-bit input: Dynamic power saving: If sleep is High, the memory/fifo
                                     // block is in power saving mode.

      .wr_clk(clk),               // 1-bit input: Write clock: Used for write operation. wr_clk must be a
                                     // free running clock.

      .wr_en(tx_valid)                  // 1-bit input: Write Enable: If the FIFO is not full, asserting this
                                     // signal causes data (on din) to be written to the FIFO. Must be held
                                     // active-low when rst or wr_rst_busy is active high.

   );

    
    
endmodule
