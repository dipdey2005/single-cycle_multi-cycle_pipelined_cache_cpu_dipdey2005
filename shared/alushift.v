`timescale 1ns/1ps
module alushift (
    input  [31:0] A,
    input  [31:0] B,
    input         dir,   // 0 = left, 1 = right
    output [31:0] Y
);

    wire [4:0] shift_amount;

    assign shift_amount = B[4:0];

    assign #2 Y = dir ? (A >> shift_amount) : (A << shift_amount);

endmodule
