#!/bin/bash
# Generate input shaper graphs from SHAPER_CALIBRATE data

GRAPH_SCRIPT="$HOME/klipper/scripts/calibrate_shaper.py"
PYTHON="$HOME/klippy-env/bin/python"
OUTPUT_DIR="$HOME/printer_data/config/input_shaper"
DATE=$(date +%Y-%m-%d-%H%M%S)

mkdir -p "$OUTPUT_DIR"

# Find the latest calibration data files
X_CSV=$(ls -t /tmp/calibration_data_x*.csv 2>/dev/null | head -1)
Y_CSV=$(ls -t /tmp/calibration_data_y*.csv 2>/dev/null | head -1)

GENERATED=0

if [ -n "$X_CSV" ]; then
    X_OUTPUT="$OUTPUT_DIR/resonances_x_${DATE}.png"
    $PYTHON "$GRAPH_SCRIPT" "$X_CSV" -o "$X_OUTPUT" 2>&1
    if [ -f "$X_OUTPUT" ]; then
        cp "$X_OUTPUT" "$OUTPUT_DIR/shaper_x_latest.png"
        GENERATED=1
    fi
fi

if [ -n "$Y_CSV" ]; then
    Y_OUTPUT="$OUTPUT_DIR/resonances_y_${DATE}.png"
    $PYTHON "$GRAPH_SCRIPT" "$Y_CSV" -o "$Y_OUTPUT" 2>&1
    if [ -f "$Y_OUTPUT" ]; then
        cp "$Y_OUTPUT" "$OUTPUT_DIR/shaper_y_latest.png"
        GENERATED=1
    fi
fi

if [ "$GENERATED" -eq 0 ]; then
    echo "ERROR: No calibration data found in /tmp/"
    echo "Run SHAPER_CALIBRATE first."
    exit 1
fi

# Display inline in Mainsail console
TS=$(date +%s)
if [ -f "$OUTPUT_DIR/shaper_x_latest.png" ]; then
    echo "X axis input shaper:"
    echo "<img src='/server/files/config/input_shaper/shaper_x_latest.png?${TS}' style='max-width:100%;margin-top:4px' />"
fi
if [ -f "$OUTPUT_DIR/shaper_y_latest.png" ]; then
    echo "Y axis input shaper:"
    echo "<img src='/server/files/config/input_shaper/shaper_y_latest.png?${TS}' style='max-width:100%;margin-top:4px' />"
fi
