#!/bin/bash

AIRPODS_MAC=9C:A9:C5:76:85:85
CONNECTED=$(bluetoothctl info "$AIRPODS_MAC" | grep "Connected: yes")

if [ -n "$CONNECTED" ]; then
    echo "AirPods are already connected."
    read -p "Do you want to disconnect them? (y/n): " answer
    case "$answer" in
	[yY][eE][sS]|[yY])
	echo -e "disconnect $AIRPODS_MAC\nexit" | bluetoothctl
	echo "Disconnected from AirPods."
	;;
    *)
      echo "Keeping AirPods connected."
      ;;
    esac
else
    echo "Connecting to AirPods..."
    # echo -e "connect $AIRPODS_MAC\nexit" | bluetoothctl

    # Optional: set audio profile
    # sleep 2  # Give it a moment to establish connection
    # pactl set-card-profile bluez_card.$PA_MAC a2dp-sink

    echo "Connection attempt finished."
fi


# if[-n "$CONNECTED"];then
# 	echo "AirPods already connected."
# else
# 	echo "Connecting Airpods"
# # 	bluetoothctl connect $AIRPODS_MAC
# fi
