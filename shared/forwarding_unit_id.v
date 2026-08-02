`timescale 1ns/1ps

module forwarding_unit_id (
    input  [4:0] id_rs1,
    input  [4:0] id_rs2,

    input  [4:0] exmem_rd,
    input        exmem_RegWrite,

    input  [4:0] memwb_rd,
    input        memwb_RegWrite,

    output reg [1:0] ForwardA_id,
    output reg [1:0] ForwardB_id
);
    always @(*) begin
        if (exmem_RegWrite && (exmem_rd != 5'b0) && (exmem_rd == id_rs1))
            ForwardA_id = 2'b10;
        else if (memwb_RegWrite && (memwb_rd != 5'b0) && (memwb_rd == id_rs1))
            ForwardA_id = 2'b01;
        else
            ForwardA_id = 2'b00;

        if (exmem_RegWrite && (exmem_rd != 5'b0) && (exmem_rd == id_rs2))
            ForwardB_id = 2'b10;
        else if (memwb_RegWrite && (memwb_rd != 5'b0) && (memwb_rd == id_rs2))
            ForwardB_id = 2'b01;
        else
            ForwardB_id = 2'b00;
    end
endmodule
