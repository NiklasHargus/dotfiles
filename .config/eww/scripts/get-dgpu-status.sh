#!/bin/bash

# The dGPU is "connected" when it is present in the PCI subsystem. Removing it
# (scripts/dgpu-priv off) deletes the sysfs entry, so presence is the state.
if [ -e /sys/bus/pci/devices/0000:03:00.0 ]; then
    echo "true"
else
    echo "false"
fi
