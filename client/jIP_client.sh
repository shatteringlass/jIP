## TODO
## 1) Implement serverResponse function

CLIENT_USER_SSH=$1
CLIENT_PASSWORD_SSH=$2 # please pass this argument in base64 format
SERVER_IP=$3
SCP_PORT=$4
SCP_PATH=$5

CLIENT_PATH=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

function requireLease {
  # send lease request with SSH public key as argument
  hostname=$1
  public_key=$2
  ip=$3
  timestamp=$4

  scp_pass=$(echo "$2" | base64 -di)

  filename=request-$public_key-$timestamp.json
  file=$CLIENT_PATH/requests/$filename
  echo -e "[\n{\n\"client\":\n{\n\t\"hostname\":\""$hostname"\",\n \t\"public_key\":\""$public_key"\",\n\t\"ip\":\""$ip"\",\n\t\"request\":\""$timestamp"\"\n}\n}\n]" > $file

  # copy request to server folder using scp, naming the request with a proper timestamp
  $CLIENT_PATH/expect -c "
    set timeout 1
    spawn scp -q -P $SCP_PORT $file $CLIENT_USER_SSH@$SERVER_IP:$SCP_PATH/$filename
    expect yes/no { send yes\r ; exp_continue }
    expect password: {send \$env(scp_pass)\r}
    expect 100%
    sleep 1
    exit
  "
}

function getHostname {
  # returns hostname
  echo $HOSTNAME
}

function getTimestamp() {
  date -u +"%Y%m%d%H%M%S"
}

function getPublicKey_sha256sum {
  # cat ~/.ssh/id_rsa.pub to retrieve SSH public key
  id_rsa=$(cat $HOME/.ssh/id_rsa.pub)
  arr=($(echo $id_rsa))
  key=${arr[1]}
  sha256sum_output=$(echo $key | sha256sum)
  sha256sum=($(echo $sha256sum_output))
  echo ${sha256sum[0]}
}

function getPublicIP {
  # returns public IP
  echo $(curl -s ipinfo.io/ip)
}


function hasRequest {
  # if we have a request*.json file present
  extension=.json
  path=$CLIENT_PATH/requests/request*$extension
  for file in $path; do
    [ -e "$file" ] && echo $file || echo null
    break
  done
}

function checkLease {
file=$(hasRequest)
extension=.json
  if [[ -f $file ]]; then
    howLong=$(isRecent $(getRequestTimestamp $file $extension))
    # the request might have been processed by the server
    if [[ $howLong -eq 1 ]]; then
      # let's try querying the server
      if [[ $(serverResponse) -eq 1 ]]; then
        # all good
        echo 1
      else
        # not yet
        echo -1
      fi
    elif [[ $howLong -eq -1 ]]; then
      # checking too soon, see you in a while
      echo -1
    fi
  else
    # no active requests found, ask for a new request
    echo 0
  fi
}

function getRequestTimestamp {
  filename=$(basename $1 $2)
  arr=($(echo $filename | sed 's/-/ /g'))
  timestamp=${arr[2]}
  echo $timestamp
}

function isRecent {
  CURR_EPOCH=$(date -u +%s)
  TOLERANCE=1800
  request_time=$(string2Epoch $1)
  if [[ $request_time -le $[$CURR_EPOCH-$TOLERANCE] ]]; then
    # adequate amount of time passed, let's ask for a server verification
    echo 1
  else
    # need to wait
    echo -1
  fi
}

function isGNUDate {
  if date --version >/dev/null 2>&1 ; then
    echo 0 # GNU compliant
  else
    echo 1 # BSD compliant
  fi
}

function parseYMD {
  string=$1
  day=${string:0:8}
  time=${string:(-6)}
  time=${time:0:2}:${time:(-4):2}:${time:(-2)}
  echo "$day $time"
}

function string2Epoch {
  string=$(parseYMD $1)
  if [[ isGNUDate -eq 0 ]]; then
    echo $(date -d "$string" +%s -u)
  else
    echo $(date -j -f "%Y%m%d %H:%M:%S" "$string" +%s)
  fi
}

function serverResponse {
  # do something
  # if good
    echo 1
  # else
    # echo 0
}

function archiveOldRequests {
  mv $CLIENT_PATH/requests/*.json $CLIENT_PATH/requests/old
  echo "Successfully moved old requests."
}

function main {
  if [ $(checkLease) -eq 1 ]; then
    echo "Server responded correctly to latest request."
    exit 0
  elif [[ $(checkLease) -eq -1 ]]; then
    # let's try again later
    echo "Please wait to check request result. We'll try again later."
    exit -1
  else
    echo "There seems to be no valid request pending."
    archiveOldRequests
    echo "Proceeding with new request generation..."
    requireLease $(getHostname) $(getPublicKey_sha256sum) $(getPublicIP) $(getTimestamp)
    exit 1
  fi
}

main #> /dev/null 2>&1
