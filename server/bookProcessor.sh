# Process orderbook against the current clients json
# Push orders to either *new* queue or *old* queue

CLIENT_PATH=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

main #> /dev/null 2>&1
