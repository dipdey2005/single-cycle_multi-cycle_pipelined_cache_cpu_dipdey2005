`timescale 1ns/1ps
module MEM_WB_reg (
    input clk,
    input reset,

    input  [31:0] pc_plus4_in,
    input  [31:0] aluResult_in,
    input  [31:0] memReadData_in,
    input  [4:0]  rd_in,

    input RegWrite_in,
    input [1:0] WBSel_in,

    output reg [31:0] pc_plus4_out,
    output reg [31:0] aluResult_out,
    output reg [31:0] memReadData_out,
    output reg [4:0]  rd_out,

    output reg RegWrite_out,
    output reg [1:0] WBSel_out
);
    always @(posedge clk) begin
        if (reset) begin
            pc_plus4_out    <= 32'b0;
            aluResult_out   <= 32'b0;
            memReadData_out <= 32'b0;
            rd_out          <= 5'b0;
            RegWrite_out    <= 1'b0;
            WBSel_out       <= 2'b0;
        end
        else begin
            pc_plus4_out    <= pc_plus4_in;
            aluResult_out   <= aluResult_in;
            memReadData_out <= memReadData_in;
            rd_out          <= rd_in;
            RegWrite_out    <= RegWrite_in;
            WBSel_out       <= WBSel_in;
        end
    end
endmodule
