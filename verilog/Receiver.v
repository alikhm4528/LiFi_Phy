`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/04/2023 11:18:54 PM
// Design Name: 
// Module Name: Receiver_tb
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

module Receiver #(
    parameter PAM_LEVEL_LOG = 2,
    parameter HADAMARD = 4,
    parameter BIT_NUM = 4,
    parameter MIDLE_BITS = 6, // number of bits of midle registers
    parameter OUT_BITS = PAM_LEVEL_LOG * (HADAMARD-1),
    parameter INPUT_BITS = HADAMARD * BIT_NUM
    )
    (
    input clk,
    input resetn,
    // input serial_in,
    input[INPUT_BITS-1:0] input_data,
    output reg[OUT_BITS-1:0] output_data,
    output reg ready
    );

    reg[BIT_NUM-1:0] data[HADAMARD-1:0];
    reg[3:0] cnt1;
    reg[3:0] cnt2;

    reg serial_in;

    integer i;
    always @(posedge clk) begin
        if(!resetn) begin
            for(i = 0; i < HADAMARD; i = i + 1)
                data[i] <= 0;
            cnt1 <= 0;
            cnt2 <= 0;
            ready <= 0;
            serial_in <= input_data[0];
        end else if(!ready) begin
            cnt1 <= cnt1 + 1;
            if((cnt1 == (BIT_NUM-1)) && (cnt2 == (HADAMARD-1)))
                serial_in <= 1'b0;
            else
                serial_in <= input_data[cnt1 + cnt2 * BIT_NUM + 1];
            data[cnt2] <= {serial_in, data[cnt2][BIT_NUM-1:1]};
            ready <= 0;
            if(cnt1 == (BIT_NUM-1)) begin
                cnt1 <= 0;
                cnt2 <= cnt2 + 1;
                if(cnt2 == (HADAMARD-1)) begin
                    cnt2 <= 0;
                    ready <= 1;
                end
            end
        end
    end

    wire [MIDLE_BITS-1:0] offset[HADAMARD-2:0];
    
    genvar j;
    for(j = 0; j < (HADAMARD-1); j = j + 1) begin
        assign offset[j] = 1;
    end

    reg [MIDLE_BITS-1:0] out_vec[HADAMARD-1:1];
    
    integer k;
    always @(*) begin
        if(HADAMARD == 2) begin
            out_vec[1] = (data[1] - data[0]);
            out_vec[1] = ({out_vec[1][MIDLE_BITS-1], out_vec[1]} + offset[0]) >> 1;

            output_data = {out_vec[1][PAM_LEVEL_LOG-1:0]};
        end else if(HADAMARD == 4) begin
            out_vec[1] = (data[3] - data[2] + data[1] - data[0]) >> 1;
            out_vec[1] = ({out_vec[1][MIDLE_BITS-1], out_vec[1]} + offset[0]) >> 1;

            out_vec[2] = (data[3] + data[2] - data[1] - data[0]) >> 1;
            out_vec[2] = ({out_vec[2][MIDLE_BITS-1], out_vec[2]} + offset[1]) >> 1;

            out_vec[3] = (data[3] - data[2] - data[1] + data[0]) >> 1;
            out_vec[3] = ({out_vec[3][MIDLE_BITS-1], out_vec[3]} + offset[2]) >> 1;

            output_data = {
                out_vec[1][PAM_LEVEL_LOG-1:0],
                out_vec[2][PAM_LEVEL_LOG-1:0],
                out_vec[3][PAM_LEVEL_LOG-1:0]};
        end else if(HADAMARD == 8) begin
            out_vec[1] = (data[7] - data[6] + data[5] - data[4] +
                data[3] - data[2] + data[1] - data[0]);
            out_vec[1] = out_vec[1] >>> 2;
            out_vec[1] = ({out_vec[1][MIDLE_BITS-1], out_vec[1]} + offset[0]) >> 1;

            out_vec[2] = (data[7] + data[6] - data[5] - data[4] +
                data[3] + data[2] - data[1] - data[0]);
            out_vec[2] = out_vec[2] >>> 2;
            out_vec[2] = ({out_vec[2][MIDLE_BITS-1], out_vec[2]} + offset[1]) >> 1;

            out_vec[3] = (data[7] - data[6] - data[5] + data[4] +
                data[3] - data[2] - data[1] + data[0]);
            out_vec[3] = out_vec[3] >>> 2;  
            out_vec[3] = ({out_vec[3][MIDLE_BITS-1], out_vec[3]} + offset[2]) >> 1;

            out_vec[4] = (data[7] + data[6] + data[5] + data[4] -
                data[3] - data[2] - data[1] - data[0]);
            out_vec[4] = out_vec[4] >>> 2;  
            out_vec[4] = ({out_vec[4][MIDLE_BITS-1], out_vec[4]} + offset[3]) >> 1;

            out_vec[5] = (data[7] - data[6] + data[5] - data[4] -
                data[3] + data[2] - data[1] + data[0]);
            out_vec[5] = out_vec[5] >>> 2;  
            out_vec[5] = ({out_vec[5][MIDLE_BITS-1], out_vec[5]} + offset[4]) >> 1;

            out_vec[6] = (data[7] + data[6] - data[5] - data[4] -
                data[3] - data[2] + data[1] + data[0]);
            out_vec[6] = out_vec[6] >>> 2;  
            out_vec[6] = ({out_vec[6][MIDLE_BITS-1], out_vec[6]} + offset[5]) >> 1;

            out_vec[7] = (data[7] - data[6] - data[5] + data[4] -
                data[3] + data[2] + data[1] - data[0]);
            out_vec[7] = out_vec[7] >>> 2;  
            out_vec[7] = ({out_vec[7][MIDLE_BITS-1], out_vec[7]} + offset[6]) >> 1;

            output_data = {
                out_vec[1][PAM_LEVEL_LOG-1:0],
                out_vec[2][PAM_LEVEL_LOG-1:0],
                out_vec[3][PAM_LEVEL_LOG-1:0],
                out_vec[4][PAM_LEVEL_LOG-1:0],
                out_vec[5][PAM_LEVEL_LOG-1:0],
                out_vec[6][PAM_LEVEL_LOG-1:0],
                out_vec[7][PAM_LEVEL_LOG-1:0]};
        end else if(HADAMARD == 16) begin
            out_vec[1] = (
                data[15] - data[14] + data[13] - data[12] +
                data[11] - data[10] + data[9] - data[8] +
                data[7] - data[6] + data[5] - data[4] +
                data[3] - data[2] + data[1] - data[0]);
            out_vec[1] = out_vec[1] >>> 3;
            out_vec[1] = ({out_vec[1][MIDLE_BITS-1], out_vec[1]} + offset[0]) >> 1;

            out_vec[2] = (
                data[15] + data[14] - data[13] - data[12] +
                data[11] + data[10] - data[9] - data[8] +
                data[7] + data[6] - data[5] - data[4] +
                data[3] + data[2] - data[1] - data[0]);
            out_vec[2] = out_vec[2] >>> 3;
            out_vec[2] = ({out_vec[2][MIDLE_BITS-1], out_vec[2]} + offset[1]) >> 1;

            out_vec[3] = (
                data[15] - data[14] - data[13] + data[12] +
                data[11] - data[10] - data[9] + data[8] +
                data[7] - data[6] - data[5] + data[4] +
                data[3] - data[2] - data[1] + data[0]);
            out_vec[3] = out_vec[3] >>> 3;  
            out_vec[3] = ({out_vec[3][MIDLE_BITS-1], out_vec[3]} + offset[2]) >> 1;

            out_vec[4] = (
                data[15] + data[14] + data[13] + data[12] -
                data[11] - data[10] - data[9] - data[8] +
                data[7] + data[6] + data[5] + data[4] -
                data[3] - data[2] - data[1] - data[0]);
            out_vec[4] = out_vec[4] >>> 3;  
            out_vec[4] = ({out_vec[4][MIDLE_BITS-1], out_vec[4]} + offset[3]) >> 1;

            out_vec[5] = (
                data[15] - data[14] + data[13] - data[12] -
                data[11] + data[10] - data[9] + data[8] +
                data[7] - data[6] + data[5] - data[4] -
                data[3] + data[2] - data[1] + data[0]);
            out_vec[5] = out_vec[5] >>> 3;  
            out_vec[5] = ({out_vec[5][MIDLE_BITS-1], out_vec[5]} + offset[4]) >> 1;

            out_vec[6] = (
                data[15] + data[14] - data[13] - data[12] -
                data[11] - data[10] + data[9] + data[8] +
                data[7] + data[6] - data[5] - data[4] -
                data[3] - data[2] + data[1] + data[0]);
            out_vec[6] = out_vec[6] >>> 3;  
            out_vec[6] = ({out_vec[6][MIDLE_BITS-1], out_vec[6]} + offset[5]) >> 1;

            out_vec[7] = (
                data[15] - data[14] - data[13] + data[12] -
                data[11] + data[10] + data[9] - data[8] +
                data[7] - data[6] - data[5] + data[4] -
                data[3] + data[2] + data[1] - data[0]);
            out_vec[7] = out_vec[7] >>> 3;  
            out_vec[7] = ({out_vec[7][MIDLE_BITS-1], out_vec[7]} + offset[6]) >> 1;

            out_vec[8] = (
                data[15] + data[14] + data[13] + data[12] +
                data[11] + data[10] + data[9] + data[8] -
                data[7] - data[6] - data[5] - data[4] -
                data[3] - data[2] - data[1] - data[0]);
            out_vec[8] = out_vec[8] >>> 3;
            out_vec[8] = ({out_vec[8][MIDLE_BITS-1], out_vec[8]} + offset[7]) >> 1;

            out_vec[9] = (
                data[15] - data[14] + data[13] - data[12] +
                data[11] - data[10] + data[9] - data[8] -
                data[7] + data[6] - data[5] + data[4] -
                data[3] + data[2] - data[1] + data[0]);
            out_vec[9] = out_vec[9] >>> 3;
            out_vec[9] = ({out_vec[9][MIDLE_BITS-1], out_vec[9]} + offset[8]) >> 1;

            out_vec[10] = (
                data[15] + data[14] - data[13] - data[12] +
                data[11] + data[10] - data[9] - data[8] -
                data[7] - data[6] + data[5] + data[4] -
                data[3] - data[2] + data[1] + data[0]);
            out_vec[10] = out_vec[10] >>> 3;  
            out_vec[10] = ({out_vec[10][MIDLE_BITS-1], out_vec[10]} + offset[9]) >> 1;

            out_vec[11] = (
                data[15] - data[14] - data[13] + data[12] +
                data[11] - data[10] - data[9] + data[8] -
                data[7] + data[6] + data[5] - data[4] -
                data[3] + data[2] + data[1] - data[0]);
            out_vec[11] = out_vec[11] >>> 3;  
            out_vec[11] = ({out_vec[11][MIDLE_BITS-1], out_vec[11]} + offset[10]) >> 1;

            out_vec[12] = (
                data[15] + data[14] + data[13] + data[12] -
                data[11] - data[10] - data[9] - data[8] -
                data[7] - data[6] - data[5] - data[4] +
                data[3] + data[2] + data[1] + data[0]);
            out_vec[12] = out_vec[12] >>> 3;  
            out_vec[12] = ({out_vec[12][MIDLE_BITS-1], out_vec[12]} + offset[11]) >> 1;

            out_vec[13] = (
                data[15] - data[14] + data[13] - data[12] -
                data[11] + data[10] - data[9] + data[8] -
                data[7] + data[6] - data[5] + data[4] +
                data[3] - data[2] + data[1] - data[0]);
            out_vec[13] = out_vec[13] >>> 3;  
            out_vec[13] = ({out_vec[13][MIDLE_BITS-1], out_vec[13]} + offset[12]) >> 1;

            out_vec[14] = (
                data[15] + data[14] - data[13] - data[12] -
                data[11] - data[10] + data[9] + data[8] -
                data[7] - data[6] + data[5] + data[4] +
                data[3] + data[2] - data[1] - data[0]);
            out_vec[14] = out_vec[14] >>> 3;  
            out_vec[14] = ({out_vec[14][MIDLE_BITS-1], out_vec[14]} + offset[13]) >> 1;

            out_vec[15] = (
                data[15] - data[14] - data[13] + data[12] -
                data[11] + data[10] + data[9] - data[8] -
                data[7] + data[6] + data[5] - data[4] +
                data[3] - data[2] - data[1] + data[0]);
            out_vec[15] = out_vec[15] >>> 3;  
            out_vec[15] = ({out_vec[15][MIDLE_BITS-1], out_vec[15]} + offset[14]) >> 1;

            output_data = {
                out_vec[1][PAM_LEVEL_LOG-1:0],
                out_vec[2][PAM_LEVEL_LOG-1:0],
                out_vec[3][PAM_LEVEL_LOG-1:0],
                out_vec[4][PAM_LEVEL_LOG-1:0],
                out_vec[5][PAM_LEVEL_LOG-1:0],
                out_vec[6][PAM_LEVEL_LOG-1:0],
                out_vec[7][PAM_LEVEL_LOG-1:0],
                out_vec[8][PAM_LEVEL_LOG-1:0],
                out_vec[9][PAM_LEVEL_LOG-1:0],
                out_vec[10][PAM_LEVEL_LOG-1:0],
                out_vec[11][PAM_LEVEL_LOG-1:0],
                out_vec[12][PAM_LEVEL_LOG-1:0],
                out_vec[13][PAM_LEVEL_LOG-1:0],
                out_vec[14][PAM_LEVEL_LOG-1:0],
                out_vec[15][PAM_LEVEL_LOG-1:0]};
        end
    end
endmodule
