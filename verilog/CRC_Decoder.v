`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/01/2023 12:23:19 AM
// Design Name: 
// Module Name: CRC
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


module CRC_Decoder #(
    parameter INPUT_BITS = 20,
    parameter OUTPUT_BITS = INPUT_BITS - 4
    )
    (
        input clk,
        input start,
        input[INPUT_BITS-1:0] InputData,
        output reg Ready,
        output reg valid,
        output [OUTPUT_BITS-1:0] OutputData
    );

    wire[4:0] Divisor = 5'b10011;
    reg[4:0] Divident;

    reg[15:0] Counter;
    reg endOfOp;

    assign OutputData = InputData[INPUT_BITS-1:4];

    always @(posedge clk) begin
        if(!start) begin
            // OutputData <= 0;
            Counter <= 0;
            Ready <= 0;
            endOfOp <= 0;
            Divident <= 0;
            valid <= 0;
        end else begin
            valid <= 0;
            if(!Counter)
                if(!endOfOp) begin
                    if(InputData[INPUT_BITS-1])
                        Divident <= 
                            {(InputData[INPUT_BITS-2:INPUT_BITS-5] ^ Divisor[3:0]),
                                InputData[INPUT_BITS-6]};
                    else
                        Divident <= {InputData[INPUT_BITS-2:INPUT_BITS-5],
                            InputData[INPUT_BITS-6]};
                    Counter <= Counter + 1;
                end else begin
                    if(Divident == 0) begin
                        valid <= 1;
                    end
                    // else begin
                    //     OutputData <= 0; // ??
                    // end
                    Ready <= 1;
                end
            else begin
                Counter <= Counter + 1;
                if(Counter == INPUT_BITS-5) begin
                    endOfOp <= 1;
                    Counter <= 0;
                    if(Divident[4])
                        Divident <= Divident ^ Divisor;
                end else begin
                    if(Divident[4])
                        Divident <= {(Divident[3:0] ^ Divisor[3:0]),
                            InputData[INPUT_BITS - 6 - Counter]};
                    else
                        Divident <= {Divident[3:0], InputData[INPUT_BITS - 6 - Counter]};
                end
            end
        end
    end

endmodule
