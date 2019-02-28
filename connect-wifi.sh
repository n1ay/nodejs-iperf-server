#!/bin/bash

SSID="$1"
pass='eethee8shaeY'

get_current_SSID() {
    /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ SSID/ {print substr($0, index($0, $2))}'
}

connect() {
    networksetup -setairportnetwork en0 $1 $2
}

while [ 1 ]
do
    echo "Running auto-wifi connect"
    current_SSID="$(get_current_SSID)"
    if ! [ "$current_SSID" == "$SSID" ]
    then
        echo "Current SSID: $current_SSID, connecting to $SSID..."
        connect "$SSID" "$pass"
    fi
    for((i=0;i<=30;i++))
    do
        sleep 1
        echo -n '.'
    done
    ((counter++))
    echo ''
done
