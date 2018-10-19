#!/usr/bin/bash
while :
do 
	top -bn1 -p $(pidof camflow-provenance) | grep "^ " | awk '{ printf("%-8s %-8s\n", $9, $10); }'
	ps --no-header -o "%cpu %mem" -p $(pidof camflow-provenance)
	#ps -p $(pidof camflow-provenance) -L -o psr,pcpu
	# echo $(pidof camflow-provenance)
	sleep 1
done
