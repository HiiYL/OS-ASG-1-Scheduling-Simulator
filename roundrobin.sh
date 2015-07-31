. readprocessinput.sh

printFile

IFS=$'\n' 
fileDat=($(for each in ${fileDat[@]}; do
  echo $each
done | sort -n -k4,4nr -k2,2 ))
unset IFS

currentTime=0
  echo
  echo
  echo "~~~ Round Robin (RRBN) Scheduling ~~~"
  echo 
  echo
  echo Grantt Chart
  printf " 0 "
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
    done
  fi
  unset hasElementUpdated
  for process in "${fileDat[@]}"
    do
      processSeparated=($process)
      arrivalTime=${processSeparated[1]}
      if  [ ! $arrivalTime -gt $currentTime ] ; then
        processSeparated[5]=true
        hasElementUpdated=false
        if ! [ -z $idleTime ]; then
          echo -n  "[*IDLE*]" $currentTime' '
          unset idleTime
        fi
        let currentTime=currentTime+$(($quantum>${processSeparated[2]} ?${processSeparated[2]}:$quantum))

        echo -n  [${processSeparated[0]}] $currentTime' '
        if [ -z "${processSeparated[4]}" ]; then
          let processSeparated[4]=${processSeparated[2]}-$quantum 
        else
          let processSeparated[4]=${processSeparated[4]}-$quantum 
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
      let count=count+1
  done
  if [ -z $hasElementUpdated ] ; then
    idleTime=true
    let currentTime=currentTime+1
    unset hasElementUpdated
  fi
  fileDat=("${fileDat[@]}")
done
  let averageTurnaroundTime=totalTurnAroundTime/processCount
  let averageWaitingTime=totalWaitingTime/processCount
  echo
  echo
  echo
  echo "Total   Turnaround Time :" $totalTurnAroundTime
  echo "Average Turnaround Time :" $averageTurnaroundTime
  echo "Total   Waiting Time    :" $totalWaitingTime
  echo "Average Waiting Time    :" $averageWaitingTime
  echo
  echo "~~~ END: Round Robin (RRBN) Scheduling ~~~"
  echo





