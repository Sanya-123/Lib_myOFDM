`ifndef __COMMON_OFDM_VH__
	`define __COMMON_OFDM_VH__

//parameter	DATA_FFT_SIZE = 16;
//parameter	DATA_FFT_FAST_SIZE = 16;
`include "commonModulation.vh"


`define PILOT_P13_I      `QPSK_1
`define PILOT_P38_I      `QPSK_1
`define PILOT_P63_I      `QPSK_1
`define PILOT_P88_I      `QPSK_1
`define PILOT_P_88_I     `QPSK_1
`define PILOT_P_63_I     `QPSK_1
`define PILOT_P_38_I     `QPSK_1
`define PILOT_P_13_I     `QPSK_1

`define PILOT_P13_Q      `QPSK_1
`define PILOT_P38_Q      `QPSK_1
`define PILOT_P63_Q      `QPSK_1
`define PILOT_P88_Q      `QPSK_1
`define PILOT_P_88_Q     `QPSK_1
`define PILOT_P_63_Q     `QPSK_1
`define PILOT_P_38_Q     `QPSK_1
`define PILOT_P_13_Q     `QPSK_1

//localparam pilot_symbol_i [7:0] = {PILOT_P13_I, PILOT_P38_I, PILOT_P63_I, PILOT_P88_I, PILOT_P_88_I, PILOT_P_63_I, PILOT_P_38_I, PILOT_P_13_I};
//localparam pilot_symbol_i [7:0] = {PILOT_P13_I, PILOT_P38_I, PILOT_P63_I, PILOT_P88_I, PILOT_P_88_I, PILOT_P_63_I, PILOT_P_38_I, PILOT_P_13_I};


`endif //__COMMON_OFDM_VH__