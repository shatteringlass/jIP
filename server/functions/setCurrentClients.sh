# Update current clients with info from stacks
# Remember to dismiss exipred clients

CLIENT_PATH=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

main #> /dev/null 2>&1
