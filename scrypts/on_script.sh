#!/bin/bash
MINER_PATH="/root/xelis/xelis-blockchain/target/release/xelis_miner"
#MINER_ADDRESS="xet:rc7nactk8xfh5xyatqnh6cea2l33rrxc9k703xj02pek9r4c4e3sqmxlghh"
MINER_ADDRESS="xel:npd2egtvcx4v6lwtshm6ytpglwgn0sd7d9lm6q9x5k92hlzjpvusq0uxwd7"
#DAEMON_ADDRESS="161.97.169.235:8080"
DAEMON_ADDRESS="185.236.234.60:8080"
NUM_THREADS_FILE="/root/xelis/trigger_miner/scrypts/threads_count"

# Retrieve the hostname and append the prefix 'mach_'
HOST_NAME=$(hostname)  # Get the current system hostname
WORKER_NAME="mach_${HOST_NAME:0:19}"  # Combine 'mach_' with the hostname and limit to 24 characters

# Read the number of threads from the file if it exists and is not empty
if [ -f "$NUM_THREADS_FILE" ] && [ -s "$NUM_THREADS_FILE" ]; then
    NUM_THREADS=$(cat "$NUM_THREADS_FILE")
else
    NUM_THREADS=""  # Ensure NUM_THREADS is empty if the file doesn't exist or is empty
fi

# Construct the command using NUM_THREADS if it is not empty
MINER_CMD="$MINER_PATH --miner-address $MINER_ADDRESS --worker $WORKER_NAME $( [ -n "$NUM_THREADS" ] && echo "--num-threads $NUM_THREADS" ) --daemon-address $DAEMON_ADDRESS"
#MINER_CMD="$MINER_PATH --miner-address $MINER_ADDRESS --worker $WORKER_NAME --num-threads 2 --daemon-address $DAEMON_ADDRESS"

# Execute the miner command if the miner is not already running
if ! pgrep -f "xelis_miner" > /dev/null; then
    echo "Running miner command: $MINER_CMD"
    $MINER_CMD &
fi
