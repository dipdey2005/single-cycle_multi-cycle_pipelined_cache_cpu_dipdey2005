`timescale 1ns/1ps
// Latches decode results (operands + control) into execute stage.
// flush : force a bubble (all control signals de-asserted) - used for
//         load-use stalls and branch-taken squashes.
module ID_EX_reg (
    input clk,
    input reset,
    input flush,

    // datapath values from ID
    input  [31:0] pc_in,
    input  [31:0] pc_plus4_in,
    input  [31:0] regData1_in,
    input  [31:0] regData2_in,
    input  [31:0] immOut_in,
    input  [4:0]  rs1_in,
    input  [4:0]  rs2_in,
    input  [4:0]  rd_in,

    // control signals from ControlUnit, valid in ID
    input RegWrite_in,
    input MemRead_in,
    input MemWrite_in,
    input ASel_in,
    input BSel_in,
    input [3:0] ALUOp_in,
    input [1:0] WBSel_in,

    // latched outputs, consumed in EX/MEM/WB
    output reg [31:0] pc_out,
    output reg [31:0] pc_plus4_out,
    output reg [31:0] regData1_out,
    output reg [31:0] regData2_out,
    output reg [31:0] immOut_out,
    output reg [4:0]  rs1_out,
    output reg [4:0]  rs2_out,
    output reg [4:0]  rd_out,

    output reg RegWrite_out,
    output reg MemRead_out,
    output reg MemWrite_out,
    output reg ASel_out,
    output reg BSel_out,
    output reg [3:0] ALUOp_out,
    output reg [1:0] WBSel_out
);
    always @(posedge clk) begin
        if (reset || flush) begin
            pc_out        <= 32'b0;
            pc_plus4_out  <= 32'b0;
            regData1_out  <= 32'b0;
            regData2_out  <= 32'b0;
            immOut_out    <= 32'b0;
            rs1_out       <= 5'b0;
            rs2_out       <= 5'b0;
            rd_out        <= 5'b0;
            // de-assert every control signal -> bubble does nothing, writes nothing
            RegWrite_out  <= 1'b0;
            MemRead_out   <= 1'b0;
            MemWrite_out  <= 1'b0;
            ASel_out      <= 1'b0;
            BSel_out      <= 1'b0;
            ALUOp_out     <= 4'b0;
            WBSel_out     <= 2'b0;
        end
        else begin
            pc_out        <= pc_in;
            pc_plus4_out  <= pc_plus4_in;
            regData1_out  <= regData1_in;
            regData2_out  <= regData2_in;
            immOut_out    <= immOut_in;
            rs1_out       <= rs1_in;
            rs2_out       <= rs2_in;
            rd_out        <= rd_in;

            RegWrite_out  <= RegWrite_in;
            MemRead_out   <= MemRead_in;
            MemWrite_out  <= MemWrite_in;
            ASel_out      <= ASel_in;
            BSel_out      <= BSel_in;
            ALUOp_out     <= ALUOp_in;
            WBSel_out     <= WBSel_in;
        end
    end
endmodule
