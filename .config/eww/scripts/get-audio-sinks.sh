#!/bin/bash

# Get the default sink name
default_sink=$(pactl get-default-sink)

# Get all audio sinks with their index, name, and description (only available/plugged in)
pactl list sinks | awk -v default_sink="$default_sink" '
    /^Sink #/ {
        if (idx != "" && name != "" && is_available) {
            gsub(/"/, "\\\"", desc)
            is_default = (name == default_sink) ? "true" : "false"
            printf "{\"index\":\"%s\",\"name\":\"%s\",\"description\":\"%s\",\"is_default\":%s}\n", idx, name, desc, is_default
        }
        idx = $2
        sub(/#/, "", idx)
        name = ""
        desc = ""
        is_available = 1
    }
    /Name:/ { name = $2 }
    /not available\)/ { is_available = 0 }
    /Description:/ {
        desc = $0
        sub(/^[[:space:]]*Description:[[:space:]]*/, "", desc)
    }
    END {
        if (idx != "" && name != "" && is_available) {
            gsub(/"/, "\\\"", desc)
            is_default = (name == default_sink) ? "true" : "false"
            printf "{\"index\":\"%s\",\"name\":\"%s\",\"description\":\"%s\",\"is_default\":%s}\n", idx, name, desc, is_default
        }
    }
' | jq -s '.'
