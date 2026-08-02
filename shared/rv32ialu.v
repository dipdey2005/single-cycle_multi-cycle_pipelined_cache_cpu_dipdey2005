`timescale 1ns/1ps

module rv32Ialu (
    input  [31:0] a,
    input  [31:0] b,
    input  [3:0]  alu_ctrl,
    output [31:0] result,
    output        zero
);

    // =====================================================
    // ADD / SUB
    // =====================================================
    wire [31:0] addsub_result;
    wire posOF, negOF;

    wire sub;
    assign sub = (alu_ctrl == 4'b0001);   // SUB

    aluaddsub u_addsub (
        .A(a),
        .B(b),
        .sub(sub),
        .Y(addsub_result),
        .posOF(posOF),
        .negOF(negOF)
    );

    // Carry for SLTU
    wire [32:0] sum_ext;
    assign sum_ext = {1'b0,a} + {1'b0,(sub ? ~b : b)} + sub;
    wire cout = sum_ext[32];

    // =====================================================
    // SLT (signed)
    // =====================================================
    wire [31:0] slt_result;

    alucomp u_comp (
        .A(a),
        .B(b),
        .Y(slt_result)
    );

    // =====================================================
    // SLTU (unsigned)
    // =====================================================
    wire [31:0] sltu_result;
    assign sltu_result = (~cout) ? 32'b1 : 32'b0;

    // =====================================================
    // LOGIC
    // =====================================================
    wire [31:0] and_result;
    wire [31:0] or_result;

    alulogic u_logic (
        .A(a),
        .B(b),
        .and_output(and_result),
        .or_output(or_result)
    );

    // =====================================================
    // SHIFT
    // dir = 0 → left
    // dir = 1 → right
    // =====================================================
    wire [31:0] shift_result;
    wire shift_dir;

    assign shift_dir = (alu_ctrl == 4'b0110); // SRL

    alushift u_shift (
        .A(a),
        .B(b),
        .dir(shift_dir),
        .Y(shift_result)
    );

    wire [31:0] xor_result;
    assign xor_result = a ^ b;  
    // =====================================================
    // RESULT MUX
    // Control Encoding
    //
    // 0000 ADD
    // 0001 SUB
    // 0010 SLL
    // 0011 SLT
    // 0100 SLTU
    // 0101 AND
    // 0110 SRL
    // 0111 OR
    // =====================================================
    assign result =
           (alu_ctrl == 4'b0000) ? addsub_result :
           (alu_ctrl == 4'b0001) ? addsub_result :
           (alu_ctrl == 4'b0010) ? shift_result  :
           (alu_ctrl == 4'b0011) ? slt_result    :
           (alu_ctrl == 4'b0100) ? sltu_result   :
           (alu_ctrl == 4'b0101) ? and_result    :
           (alu_ctrl == 4'b0110) ? shift_result  :
           (alu_ctrl == 4'b0111) ? or_result     :
           (alu_ctrl == 4'b1000) ? xor_result    :
           32'b0;

    // =====================================================
    // ZERO FLAG
    // =====================================================
    assign zero = (result == 32'b0);

endmodule