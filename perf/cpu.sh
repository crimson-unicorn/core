#!/bin/bash

while read -r cpuid cpu
do
	if [ "$cpuid" == "PSR" ]
	then
		echo "$cpu" >> "core0.txt"
		echo "$cpu" >> "core1.txt"
		echo "$cpu" >> "core2.txt"
		echo "$cpu" >> "core3.txt"
	fi
	if [ "$cpuid" == "0" ]
	then
		echo "$cpu" >> "core0.txt"
	fi
	if [ "$cpuid" == "1" ]
	then
		echo "$cpu" >> "core1.txt"
	fi
	if [ "$cpuid" == "2" ]
	then
		echo "$cpu" >> "core2.txt"
	fi
	if [ "$cpuid" == "3" ]
	then
		echo "$cpu" >> "core3.txt"
	fi
done < $1

#Must remove the first line of all corex_cpu.txt file
num0=0
num1=0
num2=0
num3=0

while read -r cpu
do
	if [ "$cpu" == "%CPU" ]
	then
		echo "$num0" >> "core0_cpu.txt"
		num0=0
	else
		num0=`echo $num0 + $cpu | bc`
	fi
done < "core0.txt"

while read -r cpu
do
	if [ "$cpu" == "%CPU" ]
	then
		echo "$num1" >> "core1_cpu.txt"
		num1=0
	else
		num1=`echo $num1 + $cpu | bc`
	fi
done < "core1.txt"

while read -r cpu
do
	if [ "$cpu" == "%CPU" ]
	then
		echo "$num2" >> "core2_cpu.txt"
		num2=0
	else
		num2=`echo $num2 + $cpu | bc`
	fi
done < "core2.txt"

while read -r cpu
do
	if [ "$cpu" == "%CPU" ]
	then
		echo "$num3" >> "core3_cpu.txt"
		num3=0
	else
		num3=`echo $num3 + $cpu | bc`
	fi
done < "core3.txt"

rm "core0.txt"
rm "core1.txt"
rm "core2.txt"
rm "core3.txt"

