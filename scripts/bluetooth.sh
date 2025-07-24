#!/bin/bash

BLUETOOTH_ICON_CONNECTED="bluetooth"
BLUETOOTH_ICON_DISCONNECTED="bluetooth_disabled"

if bluetoothctl show | grep -q "Powered: yes"; then
    if [[ $(bluetoothctl devices Connected | wc -l) -gt 0 ]]; then
        echo "$BLUETOOTH_ICON_CONNECTED"
    else
        echo "$BLUETOOTH_ICON_DISCONNECTED"
    fi
else
    echo ""
fi
