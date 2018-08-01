#!/bin/bash

mul() {
	echo $1 $2 | awk '{ print $1*$2 }' 
}

run_test() {

	throughput=$(iperf -c 192.168.121.100 -t 10 -i 1 | sed -n '16p' | sed 's/.*Bytes *//g')
	numeric_value=$(echo $throughput | awk '{ print $1 }')
	metric_prefix=$(echo $throughput | awk '{ print $2 }')

	case "$metric_prefix" in
		"Gbits/sec") value=$(mul $numeric_value 1000000000);;
		"Mbits/sec") value=$(mul $numeric_value 1000000);;
		"Kbits/sec") value=$(mul $numeric_value 1000);;
		*) value=$numeric_value;;
	esac

	echo \"$value\" > data.json
}


while [ 1 ]
do
	run_test
done

