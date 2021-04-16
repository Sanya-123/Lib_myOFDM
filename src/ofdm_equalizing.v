`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.03.2021 12:53:18
// Design Name: 
// Module Name: ofdm_equalizing
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

`include "commonOFDM.vh"

module ofdm_equalizing #(parameter DATA_SIZE = 16)(
    i_clk,
    i_reset,
    i_data_i,
    i_data_q,
    i_valid,
    o_data_i,
    o_data_q,
    i_sync_frame,
    o_valid,
    o_wayt_data
//    i_wayt_data
    ,
    d_data_for_div_i,
    d_data_for_div_q,
    d_div_coeff_i,
    d_div_coeff_q
    );
    
    input i_clk;
    input i_reset;
    input [DATA_SIZE-1:0] i_data_i;
    input [DATA_SIZE-1:0] i_data_q;
    input i_valid;
    output [DATA_SIZE-1:0] o_data_i;
    output [DATA_SIZE-1:0] o_data_q;
    input i_sync_frame;
    output o_valid;
    output o_wayt_data;
//    input i_wayt_data;

    output [DATA_SIZE-1:0] d_data_for_div_i;
    output [DATA_SIZE-1:0] d_data_for_div_q;
    output [DATA_SIZE-1:0] d_div_coeff_i;
    output [DATA_SIZE-1:0] d_div_coeff_q;
    
    //pilot -88 -63 -38 -13 13 38 63 88

localparam PILOT_MASK_L =                                                                               
    128'b00000000000010000000000000000000000001000000000000000000000000100000000000000000000000010000000000000000000000000000000000000000;
//**     |-1      |-10      |-20      |-30      |-40      |-50      |-60      |-70      |-80      |-90      |-100                       |-128
    
    
localparam PILOT_MASK_R =
    128'b00000000000000000000000000000000000000010000000000000000000000001000000000000000000000000100000000000000000000000010000000000000; 
//*      |127                       |101      |90       |80       |70       |60       |50       |40       |30       |20    |13          |0   

localparam PILOT_MASK = {PILOT_MASK_L, PILOT_MASK_R};

reg [DATA_SIZE-1:0] pilot_symbol_i [7:0] = {{`PILOT_P13_I}, {`PILOT_P38_I}, {`PILOT_P63_I}, {`PILOT_P88_I}, {`PILOT_P_88_I}, {`PILOT_P_63_I}, {`PILOT_P_38_I}, {`PILOT_P_13_I}};
reg [DATA_SIZE-1:0] pilot_symbol_q [7:0] = {{`PILOT_P13_Q}, {`PILOT_P38_Q}, {`PILOT_P63_Q}, {`PILOT_P88_Q}, {`PILOT_P_88_Q}, {`PILOT_P_63_Q}, {`PILOT_P_38_Q}, {`PILOT_P_13_Q}};

    
    reg [DATA_SIZE-1:0] data_symbol_i [255:0];
    reg [DATA_SIZE-1:0] data_symbol_q [255:0];
    
    reg wayt_data = 1'b1;
    reg [8:0] counter_resive_data = 0;
    reg [8:0] counter_send_data = 0;
    
    reg [DATA_SIZE-1:0] pilost_s_i [7:0];//принятые пилоты
    reg [DATA_SIZE-1:0] pilost_s_q [7:0];
    
    reg flag_calc_equ_coeff = 1'b0;
    reg [3:0] counter_div_data_equ_coeff = 0;
    reg [DATA_SIZE-1:0] div_pilots_a_i;
    reg [DATA_SIZE-1:0] div_pilots_a_q;
    reg [DATA_SIZE-1:0] div_pilots_b_i;
    reg [DATA_SIZE-1:0] div_pilots_b_q;
    
    wire valid_equ_coeff;
    reg d1_valid_equ_coeff;
    reg [3:0] counter_resive_data_equ_coeff = 0;
    wire [DATA_SIZE-1:0] div_pilots_res_i;
    wire [DATA_SIZE-1:0] div_pilots_res_q;
    reg [DATA_SIZE-1:0] calc_coefs_i [7:0];//насчитанные коэффициенты для эквалазера
    reg [DATA_SIZE-1:0] calc_coefs_q [7:0];
    
    reg [DATA_SIZE-1:0] calc_step_i [7:0];//насчитанные коэффициенты для эквалазера
    reg [DATA_SIZE-1:0] calc_step_q [7:0];
    reg calc_done = 1'b0;
    reg calc_step_done = 1'b0;
    
    reg [8:0] counter_send_data_to_div = 0;
    reg [DATA_SIZE-1:0] data_for_div_i;
    reg [DATA_SIZE-1:0] data_for_div_q;
    reg [DATA_SIZE-1:0] div_coeff_i;
    reg [DATA_SIZE-1:0] div_coeff_q;
    
    assign o_wayt_data = wayt_data;
    
    assign d_data_for_div_i = data_for_div_i;
    assign d_data_for_div_q = data_for_div_q;
    assign d_div_coeff_i = div_coeff_i;
    assign d_div_coeff_q = div_coeff_q;
    
    
    always @(posedge i_clk)
    begin : a_resive_data
        if(i_reset/* | i_sync_frame*/)
        begin
            counter_resive_data <= 0;
