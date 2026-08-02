`timescale 1ns/1ps

module hazard_detection_unit (
    input        idex_MemRead,
    input  [4:0] idex_rd,
    input  [4:0] ifid_rs1,
    input  [4:0] ifid_rs2,

    input        is_branch_id,   // ID-stage instruction is a branch (opcode 1100011)
    input        exmem_MemRead,  // EX/MEM-stage instruction is a load
    input  [4:0] exmem_rd,

    output stall // 1 = freeze PC & IF/ID, bubble ID/EX
);
    wire load_use_stall   = idex_MemRead &&
                             (idex_rd != 5'b0) &&
                             ((idex_rd == ifid_rs1) || (idex_rd == ifid_rs2));

    wire branch_after_load = is_branch_id && exmem_MemRead &&
                              (exmem_rd != 5'b0) &&
                              ((exmem_rd == ifid_rs1) || (exmem_rd == ifid_rs2));

    assign stall = load_use_stall || branch_after_load;
endmodule
