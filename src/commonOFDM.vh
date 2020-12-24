`ifndef __COMMON_OFDM_VH__
	`define __COMMON_OFDM_VH__

//parameter	DATA_FFT_SIZE = 16;
//parameter	DATA_FFT_FAST_SIZE = 16;

`define PILOT_P13_I      10
`define PILOT_P38_I      10
`define PILOT_P63_I      10
`define PILOT_P88_I      10
`define PILOT_P_88_I     10
`define PILOT_P_63_I     10
`define PILOT_P_38_I     10
`define PILOT_P_13_I     10

`define PILOT_P13_Q      10
`define PILOT_P38_Q      10
`define PILOT_P63_Q      10
`define PILOT_P88_Q      10
`define PILOT_P_88_Q     10
`define PILOT_P_63_Q     10
`define PILOT_P_38_Q     10
`define PILOT_P_13_Q     10

`define BPSK_MOD         3'd0
`define QPSK_MOD         3'd1
`define QAM16_MOD        3'd2
`define QAM64_MOD        3'd3
`define QAM256_MOD       3'd4

`endif //__COMMON_OFDM_VH__