//            wayt_data <= 1'b1;
        end
        else
        begin
            if(wayt_data & i_valid) counter_resive_data <= counter_resive_data + 1;
            else                    counter_resive_data <= 0;
            if(wayt_data & i_valid) data_symbol_i[counter_resive_data] <= i_data_i;
            if(wayt_data & i_valid) data_symbol_q[counter_resive_data] <= i_data_q;
        end
    end
    
    always @(posedge i_clk)
    begin : a_resive_pilots
        if(i_reset)
        begin
            
        end
        else
        begin
            if(wayt_data & i_valid)
            begin
                case(counter_resive_data)
                9'd12: begin pilost_s_i[0] <= i_data_i; pilost_s_q[0] <= i_data_q; end
                9'd37: begin pilost_s_i[1] <= i_data_i; pilost_s_q[1] <= i_data_q; end
                9'd62: begin pilost_s_i[2] <= i_data_i; pilost_s_q[2] <= i_data_q; end
                9'd87: begin pilost_s_i[3] <= i_data_i; pilost_s_q[3] <= i_data_q; end
                9'd167: begin pilost_s_i[4] <= i_data_i; pilost_s_q[4] <= i_data_q; end
                9'd192: begin pilost_s_i[5] <= i_data_i; pilost_s_q[5] <= i_data_q; end
                9'd218: begin pilost_s_i[6] <= i_data_i; pilost_s_q[6] <= i_data_q; end
                9'd243: begin pilost_s_i[7] <= i_data_i; pilost_s_q[7] <= i_data_q; end 
                default: begin end
                endcase
            end
        end
    end
    
    //calc 8 equ symols on 243 counter_resive_data
    always @(posedge i_clk)
    begin
        if(i_reset)
        begin
            flag_calc_equ_coeff <= 1'b0;
        end
        else
        begin
            if((counter_resive_data == 244))            flag_calc_equ_coeff <= 1'b1;
            else if(counter_div_data_equ_coeff == 7)    flag_calc_equ_coeff <= 1'b0;
        end
    end
    
    always @(posedge i_clk)
    begin :a_calc_coeff
        if(flag_calc_equ_coeff) counter_div_data_equ_coeff <= counter_div_data_equ_coeff + 1;
        else                    counter_div_data_equ_coeff <= 0;
        
        div_pilots_a_i <= pilost_s_i[counter_div_data_equ_coeff];
        div_pilots_a_q <= pilost_s_q[counter_div_data_equ_coeff];
        div_pilots_b_i <= pilot_symbol_i[counter_div_data_equ_coeff];
        div_pilots_b_q <= pilot_symbol_i[counter_div_data_equ_coeff];
    end
    
    always @(posedge i_clk)
    begin :a_resive_calc_coeff
        if(valid_equ_coeff)     counter_resive_data_equ_coeff <= counter_resive_data_equ_coeff + 1;
        else                    counter_resive_data_equ_coeff <= 0;
        
        if(valid_equ_coeff) calc_coefs_i[counter_resive_data_equ_coeff] <= div_pilots_res_i;
        if(valid_equ_coeff) calc_coefs_q[counter_resive_data_equ_coeff] <= div_pilots_res_q;
        
        
    end
    
    always @(posedge i_clk)
    begin :a_resive_calc_step
        if(valid_equ_coeff)
        begin
