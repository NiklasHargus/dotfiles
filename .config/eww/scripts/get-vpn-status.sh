#!/bin/bash

# `protonvpn status` takes several seconds, so check the interface it brings up
# via NetworkManager instead. ProtonVPN connections are named "ProtonVPN <server>".
if nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | grep -q '^ProtonVPN.*:wireguard$'; then
    echo "true"
else
    echo "false"
fi
