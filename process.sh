#!/bin/bash

# DO NOT override $FILEDAT when using it; 
# Make a copy of it before using for scheduling algorithms, i.e:
#
#    FILEDATCOPY=("${FILEDAT[@]}") 
#

readarray FILEDAT < $1
QUANTUM=${FILEDAT[${#FILEDAT[@]}-1]} 
unset FILEDAT[${#FILEDAT[@]}-1] #remove quantum 
PROCESSCOUNT=${#FILEDAT[@]} 

# checks
if [ $QUANTUM -lt 3 ] || [ $QUANTUM -gt 10 ] ; then
	echo "ERROR: Quantum must be between 3 to 10"
	exit
fi

function printProcess {
	PROCESS=(${FILEDAT[$1]})
	
	if [ -z $PROCESS ] ; then
		return
	fi
	
	PROCESSNAME=${PROCESS[0]}
	ARRIVAL=${PROCESS[1]}
	BURST=${PROCESS[2]}
	PRIORITY=${PROCESS[3]}
	
	echo Process Name: $PROCESSNAME
	echo Arrival Time: $ARRIVAL
	echo Burst Time: $BURST
	echo Priority: $PRIORITY
	echo 
}

COUNT=0
let END=PROCESSCOUNT-1

until [ $COUNT -gt $END ]; do
	printProcess $COUNT
	let COUNT=COUNT+1
done

echo Quantum: $QUANTUM

echo
echo "~~~ Shortest Time Remaining Next (STRN) Scheduling ~~~"
echo

STRNDAT=("${FILEDAT[@]}") 

SHORTESTBURSTIDX=0
CURRENTTIME=0
TOTALTURNAROUNDTIME=0
WAITINGTIME=0

echo "Grantt Chart: "
echo -n $CURRENTTIME' '

while [ ${#STRNDAT[@]} -gt 0 ] ; do
	SHORTESTBURST=99999
	COUNT=0
	until [ $COUNT -gt $PROCESSCOUNT ]; do
		PROCESS=(${STRNDAT[$COUNT]})
		
		if [ -z $PROCESS ] ; then
			let COUNT=COUNT+1
			continue
		fi
		
		BURST=${PROCESS[2]}

		if [ $BURST -lt $SHORTESTBURST ]; then
			SHORTESTBURST=$BURST
			SHORTESTBURSTIDX=$COUNT
		fi
		
		let COUNT=COUNT+1
	done
	
	CHOSENPROCESS=(${STRNDAT[$SHORTESTBURSTIDX]})
	PROCESSNAME=${CHOSENPROCESS[0]}
	ARRIVAL=${PROCESS[1]}
	BURST=${CHOSENPROCESS[2]}
	#~ echo "Chosen Process: " $CHOSENPROCESS
	
	let CURRENTTIME=CURRENTTIME+BURST
	echo -n  [$PROCESSNAME] $CURRENTTIME' '
	
	let TURNAROUNDTIME=CURRENTTIME-ARRIVAL
	let WAITINGTIME=WAITINGTIME+TURNAROUNDTIME-BURST
	let TOTALTURNAROUNDTIME=TOTALTURNAROUNDTIME+TURNAROUNDTIME
	
	unset STRNDAT[$SHORTESTBURSTIDX] 
done

let AVGWAITINGTIME=WAITINGTIME/PROCESSCOUNT
let AVGTURNAROUNDTIME=TOTALTURNAROUNDTIME/PROCESSCOUNT

echo
echo
echo "Total   Turnaround Time :" $TOTALTURNAROUNDTIME
echo "Average Turnaround Time :" $AVGTURNAROUNDTIME
echo "Total   Waiting Time    :" $WAITINGTIME
echo "Average Waiting Time    :" $AVGWAITINGTIME
echo
echo "~~~ END: Shortest Time Remaining Next (STRN) Scheduling ~~~"
echo
