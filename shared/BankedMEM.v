`timescale 1ns/1ps
module BankedMEM (
    input  [31:0] address,
    input         clk,
    input  [31:0] writeData,
    input         writeEn,
    output [31:0] readData
);
    reg [7:0] b0 [0:1023]; //1024 8 bit locations, total 1024 32 bit locations
    reg [7:0] b1 [0:1023];
    reg [7:0] b2 [0:1023];
    reg [7:0] b3 [0:1023];

    wire [9:0] F_addr;
    assign F_addr = address[11:2];

    assign #1 readData = {
        b3[F_addr],
        b2[F_addr],
        b1[F_addr],
        b0[F_addr]
    };
    always @(posedge clk) begin
        if (writeEn) begin
            b0[F_addr] <= writeData[7:0];
            b1[F_addr] <= writeData[15:8];
            b2[F_addr] <= writeData[23:16];
            b3[F_addr] <= writeData[31:24];
        end
    end

endmodule
