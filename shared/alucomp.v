`timescale 1ns/1ps
module alucomp (
    input  signed [31:0] A,
    input  signed [31:0] B,
    output [31:0] Y
);

    wire signed [31:0] diff;
    wire posOF, negOF;
    wire ovf;
    wire slt;

    aluaddsub u1 (
        .A(A),
        .B(B),
        .sub(1'b1),
        .Y(diff),
        .posOF(posOF),
        .negOF(negOF)
    );

    assign ovf = posOF | negOF;
    assign slt = diff[31] ^ ovf;

    assign #1 Y = slt ? 32'b1 : 32'b0;

endmodule
