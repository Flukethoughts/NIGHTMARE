#!/bin/bash
# Generate Y belt tension comparison graph for hybrid CoreXY
# Compares resonance data from left rail (stepper_y) vs right rail (stepper_y1)
# by testing at extreme X positions to bias the accelerometer signal

GRAPH_SCRIPT="$HOME/klipper/scripts/graph_accelerometer.py"
PYTHON="$HOME/klippy-env/bin/python"
OUTPUT_DIR="$HOME/printer_data/config/input_shaper"
DATE=$(date +%Y-%m-%d-%H%M%S)
OUTPUT_FILE="$OUTPUT_DIR/y-belt-tension-resonances-${DATE}.png"
LATEST_FILE="$OUTPUT_DIR/y-belt-tension-latest.png"

# Find the latest Y belt tension CSV files
LEFT=$(ls -t /tmp/raw_data_*y-belt-left*.csv 2>/dev/null | head -1)
RIGHT=$(ls -t /tmp/raw_data_*y-belt-right*.csv 2>/dev/null | head -1)

if [ -z "$LEFT" ] || [ -z "$RIGHT" ]; then
    echo "ERROR: Y belt tension CSV files not found in /tmp/"
    echo "Run MEASURE_HYBRID_Y_BELT_TENSION first."
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

$PYTHON "$GRAPH_SCRIPT" -f 120 -o "$OUTPUT_FILE" "$LEFT" "$RIGHT"

if [ -f "$OUTPUT_FILE" ]; then
    cp "$OUTPUT_FILE" "$LATEST_FILE"
    echo "<img src='/server/files/config/input_shaper/y-belt-tension-latest.png?$(date +%s)' style='max-width:100%;margin-top:4px' />"
else
    echo "ERROR: Failed to generate Y belt graph"
    exit 1
fi
