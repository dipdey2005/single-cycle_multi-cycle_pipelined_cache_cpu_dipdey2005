`timescale 1ns/1ps

// Direct-mapped, write-through, no-write-allocate cache.

module cache #(parameter NUM_LINES = 64  // 6-bit index)(
    input clk,
    input reset,

    input  [31:0] address,
    input  [31:0] writeData,
    input         memRead,
    input         memWrite,

    output [31:0] readData,
    output        stall,       // 1 = miss in progress, freeze the pipeline

    // backing store port (BankedMEM)
    output reg [31:0] mem_address,
    output reg [31:0] mem_writeData,
    output reg        mem_writeEn,
    input      [31:0] mem_readData
);
    localparam IDX_BITS = 6; // log2(NUM_LINES)

    wire [23:0] tag   = address[31:8];
    wire [IDX_BITS-1:0] index = address[7:2];

    reg [23:0] tag_array   [0:NUM_LINES-1];
    reg        valid_array [0:NUM_LINES-1];
    reg [31:0] data_array  [0:NUM_LINES-1];

    integer i;
    initial begin
        for (i = 0; i < NUM_LINES; i = i + 1)
            valid_array[i] = 1'b0;
    end

    wire hit = valid_array[index] && (tag_array[index] == tag);

    // ---- FSM ----
    localparam CHECK  = 1'b0;
    localparam REFILL = 1'b1;
    reg state;

    assign stall    = (state == CHECK) ? (memRead && !hit) : 1'b1;
    assign readData = (state == REFILL) ? mem_readData :
                       (memRead && hit)  ? data_array[index] : 32'b0;

    always @(*) begin
        // defaults: no backing-store traffic
        mem_address   = address;
        mem_writeData = writeData;
        mem_writeEn   = 1'b0;

        if (state == CHECK) begin
            if (memWrite)
                mem_writeEn = 1'b1; // write-through, every store hits the backing store
            // a read miss doesn't write the backing store; REFILL issues the read
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            state <= CHECK;
        end
        else begin
            case (state)
                CHECK: begin
                    if (memWrite && hit) begin
                        data_array[index] <= writeData; // keep cached copy coherent
                    end
                    if (memRead && !hit) begin
                        state <= REFILL; // miss: go fetch the line
                    end
                end

                REFILL: begin
                    tag_array[index]   <= tag;
                    valid_array[index] <= 1'b1;
                    data_array[index]  <= mem_readData;
                    state <= CHECK;
                end
            endcase
        end
    end
endmodule

