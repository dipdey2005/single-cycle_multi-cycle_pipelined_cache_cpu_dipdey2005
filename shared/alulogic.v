`timescale 1ns/1ps
module alulogic (
    input  [31:0] A,
    input  [31:0] B,
    output [31:0] and_output,
    output [31:0] or_output
);


    assign #1 and_output = A & B;
    assign #1 or_output = A | B;

endmodule
