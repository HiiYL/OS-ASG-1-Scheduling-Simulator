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
IFS=$'\n' 
fileDat=($(for each in ${fileDat[@]}; do
  echo $each
done | sort -n -k4,4nr -k2,2 ))
unset IFS

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
echo Quantum: $QUANTUM
echo
echo "~~~ Round Robin (RRBN) Scheduling ~~~"
echo

for process in "${fileDat[@]}"; do
  echo $process
done

currentTime=0
  echo -------------------------------------------------------
  echo Grantt Chart
  printf "0 "
while [ ${#fileDat[@]} -gt 0 ]; do
  count=0
  # has_element_not_queued=false
  for process in "$fileDat[@]}"; do
    processSeparated=($process)
    if [ -z "${processSeparated[5]}" ]; then
      has_element_not_queued=true
      break
    fi
  done
  if ! $has_element_not_queued ; then
    for process in "$fileDat[@]}"; do
      processSeparated=($process)
      unset ${processSeparated[5]}
      # echo "Unsetting!" $has_element_not_queued
    done
  fi
  # for process in "${fileDat[@]}"; do
  #   echo $process
  # done

  unset hasElementUpdated
  for process in "${fileDat[@]}"
    do
      processSeparated=($process)
      arrivalTime=${processSeparated[1]}
      # echo ${processSeparated[0]} and count is $count
      # echo ${processSeparated[0]} - Current Time: $currentTime - ArrivalTime: $arrivalTime
      # echo Count is: $count
      if  [ ! $arrivalTime -gt $currentTime ] ; then
        processSeparated[5]=true
        hasElementUpdated=false
        if ! [ -z $idleTime ]; then
          # echo "TESTING TESTING"
          echo -n  "[IDLE]" $currentTime' '
          unset idleTime
        fi
        let currentTime=currentTime+$(($QUANTUM>${processSeparated[2]} ?${processSeparated[2]}:$QUANTUM))

        echo -n  [${processSeparated[0]}] $currentTime' '
        if [ -z "${processSeparated[4]}" ]; then
          let processSeparated[4]=${processSeparated[2]}-$QUANTUM 
        else
          let processSeparated[4]=${processSeparated[4]}-$QUANTUM 
        fi
        process="${processSeparated[*]}"
        if [ ${processSeparated[4]} -lt 1 ] ; then
          let turnAroundTime="currentTime-${processSeparated[1]}"
          let totalWaitingTime="$totalWaitingTime + $turnAroundTime - ${processSeparated[2]}"
          let totalTurnAroundTime="$totalTurnAroundTime + $turnAroundTime"
          unset fileDat[$count]
        else
          fileDat[count]=$process
        fi
      fi
      # sleep 0.250
      let count=count+1
  done
  if [ -z $hasElementUpdated ] ; then
    idleTime=true
    let currentTime=currentTime+1
    unset hasElementUpdated
  fi
  fileDat=("${fileDat[@]}")
done
  let averageTurnaroundTime=totalTurnAroundTime/PROCESSCOUNT
  let averageWaitingTime=totalWaitingTime/PROCESSCOUNT
  echo
  echo -------------------------------------------------------
  echo
  echo
  echo "Total   Time Elapsed    :"  $currentTime
  echo "Total   Turnaround Time :" $totalTurnAroundTime
  echo "Average Turnaround Time :" $averageTurnaroundTime
  echo "Total   Waiting Time    :" $totalWaitingTime
  echo "Average Waiting Time    :" $averageWaitingTime
  echo
  echo "~~~ END: Round Robin (RRBN) Scheduling ~~~"
  echo





