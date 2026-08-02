`timescale 1ns/1ps

module alu_ctrl (
    input  [2:0] func3,
    input  [6:0] func7,
    output [3:0] alu_ctrl
);

    wire f7_5;
    assign f7_5 = func7[5];

    assign alu_ctrl =
           (func3 == 3'b000 && f7_5 == 1'b0) ? 4'b0000 : // ADD
           (func3 == 3'b000 && f7_5 == 1'b1) ? 4'b0001 : // SUB

           (func3 == 3'b001)                ? 4'b0010 : // SLL
           (func3 == 3'b010)                ? 4'b0011 : // SLT
           (func3 == 3'b011)                ? 4'b0100 : // SLTU
           (func3 == 3'b100)                ? 4'b0101 : // XOR

           (func3 == 3'b101 && f7_5 == 1'b0) ? 4'b0110 : // SRL
           (func3 == 3'b101 && f7_5 == 1'b1) ? 4'b0111 : // SRA

           (func3 == 3'b110)                ? 4'b1000 : // OR
           (func3 == 3'b111)                ? 4'b1001 : // AND

           4'b0000; // default ADD

endmodule