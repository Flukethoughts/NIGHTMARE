#!/bin/bash
# Install custom Klipper extras (kinematics + shell command)
# Run this after Klipper updates to restore symlinks

EXTRAS_DIR="/home/pi/klipper_extras"
KLIPPER_KIN="/home/pi/klipper/klippy/kinematics"
KLIPPER_EXTRAS="/home/pi/klipper/klippy/extras"

mkdir -p "$EXTRAS_DIR"

# Install hybrid_corexy_4wd kinematics
MODULE="hybrid_corexy_4wd.py"
if [ ! -f "$EXTRAS_DIR/$MODULE" ]; then
    echo "ERROR: $EXTRAS_DIR/$MODULE not found!"
    exit 1
fi
ln -sf "$EXTRAS_DIR/$MODULE" "$KLIPPER_KIN/$MODULE"
echo "Kinematics: $KLIPPER_KIN/$MODULE -> $EXTRAS_DIR/$MODULE"

# Install gcode_shell_command extension
MODULE="gcode_shell_command.py"
if [ ! -f "$EXTRAS_DIR/$MODULE" ]; then
    echo "ERROR: $EXTRAS_DIR/$MODULE not found!"
    exit 1
fi
ln -sf "$EXTRAS_DIR/$MODULE" "$KLIPPER_EXTRAS/$MODULE"
echo "Extension: $KLIPPER_EXTRAS/$MODULE -> $EXTRAS_DIR/$MODULE"

echo "Done. Restart Klipper to apply."
