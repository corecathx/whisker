#!/bin/bash

BAT0_PATH="/sys/class/power_supply/BAT0"
BAT1_PATH="/sys/class/power_supply/BAT1"

# Read current and full energy values from both batteries
read -r BAT0_ENERGY_NOW < "$BAT0_PATH/energy_now"
read -r BAT0_ENERGY_FULL < "$BAT0_PATH/energy_full"
read -r BAT1_ENERGY_NOW < "$BAT1_PATH/energy_now"
read -r BAT1_ENERGY_FULL < "$BAT1_PATH/energy_full"

TOTAL_ENERGY_NOW=$((BAT0_ENERGY_NOW + BAT1_ENERGY_NOW))
TOTAL_ENERGY_FULL=$((BAT0_ENERGY_FULL + BAT1_ENERGY_FULL))
BATTERY_PERCENTAGE=$(awk "BEGIN {printf \"%.1f\", ($TOTAL_ENERGY_NOW / $TOTAL_ENERGY_FULL) * 100}")

# Select icon based on battery percentage
if (( $(echo "$BATTERY_PERCENTAGE < 20" | bc -l) )); then
    ICON="battery_1_bar"
elif (( $(echo "$BATTERY_PERCENTAGE < 40" | bc -l) )); then
    ICON="battery_2_bar"
elif (( $(echo "$BATTERY_PERCENTAGE < 60" | bc -l) )); then
    ICON="battery_4_bar"
elif (( $(echo "$BATTERY_PERCENTAGE < 80" | bc -l) )); then
    ICON="battery_5_bar"
else
    ICON="battery_full"
fi

BAT0_STATUS=$(<"$BAT0_PATH/status")
BAT1_STATUS=$(<"$BAT1_PATH/status")

# Show charging icon if any battery is charging
if [[ $BAT0_STATUS == "Charging" || $BAT1_STATUS == "Charging" ]]; then
    ICON="bolt"
fi

if [[ "$1" == "time" ]]; then
    RAW=""
    if command -v upower &>/dev/null; then
        for BAT in $(upower -e | grep battery); do
            EST=$(upower -i "$BAT" | grep -E "time to empty|time to full" | awk -F: '{print $2}' | xargs)
            if [[ -n "$EST" ]]; then
                RAW="$EST"
                break
            fi
        done
    elif command -v acpi &>/dev/null; then
        RAW=$(acpi | awk -F', ' '{print $3}')
    fi

    if [[ -z "$RAW" ]]; then
        echo "N/A"
        exit 0
    fi

    # Format: 1:32 ➜ 1h 32m
    if [[ "$RAW" =~ ^([0-9]+):([0-9]+)$ ]]; then
        H=${BASH_REMATCH[1]}
        M=${BASH_REMATCH[2]}
        [[ "$H" -eq 0 ]] && echo "${M}m" || echo "${H}h ${M}m"
        exit 0
    fi

    # Format: 1.5 hours ➜ 1h
    if [[ "$RAW" =~ ^([0-9]+)(\.[0-9]+)?\ hours?$ ]]; then
        H=${BASH_REMATCH[1]}
        echo "${H}h"
        exit 0
    fi

    # Format: 19.7 minutes ➜ 20m (rounded)
    if [[ "$RAW" =~ ^([0-9]+)(\.[0-9]+)?\ minutes?$ ]]; then
        M=$(printf "%.0f" "${BASH_REMATCH[1]}")
        echo "${M}m"
        exit 0
    fi

    # Fallback: print RAW as-is
    echo "$RAW"
    exit 0
fi

if [[ "$1" == "icon" ]]; then
    echo "$ICON"
else
    echo "$BATTERY_PERCENTAGE%"
fi
