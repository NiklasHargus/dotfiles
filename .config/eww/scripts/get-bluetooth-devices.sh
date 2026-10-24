#!/bin/bash

# Get all bluetooth devices with their MAC address, name, and connection status
bluetoothctl devices | while read -r _ mac name; do
    # Get device info
    info=$(bluetoothctl info "$mac")

    # Check if connected
    if echo "$info" | grep -q "Connected: yes"; then
        connected="true"
    else
        connected="false"
    fi

    # Check if paired
    if echo "$info" | grep -q "Paired: yes"; then
        paired="true"
    else
        paired="false"
    fi

    # Only show paired devices
    if [ "$paired" = "true" ]; then
        # Escape quotes in name
        name=$(echo "$name" | sed 's/"/\\"/g')
        echo "{\"mac\":\"$mac\",\"name\":\"$name\",\"connected\":$connected}"
    fi
done | jq -s '.'
