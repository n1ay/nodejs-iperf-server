#!/bin/bash

SSID1="$1"
SSID2="$2"
pass='eethee8shaeY'

echo $SSID1 $SSID2

get_current_SSID() {
    /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ SSID/ {print substr($0, index($0, $2))}'
}

connect() {
    networksetup -setairportnetwork en0 $1 $2
}

counter_limit=40
counter=0

while [ 1 ]
do
	while [ $counter -lt $counter_limit ]
	do
	    echo "Running auto-wifi connect"
	    current_SSID="$(get_current_SSID)"
	    if ! [ "$current_SSID" == "$SSID1" ]
	    then
		echo "Current SSID: $current_SSID, connecting to $SSID1..."
		connect "$SSID1" "$pass"
	    fi
	    for((i=0;i<=30;i++))
	    do
		sleep 1
		echo -n '.'
	    done
	    ((counter++))
	    echo ''
	done

	while [ $counter -gt 0 ]
	do
	    echo "Running auto-wifi connect"
	    current_SSID="$(get_current_SSID)"
	    if ! [ "$current_SSID" == "$SSID2" ]
	    then
		echo "Current SSID: $current_SSID, connecting to $SSID2..."
		connect "$SSID2" "$pass"
	    fi
	    for((i=0;i<=30;i++))
	    do
		sleep 1
		echo -n '.'
	    done
	    echo ''
	    ((counter--))
	done
done
