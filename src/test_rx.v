`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.03.2021 16:00:11
// Design Name: 
// Module Name: test_rx
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

`include "top.svh"

module test_rx(
    i_clk,
    i_reset,
    i_clk_data,
    i_rx_valid,
    i_data_i,
    i_data_q,
    viewer
    );
    
    input i_clk;
    input i_reset;
    input i_clk_data;
    input i_rx_valid;
    input [15:0] i_data_i;
    input [15:0] i_data_q;
    
    (* dont_touch = "true", MARK_DEBUG="true" *) wire [15:0] w_data_i;
    (* dont_touch = "true", MARK_DEBUG="true" *) wire [15:0] w_data_q;
    
    (* dont_touch = "true", MARK_DEBUG="true" *) wire flag_wayt_data;
    (* dont_touch = "true", MARK_DEBUG="true" *) wire empty;
    wire full;
    (* dont_touch = "true", MARK_DEBUG="true" *) wire fft_valid;
    (* dont_touch = "true", MARK_DEBUG="true" *) wire [15:0] fft_data_i;
    (* dont_touch = "true", MARK_DEBUG="true" *) wire [15:0] fft_data_q;
    
    (* dont_touch = "true", MARK_DEBUG="true" *) wire d_in_fft_valid;
    (* dont_touch = "true", MARK_DEBUG="true" *) wire [15:0] d_in_fft_data_i;
    (* dont_touch = "true", MARK_DEBUG="true" *) wire [15:0] d_in_fft_data_q;
    
    (* dont_touch = "true", MARK_DEBUG="true" *) wire d_find_preamble_a;
    (* dont_touch = "true", MARK_DEBUG="true" *) wire d_find_preamble_b;
    
    output t_viewer viewer;
    
    assign    viewer.sync	= fft_valid;
    assign    viewer.dat	= {fft_data_q, fft_data_i};
    assign    viewer.ena 	= 1'b1;
    assign    viewer.clk    = i_clk;
    
    
    ofdm_frame_res #(   .DATA_SIZE(16)
                     )
    _ofdm_frame_res(
        .i_clk(i_clk),
        .i_en(1'b1),
        .i_reset(i_reset),
        .i_valid(!empty),
        .in_data_i(w_data_i),
        .in_data_q(w_data_q),
        .o_flag_wayt_data(flag_wayt_data),
        .o_find_preamble_a(d_find_preamble_a),
        .o_find_preamble_b(d_find_preamble_b),
        .o_fft_valid(fft_valid),
        .o_fft_data_i(fft_data_i),
        .o_fft_data_q(fft_data_q),
        
        .d_in_fft_valid(d_in_fft_valid),
        .d_in_fft_data_i(d_in_fft_data_i),
        .d_in_fft_data_q(d_in_fft_data_q)
    );
    
    
    
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

      .dout({w_data_q, w_data_i}),                   // READ_DATA_WIDTH-bit output: Read Data: The output data bus is driven
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

      .din({i_data_q, i_data_i}),                     // WRITE_DATA_WIDTH-bit input: Write Data: The input data bus used when
                                     // writing the FIFO.

      .injectdbiterr(/*injectdbiterr*/), // 1-bit input: Double Bit Error Injection: Injects a double bit error if
                                     // the ECC feature is used on block RAMs or UltraRAM macros.

      .injectsbiterr(/*injectsbiterr*/), // 1-bit input: Single Bit Error Injection: Injects a single bit error if
                                     // the ECC feature is used on block RAMs or UltraRAM macros.

      .rd_clk(i_clk),               // 1-bit input: Read clock: Used for read operation. rd_clk must be a free
                                     // running clock.

      .rd_en(flag_wayt_data),                 // 1-bit input: Read Enable: If the FIFO is not empty, asserting this
                                     // signal causes data (on dout) to be read from the FIFO. Must be held
                                     // active-low when rd_rst_busy is active high.

      .rst(i_reset),                     // 1-bit input: Reset: Must be synchronous to wr_clk. The clock(s) can be
                                     // unstable at the time of applying reset, but reset must be released only
                                     // after the clock(s) is/are stable.

      .sleep(/*sleep*/1'b0),                 // 1-bit input: Dynamic power saving: If sleep is High, the memory/fifo
                                     // block is in power saving mode.

      .wr_clk(i_clk_data),               // 1-bit input: Write clock: Used for write operation. wr_clk must be a
                                     // free running clock.

      .wr_en(i_rx_valid)                  // 1-bit input: Write Enable: If the FIFO is not full, asserting this
                                     // signal causes data (on din) to be written to the FIFO. Must be held
                                     // active-low when rst or wr_rst_busy is active high.

   );
   
endmodule
