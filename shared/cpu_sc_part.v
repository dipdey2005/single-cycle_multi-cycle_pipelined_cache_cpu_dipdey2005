`timescale 1ns/1ps

module cpu_sc_part(input clk);

    reg [31:0] pc;
    wire [31:0] pc_plus_4 = pc + 4;
    wire [31:0] instruction;

    initial pc = 0;

    always @(posedge clk) begin
        pc <= pc_plus_4;
    end

    BankedMEM IMEM (
        .address(pc),
        .clk(clk),
        .writeData(32'b0),
        .writeEn(1'b0),
        .readData(instruction)
    );

    wire RegWrite, BSel, MemWrite, MemRead;
    wire [3:0] ALUOp;
    wire [1:0] ImmSel;
    wire Branch_Unsigned, ASel, PCSel;
    wire [1:0] WBSel;

    ControlUnit CU (
        .inst(instruction),
        .branch_equal(1'b0),
        .branch_lessthan(1'b0),
        .RegWrite(RegWrite),
        .BSel(BSel),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .ALUOp(ALUOp),
        .ImmSel(ImmSel),
        .Branch_Unsigned(Branch_Unsigned),
        .ASel(ASel),
        .WBSel(WBSel),
        .PCSel(PCSel)
    );

    wire [4:0] rs1 = instruction[19:15];
    wire [4:0] rs2 = instruction[24:20];
    wire [4:0] rd  = instruction[11:7];

    wire [31:0] regData1, regData2;
    wire [31:0] writeBackData;

    reg_file RF (
        .clk(clk),
        .reset(1'b0),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(writeBackData),
        .reg_write_en(RegWrite),
        .read_data1(regData1),
        .read_data2(regData2)
    );

    wire [31:0] immOut;

    immGen IG (
        .inst(instruction),
        .immSel(ImmSel),
        .immOut(immOut)
    );

    wire [31:0] aluA = (ASel) ? pc : regData1;
    wire [31:0] aluB = (BSel) ? immOut : regData2;

    wire [31:0] aluResult;
    wire zero;

    rv32Ialu alu (
        .a(aluA),
        .b(aluB),
        .alu_ctrl(ALUOp),
        .result(aluResult),
        .zero(zero)
    );

    wire [31:0] memReadData;

    BankedMEM DMEM (
        .address(aluResult),
        .clk(clk),
        .writeData(regData2),
        .writeEn(MemWrite),
        .readData(memReadData)
    );

    assign writeBackData = (WBSel == 2'b10) ? pc_plus_4 :
                           (WBSel == 2'b01) ? aluResult :
                                              memReadData;

endmodule