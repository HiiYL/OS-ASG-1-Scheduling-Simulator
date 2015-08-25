. readprocessinput.sh

printFile

ARRIVED_PROCESSES=()
IFS=$'\n' 
fileDat=($(for each in ${fileDat[@]}; do
  echo $each
done | sort -n -k2,2 ))
unset IFS
currentTime=0
while [ ${#fileDat[@]} -gt 0 ] || [ ${#ARRIVED_PROCESSES[@]} -gt 0 ]; do
  for index in "${!fileDat[@]}"; do
    process=${fileDat[$index]}
    processSeparated=($process)
    arrivalTime=${processSeparated[1]}
    if [ ! $arrivalTime -gt $currentTime ] ; then
      ARRIVED_PROCESSES+=("$process")
      unset fileDat[$index]
    fi
  done
  for index in "${!ARRIVED_PROCESSES[@]}"; do
    process=${ARRIVED_PROCESSES[$index]}
    processSeparated=($process)
    arrivalTime=${processSeparated[1]}
    processName=${processSeparated[0]}
    if [ ! ${processSeparated[2]} -gt $quantum ] ; then
      let currentTime=currentTime+processSeparated[2]
      unset ARRIVED_PROCESSES[$index]
      echo -n  [${processSeparated[0]}] $currentTime' '
    else
      let processSeparated[2]=processSeparated[2]-quantum
      let currentTime=currentTime+quantum
      # processSeparated[4]=$currentTime
      process="${processSeparated[*]}"
      ARRIVED_PROCESSES[$index]=$process
      ARRIVED_PROCESSES+=("${ARRIVED_PROCESSES[$index]}")
      unset ARRIVED_PROCESSES[$index]
      echo -n  [${processSeparated[0]}] $currentTime' '
    fi
    sleep 0.250
    break
  done
  if [ ! ${#ARRIVED_PROCESSES[@]} -gt 1 ] ; then
    for index in "${!fileDat[@]}" ; do
      process=${fileDat[$index]}
      processSeparated=($process)
      arrivalTime=${processSeparated[1]}
      let currentTime=arrivalTime
      echo -n [*IDLE*] $currentTime' '
      break
    done
  fi
done





