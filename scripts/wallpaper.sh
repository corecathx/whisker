#!/bin/bash

# wallpaper.sh: Generate colors from a wallpaper using matugen
# Usage: ./wallpaper.sh /path/to/wallpaper.png

# Set the config path
CONFIG_PATH="$HOME/.config/whisker/colors.json"

# Ensure wallpaper path is provided
if [ -z "$1" ]; then
    echo "[wallpaper.sh] Error: No wallpaper path provided."
    echo "Usage: $0 /path/to/wallpaper.png"
    exit 1
fi

WALLPAPER="$1"

# Run matugen and save output
echo "[wallpaper.sh] Generating colors from: $WALLPAPER"
if ! matugen image "$WALLPAPER" -m dark -j hex > "$CONFIG_PATH"; then
    echo "[wallpaper.sh] Failed to generate colors."
    exit 1
fi

echo "[wallpaper.sh] Colors saved to $CONFIG_PATH"
