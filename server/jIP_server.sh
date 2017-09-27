CLIENT_PATH="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"/functions/

CLR="$CLIENT_PATH"/checkLastRun.sh
SLR="$CLIENT_PATH"/setLastRun.sh
BPR="$CLIENT_PATH"/bookProcessor.sh
QPR="$CLIENT_PATH"/queueProcessor.sh
SCC="$CLIENT_PATH"/setCurrentClients.sh
BOB="$CLIENT_PATH"/buildOrderbook.sh
GCC="$CLIENT_PATH"/getCurrentClients.sh
CUP="$CLIENT_PATH"/cleanUp.sh

function main {
  # checkLastRun
  lastRun=$($CLR)
  if [[ $lastRun -ne -1 ]]; then # timestamp expired or not found
    $($BOB) # buildOrderbook
    $($GCC) # getCurrentClients
    $($BPR) # bookProcessor
    $($QPR) # queueProcessor
    $($SCC) # setCurrentClients
    $($CUP) #cleanUp
    $($SLR) # setLastRun
  else # try again later
    # ..
  fi
}

main #> /dev/null 2>&1
