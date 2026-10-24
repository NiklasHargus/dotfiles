#!/bin/bash

# unbind device from the driver if it is bound
echo 0000:03:00.0 | sudo tee /sys/bus/pci/drivers/i915/unbind
echo 0000:03:00.0 | sudo tee /sys/bus/pci/drivers/xe/unbind
# allow PM
echo auto | sudo tee /sys/bus/pci/devices/0000\:03\:00.0/power/control
# remove device from pci subsystem
echo 1 | sudo tee /sys/bus/pci/devices/0000\:03\:00.0/remove
