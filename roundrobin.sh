readarray fileDat < $1
QUANTUM=${fileDat[${#fileDat[@]}-1]} 
unset fileDat[${#fileDat[@]}-1] #remove quantum 
PROCESSCOUNT=${#fileDat[@]} 
totalTurnAroundTime=0
# checks
if [ $QUANTUM -lt 3 ] || [ $QUANTUM -gt 10 ] ; then
  echo "ERROR: Quantum must be between 3 to 10"
  exit
fi

for el in "${fileDat[@]}"     ## Sorts input by priority
do
    echo "$el"
done | sort -t' ' -n -k4,4 -k2,2

function printProcess() {
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
for process in "${fileDat[@]}"
do
   printProcess "$process"
done

echo Quantum: $QUANTUM

currentTime=0
arrivedProcess=()
  echo -------------------------------------------------------
while [ ${#fileDat[@]} -gt 0 ]; do
  count=0

  for process in "${fileDat[@]}"      #Moves arrived process to arrivedProcess array 
    do
      processSeparated=($process)
      arrivalTime=${processSeparated[1]}
      # echo PRocess Separated = ${processSeparated[2]}
      # echo Current Time: $currentTime  Arrival Time: $arrivalTime
      if ! [ $arrivalTime -gt $currentTime ] ; then
        # echo "--------" 
        printf "| "${processSeparated[0]} "|"
        # echo "--------"
        # echo $process
        # echo Before Quantum - ${processSeparated[2]}
        let currentTime=currentTime+$(($QUANTUM>${processSeparated[2]} ?${processSeparated[2]}:$QUANTUM))
        let processSeparated[2]=${processSeparated[2]}-$QUANTUM 
        process="${processSeparated[*]}"
        # fileDat[count]=$process
        # echo After - ${#fileDat[@]}
        if [ ${processSeparated[2]} -lt 1 ] ; then
          # echo Remove - Before: ${#fileDat[@]} 
          # fileDat=("${fileDat[@]:$count}")
          # echo DELETING IS NOT WORKING WTF $count
          let totalTurnAroundTime="$totalTurnAroundTime + (currentTime-$processSeparated[1])"

          unset fileDat[$count]
          # echo Remove - After: ${#fileDat[@]} 
          # fileDat=("${fileDat[@]:$count}")
          # echo After - ${#fileDat[@]}
        else
          fileDat[count]=$process
        fi
        # echo After Quantum - ${processSeparated[2]}

        # echo $process
        # echo Size of Array: ${#fileDat[@]}
        # echo Arrived Process is: $arrivedProcess
        # echo ${#arrivedProcess[@]}
      fi
      # sleep 0.250
      # echo Count is $count
      let count=count+1
  done
  fileDat=("${fileDat[@]}")
done
  let averageTurnaroundTime=totalTurnAroundTime/PROCESSCOUNT
  # averageTurnaroundTime = 
  echo
  echo -------------------------------------------------------
  echo
  echo
  echo Total Time Elapsed:  $currentTime
  echo Total Turnaround Time : $totalTurnAroundTime
  echo Average Turnaround Time : $averageTurnaroundTime
  echo
  echo "~~~ END: Round Robin (RRBN) Scheduling ~~~"
  echo





