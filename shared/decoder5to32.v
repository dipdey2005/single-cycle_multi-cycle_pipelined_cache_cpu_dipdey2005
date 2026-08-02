`timescale 1ns/1ps   

module decoder5to32(
    input        reg_write_en, 
    input  [4:0] rd,           
    output [31:0] dec_out      //one hot output
);

    // One-hot decoder:
    // - If write enabled → shift 1 to position 'rd'
    // - Else → all zeros
    assign #1 dec_out = (reg_write_en) ? 
                        ((32'b1 << rd)) 
                        : 32'b0;
//with delay
endmodule