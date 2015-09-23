#!/bin/bash

# DO NOT override $fileDat when using it; 
# Make a copy of it before using for a scheduling algorithms, i.e:
#
#    fileDatCopy=("${fileDat[@]}") 
#

if [ -z $1 ]; then
	echo "ERROR: please set the first argument as the input file name, i.e:  "
	echo
	echo "          strn.sh input.txt"
	echo
	exit 
fi

readarray fileDat < $1
quantum=${fileDat[${#fileDat[@]}-1]} 
unset fileDat[${#fileDat[@]}-1] #remove quantum 
processCount=${#fileDat[@]} 

# checks
if [ $quantum -lt 2 ] || [ $quantum -gt 10 ] ; then
  echo "ERROR: Quantum must be between 3 to 10"
  exit
fi

function printProcess() 
{
	process=($1)
	if [ -z $process ] ; then
	return
	fi

	processName=${process[0]}
	arrival=${process[1]}
	burst=${process[2]}
	priority=${process[3]}

	echo Process Name: $processName
	echo Arrival Time: $arrival
	echo Burst Time: $burst
	echo Priority: $priority
	echo 
}

function printFile()
{
	for process in "${fileDat[@]}"
	do
	   printProcess "$process"
	done

	echo Quantum: $quantum
}
