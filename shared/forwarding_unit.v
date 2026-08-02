`timescale 1ns/1ps

module forwarding_unit (
    input  [4:0] idex_rs1,
    input  [4:0] idex_rs2,

    input  [4:0] exmem_rd,
    input        exmem_RegWrite,

    input  [4:0] memwb_rd,
    input        memwb_RegWrite,

    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB
);
    always @(*) begin
        // ForwardA (rs1)
        if (exmem_RegWrite && (exmem_rd != 5'b0) && (exmem_rd == idex_rs1))
            ForwardA = 2'b10;
        else if (memwb_RegWrite && (memwb_rd != 5'b0) && (memwb_rd == idex_rs1))
            ForwardA = 2'b01;
        else
            ForwardA = 2'b00;

        // ForwardB (rs2)
        if (exmem_RegWrite && (exmem_rd != 5'b0) && (exmem_rd == idex_rs2))
            ForwardB = 2'b10;
        else if (memwb_RegWrite && (memwb_rd != 5'b0) && (memwb_rd == idex_rs2))
            ForwardB = 2'b01;
        else
            ForwardB = 2'b00;
    end
endmodule
