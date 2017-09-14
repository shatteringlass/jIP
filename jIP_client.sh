## TODO
## - SPAWN FUNCTION INSIDE requireLease
## - string2Epoch
## - serverResponse
## - general testing, last commit was not tested at all

CLIENT_USER_SSH=$1
CLIENT_PASSWORD_SSH=$2
SERVER_IP=$3
SCP_PORT=$4
SCP_PATH=$5

CLIENT_PATH=$(basename $0)


function requireLease {
  # send lease request with SSH public key as argument
  hostname=$1
  public_key=$2
  ip=$3
  timestamp=$4

  filename=$(echo request-$public_key-$timestamp).json
  echo -e "[\n{\n\"client\":\n{\n\t\"hostname\":\""$hostname"\",\n \t\"public_key\":\""$public_key"\",\n\t\"ip\":\""$ip"\",\n\t\"request\":\""$timestamp"\"\n}\n}\n]" > $filename

  # copy request to server folder using scp, naming the request with a proper timestamp
  # spawn scp -q ./$filename $1@
}

function getHostname {
  # returns hostname
  echo $HOSTNAME
}

function getTimestamp() {
  date -u +"%Y%m%d%H%M%S"
}

function getPublicKey_md5 {
  # cat ~/.ssh/id_rsa.pub to retrieve SSH public key
  id_rsa=$(cat $HOME/.ssh/id_rsa.pub)
  arr=($(echo $id_rsa))
  md5_output=$(md5 -s ${arr[1]})
  md5=($(echo $md5_output))
  echo ${md5[3]}
}

function getPublicIP {
  # returns public IP
  echo $(curl ipinfo.io/ip)
}

function checkLease {
  # if we have a request*.json file present
  cd $CLIENT_PATH

  extension=.json
  filename=request*$extension
  file=$(ls $filename)

  if [ -f $file ]; then
      howLong=$(isRecent $(getRequestTimestamp $file $extension))
      if [ $howLong == 1 ]; then
        if [ serverResponse == 1 ]; then
          return 1
        else
          return 0
        fi
      elif [[ $howLong == -1 ]]; then
        # retry in a little while
        return -1
      fi
  else
    return 0
  fi
}

function getRequestTimestamp {
  filename=$(basename $1 $2)
  arr=($(echo $filename | sed 's/-/ /g'))
  timestamp=${arr[2]}
  return timestamp
}

function isRecent {
  CURREPOCH=$(date +%s)
  PRECISION=1800
  OTHER_TIME = $(string2Epoch $1)
  if [ OTHER_TIME -le ((CURREPOCH - PRECISION)) ]; then
    # adequate amount of time passed, let's ask for a server verification
    return 1
  else
    # need to wait
    return -1
}

function string2Epoch {
  # split YYYYMMDDHHMMSSz and evaluate epoch
  return $(date +%s)
}

function serverResponse {
  # do something
  # if good
    return 1
  # else
    # return 0
}

function main {
  if [ $(checkLease) == 1 ]; then
    echo "Server responded correctly to latest request"
    exit 0
  elif [[ $(checkLease) == -1 ]]; then
    # let's try again later
    exit -1
  else
    requireLease $(getHostname) $(getPublicKey_md5) $(getPublicIP) $(getTimestamp)
    exit 1
  fi
}

main > /dev/null 2>&1
