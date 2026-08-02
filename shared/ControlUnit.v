`timescale 1ns/1ps
module ControlUnit (
    input [31:0] inst,
    input branch_equal,
    input branch_lessthan,
    output reg RegWrite,
    output reg BSel,        
    output reg MemWrite,
    output reg MemRead,
    output reg [3:0] ALUOp,     // FIXED: now 4-bit
    output reg [1:0] ImmSel,
    output reg Branch_Unsigned,
    output reg ASel,
    output reg [1:0] WBSel,
    output reg PCSel
);

    wire [6:0] opcode = inst[6:0];
    wire [2:0] funct3 = inst[14:12];
    wire [6:0] funct7 = inst[31:25];

    always @(*) begin
        // ================= DEFAULTS =================
        RegWrite        = 0;
        BSel            = 0; 
        MemWrite        = 0;
        MemRead         = 0;
        ALUOp           = 4'b0000; // ADD default
        ImmSel          = 2'b00;
        Branch_Unsigned = 0;
        ASel            = 0;
        WBSel           = 2'b01; 
        PCSel           = 0;

        case (opcode)

            // ================= R-TYPE =================
            7'b0110011: begin
                RegWrite = 1;
                BSel     = 0;

                case (funct3)
                    3'b000: ALUOp = (funct7[5]) ? 4'b0001 : 4'b0000; // SUB / ADD
                    3'b001: ALUOp = 4'b0010; // SLL
                    3'b010: ALUOp = 4'b0011; // SLT
                    3'b011: ALUOp = 4'b0100; // SLTU
                    3'b111: ALUOp = 4'b0101; // AND
                    3'b110: ALUOp = 4'b0111; // OR
                    3'b101: ALUOp = 4'b0110; // SRL ,we dont consider sra for now
                    default: ALUOp = 4'b0000;
                endcase
            end

            // ================= I-TYPE =================
            7'b0010011: begin
                RegWrite = 1;
                BSel     = 1;
                ImmSel   = 2'b00;
                WBSel    = 2'b01;

                case (funct3)
                    3'b000: ALUOp = 4'b0000; // ADDI
                    3'b010: ALUOp = 4'b0011; // SLTI
                    3'b011: ALUOp = 4'b0100; // SLTIU
                    3'b100: ALUOp = 4'b1000; // XORI
                    3'b111: ALUOp = 4'b0101; // ANDI
                    3'b110: ALUOp = 4'b0111; // ORI
                    3'b001: ALUOp = 4'b0010; // SLLI
                    3'b101: ALUOp = 4'b0110; // SRLI
                    default: ALUOp = 4'b0000;
                endcase
            end

            // ================= LOAD =================
            7'b0000011: begin
                RegWrite = 1;
                BSel     = 1;
                MemRead  = 1;
                ImmSel   = 2'b00;
                WBSel    = 2'b00;
                ALUOp    = 4'b0000; // ADD
            end

            // ================= STORE =================
            7'b0100011: begin
                BSel     = 1;
                MemWrite = 1;
                ImmSel   = 2'b01;
                ALUOp    = 4'b0000; // ADD
            end

            // ================= BRANCH =================
            7'b1100011: begin
                BSel   = 1;
                ASel   = 1;
                ImmSel = 2'b10;
                ALUOp  = 4'b0000; 

                case (funct3)
                    3'b000: PCSel = branch_equal;          
                    3'b001: PCSel = !branch_equal;         
                    3'b100: PCSel = branch_lessthan;       
                    3'b101: PCSel = !branch_lessthan;      
                    3'b110: begin                          
                        Branch_Unsigned = 1;
                        PCSel = branch_lessthan;
                    end
                    3'b111: begin                          
                        Branch_Unsigned = 1;
                        PCSel = !branch_lessthan;
                    end
                endcase
            end

            // ================= JAL =================
            7'b1101111: begin
                RegWrite = 1;
                ASel     = 1;        // PC
                BSel     = 1;        // IMM
                ImmSel   = 2'b11;    // J-type (must fix immGen)
                PCSel    = 1;
                WBSel    = 2'b10;
                ALUOp    = 4'b0000;  // ADD
            end

        endcase
    end
endmodule