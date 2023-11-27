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

`define NUMBER_OF_TESTS 100
`define HADAMARD 16
`define PAM_LEVEL 4
`define BIT_NUM ($clog2(`HADAMARD) + $clog2(`PAM_LEVEL))
`define N (`BIT_NUM * `HADAMARD + 4) // input number of bits
`define M ((`HADAMARD-1) * $clog2(`PAM_LEVEL)) // output number of bits
// `define INPUT_BITS (`HADAMARD * `BIT_NUM + 4)

module Wrapper_Receiver_tb;

    reg clk = 0;
    reg resetn = 0;
    // reg serial_in = 0;
    reg[`N-1:0] input_data;
    wire[`M-1:0] output_data;
    wire ready;

    always @(clk)
        clk <= #5 ~clk;

    reg[`N-1:0] input_array[`NUMBER_OF_TESTS-1:0];
    reg[`M-1:0] output_array[`NUMBER_OF_TESTS-1:0];

    integer i;
    integer j;
    integer number_of_erros = 0;
    initial begin
        $readmemb("EncodedData.txt", input_array);
        $readmemb("DecodedData.txt", output_array);
        
        // input_data = input_array[0];
        // resetn = 0;
        // @(posedge clk);
        // resetn = #1 1;

        for(j = 0; j < `NUMBER_OF_TESTS; j = j + 1) begin
            input_data = input_array[j];
            resetn = 0;
            @(posedge clk);
            resetn = #1 1;
            for(i = 0; i < 2 * `N; i = i + 1)
                @(posedge clk);
            // @(posedge ready);
            #1;
            if(output_data !== output_array[j]) begin
                number_of_erros = number_of_erros + 1;
                $write("ERROR : expected %b returned %b\n", output_data, output_array[j]);
            end
        end

        if(number_of_erros == 0) begin
            $write("ALL TESTS PASSED!\n");
        end else begin
            $write("number of errors = %d\n", number_of_erros);
        end
        $stop;
    end

    Wrapper_Receiver receiver(
        .clk(clk),
        .resetn(resetn),
        .input_data(input_data),
        .output_data(output_data),
        .ready(ready)
    );
    defparam receiver.HADAMARD = `HADAMARD;
    defparam receiver.PAM_LEVEL_LOG = $clog2(`PAM_LEVEL);
    // log2(HADAMARD) + log2(PAM_LEVEL)
    defparam receiver.BIT_NUM = `BIT_NUM;
    // 2 * log2(HADAMARD) + log2(PAM_LEVEL)
    defparam receiver.MIDLE_BITS = $clog2(`HADAMARD) + `BIT_NUM;

endmodule
