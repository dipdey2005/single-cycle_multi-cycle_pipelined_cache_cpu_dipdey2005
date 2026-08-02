`timescale 1ns/1ps
// Latches fetch results into decode stage.
// stall  : hold current contents (load-use hazard / structural stall from EX)
// flush  : force a NOP into decode (branch taken misprediction)
module IF_ID_reg (
    input clk,
    input reset,
    input stall,
    input flush,
    input  [31:0] pc_in,
    input  [31:0] pc_plus4_in,
    input  [31:0] instruction_in,

    output reg [31:0] pc_out,
    output reg [31:0] pc_plus4_out,
    output reg [31:0] instruction_out
);
    always @(posedge clk) begin
        if (reset || flush) begin
            pc_out          <= 32'b0;
            pc_plus4_out    <= 32'b0;
            instruction_out <= 32'h00000013; // ADDI x0,x0,0 (NOP)
        end
        else if (!stall) begin
            pc_out          <= pc_in;
            pc_plus4_out    <= pc_plus4_in;
            instruction_out <= instruction_in;
        end
        // else: stall -> hold current values (do nothing)
    end
endmodule
