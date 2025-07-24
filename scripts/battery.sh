#!/bin/bash

BAT0_PATH="/sys/class/power_supply/BAT0"
BAT1_PATH="/sys/class/power_supply/BAT1"

read -r BAT0_ENERGY_NOW < "$BAT0_PATH/energy_now"
read -r BAT0_ENERGY_FULL < "$BAT0_PATH/energy_full"
read -r BAT1_ENERGY_NOW < "$BAT1_PATH/energy_now"
read -r BAT1_ENERGY_FULL < "$BAT1_PATH/energy_full"

TOTAL_ENERGY_NOW=$((BAT0_ENERGY_NOW + BAT1_ENERGY_NOW))
TOTAL_ENERGY_FULL=$((BAT0_ENERGY_FULL + BAT1_ENERGY_FULL))
BATTERY_PERCENTAGE=$(awk "BEGIN {printf \"%.1f\", ($TOTAL_ENERGY_NOW / $TOTAL_ENERGY_FULL) * 100}")

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

# Check charging status
BAT0_STATUS=$(<"$BAT0_PATH/status")
BAT1_STATUS=$(<"$BAT1_PATH/status")

if [[ $BAT0_STATUS == "Charging" || $BAT1_STATUS == "Charging" ]]; then
    ICON="bolt"
fi


# Output
if [[ "$1" == "icon" ]]; then
    echo "$ICON"
else
    echo "$BATTERY_PERCENTAGE%"
fi
