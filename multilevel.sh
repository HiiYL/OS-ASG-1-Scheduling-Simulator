. readprocessinput.sh
function addArrivedProcessToArray()
{
  highest_priority_added=3
  for count in "${!fileDat[@]}"; do
    inner_process=${fileDat[$count]}
    inner_processSeparated=($inner_process)
    inner_arrivalTime=${inner_processSeparated[1]}
    inner_priority=${inner_processSeparated[3]}
    inner_processSeparated[4]=${inner_processSeparated[2]} #Backup burst to slot 4
    inner_process="${inner_processSeparated[*]}"
    if [ ! $inner_arrivalTime -gt $currentTime ] ; then
      if [ $inner_priority -lt 3 ] ; then
        Queue1+=("$inner_process")
        highest_priority_added=1
      elif [ $inner_priority -lt 5 ] ; then
        Queue2+=("$inner_process")
        if [ $highest_priority_added -gt 1 ] ; then
          highest_priority_added=2
        fi
      else
        Queue3+=("$inner_process")
      fi
      unset fileDat[$count]
    fi
  done
  return $highest_priority_added
}

Queue1=()
Queue2=()
Queue3=()
currentTime=0
IFS=$'\n' ##sort processes according to arrival time
fileDat=($(for each in ${fileDat[@]}; do
  echo $each
done | sort -n -k4,4 -k2,2 ))
unset IFS
printFile
  # echo FileDat
  # for process in "${fileDat[@]}" ; do
  #   echo $process
  # done
addArrivedProcessToArray

while [ ${#fileDat[@]} -gt 0 ] || [ ${#Queue1[@]} -gt 0 ] || [ ${#Queue2[@]} -gt 0 ] || [ ${#Queue3[@]} -gt 0 ]; do
  addArrivedProcessToArray
  # echo FileDat
  # for process in "${fileDat[@]}" ; do
  #   echo $process
  # done
  # echo Queue1
  # for process in "${Queue1[@]}" ; do
  #   echo $process
  # done
  # echo Queue2
  # for process in "${Queue2[@]}" ; do
  #   echo $process
  # done
  # echo Queue3
  # for process in "${Queue3[@]}" ; do
  #   echo $process
  # done
  # echo ${#fileDat[@]} and ${#Queue1[@]} and ${#Queue2[@]} and ${#Queue3[@]}
  if [ ${#Queue1[@]} -gt 0 ] ; then
    for index in "${!Queue1[@]}"; do
      process=${Queue1[$index]}
      processSeparated=($process)
      processName=${processSeparated[0]}
      arrivalTime=${processSeparated[1]}
      burstTime=${processSeparated[2]}
      backupBurstTime=${processSeparated[4]}
      if [ ! $burstTime -gt $quantum ] ; then
        let currentTime=currentTime+burstTime
        let totalWaitingTime=totalWaitingTime+currentTime-arrivalTime-backupBurstTime
        let totalTurnAroundTime=totalTurnAroundTime+currentTime-arrivalTime
        echo -n  [$processName] $currentTime' '
      else
        let processSeparated[2]=processSeparated[2]-quantum
        let currentTime=currentTime+quantum
        process="${processSeparated[*]}"
        Queue1[$index]=$process
        addArrivedProcessToArray
        echo -n  [$processName] $currentTime' '
        Queue1+=("${Queue1[$index]}")
      fi
      unset Queue1[$index]
      sleep 0.250
      break
    done
  elif [ ${#Queue2[@]} -gt 0 ] ; then
    while [ ${#Queue2[@]} -gt 0 ] ; do
      # echo
      # echo
      # echo Queue2
      # for process in "${Queue2[@]}" ; do
      #   echo $process
      # done
      # echo
      # echo
      for index in "${!Queue2[@]}"; do
        process=${Queue2[$index]}
        processSeparated=($process)
        processName=${processSeparated[0]}
        arrivalTime=${processSeparated[1]}
        burstTime=${processSeparated[2]}
        backupBurstTime=${processSeparated[4]}
        if [ $burstTime -gt 1 ] ; then
          let processSeparated[2]=processSeparated[2]-1
          let currentTime=currentTime+1
          process="${processSeparated[*]}"
          Queue2[$index]=$process
        else
          let processSeparated[2]=processSeparated[2]-1
          let currentTime=currentTime+1
          process="${processSeparated[*]}"
          let totalWaitingTime=totalWaitingTime+currentTime-arrivalTime-backupBurstTime
          let totalTurnAroundTime=totalTurnAroundTime+currentTime-arrivalTime
          echo -n  [$processName] $currentTime' '
          unset Queue2[$index]
        fi
        break
      done
      addArrivedProcessToArray
      i=$?
      if [ $i -lt 2 ] ; then
        break
      fi
    done
  else
    while [ ${#Queue3[@]} -gt 0 ] ; do
      # echo Queue3
      # for process in "${Queue3[@]}" ; do
      #   echo $process
      # done
      for index in "${!Queue3[@]}"; do
        process=${Queue3[$index]}
        processSeparated=($process)
        processName=${processSeparated[0]}
        arrivalTime=${processSeparated[1]}
        burstTime=${processSeparated[2]}
        backupBurstTime=${processSeparated[4]}
        if [ $burstTime -gt 1 ] ; then
          let processSeparated[2]=processSeparated[2]-1
          let currentTime=currentTime+1
          process="${processSeparated[*]}"
          Queue3[$index]=$process
        else
          let processSeparated[2]=processSeparated[2]-1
          let currentTime=currentTime+1
          process="${processSeparated[*]}"
          let totalWaitingTime=totalWaitingTime+currentTime-arrivalTime-backupBurstTime
          let totalTurnAroundTime=totalTurnAroundTime+currentTime-arrivalTime
          echo -n  [$processName] $currentTime' '
          unset Queue3[$index]
        fi
        break
      done
      addArrivedProcessToArray
      i=$?
      if [ $i -lt 3 ] ; then
        break
      fi
    done
  fi
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