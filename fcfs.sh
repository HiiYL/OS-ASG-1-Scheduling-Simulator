#!/bin/bash

. readprocessinput.sh

# uncomment to print the input of the file
printFile

echo
echo "~~~ Pre-emptive FCFS Scheduling ~~~"
echo

strnProcesses=("${fileDat[@]}") 

# stores all the processes that have arrived:
arrivedProcesses=()
arrivedProcessesIdx=0

totalTurnAroundTime=0
shortestBurstIdx=0
currentTime=0
totalTurnAroundTime=0
totalWaitingTime=0

# When no process is available, value is -1, otherwise it is the index of the chosen process.
chosenProcessIdx=-1
# currentProcessIdx is init at -2, where it represents a state where neither
# no process or process is current; it has not been initialize yet.
currentProcessIdx=-2 

echo "Grantt Chart: "

while [ ${#strnProcesses[@]} -gt 0 ] || [ ${#arrivedProcesses[@]} -gt 0 ]; do
	## Add to arrivedProcesses array
	# update the arrived processes via on the current time of OS and arrival time of process:
	count=0
	until [ $count -gt $processCount ]; do
		process=(${strnProcesses[$count]})
		
		if [ -z $process ] ; then
			let count=count+1
			continue
		fi
		
		arrival=${process[1]}

		if [ $arrival -le $currentTime ]; then
			# appends current burst time which will be decremented as it is being consumed.
			currentBurst=${process[2]}
			arrivedProcesses[$arrivedProcessesIdx]=${strnProcesses[$count]}' '$currentBurst
			let arrivedProcessesIdx=arrivedProcessesIdx+1
			unset strnProcesses[$count]
			
			#~ echo "arrived process " ${arrivedProcesses[@]} "with count " $count
		fi
		
		
		let count=count+1
	done
	## END: Add to arrivedProcesses array
	
	## Deal with finished processes
	count=0
	until [ $count -ge $arrivedProcessesIdx ]; do
		process=(${arrivedProcesses[$count]})
		
		if [ -z $process ] ; then
			let count=count+1
			continue
		fi
		
		burst=${process[4]}
		
		if [ $burst -eq 0 ]; then
			# remove any process with burst time of 0; they are finished.
			unset arrivedProcesses[$count]
			#~ echo "(process finished: "${process[0]}" at time "$currentTime")"
			
			# here current time is the finishing time
			arrivalTime=${process[1]}
			burst=${process[2]}
			let turnaroundTime=currentTime-arrivalTime
			let waitingTime=turnaroundTime-burst
			let totalTurnAroundTime=totalTurnAroundTime+turnaroundTime
			let totalWaitingTime=totalWaitingTime+waitingTime
			continue
		fi
		
		let count=count+1
	done
	## END: Deal with finished processes

	## Choose process based on shortest burst time
	count=0
	highestPriority=9999999
	if [ ${#arrivedProcesses[@]} -gt 0 ]; then
		# choose an arrived process based on shortest burst time
		until [ $count -ge $arrivedProcessesIdx ]; do
			process=(${arrivedProcesses[$count]})
		
			if [ -z $process ] ; then
				let count=count+1
				continue
			fi
			
			currentPriority=${process[3]}
			
			if [ $currentPriority -lt $highestPriority ]; then
				highestPriority=$currentPriority
				chosenProcessIdx=$count
			fi
			
			let count=count+1
		done
	else
		chosenProcessIdx=-1
	fi
	## END: Choose process based on shortest burst time
	
	## Decrement burst time if process is consumed
	if [ $chosenProcessIdx -ne -1 ]; then
		# if process is chosen, deduct burst time:
		process=(${arrivedProcesses[$chosenProcessIdx]})
		let newBurstTime=${process[4]}-1
		#~ echo "new burst time" $newBurstTime
		process[4]=$newBurstTime
		arrivedProcesses[$chosenProcessIdx]=${process[@]}
	fi
	## END: Decrement burst time if process is consumed
	
	## Print Gantt chart
	if [ $currentProcessIdx -ne $chosenProcessIdx ]; then 
		
		if [ $chosenProcessIdx -eq -1 ]; then 
			if [ ${#strnProcesses[@]} -gt 0 ] || [ $currentProcessIdx -eq -2 ]; then
				echo -n $currentTime [*IDLE*]' '
			else
				# ending arrival time
				echo -n $currentTime
			fi
		else
			process=(${arrivedProcesses[$chosenProcessIdx]})
			processName=${process[0]}
			
			echo -n $currentTime [$processName]' '
		fi
		
		currentProcessIdx=$chosenProcessIdx
	fi
	## END: Print Gantt chart
	
	let currentTime=currentTime+1
done

echo
echo
echo "Total   Turnaround Time : "$totalTurnAroundTime
echo "Total   Waiting Time    :" $totalWaitingTime
echo -n "Average Turnaround Time : "; bc <<< 'scale=2;'$totalTurnAroundTime'/'$processCount
echo -n "Average Waiting Time    : "; bc <<< 'scale=2;'$totalWaitingTime'/'$processCount
echo
echo "~~~ END: Pre-emptive FCFS Scheduling ~~~"
echo
