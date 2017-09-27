# checkLastRun

CLIENT_PATH=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
THR=300

function getTimestamp {
    timestamp="$CLIENT_PATH"/timestampLastRun
    if [[ -e  timestamp ]]; then
      echo "$(cat "$timestamp")"
    else
      echo 1 # timestamp not found
}

function main {
    date=$(date +%s -u)
    delta=$(($date-$(getTimestamp)))
    if [[ $delta -le $THR ]]; then
      echo -1 # try again later
    else
      echo 0 # more than $THR seconds have passed, echo 0
    fi
}

main #> /dev/null 2>&1
