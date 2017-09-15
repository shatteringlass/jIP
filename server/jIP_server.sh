CLIENT_PATH=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

function acquireRequests {
# periodic check: JSONs available inside requests folder?
# if available, send for processing
  folder=$CLIENT_PATH/requests
  file=request*.json
  orderbook=$folder/orderbook.json # orderbook
  pending=$(ls -1 $folder/$file | wc -l) # let's check how many requests we got
  echo '[' > $orderbook
  for i in $(echo $folder/$file); do
    #TODO: maybe check request key against an accepted dictionary? Although scp already checks sender identity
    pending=$[$pending-1] # decrement requests remaining
    parseJSON "$i"| buildOrderbook $orderbook $pending # parse i-th request and append to orderbook
  done
  removeOld
}

function parseJSON {
  # Use jq to parse a pending request
  input=$(cat $1)
  output=$(echo "$input" | jq .[])
  echo $output
}

function buildOrderbook {
  # The idea is to add json blocks to an orderbook file (first argument).
  # To provide proper syntax, a "remaining block" counter (second argument, $pending) is provided.
  # While $pending>0, a ",\n" is written after the block
  # Write "\n]" then reparse to adjust syntax
}

function manageOrderbook {
    # Acquire the properly-parsed orderbook (first argument) and produce filtered sub-books
    filterOrderbook $1 'renewals' | renewLease # pipe renewals to own subroutine
    filterOrderbook $1 'starts' | startLease # pipe new leases to own subroutine
    filterOrderbook $1 'old' | endLease # pipe old leases to own subroutine (for dismission)

}

function startLease {

}


function renewLease {

}

function endLease {

}

function removeOld {

}

function main {
  acquireRequests
  manageOrderbook
}

main #> /dev/null 2>&1
