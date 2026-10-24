#!/bin/bash

# Name of the active ProtonVPN server, e.g. "NO-FREE#6". Empty when disconnected.
nmcli -t -f NAME,TYPE connection show --active 2>/dev/null \
    | grep '^ProtonVPN.*:wireguard$' \
    | head -n1 \
    | sed 's/:wireguard$//; s/^ProtonVPN //'
