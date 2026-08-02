`timescale 1ns/1ps
module cpu_SC_dut(input clk);

    reg [31:0] pc;
    wire [31:0] pc_plus_4;
    assign #1 pc_plus_4 = pc + 4;
    wire [31:0] inst;
    wire [31:0] alu;
    wire PCSel;
    wire [31:0] next_pc;

    assign next_pc = (PCSel) ? alu : pc_plus_4; // pcsel mux
    initial pc = 0;
    always @(posedge clk) begin
        pc <= #1 next_pc;
    end

    BankedMEM IMEM (
        .address(pc),
        .clk(clk),
        .writeData(32'b0),
        .writeEn(1'b0),
        .readData(inst)
    );

    wire RegWEn, ASel, BSel, MemRead, MemWrite, BrUn, BrEq, BrLT;
    wire [3:0] ALUSel;
    wire [1:0] ImmSel, WBSel;

    ControlUnit CU (
        .inst(inst),
        .branch_equal(BrEq),
        .branch_lessthan(BrLT),
        .RegWrite(RegWEn),      
        .BSel(BSel),            
        .MemWrite(MemWrite),
        .MemRead(MemRead),       
        .ALUOp(ALUSel),         
        .ImmSel(ImmSel),
        .Branch_Unsigned(BrUn),
        .ASel(ASel),
        .WBSel(WBSel),
        .PCSel(PCSel)
    );

    wire [31:0] DataA, DataB, wb;
    reg_file RF (
        .clk(clk),
        .reset(1'b0), 
        .rs1(inst[19:15]),
        .rs2(inst[24:20]),
        .rd(inst[11:7]),
        .write_data(wb),
        .reg_write_en(RegWEn),
        .read_data1(DataA),
        .read_data2(DataB)
    );

    wire [31:0] imm;
    immGen IG (
        .inst(inst),
        .immSel(ImmSel),
        .immOut(imm)
    );

    // Structural Branch 
    BranchComparator BC (
        .DataA(DataA),
        .DataB(DataB),
        .BrUn(BrUn),
        .BrEq(BrEq),
        .BrLT(BrLT)
    );

    wire [31:0] alu_input_a = (ASel) ? pc : DataA; //asel mux
    wire [31:0] alu_input_b = (BSel) ? imm : DataB; //bsel mux

    rv32Ialu alu_inst (
        .a(alu_input_a),
        .b(alu_input_b),
        .alu_ctrl(ALUSel),
        .result(alu),
        .zero()
    );

    wire [31:0] mem;
    BankedMEM DMEM (
        .address(alu),

        .clk(clk),
        .writeData(DataB),
        .writeEn(MemWrite),
        .readData(mem)
    );

    assign wb = (WBSel == 2'b10) ? pc_plus_4 :                    //wbsel mux
                (WBSel == 2'b01) ? alu : 
                                   mem;

endmodule