function acquireRequests {
# check .requests folder for incoming JSONs, process one by one
  folder='.requests'
  for $i.json in $folder:
    key = "key"
    validateKey $key
    processRequest $i.json
}

function processRequest {

}

function startLease {

}

function endLease {

}

function renewLease {

}

function main {
  acquireRequests
  renewLease
  endLease
  startLease
}

main > /dev/null 2>&1
