module mult_ctrl(
    input [5:0] uPC,

    output reg IRLd,
    output reg [2:0] RegSel,
    output reg RegWr,
    output reg RegEn,
    output reg ALd,
    output reg BLd,
    output reg [2:0] ALUOp,
    output reg ALUEn,
    output reg MALd,
    output reg MemWr,
    output reg MemEn,
    output reg [2:0] ImmSel,
    output reg ImmEn,

    output reg [2:0] micro_seq_ctrl,
    output reg [5:0] next_uPC_addr
);

always @(*) begin
    // defaults
    IRLd=0; RegWr=0; RegEn=0; ALd=0; BLd=0;
    ALUEn=0; MALd=0; MemWr=0; MemEn=0; ImmEn=0;
    RegSel=3'b000; ALUOp=3'b000; ImmSel=3'b000;
    micro_seq_ctrl=3'b000; next_uPC_addr=6'd0;

    case(uPC)

    // ================= FETCH =================
    6'd0: begin
        RegSel=3'b000; RegEn=1; MALd=1;
    end

    6'd1: begin
        MemEn=1; IRLd=1;
        micro_seq_ctrl=3'b001; // stall
    end

    6'd2: begin
        RegSel=3'b000; RegEn=1; ALd=1;
    end

    6'd3: begin
        ALUOp=3'b101; ALUEn=1;
        RegSel=3'b000; RegWr=1;
    end

    6'd4: begin
        micro_seq_ctrl=3'b010; // decode
    end

    // ================= ADD =================
    6'd10: begin
        RegSel=3'b011; RegEn=1; ALd=1;
    end

    6'd11: begin
        RegSel=3'b100; RegEn=1; BLd=1;
    end

    6'd12: begin
        ALUOp=3'b000; ALUEn=1;
        RegSel=3'b010; RegWr=1;
        micro_seq_ctrl=3'b011; next_uPC_addr=6'd0;
    end

    // ================= ADDI =================
    6'd20: begin
        RegSel=3'b011; RegEn=1; ALd=1;
    end

    6'd21: begin
        ImmSel=3'b000; ImmEn=1; BLd=1;
    end

    6'd22: begin
        ALUOp=3'b000; ALUEn=1;
        RegSel=3'b010; RegWr=1;
        micro_seq_ctrl=3'b011; next_uPC_addr=6'd0;
    end

    // ================= SUB =================
    6'd24: begin
        RegSel=3'b011; RegEn=1; ALd=1;
    end

    6'd25: begin
        RegSel=3'b100; RegEn=1; BLd=1;
    end

    6'd26: begin
        ALUOp=3'b001; ALUEn=1;
        RegSel=3'b010; RegWr=1;
        micro_seq_ctrl=3'b011; next_uPC_addr=6'd0;
    end

    // ================= XORI =================
    6'd28: begin
        RegSel=3'b011; RegEn=1; ALd=1;
    end

    6'd29: begin
        ImmSel=3'b000; ImmEn=1; BLd=1;
    end

    6'd30: begin
        ALUOp=3'b100; ALUEn=1;
        RegSel=3'b010; RegWr=1;
        micro_seq_ctrl=3'b011; next_uPC_addr=6'd0;
    end

    // ================= LW =================
    6'd32: begin
        RegSel=3'b011; RegEn=1; ALd=1;
    end

    6'd33: begin
        ImmSel=3'b000; ImmEn=1; BLd=1;
    end

    6'd34: begin
        ALUOp=3'b000; ALUEn=1; MALd=1;
    end

    6'd35: begin
        MemEn=1;
        RegSel=3'b010; RegWr=1;
        micro_seq_ctrl=3'b011; next_uPC_addr=6'd0;
    end

    // ================= SW =================
    6'd40: begin
        RegSel=3'b011; RegEn=1; ALd=1;
    end

    6'd41: begin
        ImmSel=3'b001; ImmEn=1; BLd=1;
    end

    6'd42: begin
        ALUOp=3'b000; ALUEn=1; MALd=1;
    end

    6'd43: begin
        RegSel=3'b100; RegEn=1; MemWr=1;
        micro_seq_ctrl=3'b011; next_uPC_addr=6'd0;
    end

    // ================= BNE =================
    6'd50: begin
        RegSel=3'b011; RegEn=1; ALd=1;
    end

    6'd51: begin
        RegSel=3'b100; RegEn=1; BLd=1;
    end

    6'd52: begin
        ALUOp=3'b001; ALUEn=1; BLd=1; // store result in B
    end

    6'd53: begin
        micro_seq_ctrl=3'b101; // NZ
        next_uPC_addr=6'd54;
    end

    6'd54: begin
        RegSel=3'b000; RegEn=1; ALd=1;
    end

    6'd55: begin
        ImmSel=3'b010; ImmEn=1; BLd=1;
    end

    6'd56: begin
        ALUOp=3'b000; ALUEn=1;
        RegSel=3'b000; RegWr=1;
        micro_seq_ctrl=3'b011; next_uPC_addr=6'd0;
    end

    endcase
end

endmodule