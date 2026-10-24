#!/bin/bash
bluetoothctl remove D4:0C:C8:E2:52:EA
sleep 0.5
bluetoothctl scan on
sleep 3.0
bluetoothctl scan off
bluetoothctl pair D4:0C:C8:E2:52:EA
