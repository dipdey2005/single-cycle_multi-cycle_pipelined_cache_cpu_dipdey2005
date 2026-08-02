`timescale 1ns/1ps

module reg32(
    input clk,
    input reset,
    input we,
    input [31:0] d,
    output reg [31:0] q  //output needs to be registered
    );

    always @(posedge clk) begin
        if(reset) begin  //synchronous reset
            q <= #1 32'b0; //reset with delay
        end
        else begin
            if(we) begin
                q <= #1 d; //load input data with delay
            end
            else begin
                 q <= q; //hold previous value
            end
        end        
    end
endmodule
