module mult_seq(
    input clk,
    input rst,

    input [6:0] opcode,
    input zero,
    input busy,

    input [2:0] next_type,
    input [5:0] next_addr,

    output reg [5:0] uPC
);

    reg [5:0] next_uPC;

    always @(posedge clk or posedge rst) begin
        if (rst)
            uPC <= 6'd0;
        else
            uPC <= next_uPC;
    end

    always @(*) begin
        case (next_type)

            // N → next
            3'b000: begin
                next_uPC = uPC + 1;
            end

            // S → stall if busy
            3'b001: begin
                if (busy)
                    next_uPC = uPC;
                else
                    next_uPC = uPC + 1;
            end

            // D → decode
            3'b010: begin
                case (opcode)

                    7'b0110011: next_uPC = 6'd10; // R-type
                    7'b0010011: next_uPC = 6'd20; // ADDI 
                    7'b0000011: next_uPC = 6'd32; // LW 
                    7'b0100011: next_uPC = 6'd40; // SW
                    7'b1100011: next_uPC = 6'd50; // BNE

                    default:    next_uPC = 6'd0;
                endcase
            end

            // J → jump
            3'b011: begin
                next_uPC = next_addr;
            end

            // EZ → if zero
            3'b100: begin
                if (zero)
                    next_uPC = next_addr;
                else
                    next_uPC = 6'd0;
            end

            // NZ → if not zero
            3'b101: begin
                if (!zero)
                    next_uPC = next_addr;
                else
                    next_uPC = 6'd0; // fixed
            end

            default: begin
                next_uPC = uPC + 1;
            end

        endcase
    end

endmodule