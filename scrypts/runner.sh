#!/bin/bash
REPO_DIR="/root/xelis/trigger_miner"
XELIS_DIR="/root/xelis/xelis-blockchain"
TOGGLE_FILE="$REPO_DIR/scrypts/toggle"
XELIS_TOGGLE_FILE="$REPO_DIR/scrypts/update_blockchain"
MINER_NAME="xelis_miner"
SCRIPT_DIR="$REPO_DIR/scrypts"
FIRST_RUN_MARKER="$REPO_DIR/first_run_marker"  # File to check if it's the first run
SLEEP_DURATION=15

# Check and execute on first run
if [[ ! -f "$FIRST_RUN_MARKER" && "$CURRENT_TOGGLE" == "1" ]]; then
    echo "First run detected. Executing on_script.sh"
    $SCRIPT_DIR/on_script.sh &
    touch "$FIRST_RUN_MARKER"
fi

update_repo_and_check_toggle() {
    cd "$REPO_DIR"
    GIT_OUTPUT=$(git pull)

    if [ ! -f "$TOGGLE_FILE" ]; then
        echo "Toggle file not found."
        return
    fi

    CURRENT_TOGGLE=$(cat "$TOGGLE_FILE")

    # Check for changes in the repository or if the toggle is "1"
    if [[ "$GIT_OUTPUT" != *'Already up to date.'* && "$CURRENT_TOGGLE" == "1" ]]; then
        # Kill the miner process if running, regardless of changes, then start it
        pkill -f "$MINER_NAME"
        $SCRIPT_DIR/on_script.sh &
    elif [ "$CURRENT_TOGGLE" == "1" ]; then
        # Start the miner only if it's not running
        if ! pgrep -f "$MINER_NAME" > /dev/null; then
            $SCRIPT_DIR/on_script.sh &
        fi
    elif [ "$CURRENT_TOGGLE" == "0" ]; then
        pkill -f "$MINER_NAME"
    else
        echo "Unexpected content in toggle file: $CURRENT_TOGGLE"
    fi
}

update_xelis_blockchain() {
    cd "$XELIS_DIR"
    XELIS_GIT_OUTPUT=$(git pull)

    if [[ "$XELIS_GIT_OUTPUT" != *'Already up to date.'* ]]; then
        echo "Changes detected in XELIS blockchain repo. Rebuilding..."
        cargo build --release
    else
        echo "No changes detected in XELIS blockchain repo."
    fi
}

while true; do
    update_repo_and_check_toggle

    # Ensure the toggle file exists before trying to read it
    if [ -f "$XELIS_TOGGLE_FILE" ]; then
        XELIS_TOGGLE=$(cat "$XELIS_TOGGLE_FILE")
        if [[ "$XELIS_TOGGLE" == "1" ]]; then
            update_xelis_blockchain
        fi
    else
        echo "XELIS toggle file not found."
    fi

    sleep $SLEEP_DURATION
done
