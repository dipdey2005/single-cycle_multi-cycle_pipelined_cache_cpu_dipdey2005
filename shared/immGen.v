`timescale 1ns/1ps
module immGen (
    input  [31:0] inst,
    input  [1:0]  immSel,
    output [31:0] immOut
);
    wire [31:0] iType;
    wire [31:0] sType;
    wire [31:0] bType;
    wire [31:0] jType;

    assign iType = {{20{inst[31]}}, inst[31:20]};
    assign sType = {{20{inst[31]}}, inst[31:25], inst[11:7]};
    assign bType = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
    assign jType = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};

    mux4x1 u_imux(
        .d0(iType),
        .d1(sType),
        .d2(bType),
        .d3(jType),
        .sel(immSel),
        .y(immOut));
endmodule
