`timescale 1ns/1ps
module PCInc (
    input  [31:0] oldPC,
    input clk,
    output reg [31:0] newPC
);
    wire [31:0] tempPC;
    aluaddsub u_PCInc (
        .A(oldPC),
        .B(32'h00000004),
        .sub(1'b0),
        .Y(tempPC),
        .posOF(),
        .negOF()
    );
    always@(posedge clk) begin
        newPC <=  #1 tempPC;
    end

endmodule
