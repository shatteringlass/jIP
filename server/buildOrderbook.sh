CLIENT_PATH=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

function acquireRequests {
    # periodic check: JSONs available inside requests folder?
    # if available, send for processing
    local folder=$CLIENT_PATH/requests
    local file=request*.json
    local orderbook=$folder/orderbook.json # orderbook
    local pending=$(ls -1 $folder/$file | wc -l) # let's check how many requests we got
    echo -e -e '[' > $orderbook
    for i in $(echo -e $folder/$file); do
        #TODO: maybe check request key against an accepted dictionary? Although scp already checks sender identity
        local json=$(unboxJSON $i)
        echo -e $json | buildOrderbook "${orderbook}" "${pending}" # parse i-th request and append to orderbook
        pending=$((--pending)) # decrement requests remaining
    done
    echo -e -e ']' >> $orderbook
    fixJSON $orderbook > "${folder}"/orderbook-fix.json
    mv "${folder}"/orderbook-fix.json "${orderbook}"
}


function fixJSON {
    # Use jq to parse a pending request
    local input=$(cat $1)
    local output=$(echo -e "$input" | jq .)
    echo -e $output
}

function unboxJSON {
    # Use jq to parse a pending request
    local input=$(cat $1)
    local output=$(echo -e "$input" | jq .[])
    echo -e $output
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
            echo -e -e $data, >> $block
            # Write "\n]" then reparse to adjust syntax
        else
            echo -e -e $data >> $block
        fi
    done
}
