# setLastRun

CLIENT_PATH=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

function main {
    $(date +%s -u) > "$CLIENT_PATH"/timestampLastRun 
}

main #> /dev/null 2>&1
