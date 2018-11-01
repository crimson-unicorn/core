#!/bin/bash
while :
do 
	top -bn1 -p $(pidof main) | grep "^ " | awk '{ printf("%-8s %-8s\n", $9, $10); }'
	ps --no-header -o "%cpu %mem" -p $(pidof main)
	ps -p $(pidof main) -L -o psr,pcpu
	# echo $(pidof main)
	sleep 1
done
