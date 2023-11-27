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

`define INPUT_BITS 20
`define OUTPUT_BITS (`INPUT_BITS - 4)

module CRC_tb;

    reg clk = 0;
    reg resetn;
    reg[`INPUT_BITS-1:0] InputData;
    wire Ready;
    wire valid;
    wire[`OUTPUT_BITS-1:0] OutputData;

    always @(clk)
        clk <= #5 ~clk;

    integer i;
    integer j;
    integer number_of_erros = 0;
    initial begin

        resetn = 0;

        InputData = 20'b1000_0000_0100_0010_0010;

        @(posedge clk);
        resetn = #1 1;

        for(i = 0; i < `INPUT_BITS; i = i + 1)
            @(posedge clk);
        
        $stop;
    end

    CRC_Decoder decoder(
        .clk(clk),
        .start(resetn),
        .InputData(InputData),
        .Ready(Ready),
        .valid(valid),
        .OutputData(OutputData)
    );
    defparam decoder.INPUT_BITS = `INPUT_BITS;

endmodule
