#!/usr/bin/env bash
set -e

LAB="$1"
TASK="$2"
TB="$3"

if [ -z "$LAB" ] || [ -z "$TASK" ] || [ -z "$TB" ]; then
  echo "Usage: compile.sh <lab> <task> <testbench>"
  exit 1
fi

LAB_DIR="labs/${LAB}"
TASK_DIR="${LAB_DIR}/${TASK}"
TB_FILE="${LAB_DIR}/tb/${TB}"
DUT_FILE="${TASK_DIR}/dut.v"
ARTEFACT_DIR="artefacts/${LAB}"

# Sanity checks
[ -d "$LAB_DIR" ] || { echo "Error: lab not found"; exit 1; }
[ -d "$TASK_DIR" ] || { echo "Error: task not found"; exit 1; }
[ -f "$DUT_FILE" ] || { echo "Error: dut.v not found"; exit 1; }
[ -f "$TB_FILE" ] || { echo "Error: testbench not found"; exit 1; }

mkdir -p "$ARTEFACT_DIR"

OUT_SIM="${ARTEFACT_DIR}/${TASK}_${TB%.v}.sim"

# Collect Verilog files from task directory
TASK_FILES=()
for f in "$TASK_DIR"/*.v; do
  [ -e "$f" ] && TASK_FILES+=("$f")
done

# Collect shared files *only if they exist*
SHARED_FILES=()
if [ -d "shared" ]; then
  for f in shared/*.v; do
    [ -e "$f" ] && SHARED_FILES+=("$f")
  done
fi

iverilog -g2012 -Wall \
  -o "$OUT_SIM" \
  "${SHARED_FILES[@]}" \
  "${TASK_FILES[@]}" \
  "$TB_FILE"

echo "✔ Compiled: $OUT_SIM"
