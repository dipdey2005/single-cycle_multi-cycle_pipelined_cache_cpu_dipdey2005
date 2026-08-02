`timescale 1ns/1ps

module reg_file(
    input clk,
    input reset,
    input reg_write_en,
    input  [4:0]  rd,
    input  [4:0]  rs1,
    input  [4:0]  rs2,
    input [31:0] write_data,   
    output [31:0] read_data1,   
    output [31:0] read_data2
);
    wire [31:0] reg_out[31:0]; 
    wire [31:0] dec_out;

    decoder5to32 decoder1(
        .reg_write_en(reg_write_en),
        .rd(rd),                 
        .dec_out(dec_out)
    );

    genvar i;

    generate
        for (i = 0; i < 32; i = i + 1) begin : REG_ARRAY
            if (i == 0) begin
                assign reg_out[i] = 32'b0;
            end
            else begin
                reg32 r (
                    .clk(clk),
                    .reset(reset),
                    .we(dec_out[i]), 
                    .d(write_data),
                    .q(reg_out[i])
                );
            end
        end
    endgenerate


    assign #1 read_data1 = reg_out[rs1];
    assign #1 read_data2 = reg_out[rs2];

endmodule
