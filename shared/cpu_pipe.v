`timescale 1ns/1ps

module cpu_pipe (input clk, input reset);

    // ================= IF =================
    reg  [31:0] pc;
    wire [31:0] pc_plus4;
    wire [31:0] instruction_if;
    wire [31:0] pc_branch_target;   // computed in ID
    wire        pc_src_sel;         // 1 = take branch target, from ID

    aluaddsub u_pc_adder (
        .A(pc), .B(32'h00000004), .sub(1'b0),
        .Y(pc_plus4), .posOF(), .negOF()
    );

    wire stall_pc;  // from hazard unit (load-use)

    always @(posedge clk) begin
        if (reset)
            pc <= 32'b0;
        else if (!stall_pc)
            pc <= pc_src_sel ? pc_branch_target : pc_plus4;
        // else hold PC (stall)
    end

    BankedMEM IMEM (
        .address(pc), .clk(clk),
        .writeData(32'b0), .writeEn(1'b0),
        .readData(instruction_if)
    );

    // ---- IF/ID register ----
    wire [31:0] pc_id, pc_plus4_id, instruction;
    wire flush_ifid; // = pc_src_sel (branch taken)

    IF_ID_reg u_ifid (
        .clk(clk), .reset(reset),
        .stall(stall_pc), .flush(flush_ifid),
        .pc_in(pc), .pc_plus4_in(pc_plus4), .instruction_in(instruction_if),
        .pc_out(pc_id), .pc_plus4_out(pc_plus4_id), .instruction_out(instruction)
    );

    // ================= ID =================
    wire [4:0] rs1 = instruction[19:15];
    wire [4:0] rs2 = instruction[24:20];
    wire [4:0] rd_id = instruction[11:7];

    wire RegWrite_id, BSel_id, MemWrite_id, MemRead_id, ASel_id, PCSel_id;
    wire [3:0] ALUOp_id;
    wire [1:0] ImmSel_id, WBSel_id;
    wire Branch_Unsigned_id;

    wire branch_equal, branch_lessthan;

    ControlUnit CU (
        .inst(instruction),
        .branch_equal(branch_equal),
        .branch_lessthan(branch_lessthan),
        .RegWrite(RegWrite_id), .BSel(BSel_id),
        .MemWrite(MemWrite_id), .MemRead(MemRead_id),
        .ALUOp(ALUOp_id), .ImmSel(ImmSel_id),
        .Branch_Unsigned(Branch_Unsigned_id), .ASel(ASel_id),
        .WBSel(WBSel_id), .PCSel(PCSel_id)
    );

    wire [31:0] regData1, regData2;
    wire        wb_RegWrite;      // from WB stage, fed back this cycle
    wire [4:0]  wb_rd;
    wire [31:0] wb_writeData;

    reg_file RF (
        .clk(clk), .reset(reset),
        .rs1(rs1), .rs2(rs2), .rd(wb_rd),
        .write_data(wb_writeData), .reg_write_en(wb_RegWrite),
        .read_data1(regData1), .read_data2(regData2)
    );

    wire [31:0] immOut;
    immGen IG (
        .inst(instruction), .immSel(ImmSel_id), .immOut(immOut)
    );

    // ---- ID-stage forwarding into the branch comparator ----
    wire [1:0] ForwardA_id, ForwardB_id;

    forwarding_unit_id u_fwd_id (
        .id_rs1(rs1), .id_rs2(rs2),
        .exmem_rd(rd_mem), .exmem_RegWrite(RegWrite_mem),
        .memwb_rd(rd_wb), .memwb_RegWrite(RegWrite_wb),
        .ForwardA_id(ForwardA_id), .ForwardB_id(ForwardB_id)
    );

    wire [31:0] bcDataA = (ForwardA_id == 2'b10) ? exmem_aluResult :
                          (ForwardA_id == 2'b01) ? memwb_writeData : regData1;
    wire [31:0] bcDataB = (ForwardB_id == 2'b10) ? exmem_aluResult :
                          (ForwardB_id == 2'b01) ? memwb_writeData : regData2;

    // branch resolved here in ID, now with forwarded operands
    BranchComparator BC (
        .DataA(bcDataA), .DataB(bcDataB), .BrUn(Branch_Unsigned_id),
        .BrEq(branch_equal), .BrLT(branch_lessthan)
    );

    assign pc_src_sel       = PCSel_id;
    assign pc_branch_target = pc_id + immOut; // both JAL and branch targets are PC-relative
    assign flush_ifid       = pc_src_sel;

    // ---- ID/EX register ----
    wire flush_idex; // = load-use stall bubble OR branch flush
    wire [31:0] pc_ex, pc_plus4_ex, regData1_ex, regData2_ex, immOut_ex;
    wire [4:0]  rs1_ex, rs2_ex, rd_ex;
    wire RegWrite_ex, MemRead_ex, MemWrite_ex, ASel_ex, BSel_ex;
    wire [3:0] ALUOp_ex;
    wire [1:0] WBSel_ex;

    assign flush_idex = stall_pc || pc_src_sel;

    ID_EX_reg u_idex (
        .clk(clk), .reset(reset), .flush(flush_idex),
        .pc_in(pc_id), .pc_plus4_in(pc_plus4_id),
        .regData1_in(regData1), .regData2_in(regData2), .immOut_in(immOut),
        .rs1_in(rs1), .rs2_in(rs2), .rd_in(rd_id),
        .RegWrite_in(RegWrite_id), .MemRead_in(MemRead_id), .MemWrite_in(MemWrite_id),
        .ASel_in(ASel_id), .BSel_in(BSel_id), .ALUOp_in(ALUOp_id), .WBSel_in(WBSel_id),
        .pc_out(pc_ex), .pc_plus4_out(pc_plus4_ex),
        .regData1_out(regData1_ex), .regData2_out(regData2_ex), .immOut_out(immOut_ex),
        .rs1_out(rs1_ex), .rs2_out(rs2_ex), .rd_out(rd_ex),
        .RegWrite_out(RegWrite_ex), .MemRead_out(MemRead_ex), .MemWrite_out(MemWrite_ex),
        .ASel_out(ASel_ex), .BSel_out(BSel_ex), .ALUOp_out(ALUOp_ex), .WBSel_out(WBSel_ex)
    );

    // ================= EX =================
    wire [1:0] ForwardA, ForwardB;
    wire [31:0] exmem_aluResult, memwb_writeData; // driven below

    wire [31:0] fwdA_val = (ForwardA == 2'b10) ? exmem_aluResult :
                           (ForwardA == 2'b01) ? memwb_writeData : regData1_ex;
    wire [31:0] fwdB_val = (ForwardB == 2'b10) ? exmem_aluResult :
                           (ForwardB == 2'b01) ? memwb_writeData : regData2_ex;

    wire [31:0] aluA = ASel_ex ? pc_ex : fwdA_val;
    wire [31:0] aluB = BSel_ex ? immOut_ex : fwdB_val;

    wire [31:0] aluResult_ex;
    wire zero_ex;

    rv32Ialu alu (
        .a(aluA), .b(aluB), .alu_ctrl(ALUOp_ex),
        .result(aluResult_ex), .zero(zero_ex)
    );

    // ---- EX/MEM register ----
    wire RegWrite_mem, MemRead_mem, MemWrite_mem;
    wire [1:0] WBSel_mem;
    wire [31:0] pc_plus4_mem, aluResult_mem, storeData_mem;
    wire [4:0] rd_mem;

    EX_MEM_reg u_exmem (
        .clk(clk), .reset(reset),
        .pc_plus4_in(pc_plus4_ex), .aluResult_in(aluResult_ex),
        .storeData_in(fwdB_val), .rd_in(rd_ex),
        .RegWrite_in(RegWrite_ex), .MemRead_in(MemRead_ex), .MemWrite_in(MemWrite_ex),
        .WBSel_in(WBSel_ex),
        .pc_plus4_out(pc_plus4_mem), .aluResult_out(aluResult_mem),
        .storeData_out(storeData_mem), .rd_out(rd_mem),
        .RegWrite_out(RegWrite_mem), .MemRead_out(MemRead_mem), .MemWrite_out(MemWrite_mem),
        .WBSel_out(WBSel_mem)
    );
    assign exmem_aluResult = aluResult_mem; // tap for forwarding mux above

    // ================= MEM =================
    wire [31:0] memReadData_mem;
    BankedMEM DMEM (
        .address(aluResult_mem), .clk(clk),
        .writeData(storeData_mem), .writeEn(MemWrite_mem),
        .readData(memReadData_mem)
    );

    // ---- MEM/WB register ----
    wire RegWrite_wb;
    wire [1:0] WBSel_wb;
    wire [31:0] pc_plus4_wb, aluResult_wb, memReadData_wb;
    wire [4:0] rd_wb;

    MEM_WB_reg u_memwb (
        .clk(clk), .reset(reset),
        .pc_plus4_in(pc_plus4_mem), .aluResult_in(aluResult_mem),
        .memReadData_in(memReadData_mem), .rd_in(rd_mem),
        .RegWrite_in(RegWrite_mem), .WBSel_in(WBSel_mem),
        .pc_plus4_out(pc_plus4_wb), .aluResult_out(aluResult_wb),
        .memReadData_out(memReadData_wb), .rd_out(rd_wb),
        .RegWrite_out(RegWrite_wb), .WBSel_out(WBSel_wb)
    );

    // ================= WB =================
    assign wb_writeData = (WBSel_wb == 2'b10) ? pc_plus4_wb :
                          (WBSel_wb == 2'b01) ? aluResult_wb :
                                                 memReadData_wb;
    assign wb_RegWrite = RegWrite_wb;
    assign wb_rd       = rd_wb;
    assign memwb_writeData = wb_writeData; // tap for forwarding mux above

    // ================= Hazard / forwarding units =================
    wire is_branch_id = (instruction[6:0] == 7'b1100011);

    hazard_detection_unit u_hazard (
        .idex_MemRead(MemRead_ex), .idex_rd(rd_ex),
        .ifid_rs1(rs1), .ifid_rs2(rs2),
        .is_branch_id(is_branch_id),
        .exmem_MemRead(MemRead_mem), .exmem_rd(rd_mem),
        .stall(stall_pc)
    );

    forwarding_unit u_fwd (
        .idex_rs1(rs1_ex), .idex_rs2(rs2_ex),
        .exmem_rd(rd_mem), .exmem_RegWrite(RegWrite_mem),
        .memwb_rd(rd_wb), .memwb_RegWrite(RegWrite_wb),
        .ForwardA(ForwardA), .ForwardB(ForwardB)
    );

endmodule
