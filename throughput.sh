#!/bin/bash

mul() {
	echo $1 $2 | awk '{ print $1*$2 }'
}

run_test() {
    echo '"0"' > data.json
    if [ "$(uname)" == "Darwin" ]
    then
	    throughput=$(gtimeout --signal=9 10 iperf -c 192.168.121.100 -t 8 -i 1 | sed -n '14p' | sed 's/.*Bytes *//g')
    else
        throughput=$(timeout 10 iperf --signal=9 -c 192.168.121.100 -t 8 -i 1 | sed -n '14p' | sed 's/.*Bytes *//g')
    fi
    numeric_value=$(echo $throughput | awk '{ print $1 }')
	metric_prefix=$(echo $throughput | awk '{ print $2 }')

	case "$metric_prefix" in
		"Gbits/sec") value=$(mul $numeric_value 1000);;
		"Mbits/sec") value=$numeric_value;;
		"Kbits/sec") value=$(mul $numeric_value 0.001);;
		"bits/sec") value=$(mul $numeric_value 0.000001);;
		*) value=0;;
	esac

	echo \"$value\" > data.json
}


while [ 1 ]
do
	run_test
done

