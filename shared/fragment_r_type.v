`timescale 1ns/1ps

module fragment_r_type(
    input         clk,
    input         reset,
    input reg_write_en,
    input [31:0] instr
);
    wire  [4:0]  rd;
    wire  [4:0]  rs1;
    wire  [4:0]  rs2;
    wire  [2:0]  func3;
    wire  [6:0]  func7;
    wire  [3:0]  alu_ctrl;
    wire [31:0]  read_data1;
    wire [31:0]  read_data2;
    wire [31:0]  write_data;
    wire         zero;
    assign rd = instr[11:7];
    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];
    assign func3 = instr[14:12];
    assign func7 = instr[31:25];

    alu_ctrl inst2(
        .func3(func3),
        .func7(func7),
        .alu_ctrl(alu_ctrl)
    );

    rv32Ialu inst3(
        .a(read_data1),
        .b(read_data2),
        .alu_ctrl(alu_ctrl),
        .result(write_data),
        .zero(zero)
    );

    reg_file inst4(
        .clk(clk),
        .reset(reset),
        .reg_write_en(reg_write_en),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );
endmodule