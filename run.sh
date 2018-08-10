#!/bin/bash

#restart wpa, dhclient and nodejs server every X seconds
restart_timeout=7200

if [ -z "$(uname | grep -i darwin)" ]
then
    sys_type='linux'
else
    sys_type='darwin'
fi

clean_darwin() {
	echo "Running ${FUNCNAME[0]}..."
    ps -ef | grep -i screen | grep node | awk '{ print $2 }' | xargs kill -9
	ps -ef | grep node | grep iperf | awk '{ print$2 }' | xargs kill -9
	screen -wipe
	echo "${FUNCNAME[0]}: OK"
}

 clean_linux() {
     echo "Running ${FUNCNAME[0]}..."
     ps -ef | grep -i screen | grep wpa | awk '{ print $2 }' | xargs kill -9
     ps -ef | grep -i screen | grep node | awk '{ print $2 }' | xargs kill -9
     ps -ef | grep wpa_supp | awk '{ print $2 }' | xargs sudo kill -9
     ps -ef | grep node | grep iperf | awk '{ print$2 }' | xargs kill -9
     screen -wipe
     echo "${FUNCNAME[0]}: OK"
 }

clean() {
    echo "Running ${FUNCNAME[0]}..."
    clean_${sys_type}
    echo "${FUNCNAME[0]}: OK"
}

finish() {
	echo "Running ${FUNCNAME[0]}..."
	clean
	exit
}

#trap for cleaning after ctrl-c
trap finish INT

main() {
    echo "Running ${FUNCNAME[0]}..."
    main_${sys_type}
}

main_linux() {
	echo "Running ${FUNCNAME[0]}..."
	echo "Running wpa supplicant for wlan0 interface"
	clean
	echo -n "" > wpa.log
	screen -S wpa -d -m sudo wpa_supplicant -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf -dd -f wpa.log

	auth=""
	while [ -z "$auth"  ]
	do
		echo -n "Waiting for wpa supplicant to authenticate"
		for i in $(seq 1 30)
		do
			if ! [ -z "$auth" ]
			then
				break
			fi
        		auth=$(grep "EAPOL authentication completed - result=SUCCESS" wpa.log)
			sleep 1
			echo -n "."
		done
		echo ""
	done

	echo $auth
	sudo dhclient wlan0 -v

	echo -e "\nRunning nodejs server on $(ifconfig enp0s3 | grep "inet addr" | awk '{ print $2 }'):8080"
	cd nodejs-iperf-server
    screen -S node -d -m nodejs iperf_server.js
	cd ..
    echo "${FUNCNAME[0]}: OK"
}

main_darwin() {
    echo "Running ${FUNCNAME[0]}..."
    clean
    echo -e "\nRunning nodejs server on $(ifconfig en0 | grep "inet addr" | awk '{ print $2 }'):8080"
    cd nodejs-iperf-server
    screen -S node -d -m node iperf_server.js
    cd ..
}

if [ $# -eq 0 ]
then
    echo "Detected $sys_type system"
	echo "Restarting everything every $restart_timeout seconds"
	while [ 1 ]
    do
        if [ "$sys_type" == "linux" ]
        then
		    timeout --signal=9 $restart_timeout ./$(basename "$0") main
		    sleep $restart_timeout
		    echo "" > wpa.log
        else
            gtimeout --signal=9 $restart_timeout ./$(basename "$0") main
            sleep $restart_timeout
        fi
		clean
	done
elif [ $# -eq 1 ] && [ "$1" == "main"  ]
then
	echo "Calling main..."
	main
elif [ $# -eq 1 ] && ([ "$1" == "clean" ] || [ "$1" == "c" ])
then
        echo "Calling clean..."
        clean
else
	echo "Unsupported command. Exiting..."
fi

