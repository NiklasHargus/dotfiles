#!/bin/bash

# AirPods MAC address
AIRPODS_MAC="9C:A9:C5:76:85:85"

# Check if AirPods are connected
if bluetoothctl info "$AIRPODS_MAC" | grep -q "Connected: yes"; then
    echo "Disconnecting AirPods..."
    bluetoothctl disconnect "$AIRPODS_MAC"
else
    echo "Connecting AirPods..."
    bluetoothctl connect "$AIRPODS_MAC"
fi
