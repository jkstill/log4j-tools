#!/usr/bin/env bash

: << 'SETUP'

 python3 -m venv log4j-env
 source log4j-env/bin/activate
 pip install -r requirements.txt

SETUP

source log4j-env/bin/activate

[[ $? -eq 0 ]] || {
  echo
  echo Did you set up the python environment?
  echo
  exit 1
}

declare logDir=logs

mkdir -p $logDir

declare -A scanDirs=(
  [orachk]='/u01/app/orachk/19.2'
  [grid]='/u01/app/19.0.0/grid2'
  [ohome]='/u01/app/oracle/product/19.0.0/dbhome_2'
)

declare -A scripts=(
  [log4jJarScan]='scan_log4j_calls_jar.py'
  [log4jSrcScan]='scan_log4j_calls_src.py'
  [log4jVersionScan]='scan_log4j_versions.py'
)

declare timestamp=$(date '+%Y-%m-%d_%H-%M-%S')

for dirKey in ${!scanDirs[@]}
do
  echo checking $dirKey: ${scanDirs[$dirKey]}

  for scriptKey in ${!scripts[@]}
  do
	 echo "	running: $scriptKey ${scripts[$scriptKey]}"
	 scanLog=$logDir/$dirKey-$scriptKey-${timestamp}.log
	 scanErrLog=$logDir/$dirKey-$scriptKey-err-${timestamp}.log

	 python ${scripts[$scriptKey]} ${scanDirs[$dirKey]} > $scanLog 2>$scanErrLog

  done

done

