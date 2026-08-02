## RISC-V (RV32I) CPU in Verilog

This repo contains a RISC-V processor built through three progressively more advanced
architectures- single-cycle, multi-cycle, and a 5-stage pipelined CPU with a direct mapped cache
along with the modules, testbenches, and scripts used to build and verify each version.

All three versions implement the same RV32I instruction subset and share the same
underlying functional modules (ALU, register file, control unit, etc.), so each design
can be verified against the others' outputs.

## Repo structure

| Folder | Contents |
|---|---|
| `shared/` | The core Verilog **modules** reused across all three CPU versions - ALU, control unit, register file, immediate generator, decoders, memory, etc. |
| `duttb/` | **DUT (Device Under Test) and testbench** files - one set per CPU version (single-cycle, multi-cycle, pipelined), used to drive instruction sequences through each design and check correctness. |
| `scripts/` | Build/simulation scripts for compiling and running the testbenches. |

## Architecture progression

1. **Single-cycle CPU** - each instruction executes fully in one clock cycle. Establishes
   the core datapath: ALU, register file, control unit, immediate generator, and memory
   blocks.
2. **Multi-cycle CPU** - a single-bus datapath that reuses the same functional
   units across multiple clock cycles per instruction.
3. **Pipelined CPU + cache** 0 restructures the datapath into five overlapping stages
   (Fetch, Decode, Execute, Memory, Writeback) so multiple instructions execute
   concurrently. Includes:
   - Forwarding logic (EX and MEM/WB) to resolve data hazards without stalling
   - A hazard detection unit for load-use hazards forwarding can't fix
   - Branch resolution moved to the Decode stage, cutting the misprediction penalty to a
     single bubble cycle instead of two
   - A direct-mapped, write-through data cache, with stall logic to freeze the pipeline
     cleanly during a cache miss without corrupting in-flight instructions

## Running the testbenches

See `scripts/` for the simulation build/run scripts, and `duttb/` for the corresponding
testbench for each CPU version.
