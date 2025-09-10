#!/bin/bash

# wallpaper.sh: Generate colors from a wallpaper using matugen
# Usage: ./wallpaper.sh /path/to/wallpaper.png mode colorscheme

# Set the config path
CONFIG_PATH="$HOME/.config/whisker/colors.json"

# Ensure wallpaper path, mode, and colorscheme are provided
if [ $# -lt 3 ]; then
    echo "[wallpaper.sh] Error: Missing arguments."
    echo "Usage: $0 /path/to/wallpaper.png <mode> <colorscheme>"
    exit 1
fi

WALLPAPER="$1"
MODE="$2"
COLORSCHEME="$3"

# Run matugen and save output
echo "[wallpaper.sh] Generating colors from: $WALLPAPER with mode=$MODE and scheme=$COLORSCHEME"
if ! matugen image "$WALLPAPER" -m "$MODE" -t "scheme-$COLORSCHEME" -j hex > "$CONFIG_PATH"; then
    echo "[wallpaper.sh] Failed to generate colors."
    exit 1
fi
notify-send "Whisker" "Wallpaper color generation completed!"
echo "[wallpaper.sh] Colors saved to $CONFIG_PATH"
