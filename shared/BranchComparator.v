`timescale 1ns/1ps
module BranchComparator (
    input [31:0] DataA,
    input [31:0] DataB,
    input BrUn,
    output BrEq,
    output BrLT
);

    assign BrEq = (DataA == DataB);

    assign BrLT = (BrUn) ? (DataA < DataB) : ($signed(DataA) < $signed(DataB));

endmodule