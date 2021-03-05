`ifndef __COMMON_OFDM_VH__
	`define __COMMON_OFDM_VH__

//parameter	DATA_FFT_SIZE = 16;
//parameter	DATA_FFT_FAST_SIZE = 16;

`define BPSK_MOD         3'd0
`define QPSK_MOD         3'd1
`define QAM16_MOD        3'd2
`define QAM64_MOD        3'd3
`define QAM256_MOD       3'd4

//MAP modulation
/* BPSK  I   Q
 *  0    -1  0
 *  1    1   0
*/
/* QPSK  I(Q)
 *  0    -1
 *  1    1
*/
/* QAM16  I(Q)
 *  00    -3
 *  01    -1
 *  11    1
 *  10    3
*/
/* QAM64  I(Q)
 *  000   -7
 *  001   -5
 *  011   -3
 *  010   -1
 *  110   1
 *  111   3
 *  101   5
 *  100   7
*/
/* QAM256  I(Q)
 *  0001   -15
 *  0101   -13
 *  0111   -11
 *  0011   -9
 *  0010   -7
 *  0110   -5
 *  0100   -3
 *  0000   -1
 *  1000   1
 *  1100   3
 *  1110   5
 *  1010   7
 *  1011   9
 *  1111   11
 *  1101   13
 *  1001   15
*/

//scale modulation = val*2/sqrt(N)  N - point of modulation
//scale x8
`define BPSK__1                 -170 /*-21.2132 = -1*15*2/sqrt(2)*/
`define BPSK_1                  170 /*21.2132 = 1*15*2/sqrt(2)*/

`define QPSK__1                 -120 /*-15 = -1*15*2/sqrt(4)*/
`define QPSK_1                  120 /*15 = 1*15*2/sqrt(4)*/

`define QAM16__3                -180 /*-22.5 = -3*15*2/sqrt(16)*/
`define QAM16__1                -60 /*-7.5 = -1*15*2/sqrt(16)*/
`define QAM16_1                 60 /*7.5 = 1*15*2/sqrt(16)*/
`define QAM16_3                 180 /*722.5 = 3*15*2/sqrt(16)*/

`define QAM64__7                -210 /*-26.25 = -7*15*2/sqrt(64)*/
`define QAM64__5                -150 /*-18.75 = -5*15*2/sqrt(64)*/
`define QAM64__3                -90 /*-11.25 = -3*15*2/sqrt(64)*/
`define QAM64__1                -30 /*-3.75 = -1*15*2/sqrt(64)*/
`define QAM64_1                 30 /*3.75 = 1*15*2/sqrt(64)*/
`define QAM64_3                 90 /*11.25 = 3*15*2/sqrt(64)*/
`define QAM64_5                 150 /*18.75 = 5*15*2/sqrt(64)*/
`define QAM64_7                 210 /*26.25 = 7*15*2/sqrt(64)*/

`define QAM256__15              -225 /*-28.125 = -15*15*2/sqrt(256)*/
`define QAM256__13              -195 /*-24.375 = -13*15*2/sqrt(256)*/
`define QAM256__11              -165 /*-20.625 = -11*15*2/sqrt(256)*/
`define QAM256__9               -135 /*-16.875 = -9*15*2/sqrt(256)*/
`define QAM256__7               -105 /*-13.125 = -7*15*2/sqrt(256)*/
`define QAM256__5               -75 /*-9.375 = -5*15*2/sqrt(256)*/
`define QAM256__3               -45 /*-5.625 = -3*15*2/sqrt(256)*/
`define QAM256__1               -15 /*-1.875 = -1*15*2/sqrt(256)*/
`define QAM256_1                15 /*1.875 = 1*15*2/sqrt(256)*/
`define QAM256_3                45 /*5.625 = 3*15*2/sqrt(256)*/
`define QAM256_5                75 /*9.375 = 5*15*2/sqrt(256)*/
`define QAM256_7                105 /*13.125 = 7*15*2/sqrt(256)*/
`define QAM256_9                135 /*16.875 = 9*15*2/sqrt(256)*/
`define QAM256_11               165 /*20.625 = 11*15*2/sqrt(256)*/
`define QAM256_13               195 /*24.375 = 13*15*2/sqrt(256)*/
`define QAM256_15               225 /*28.125 = 15*15*2/sqrt(256)*/

//For demap modulation
`define DMP_QAM16__3            -120 /*-15 = QAM16__3 + step/2 = -22.5+7.5*/
`define DMP_QAM16__1            0 /*0 = QAM16__1 + step/2 = -7.5+7.5*/
`define DMP_QAM16_1             120 /*15 = QAM16_1 + step/2 = 7.5+7.5*/

`define DMP_QAM64__7            -180 /*-22.5 = QAM64__7 + step/2 = -26.25+3.75*/
`define DMP_QAM64__5            -120 /*-15 = QAM64__5 + step/2 = -22.5+3.75*/
`define DMP_QAM64__3            -60 /*-22.5 = QAM64__3 + step/2 = -11.25+3.75*/
`define DMP_QAM64__1            0 /*-22.5 = QAM64__1 + step/2 = -3.75+3.75*/
`define DMP_QAM64_1             60 /*-22.5 = QAM64_1 + step/2 = 3.75+3.75*/
`define DMP_QAM64_3             120 /*-22.5 = QAM64_3 + step/2 = 11.25+3.75*/
`define DMP_QAM64_5             180 /*-22.5 = QAM64_5 + step/2 = 18.75+3.75*/

`define DMP_QAM256__15          -210 /*-26.25 = QAM256__15 + step/2 = -28.125+1.875*/
`define DMP_QAM256__13          -180 /*-22.5 = QAM256__13 + step/2 = -24.375+1.875*/
`define DMP_QAM256__11          -150 /*-18.75 = QAM256__11 + step/2 = -20.625+1.875*/
`define DMP_QAM256__9           -120 /*-15 = QAM256__9 + step/2 = -16.875+1.875*/
`define DMP_QAM256__7           -90 /*-11.25 = QAM256__7 + step/2 = -13.125+1.875*/
`define DMP_QAM256__5           -60 /*-7.5 = QAM256__5 + step/2 = -9.375+1.875*/
`define DMP_QAM256__3           -30 /*-3.75 = QAM256__3 + step/2 = -5.625+1.875*/
`define DMP_QAM256__1           0 /*0 = QAM256__1 + step/2 = -1.875+1.875*/
`define DMP_QAM256_1            30 /*3.75 = QAM256_1 + step/2 = 1.875+1.875*/
`define DMP_QAM256_3            60 /*7.5 = QAM256_3 + step/2 = 5.625+1.875*/
`define DMP_QAM256_5            90 /*11.25 = QAM256_5 + step/2 = 9.375+1.875*/
`define DMP_QAM256_7            120 /*15 = QAM256_7 + step/2 = 13.125+1.875*/
`define DMP_QAM256_9            150 /*18.75 = QAM256_9 + step/2 = 16.875+1.875*/
`define DMP_QAM256_11           180 /*22.5 = QAM256_11 + step/2 = 20.625+1.875*/
`define DMP_QAM256_13           210 /*26.25 = QAM256_13 + step/2 = 24.375+1.875*/


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


`endif //__COMMON_OFDM_VH__