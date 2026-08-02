module mult_cpu(
    input clk,
    input rst
);

    // ================= Control Signals =================
    wire IRLd;
    wire [2:0] RegSel;
    wire RegWr, RegEn;
    wire ALd, BLd;
    wire [2:0] ALUOp;
    wire ALUEn;
    wire MALd;
    wire MemWr, MemEn;
    wire [2:0] ImmSel;
    wire ImmEn;

    // ================= Status Signals =================
    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire zero;
    wire busy;

    // ================= Sequencer Signals =================
    wire [2:0] micro_seq_ctrl;
    wire [5:0] next_uPC_addr;
    wire [5:0] uPC;

    // ================= Datapath =================
    datapath DP (
        .clk(clk),
        .rst(rst),

        .IRLd(IRLd),
        .RegSel(RegSel),
        .RegWr(RegWr),
        .RegEn(RegEn),
        .ALd(ALd),
        .BLd(BLd),
        .ALUOp(ALUOp),
        .ALUEn(ALUEn),
        .MALd(MALd),
        .MemWr(MemWr),
        .MemEn(MemEn),
        .ImmSel(ImmSel),
        .ImmEn(ImmEn),

        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .zero(zero),
        .busy(busy)
    );

    // ================= Control ROM =================
    mult_ctrl CTRL (
        .uPC(uPC),

        .IRLd(IRLd),
        .RegSel(RegSel),
        .RegWr(RegWr),
        .RegEn(RegEn),
        .ALd(ALd),
        .BLd(BLd),
        .ALUOp(ALUOp),
        .ALUEn(ALUEn),
        .MALd(MALd),
        .MemWr(MemWr),
        .MemEn(MemEn),
        .ImmSel(ImmSel),
        .ImmEn(ImmEn),

        .micro_seq_ctrl(micro_seq_ctrl),
        .next_uPC_addr(next_uPC_addr)
    );

    // ================= Microsequencer =================
    mult_seq SEQ (
        .clk(clk),
        .rst(rst),

        .opcode(opcode),
        .zero(zero),
        .busy(busy),

        .next_type(micro_seq_ctrl),
        .next_addr(next_uPC_addr),

        .uPC(uPC)
    );

endmodule