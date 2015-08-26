. readprocessinput.sh
printFile
function addProcessToArray()
{
  for count in "${!fileDat[@]}"; do
    inner_process=${fileDat[$count]}
    inner_processSeparated=($inner_process)
    inner_arrivalTime=${inner_processSeparated[1]}
    inner_processSeparated[4]=${inner_processSeparated[2]} #Backup burst to slot 4
    inner_process="${inner_processSeparated[*]}"
    if [ ! $inner_arrivalTime -gt $currentTime ] ; then
      ARRIVED_PROCESSES+=("$inner_process")
      unset fileDat[$count]
    fi
  done
}
function checkIdle()
{
  if [ ! ${#ARRIVED_PROCESSES[@]} -gt 0 ]; then
    for index in "${!fileDat[@]}" ; do
      process=${fileDat[$index]}
      processSeparated=($process)
      arrivalTime=${processSeparated[1]}
      if [ $arrivalTime -gt $currentTime ] ; then
        let currentTime=arrivalTime
        echo -n [*IDLE*] $currentTime' '
        addProcessToArray
      fi
      break
    done
  fi
}
totalTurnAroundTime=0
totalWaitingTime=0
ARRIVED_PROCESSES=()
currentTime=0
while [ ${#fileDat[@]} -gt 0 ] || [ ${#ARRIVED_PROCESSES[@]} -gt 0 ]; do
  addProcessToArray
  checkIdle
  for index in "${!ARRIVED_PROCESSES[@]}"; do
    process=${ARRIVED_PROCESSES[$index]}
    processSeparated=($process)
    arrivalTime=${processSeparated[1]}
    processName=${processSeparated[0]}
    if [ ! ${processSeparated[2]} -gt $quantum ] ; then
      let currentTime=currentTime+processSeparated[2]
      let totalWaitingTime=totalWaitingTime+currentTime-processSeparated[4]
      let totalTurnAroundTime=totalTurnAroundTime+currentTime-processSeparated[1]
      echo -n  [${processSeparated[0]}] $currentTime' '
    else
      let processSeparated[2]=processSeparated[2]-quantum
      let currentTime=currentTime+quantum
      process="${processSeparated[*]}"
      ARRIVED_PROCESSES[$index]=$process
      addProcessToArray
      echo -n  [${processSeparated[0]}] $currentTime' '
      ARRIVED_PROCESSES+=("${ARRIVED_PROCESSES[$index]}")
    fi
    unset ARRIVED_PROCESSES[$index]
    break
  done
done
echo
echo
echo "Total   Turnaround Time : "$totalTurnAroundTime
echo "Total   Waiting Time    :" $totalWaitingTime
echo -n "Average Turnaround Time : "; bc <<< 'scale=2;'$totalTurnAroundTime'/'$processCount
echo -n "Average Waiting Time    : "; bc <<< 'scale=2;'$totalWaitingTime'/'$processCount
echo
echo "~~~ END: Round Robin (RRBN) Scheduling ~~~"
echo




