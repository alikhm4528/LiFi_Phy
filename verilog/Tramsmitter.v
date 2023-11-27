`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/04/2023 04:40:25 PM
// Design Name: 
// Module Name: Tramsmitter
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


module Tramsmitter #(
    parameter PAM_LEVEL_LOG = 2,
    parameter HADAMARD = 4,
    parameter BIT_NUM = 4,
    parameter MIDLE_BITS = 6, // number of bits of midle registers
    parameter OUT_BITS = HADAMARD * BIT_NUM,
    parameter INPUT_BITS = PAM_LEVEL_LOG * (HADAMARD-1)
    )
    (
    input clk,
    input resetn,
    // input serial_in,
    input[INPUT_BITS-1:0] input_data,
    output reg[OUT_BITS-1:0] output_data,
    output reg ready
    );

    reg[PAM_LEVEL_LOG-1:0] data[HADAMARD-1:0];
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
            if((cnt1 == (PAM_LEVEL_LOG-1)) && (cnt2 == (HADAMARD-2)))
                serial_in <= 1'b0;
            else
                serial_in <= input_data[(cnt1 + cnt2 * PAM_LEVEL_LOG + 1)];
            if(PAM_LEVEL_LOG >= 2) begin
                data[cnt2] <= {serial_in, data[cnt2][PAM_LEVEL_LOG-1:1]};
            end else begin
                data[cnt2] <= serial_in;
            end
            ready <= 0;
            if(cnt1 == (PAM_LEVEL_LOG-1)) begin
                cnt1 <= 0;
                cnt2 <= cnt2 + 1;
                if(cnt2 == (HADAMARD-2)) begin
                    cnt2 <= 0;
                    ready <= 1;
                end
            end
        end
    end

    wire [MIDLE_BITS-1:0] offset[HADAMARD-1:0];
    
    assign offset[0] = 0;
    genvar j;
    for(j = 1; j < HADAMARD; j = j + 1) begin
        assign offset[j] = (HADAMARD >> 1);
    end

    reg [MIDLE_BITS-1:0] out_vec[HADAMARD-1:0];
    reg [MIDLE_BITS-1:0] min_vec;

    integer k;
    always @(*) begin
        if(HADAMARD == 2) begin
            out_vec[0] = (data[1] + data[0]) + offset[0];
            out_vec[1] = (data[1] - data[0]) + offset[1];

            min_vec = out_vec[0];
            for(k = 1; k < 2; k = k + 1) begin
                if($signed(min_vec) > $signed(out_vec[k]))
                    min_vec = out_vec[k];
            end

            out_vec[0] = out_vec[0] - min_vec;
            out_vec[1] = out_vec[1] - min_vec;

            output_data = {
                out_vec[0][BIT_NUM-1:0],
                out_vec[1][BIT_NUM-1:0]};
        end else if(HADAMARD == 4) begin
            out_vec[0] = (data[3] + data[2] + data[1] + data[0]) + offset[0];
            out_vec[1] = (data[3] - data[2] + data[1] - data[0]) + offset[1];
            out_vec[2] = (data[3] + data[2] - data[1] - data[0]) + offset[2];
            out_vec[3] = (data[3] - data[2] - data[1] + data[0]) + offset[3];

            min_vec = out_vec[0];
            for(k = 1; k < 4; k = k + 1) begin
                if($signed(min_vec) > $signed(out_vec[k]))
                    min_vec = out_vec[k];
            end

            out_vec[0] = out_vec[0] - min_vec;
            out_vec[1] = out_vec[1] - min_vec;
            out_vec[2] = out_vec[2] - min_vec;
            out_vec[3] = out_vec[3] - min_vec;

            output_data = {
                out_vec[0][BIT_NUM-1:0],
                out_vec[1][BIT_NUM-1:0],
                out_vec[2][BIT_NUM-1:0],
                out_vec[3][BIT_NUM-1:0]};
        end else if(HADAMARD == 8) begin
            out_vec[0] = (data[7] + data[6] + data[5] + data[4] +
                data[3] + data[2] + data[1] + data[0]) + offset[0];

            out_vec[1] = (data[7] - data[6] + data[5] - data[4] +
                data[3] - data[2] + data[1] - data[0]) + offset[1];

            out_vec[2] = (data[7] + data[6] - data[5] - data[4] +
                data[3] + data[2] - data[1] - data[0]) + offset[2];

            out_vec[3] = (data[7] - data[6] - data[5] + data[4] +
                data[3] - data[2] - data[1] + data[0]) + offset[3];

            out_vec[4] = (data[7] + data[6] + data[5] + data[4] -
                data[3] - data[2] - data[1] - data[0]) + offset[4];

            out_vec[5] = (data[7] - data[6] + data[5] - data[4] -
                data[3] + data[2] - data[1] + data[0]) + offset[5];

            out_vec[6] = (data[7] + data[6] - data[5] - data[4] -
                data[3] - data[2] + data[1] + data[0]) + offset[6];

            out_vec[7] = (data[7] - data[6] - data[5] + data[4] -
                data[3] + data[2] + data[1] - data[0]) + offset[7];

            min_vec = out_vec[0];
            for(k = 1; k < 8; k = k + 1) begin
                if($signed(min_vec) > $signed(out_vec[k]))
                    min_vec = out_vec[k];
            end

            out_vec[0] = out_vec[0] - min_vec;
            out_vec[1] = out_vec[1] - min_vec;
            out_vec[2] = out_vec[2] - min_vec;
            out_vec[3] = out_vec[3] - min_vec;
            out_vec[4] = out_vec[4] - min_vec;
            out_vec[5] = out_vec[5] - min_vec;
            out_vec[6] = out_vec[6] - min_vec;
            out_vec[7] = out_vec[7] - min_vec;

            output_data = {
                out_vec[0][BIT_NUM-1:0],
                out_vec[1][BIT_NUM-1:0],
                out_vec[2][BIT_NUM-1:0],
                out_vec[3][BIT_NUM-1:0],
                out_vec[4][BIT_NUM-1:0],
                out_vec[5][BIT_NUM-1:0],
                out_vec[6][BIT_NUM-1:0],
                out_vec[7][BIT_NUM-1:0]};
        end else if(HADAMARD == 16) begin
            out_vec[0] = (
                data[15] + data[14] + data[13] + data[12] +
                data[11] + data[10] + data[9] + data[8] +
                data[7] + data[6] + data[5] + data[4] +
                data[3] + data[2] + data[1] + data[0]) + offset[0];

            out_vec[1] = (
                data[15] - data[14] + data[13] - data[12] +
                data[11] - data[10] + data[9] - data[8] +
                data[7] - data[6] + data[5] - data[4] +
                data[3] - data[2] + data[1] - data[0]) + offset[1];

            out_vec[2] = (
                data[15] + data[14] - data[13] - data[12] +
                data[11] + data[10] - data[9] - data[8] +
                data[7] + data[6] - data[5] - data[4] +
                data[3] + data[2] - data[1] - data[0]) + offset[2];

            out_vec[3] = (
                data[15] - data[14] - data[13] + data[12] +
                data[11] - data[10] - data[9] + data[8] +
                data[7] - data[6] - data[5] + data[4] +
                data[3] - data[2] - data[1] + data[0]) + offset[3];

            out_vec[4] = (
                data[15] + data[14] + data[13] + data[12] -
                data[11] - data[10] - data[9] - data[8] +
                data[7] + data[6] + data[5] + data[4] -
                data[3] - data[2] - data[1] - data[0]) + offset[4];

            out_vec[5] = (
                data[15] - data[14] + data[13] - data[12] -
                data[11] + data[10] - data[9] + data[8] +
                data[7] - data[6] + data[5] - data[4] -
                data[3] + data[2] - data[1] + data[0]) + offset[5];

            out_vec[6] = (
                data[15] + data[14] - data[13] - data[12] -
                data[11] - data[10] + data[9] + data[8] +
                data[7] + data[6] - data[5] - data[4] -
                data[3] - data[2] + data[1] + data[0]) + offset[6];

            out_vec[7] = (
                data[15] - data[14] - data[13] + data[12] -
                data[11] + data[10] + data[9] - data[8] +
                data[7] - data[6] - data[5] + data[4] -
                data[3] + data[2] + data[1] - data[0]) + offset[7];

            out_vec[8] = (
                data[15] + data[14] + data[13] + data[12] +
                data[11] + data[10] + data[9] + data[8] -
                data[7] - data[6] - data[5] - data[4] -
                data[3] - data[2] - data[1] - data[0]) + offset[8];

            out_vec[9] = (
                data[15] - data[14] + data[13] - data[12] +
                data[11] - data[10] + data[9] - data[8] -
                data[7] + data[6] - data[5] + data[4] -
                data[3] + data[2] - data[1] + data[0]) + offset[9];

            out_vec[10] = (
                data[15] + data[14] - data[13] - data[12] +
                data[11] + data[10] - data[9] - data[8] -
                data[7] - data[6] + data[5] + data[4] -
                data[3] - data[2] + data[1] + data[0]) + offset[10];

            out_vec[11] = (
                data[15] - data[14] - data[13] + data[12] +
                data[11] - data[10] - data[9] + data[8] -
                data[7] + data[6] + data[5] - data[4] -
                data[3] + data[2] + data[1] - data[0]) + offset[11];

            out_vec[12] = (
                data[15] + data[14] + data[13] + data[12] -
                data[11] - data[10] - data[9] - data[8] -
                data[7] - data[6] - data[5] - data[4] +
                data[3] + data[2] + data[1] + data[0]) + offset[12];

            out_vec[13] = (
                data[15] - data[14] + data[13] - data[12] -
                data[11] + data[10] - data[9] + data[8] -
                data[7] + data[6] - data[5] + data[4] +
                data[3] - data[2] + data[1] - data[0]) + offset[13];

            out_vec[14] = (
                data[15] + data[14] - data[13] - data[12] -
                data[11] - data[10] + data[9] + data[8] -
                data[7] - data[6] + data[5] + data[4] +
                data[3] + data[2] - data[1] - data[0]) + offset[14];

            out_vec[15] = (
                data[15] - data[14] - data[13] + data[12] -
                data[11] + data[10] + data[9] - data[8] -
                data[7] + data[6] + data[5] - data[4] +
                data[3] - data[2] - data[1] + data[0]) + offset[15];

            min_vec = out_vec[0];
            for(k = 1; k < 16; k = k + 1) begin
                if($signed(min_vec) > $signed(out_vec[k]))
                    min_vec = out_vec[k];
            end

            out_vec[0] = out_vec[0] - min_vec;
            out_vec[1] = out_vec[1] - min_vec;
            out_vec[2] = out_vec[2] - min_vec;
            out_vec[3] = out_vec[3] - min_vec;
            out_vec[4] = out_vec[4] - min_vec;
            out_vec[5] = out_vec[5] - min_vec;
            out_vec[6] = out_vec[6] - min_vec;
            out_vec[7] = out_vec[7] - min_vec;
            out_vec[8] = out_vec[8] - min_vec;
            out_vec[9] = out_vec[9] - min_vec;
            out_vec[10] = out_vec[10] - min_vec;
            out_vec[11] = out_vec[11] - min_vec;
            out_vec[12] = out_vec[12] - min_vec;
            out_vec[13] = out_vec[13] - min_vec;
            out_vec[14] = out_vec[14] - min_vec;
            out_vec[15] = out_vec[15] - min_vec;

            output_data = {
                out_vec[0][BIT_NUM-1:0],
                out_vec[1][BIT_NUM-1:0],
                out_vec[2][BIT_NUM-1:0],
                out_vec[3][BIT_NUM-1:0],
                out_vec[4][BIT_NUM-1:0],
                out_vec[5][BIT_NUM-1:0],
                out_vec[6][BIT_NUM-1:0],
                out_vec[7][BIT_NUM-1:0],
                out_vec[8][BIT_NUM-1:0],
                out_vec[9][BIT_NUM-1:0],
                out_vec[10][BIT_NUM-1:0],
                out_vec[11][BIT_NUM-1:0],
                out_vec[12][BIT_NUM-1:0],
                out_vec[13][BIT_NUM-1:0],
                out_vec[14][BIT_NUM-1:0],
                out_vec[15][BIT_NUM-1:0]};
        end
    end
endmodule
