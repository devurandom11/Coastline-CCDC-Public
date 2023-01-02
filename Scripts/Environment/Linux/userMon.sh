#!/bin/bash
# Script to monitor for user changes and provide logging and alerts

# Initial snapshot of users
initial_snapshot=$(awk -F: '$7 != "nologin" {print $1}' /etc/passwd)

# Set default alert interval to 60 seconds
alert_interval=60

# Set default alert behavior to flash and beep
flash=1
beep=1

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
    -i | --interval)
        alert_interval="$2"
        shift
        shift
        ;;
    -f | -noflash | --noflash)
        flash=0
        shift
        ;;
    -b | -nobeep | --nobeep)
        beep=0
        shift
        ;;
    -h | --help)
        echo "Usage: user_monitor.sh [-i INTERVAL] [-f] [-b] [-h]"
        echo "Options:"
        echo "  -i INTERVAL, --interval INTERVAL  Set the interval at which the script checks for changes to the user configuration, in seconds. The default is 60 seconds."
        echo "  -f, --noflash                     Disable the terminal flashing behavior when an alert is triggered."
        echo "  -b, --nobeep                      Disable the beep sound when an alert is triggered."
        echo "  -h, --help                        Show this help message and exit."
        exit
        ;;
    *)
        shift
        ;;
    esac
done

# Start main loop
while :; do
    # Get a list of current users with shell access
    current_users=$(awk -F: '$7 != "nologin" {print $1}' /etc/passwd)

    # Check if the current list of users is different from the initial snapshot
    if [ "$current_users" != "$initial_snapshot" ]; then
        # Output alert to terminal and log file
        alert_time=$(date "+%Y-%m-%d %H:%M:%S")
        echo "\n\n[$alert_time] ALERT: There have been changes to the user configuration on the system!" | tee -a alert.log
        diff -u --color <(echo "$initial_snapshot") <(echo "$current_users") | tee -a alert.log

        # Flash rainbow colors if enabled
        if [ $flash -eq 1 ]; then
            while read -t 0; do
                for i in {1..30}; do
                    tput setab $(((i % 7) + 1))
                    sleep .25
                done
                tput sgr0
            done
        fi

        # Play beep sound if enabled
        if [ $beep -eq 1 ]; then
            beep
        fi

        # Wait for user to press a key
        read -n 1 -s

        # Reset initial snapshot
        initial_snapshot=$current_users
    fi

    # Sleep for specified interval before checking again
    sleep $alert_interval
done
