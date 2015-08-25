. readprocessinput.sh

printFile
function addProcessToArray()
{
  for count in "${!fileDat[@]}"; do
    inner_process=${fileDat[$count]}
    inner_processSeparated=($inner_process)
    inner_arrivalTime=${inner_processSeparated[1]}
    if [ ! $inner_arrivalTime -gt $currentTime ] ; then
      ARRIVED_PROCESSES+=("$inner_process")
      unset fileDat[$count]
    fi
  done
}
function checkIdle()
{
  if [ ! ${#ARRIVED_PROCESSES[@]} -gt 1 ]; then
    for index in "${!fileDat[@]}" ; do
      process=${fileDat[$index]}
      processSeparated=($process)
      arrivalTime=${processSeparated[1]}
      if [ $arrivalTime -gt $currentTime ] && [ -z $objectRemoved ] ; then
        let currentTime=arrivalTime
        echo -n [*IDLE*] $currentTime' '
      fi
      unset objectRemoved
      break
    done
  fi
}
ARRIVED_PROCESSES=()
IFS=$'\n' 
fileDat=($(for each in ${fileDat[@]}; do
  echo $each
done | sort -n -k2,2 ))
unset IFS
currentTime=0
while [ ${#fileDat[@]} -gt 0 ] || [ ${#ARRIVED_PROCESSES[@]} -gt 0 ]; do
  addProcessToArray
  for index in "${!ARRIVED_PROCESSES[@]}"; do
    process=${ARRIVED_PROCESSES[$index]}
    processSeparated=($process)
    arrivalTime=${processSeparated[1]}
    processName=${processSeparated[0]}
    if [ ! ${processSeparated[2]} -gt $quantum ] ; then
      let currentTime=currentTime+processSeparated[2]
      unset ARRIVED_PROCESSES[$index]
      echo -n  [${processSeparated[0]}] $currentTime' '
      objectRemoved=true
    else
      let processSeparated[2]=processSeparated[2]-quantum
      let currentTime=currentTime+quantum
      process="${processSeparated[*]}"
      ARRIVED_PROCESSES[$index]=$process
      addProcessToArray
      echo -n  [${processSeparated[0]}] $currentTime' '
      ARRIVED_PROCESSES+=("${ARRIVED_PROCESSES[$index]}")
      unset ARRIVED_PROCESSES[$index]
    fi
    break
  done
  checkIdle
done
echo





