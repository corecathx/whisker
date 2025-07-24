#!/bin/bash

WIFI_SIGNAL_0="signal_wifi_0_bar"
WIFI_SIGNAL_1="network_wifi_1_bar"
WIFI_SIGNAL_2="network_wifi_2_bar"
WIFI_SIGNAL_3="network_wifi_3_bar"
WIFI_SIGNAL_4="signal_wifi_4_bar"
WIFI_ICON_DISCONNECTED="signal_wifi_off"
ETH_ICON_CONNECTED="settings_ethernet"
BLUETOOTH_ICON_CONNECTED="bluetooth"
BLUETOOTH_ICON_DISCONNECTED="bluetooth_disabled"

if nmcli -t -f DEVICE,TYPE,STATE dev | grep -q "ethernet:connected"; then
    echo "$ETH_ICON_CONNECTED"
    exit 0
elif nmcli radio wifi | grep -q "enabled"; then
    WIFI_SIGNAL=$(nmcli -t -f IN-USE,SIGNAL dev wifi | grep '^*' | cut -d: -f2)
    if [[ -n $WIFI_SIGNAL ]]; then
        if (( WIFI_SIGNAL >= 75 )); then
            echo "$WIFI_SIGNAL_4"
            exit 0
        elif (( WIFI_SIGNAL >= 50 )); then
            echo "$WIFI_SIGNAL_3"
            exit 0
        elif (( WIFI_SIGNAL >= 25 )); then
            echo "$WIFI_SIGNAL_2"
            exit 0
        elif (( WIFI_SIGNAL > 0 )); then
            echo "$WIFI_SIGNAL_1"
            exit 0
        else
            echo "$WIFI_SIGNAL_0"
            exit 0
        fi
    else
        echo "$WIFI_ICON_DISCONNECTED"
        exit 0
    fi
else
    echo "$WIFI_ICON_DISCONNECTED"
    exit 0
fi
