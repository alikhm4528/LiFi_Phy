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

module Wrapper_Receiver #(
    parameter PAM_LEVEL_LOG = 2,
    parameter HADAMARD = 4,
    parameter BIT_NUM = 4,
    parameter MIDLE_BITS = 6, // number of bits of midle registers
    parameter OUT_BITS = PAM_LEVEL_LOG * (HADAMARD-1),
    parameter INPUT_BITS = HADAMARD * BIT_NUM + 4,
    parameter CRC_OUTPUT_BITS = INPUT_BITS - 4
    )
    (
    input clk,
    input resetn,
    input[INPUT_BITS-1:0] input_data,
    output wire[OUT_BITS-1:0] output_data,
    output wire ready
    );

    wire crc_valid;
    wire[CRC_OUTPUT_BITS-1:0] crc_output;
    CRC_Decoder decoder(
        .clk(clk),
        .start(resetn),
        .InputData(input_data),
        .Ready(),
        .valid(crc_valid),
        .OutputData(crc_output)
    );
    defparam decoder.INPUT_BITS = INPUT_BITS;

    Receiver receiver(
        .clk(clk),
        .resetn(crc_valid),
        .input_data(crc_output),
        .output_data(output_data),
        .ready(ready)
    );
    defparam receiver.HADAMARD = HADAMARD;
    defparam receiver.PAM_LEVEL_LOG = PAM_LEVEL_LOG;
    // log2(HADAMARD) + log2(PAM_LEVEL)
    defparam receiver.BIT_NUM = BIT_NUM;
    // 2 * log2(HADAMARD) + log2(PAM_LEVEL)
    defparam receiver.MIDLE_BITS = MIDLE_BITS;

endmodule
