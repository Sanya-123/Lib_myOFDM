/*
 * short_preamble_rom - TODO
 *
 * Michael Tetemke Mehari michael.mehari@ugent.be
 */

module short_preamble_rom_my
(
  addr,
  dout_i,
  dout_q  
);

    input      [3:0]  addr;
    output reg [15:0] dout_i;
    output reg [15:0] dout_q;

  always @ *
    case (addr)
              0:   dout_i = 16'h05E3;
              1:   dout_i = 16'hEF0C;
              2:   dout_i = 16'hFE47;
              3:   dout_i = 16'h1246;
              4:   dout_i = 16'h0BC7;
              5:   dout_i = 16'h1246;
              6:   dout_i = 16'hFE47;
              7:   dout_i = 16'hEF0C;
              8:   dout_i = 16'h05E3;
              9:   dout_i = 16'h004D;
             10:   dout_i = 16'hF5F3;
             11:   dout_i = 16'hFE61;
             12:   dout_i = 16'h0000;
             13:   dout_i = 16'hFE61;
             14:   dout_i = 16'hF5F3;
             15:   dout_i = 16'h004D;

          default: dout_i = 16'h0000;
    endcase
    
    always @ *
        case (addr)
              0:   dout_q = 16'h05E3;
              1:   dout_q = 16'h004D;
              2:   dout_q = 16'hF5F3;
              3:   dout_q = 16'hFE61;
              4:   dout_q = 16'h0000;
              5:   dout_q = 16'hFE61;
              6:   dout_q = 16'hF5F3;
              7:   dout_q = 16'h004D;
              8:   dout_q = 16'h05E3;
              9:   dout_q = 16'hEF0C;
             10:   dout_q = 16'hFE47;
             11:   dout_q = 16'h1246;
             12:   dout_q = 16'h0BC7;
             13:   dout_q = 16'h1246;
             14:   dout_q = 16'hFE47;
             15:   dout_q = 16'hEF0C;

          default: dout_q = 16'h0000;
    endcase

endmodule
