SERVER_IP="0.0.0.0"

function requireLease {
  # send lease request with SSH public key as argument
  hostname=$1
  public_key=$2
  ip=$3

  echo -e "{\n\t\"hostname\":\""$hostname"\",\n \t\"public_key\":\""$public_key"\",\n\t\"ip\":\""$ip"\"\n}" > request.json

  # copy request to server folder using scp
  # scp....
}

function myHostname {
  # return hostname
  echo $HOSTNAME
}

function obtainPublicKey {
  # cat ~/.ssh/id_rsa.pub to retrieve SSH public key
  echo $(cat ~/.ssh/id_rsa.pub)
}

function myPublicIP {
  # return public IP
  echo $(curl ipinfo.io/ip)
}

function main {
  requireLease $(myHostname) $(obtainPublicKey) $(myPublicIP)
}

main > /dev/null 2>&1
