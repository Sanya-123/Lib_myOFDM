/*
 * long_preamble_rom - TODO
 *
 * Michael Tetemke Mehari michael.mehari@ugent.be
 */

module long_preamble_rom_my
(
    addr,
    dout_i,
    dout_q
);

    input  [7:0]  addr;
    output reg [15:0] dout_i;
    output reg [15:0] dout_q;

    always @ *
        case (addr)
              0:   dout_i = 16'h0000;
              1:   dout_i = 16'hF382;
              2:   dout_i = 16'hF273;
              3:   dout_i = 16'hF143;
              4:   dout_i = 16'hF91E;
              5:   dout_i = 16'h097A;
              6:   dout_i = 16'h02A0;
              7:   dout_i = 16'h021F;
              8:   dout_i = 16'h1350;
              9:   dout_i = 16'h02CA;
             10:   dout_i = 16'hF598;
             11:   dout_i = 16'hFE31;
             12:   dout_i = 16'hF42E;
             13:   dout_i = 16'hF7A7;
             14:   dout_i = 16'hFAF8;
             15:   dout_i = 16'hF369;
             16:   dout_i = 16'h0800;
             17:   dout_i = 16'h0086;
             18:   dout_i = 16'hEB70;
             19:   dout_i = 16'h01EA;
             20:   dout_i = 16'h077E;
             21:   dout_i = 16'h0611;
             22:   dout_i = 16'h0EB8;
             23:   dout_i = 16'hFF7A;
             24:   dout_i = 16'h0350;
             25:   dout_i = 16'h0D97;
             26:   dout_i = 16'h0710;
             27:   dout_i = 16'h0B3A;
             28:   dout_i = 16'hFC6E;
             29:   dout_i = 16'hF567;
             30:   dout_i = 16'h0E3A;
             31:   dout_i = 16'h0F67;
             32:   dout_i = 16'h0000;
             33:   dout_i = 16'hF099;
             34:   dout_i = 16'hF1C6;
             35:   dout_i = 16'h0A99;
             36:   dout_i = 16'h0392;
             37:   dout_i = 16'hF4C6;
             38:   dout_i = 16'hF8F0;
             39:   dout_i = 16'hF269;
             40:   dout_i = 16'hFCB0;
             41:   dout_i = 16'h0086;
             42:   dout_i = 16'hF148;
             43:   dout_i = 16'hF9EF;
             44:   dout_i = 16'hF882;
             45:   dout_i = 16'hFE16;
             46:   dout_i = 16'h1490;
             47:   dout_i = 16'hFF7A;
             48:   dout_i = 16'hF800;
             49:   dout_i = 16'h0C97;
             50:   dout_i = 16'h0508;
             51:   dout_i = 16'h0859;
             52:   dout_i = 16'h0BD2;
             53:   dout_i = 16'h01CF;
             54:   dout_i = 16'h0A68;
             55:   dout_i = 16'hFD36;
             56:   dout_i = 16'hECB0;
             57:   dout_i = 16'hFDE1;
             58:   dout_i = 16'hFD60;
             59:   dout_i = 16'hF686;
             60:   dout_i = 16'h06E2;
             61:   dout_i = 16'h0EBD;
             62:   dout_i = 16'h0D8D;
             63:   dout_i = 16'h0C7E;
             64:   dout_i = 16'h0000;
             65:   dout_i = 16'hF382;
             66:   dout_i = 16'hF273;
             67:   dout_i = 16'hF143;
             68:   dout_i = 16'hF91E;
             69:   dout_i = 16'h097A;
             70:   dout_i = 16'h02A0;
             71:   dout_i = 16'h021F;
             72:   dout_i = 16'h1350;
             73:   dout_i = 16'h02CA;
             74:   dout_i = 16'hF598;
             75:   dout_i = 16'hFE31;
             76:   dout_i = 16'hF42E;
             77:   dout_i = 16'hF7A7;
             78:   dout_i = 16'hFAF8;
             79:   dout_i = 16'hF369;
             80:   dout_i = 16'h0800;
             81:   dout_i = 16'h0086;
             82:   dout_i = 16'hEB70;
             83:   dout_i = 16'h01EA;
             84:   dout_i = 16'h077E;
             85:   dout_i = 16'h0611;
             86:   dout_i = 16'h0EB8;
             87:   dout_i = 16'hFF7A;
             88:   dout_i = 16'h0350;
             89:   dout_i = 16'h0D97;
             90:   dout_i = 16'h0710;
             91:   dout_i = 16'h0B3A;
             92:   dout_i = 16'hFC6E;
             93:   dout_i = 16'hF567;
             94:   dout_i = 16'h0E3A;
             95:   dout_i = 16'h0F67;
             96:   dout_i = 16'h0000;
             97:   dout_i = 16'hF099;
             98:   dout_i = 16'hF1C6;
             99:   dout_i = 16'h0A99;
            100:   dout_i = 16'h0392;
            101:   dout_i = 16'hF4C6;
            102:   dout_i = 16'hF8F0;
            103:   dout_i = 16'hF269;
            104:   dout_i = 16'hFCB0;
            105:   dout_i = 16'h0086;
            106:   dout_i = 16'hF148;
            107:   dout_i = 16'hF9EF;
            108:   dout_i = 16'hF882;
            109:   dout_i = 16'hFE16;
            110:   dout_i = 16'h1490;
            111:   dout_i = 16'hFF7A;
            112:   dout_i = 16'hF800;
            113:   dout_i = 16'h0C97;
            114:   dout_i = 16'h0508;
            115:   dout_i = 16'h0859;
            116:   dout_i = 16'h0BD2;
            117:   dout_i = 16'h01CF;
            118:   dout_i = 16'h0A68;
            119:   dout_i = 16'hFD36;
            120:   dout_i = 16'hECB0;
            121:   dout_i = 16'hFDE1;
            122:   dout_i = 16'hFD60;
            123:   dout_i = 16'hF686;
            124:   dout_i = 16'h06E2;
            125:   dout_i = 16'h0EBD;
            126:   dout_i = 16'h0D8D;
            127:   dout_i = 16'h0C7E;
            128:   dout_i = 16'h0000;
            129:   dout_i = 16'hF382;
            130:   dout_i = 16'hF273;
            131:   dout_i = 16'hF143;
            132:   dout_i = 16'hF91E;
            133:   dout_i = 16'h097A;
            134:   dout_i = 16'h02A0;
            135:   dout_i = 16'h021F;
            136:   dout_i = 16'h1350;
            137:   dout_i = 16'h02CA;
            138:   dout_i = 16'hF598;
            139:   dout_i = 16'hFE31;
            140:   dout_i = 16'hF42E;
            141:   dout_i = 16'hF7A7;
            142:   dout_i = 16'hFAF8;
            143:   dout_i = 16'hF369;
            144:   dout_i = 16'h0800;
            145:   dout_i = 16'h0086;
            146:   dout_i = 16'hEB70;
            147:   dout_i = 16'h01EA;
            148:   dout_i = 16'h077E;
            149:   dout_i = 16'h0611;
            150:   dout_i = 16'h0EB8;
            151:   dout_i = 16'hFF7A;
            152:   dout_i = 16'h0350;
            153:   dout_i = 16'h0D97;
            154:   dout_i = 16'h0710;
            155:   dout_i = 16'h0B3A;
            156:   dout_i = 16'hFC6E;
            157:   dout_i = 16'hF567;
            158:   dout_i = 16'h0E3A;
            159:   dout_i = 16'h0F67;

          default: dout_i = 16'h00000;
    endcase
    
    always @ *
        case (addr)
              0:   dout_q = 16'hEC00;
              1:   dout_q = 16'h0193;
              2:   dout_q = 16'h0BBD;
              3:   dout_q = 16'hF43D;
              4:   dout_q = 16'hFFA4;
              5:   dout_q = 16'h099C;
              6:   dout_q = 16'hEFB4;
              7:   dout_q = 16'hF066;
              8:   dout_q = 16'hFB84;
              9:   dout_q = 16'hF8C6;
             10:   dout_q = 16'hF848;
             11:   dout_q = 16'h08E7;
             12:   dout_q = 16'h0A86;
             13:   dout_q = 16'hEF33;
             14:   dout_q = 16'hF8AD;
             15:   dout_q = 16'h04BA;
             16:   dout_q = 16'h0800;
             17:   dout_q = 16'h0F43;
             18:   dout_q = 16'hFD1F;
             19:   dout_q = 16'h0782;
             20:   dout_q = 16'h0322;
             21:   dout_q = 16'hEE7D;
             22:   dout_q = 16'h0020;
             23:   dout_q = 16'h06D4;
             24:   dout_q = 16'h0C7C;
             25:   dout_q = 16'hFB18;
             26:   dout_q = 16'hF143;
             27:   dout_q = 16'h07A8;
             28:   dout_q = 16'h02B4;
             29:   dout_q = 16'h0C65;
             30:   dout_q = 16'h0517;
             31:   dout_q = 16'hFF58;
             32:   dout_q = 16'h1400;
             33:   dout_q = 16'hFF58;
             34:   dout_q = 16'h0517;
             35:   dout_q = 16'h0C65;
             36:   dout_q = 16'h02B4;
             37:   dout_q = 16'h07A8;
             38:   dout_q = 16'hF143;
             39:   dout_q = 16'hFB18;
             40:   dout_q = 16'h0C7C;
             41:   dout_q = 16'h06D4;
             42:   dout_q = 16'h0020;
             43:   dout_q = 16'hEE7D;
             44:   dout_q = 16'h0322;
             45:   dout_q = 16'h0782;
             46:   dout_q = 16'hFD1F;
             47:   dout_q = 16'h0F43;
             48:   dout_q = 16'h0800;
             49:   dout_q = 16'h04BA;
             50:   dout_q = 16'hF8AD;
             51:   dout_q = 16'hEF33;
             52:   dout_q = 16'h0A86;
             53:   dout_q = 16'h08E7;
             54:   dout_q = 16'hF848;
             55:   dout_q = 16'hF8C6;
             56:   dout_q = 16'hFB84;
             57:   dout_q = 16'hF066;
             58:   dout_q = 16'hEFB4;
             59:   dout_q = 16'h099C;
             60:   dout_q = 16'hFFA4;
             61:   dout_q = 16'hF43D;
             62:   dout_q = 16'h0BBD;
             63:   dout_q = 16'h0193;
             64:   dout_q = 16'hEC00;
             65:   dout_q = 16'h0193;
             66:   dout_q = 16'h0BBD;
             67:   dout_q = 16'hF43D;
             68:   dout_q = 16'hFFA4;
             69:   dout_q = 16'h099C;
             70:   dout_q = 16'hEFB4;
             71:   dout_q = 16'hF066;
             72:   dout_q = 16'hFB84;
             73:   dout_q = 16'hF8C6;
             74:   dout_q = 16'hF848;
             75:   dout_q = 16'h08E7;
             76:   dout_q = 16'h0A86;
             77:   dout_q = 16'hEF33;
             78:   dout_q = 16'hF8AD;
             79:   dout_q = 16'h04BA;
             80:   dout_q = 16'h0800;
             81:   dout_q = 16'h0F43;
             82:   dout_q = 16'hFD1F;
             83:   dout_q = 16'h0782;
             84:   dout_q = 16'h0322;
             85:   dout_q = 16'hEE7D;
             86:   dout_q = 16'h0020;
             87:   dout_q = 16'h06D4;
             88:   dout_q = 16'h0C7C;
             89:   dout_q = 16'hFB18;
             90:   dout_q = 16'hF143;
             91:   dout_q = 16'h07A8;
             92:   dout_q = 16'h02B4;
             93:   dout_q = 16'h0C65;
             94:   dout_q = 16'h0517;
             95:   dout_q = 16'hFF58;
             96:   dout_q = 16'h1400;
             97:   dout_q = 16'hFF58;
             98:   dout_q = 16'h0517;
             99:   dout_q = 16'h0C65;
            100:   dout_q = 16'h02B4;
            101:   dout_q = 16'h07A8;
            102:   dout_q = 16'hF143;
            103:   dout_q = 16'hFB18;
            104:   dout_q = 16'h0C7C;
            105:   dout_q = 16'h06D4;
            106:   dout_q = 16'h0020;
            107:   dout_q = 16'hEE7D;
            108:   dout_q = 16'h0322;
            109:   dout_q = 16'h0782;
            110:   dout_q = 16'hFD1F;
            111:   dout_q = 16'h0F43;
            112:   dout_q = 16'h0800;
            113:   dout_q = 16'h04BA;
            114:   dout_q = 16'hF8AD;
            115:   dout_q = 16'hEF33;
            116:   dout_q = 16'h0A86;
            117:   dout_q = 16'h08E7;
            118:   dout_q = 16'hF848;
            119:   dout_q = 16'hF8C6;
            120:   dout_q = 16'hFB84;
            121:   dout_q = 16'hF066;
            122:   dout_q = 16'hEFB4;
            123:   dout_q = 16'h099C;
            124:   dout_q = 16'hFFA4;
            125:   dout_q = 16'hF43D;
            126:   dout_q = 16'h0BBD;
            127:   dout_q = 16'h0193;
            128:   dout_q = 16'hEC00;
            129:   dout_q = 16'h0193;
            130:   dout_q = 16'h0BBD;
            131:   dout_q = 16'hF43D;
            132:   dout_q = 16'hFFA4;
            133:   dout_q = 16'h099C;
            134:   dout_q = 16'hEFB4;
            135:   dout_q = 16'hF066;
            136:   dout_q = 16'hFB84;
            137:   dout_q = 16'hF8C6;
            138:   dout_q = 16'hF848;
            139:   dout_q = 16'h08E7;
            140:   dout_q = 16'h0A86;
            141:   dout_q = 16'hEF33;
            142:   dout_q = 16'hF8AD;
            143:   dout_q = 16'h04BA;
            144:   dout_q = 16'h0800;
            145:   dout_q = 16'h0F43;
            146:   dout_q = 16'hFD1F;
            147:   dout_q = 16'h0782;
            148:   dout_q = 16'h0322;
            149:   dout_q = 16'hEE7D;
            150:   dout_q = 16'h0020;
            151:   dout_q = 16'h06D4;
            152:   dout_q = 16'h0C7C;
            153:   dout_q = 16'hFB18;
            154:   dout_q = 16'hF143;
            155:   dout_q = 16'h07A8;
            156:   dout_q = 16'h02B4;
            157:   dout_q = 16'h0C65;
            158:   dout_q = 16'h0517;
            159:   dout_q = 16'hFF58;

          default: dout_q = 16'h0000;
    endcase

endmodule
