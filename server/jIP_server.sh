CLIENT_PATH=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

function acquireRequests {
# periodic check: JSONs available inside requests folder?
# if available, send for processing
  local folder=$CLIENT_PATH/requests
  local file=request*.json
  local orderbook=$folder/orderbook.json # orderbook
  local pending=$(ls -1 $folder/$file | wc -l) # let's check how many requests we got
  echo -e '[' > $orderbook
  for i in $(echo $folder/$file); do
    #TODO: maybe check request key against an accepted dictionary? Although scp already checks sender identity
    local json=$(unboxJSON $i)
    echo $json | buildOrderbook "${orderbook}" "${pending}" # parse i-th request and append to orderbook
    pending=$((--pending)) # decrement requests remaining
  done
  echo -e ']' >> $orderbook
  fixJSON $orderbook > "${folder}"/orderbook-fix.json
  mv "${folder}"/orderbook-fix.json "${orderbook}"
}

function fixJSON {
  # Use jq to parse a pending request
  local input=$(cat $1)
  local output=$(echo "$input" | jq .)
  echo $output
}

function unboxJSON {
  # Use jq to parse a pending request
  local input=$(cat $1)
  local output=$(echo "$input" | jq .[])
  echo $output
}

function buildOrderbook {
  # The idea is to add json blocks to an orderbook file (first argument).
  local block=$1
  # To provide proper syntax, a "remaining block" counter (second argument, $pending) is provided.
  local counter=$2
  # While $pending>0, a ",\n" is written after the block
  while read data
  do
    if [[ $counter -gt 1 ]]; then
      echo -e $data, >> $block
  # Write "\n]" then reparse to adjust syntax
    else
      echo -e $data >> $block
    fi
  done
}

function manageOrderbook {
    # Acquire the properly-parsed orderbook (first argument) and produce filtered sub-books
    local orderbook=$1
    local type=$2
    doFiltering $orderbook $type | $(pickAction)
}

function pickAction {
  local type=$1
  if [[ $type -eq "renew" ]]; then
    echo renewLease
  elif [[ $type -eq "start" ]]; then
    echo startLease
  elif [[ $type -eq "prune" ]]; then
    echo endLease
  else $(doNothing)
  fi
}

function doFiltering {
  local orderbook=$1
  local type=$2

  if [[ $type -eq "renew" ]]; then
    # filter new hostnames
  elif [[ $type -eq "start" ]]; then
  # filter preexisting hostnames
  elif [[ $type -eq "prune" ]]; then
  # filter aged hostnames
  fi
}

function startLease {
  # activate "lease" (TBD)
  # add client to current_clients.json
}

function renewLease {
  # update "lease" (TBD)
  # update client in current_clients.json
}

function endLease {
  # revoke "lease" (TBD)
  # remove client in current_clients.json
}

function doNothing {
  # just in case
  continue
}

function removeOldRequests {
  # remove jsons from requests folder (useful?)
}

function main {
  acquireRequests
  if [[ -f $CLIENT_PATH/requests/orderbook.json ]]; then
    local orderbook=$CLIENT_PATH/requests/orderbook.json
    manageOrderbook $orderbook 'renew'
    manageOrderbook $orderbook 'start'
    manageOrderbook $orderbook 'prune'
  fi
  #removeOldRequests
}

main #> /dev/null 2>&1