//            case(counter_resive_data_equ_coeff)
//            4'd1: begin calc_step_i[1] <= (div_pilots_res_i - calc_coefs_i[0]);                                     end
//            4'd2: begin calc_step_i[2] <= (div_pilots_res_i - calc_coefs_i[1]); calc_step_i[1] <= calc_step_i[1]/25;end
//            4'd3: begin calc_step_i[3] <= (div_pilots_res_i - calc_coefs_i[2]); calc_step_i[2] <= calc_step_i[2]/25;end
//            4'd4: begin calc_step_i[4] <= (div_pilots_res_i - calc_coefs_i[3]); calc_step_i[3] <= calc_step_i[3]/25;end
//            4'd5: begin calc_step_i[5] <= (div_pilots_res_i - calc_coefs_i[4]); calc_step_i[4] <= calc_step_i[4]/25;end
//            4'd6: begin calc_step_i[6] <= (div_pilots_res_i - calc_coefs_i[5]); calc_step_i[5] <= calc_step_i[5]/25;end
//            4'd7: begin calc_step_i[7] <= (div_pilots_res_i - calc_coefs_i[6]); calc_step_i[6] <= calc_step_i[6]/25;end
//            endcase
//            if(counter_resive_data_equ_coeff == 4'd7)   calc_step_i[0] <= (calc_coefs_i[0] - div_pilots_res_i);
            //easy etnterpolation
            case(counter_resive_data_equ_coeff)
            4'd1: begin calc_step_i[1] <= ({div_pilots_res_i[DATA_SIZE-1],div_pilots_res_i[DATA_SIZE-1:1]} - {calc_coefs_i[0][DATA_SIZE-1], calc_coefs_i[0][DATA_SIZE-1:1]}); end
            4'd2: begin calc_step_i[2] <= ({div_pilots_res_i[DATA_SIZE-1],div_pilots_res_i[DATA_SIZE-1:1]} - {calc_coefs_i[1][DATA_SIZE-1], calc_coefs_i[1][DATA_SIZE-1:1]}); end
            4'd3: begin calc_step_i[3] <= ({div_pilots_res_i[DATA_SIZE-1],div_pilots_res_i[DATA_SIZE-1:1]} - {calc_coefs_i[2][DATA_SIZE-1], calc_coefs_i[2][DATA_SIZE-1:1]}); end
            4'd4: begin calc_step_i[4] <= ({div_pilots_res_i[DATA_SIZE-1],div_pilots_res_i[DATA_SIZE-1:1]} - {calc_coefs_i[3][DATA_SIZE-1], calc_coefs_i[3][DATA_SIZE-1:1]}); end
            4'd5: begin calc_step_i[5] <= ({div_pilots_res_i[DATA_SIZE-1],div_pilots_res_i[DATA_SIZE-1:1]} - {calc_coefs_i[4][DATA_SIZE-1], calc_coefs_i[4][DATA_SIZE-1:1]}); end
            4'd6: begin calc_step_i[6] <= ({div_pilots_res_i[DATA_SIZE-1],div_pilots_res_i[DATA_SIZE-1:1]} - {calc_coefs_i[5][DATA_SIZE-1], calc_coefs_i[5][DATA_SIZE-1:1]}); end
            4'd7: begin calc_step_i[7] <= ({calc_coefs_i[0][DATA_SIZE-1], calc_coefs_i[0][DATA_SIZE-1:1]} - {div_pilots_res_i[DATA_SIZE-1],div_pilots_res_i[DATA_SIZE-1:1]}); end
            endcase
            if(counter_resive_data_equ_coeff == 4'd7)   calc_step_i[0] <= ({calc_coefs_i[0][DATA_SIZE-1], calc_coefs_i[0][DATA_SIZE-1:1]} - {div_pilots_res_i[DATA_SIZE-1],div_pilots_res_i[DATA_SIZE-1:1]});
            
            case(counter_resive_data_equ_coeff)
            4'd1: begin calc_step_q[1] <= ({div_pilots_res_q[DATA_SIZE-1],div_pilots_res_q[DATA_SIZE-1:1]} - {calc_coefs_q[0][DATA_SIZE-1], calc_coefs_q[0][DATA_SIZE-1:1]}); end
            4'd2: begin calc_step_q[2] <= ({div_pilots_res_q[DATA_SIZE-1],div_pilots_res_q[DATA_SIZE-1:1]} - {calc_coefs_q[1][DATA_SIZE-1], calc_coefs_q[1][DATA_SIZE-1:1]}); end
            4'd3: begin calc_step_q[3] <= ({div_pilots_res_q[DATA_SIZE-1],div_pilots_res_q[DATA_SIZE-1:1]} - {calc_coefs_q[2][DATA_SIZE-1], calc_coefs_q[2][DATA_SIZE-1:1]}); end
            4'd4: begin calc_step_q[4] <= ({div_pilots_res_q[DATA_SIZE-1],div_pilots_res_q[DATA_SIZE-1:1]} - {calc_coefs_q[3][DATA_SIZE-1], calc_coefs_q[3][DATA_SIZE-1:1]}); end
            4'd5: begin calc_step_q[5] <= ({div_pilots_res_q[DATA_SIZE-1],div_pilots_res_q[DATA_SIZE-1:1]} - {calc_coefs_q[4][DATA_SIZE-1], calc_coefs_q[4][DATA_SIZE-1:1]}); end
            4'd6: begin calc_step_q[6] <= ({div_pilots_res_q[DATA_SIZE-1],div_pilots_res_q[DATA_SIZE-1:1]} - {calc_coefs_q[5][DATA_SIZE-1], calc_coefs_q[5][DATA_SIZE-1:1]}); end
            4'd7: begin calc_step_q[7] <= ({calc_coefs_q[0][DATA_SIZE-1], calc_coefs_q[0][DATA_SIZE-1:1]} - {div_pilots_res_q[DATA_SIZE-1],div_pilots_res_q[DATA_SIZE-1:1]}); end
            endcase
            if(counter_resive_data_equ_coeff == 4'd7)   calc_step_q[0] <= ({calc_coefs_q[0][DATA_SIZE-1], calc_coefs_q[0][DATA_SIZE-1:1]} - {div_pilots_res_q[DATA_SIZE-1],div_pilots_res_q[DATA_SIZE-1:1]});
            
            
        end
        else
        begin
//            calc_step_i[7] <= calc_step_i[7]/26;
//            calc_step_i[0] <= calc_step_i[0]/26;
        end
    end
    
    always @(posedge i_clk)
    begin
        if(i_reset)
        begin
            wayt_data <= 1'b1;
        end
        else
        begin
            if((counter_resive_data == 255) & wayt_data & i_valid)  wayt_data <= 1'b0;
            else if(counter_resive_data_equ_coeff == 4'd7)          wayt_data <= 1'b1;
        end
    end
    
    always @(posedge i_clk)
    begin
        if(i_reset)
        begin
            calc_done <= 1'b0;
        end
        else
        begin
            d1_valid_equ_coeff <= valid_equ_coeff;
            if({d1_valid_equ_coeff, valid_equ_coeff} == 2'b10)  calc_done <= 1'b1;
            else if (counter_send_data_to_div == 256)           calc_done <= 1'b0;
            
            if(!wayt_data)
            begin
                
            end
        end
    end
    
    always @(posedge i_clk)
    begin
        if(calc_done | ({d1_valid_equ_coeff, valid_equ_coeff} == 2'b10))    counter_send_data_to_div <= counter_send_data_to_div + 1;
        else                                                                counter_send_data_to_div <= 0;
    end
    
    always @(posedge i_clk)
    begin
        data_for_div_i <= data_symbol_i[counter_send_data_to_div];
        data_for_div_q <= data_symbol_q[counter_send_data_to_div];
        
        if(counter_send_data_to_div == 0)           div_coeff_i <= 1;
        else if(counter_send_data_to_div <= 13)     div_coeff_i <= calc_coefs_i[0] + calc_step_i[0];
        else if(counter_send_data_to_div <= 38)     div_coeff_i <= calc_coefs_i[1] + calc_step_i[1];
        else if(counter_send_data_to_div <= 63)     div_coeff_i <= calc_coefs_i[2] + calc_step_i[2];
        else if(counter_send_data_to_div <= 88)     div_coeff_i <= calc_coefs_i[3] + calc_step_i[3];
        
        else if(counter_send_data_to_div <= 127)    div_coeff_i <= calc_coefs_i[3];
        else if(counter_send_data_to_div <= 167)    div_coeff_i <= calc_coefs_i[4];
        
        else if(counter_send_data_to_div <= 193)    div_coeff_i <= calc_coefs_i[4] + calc_step_i[4];
        else if(counter_send_data_to_div <= 218)    div_coeff_i <= calc_coefs_i[5] + calc_step_i[5];
        else if(counter_send_data_to_div <= 243)    div_coeff_i <= calc_coefs_i[6] + calc_step_i[6];
        else if(counter_send_data_to_div <= 255)    div_coeff_i <= calc_coefs_i[7] + calc_step_i[7];
                
        
        if(counter_send_data_to_div == 0)           div_coeff_q <= 1;
        else if(counter_send_data_to_div <= 13)     div_coeff_q <= calc_coefs_q[0] + calc_step_q[0];
        else if(counter_send_data_to_div <= 38)     div_coeff_q <= calc_coefs_q[1] + calc_step_q[1];
        else if(counter_send_data_to_div <= 63)     div_coeff_q <= calc_coefs_q[2] + calc_step_q[2];
        else if(counter_send_data_to_div <= 88)     div_coeff_q <= calc_coefs_q[3] + calc_step_q[3];
        
        else if(counter_send_data_to_div <= 127)    div_coeff_q <= calc_coefs_q[3];
        else if(counter_send_data_to_div <= 167)    div_coeff_q <= calc_coefs_q[4];
        
        else if(counter_send_data_to_div <= 193)    div_coeff_q <= calc_coefs_q[4] + calc_step_q[4];
        else if(counter_send_data_to_div <= 218)    div_coeff_q <= calc_coefs_q[5] + calc_step_q[5];
        else if(counter_send_data_to_div <= 243)    div_coeff_q <= calc_coefs_q[6] + calc_step_q[6];
        else if(counter_send_data_to_div <= 255)    div_coeff_q <= calc_coefs_q[7] + calc_step_q[7];
    end
    
    
    div_complex #(.DATA_SIZE(DATA_SIZE)) 
    _calc_coeff(
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_valid(flag_calc_equ_coeff),
        .i_data_a_i(div_pilots_a_i),
        .i_data_a_q(div_pilots_a_q),
        .i_data_b_i(div_pilots_b_i),
        .i_data_b_q(div_pilots_b_q),
        .o_data_i(div_pilots_res_i),
        .o_data_q(div_pilots_res_q),
        .o_valid(valid_equ_coeff)
    );
    
    div_complex #(.DATA_SIZE(DATA_SIZE)) 
    _div_complex(
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_valid(calc_done),
        .i_data_a_i(data_for_div_i),
        .i_data_a_q(data_for_div_q),
        .i_data_b_i(div_coeff_i),
        .i_data_b_q(div_coeff_q),
        .o_data_i(o_data_i),
        .o_data_q(o_data_q),
        .o_valid(o_valid)
    );
    
endmodule
