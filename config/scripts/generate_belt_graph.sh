#!/bin/bash
# Generate belt tension comparison graph from resonance test data
# Overlays upper and lower belt frequency responses for comparison

GRAPH_SCRIPT="$HOME/klipper/scripts/graph_accelerometer.py"
PYTHON="$HOME/klippy-env/bin/python"
OUTPUT_DIR="$HOME/printer_data/config/input_shaper"
DATE=$(date +%Y-%m-%d-%H%M%S)
OUTPUT_FILE="$OUTPUT_DIR/belt-tension-resonances-${DATE}.png"
LATEST_FILE="$OUTPUT_DIR/belt-tension-latest.png"

# Find the latest belt tension CSV files (handles both old and new Klipper axis naming)
UPPER=$(ls -t /tmp/raw_data_*belt-tension-upper*.csv 2>/dev/null | head -1)
LOWER=$(ls -t /tmp/raw_data_*belt-tension-lower*.csv 2>/dev/null | head -1)

if [ -z "$UPPER" ] || [ -z "$LOWER" ]; then
    echo "ERROR: Belt tension CSV files not found in /tmp/"
    echo "Run MEASURE_COREXY_BELT_TENSION first."
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

$PYTHON "$GRAPH_SCRIPT" -f 120 -o "$OUTPUT_FILE" "$UPPER" "$LOWER"

if [ -f "$OUTPUT_FILE" ]; then
    # Copy to latest for easy reference
    cp "$OUTPUT_FILE" "$LATEST_FILE"
    # Output img tag - Mainsail renders HTML in console via v-html
    echo "<img src='/server/files/config/input_shaper/belt-tension-latest.png?$(date +%s)' style='max-width:100%;margin-top:4px' />"
else
    echo "ERROR: Failed to generate graph"
    exit 1
fi
