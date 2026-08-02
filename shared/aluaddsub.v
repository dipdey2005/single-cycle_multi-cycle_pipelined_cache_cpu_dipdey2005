`timescale 1ns/1ps

module aluaddsub(
    input  signed [31:0] A,
    input  signed [31:0] B,
    input                sub,
    output signed [31:0] Y,
    output               posOF,
    output               negOF
);

wire [31:0] B_real;
wire [32:0] sum_ext;

assign B_real = sub ? ~B : B;

assign sum_ext = {1'b0, A} + {1'b0, B_real} + {32'b0, sub};

assign #3 Y = sum_ext[31:0];

assign #3 posOF =  sum_ext[31] & ~sum_ext[32];
assign #3 negOF = ~sum_ext[31] &  sum_ext[32];

endmodule
