#!/bin/bash

# Get the current active connection
active_ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)

# Get all available wifi networks
nmcli -t -f ssid,signal,security dev wifi list | while IFS=: read -r ssid signal security; do
    # Skip empty SSIDs
    if [ -z "$ssid" ]; then
        continue
    fi

    # Check if this is the active network
    if [ "$ssid" = "$active_ssid" ]; then
        connected="true"
    else
        connected="false"
    fi

    # Escape quotes in SSID
    ssid=$(echo "$ssid" | sed 's/"/\\"/g')

    echo "{\"ssid\":\"$ssid\",\"signal\":$signal,\"security\":\"$security\",\"connected\":$connected}"
done | jq -s 'unique_by(.ssid) | sort_by(.signal) | reverse | map(select(.connected == true or .signal >= 40)) | .[0:5]'
