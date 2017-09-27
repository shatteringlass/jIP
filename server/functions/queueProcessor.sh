# FIFO queue management
# Items from queue *new* --> doSomething()
# Items from queue *old* --> doSomethingElse()
# If no error raised, setCurrentClients

CLIENT_PATH=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

main #> /dev/null 2>&1
