#!/bin/bash
# Script to monitor for user changes and provide logging and alerts

# Initial snapshot of users
initial_snapshot=$(awk -F: '$7 != "nologin" {print $1}' /etc/passwd)

# Set default alert interval to 60 seconds
alert_interval=60

# Set default alert behavior to beep
beep=1

# Set color variables
red='\033[0;31m'
yellow='\033[1;33m'
reset='\033[0m'

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
    -i | --interval)
        alert_interval="$2"
        shift
        shift
        ;;
    -b | -nobeep | --nobeep)
        beep=0
        shift
        ;;
    -h | --help)
        echo "Usage: user_monitor.sh [-i INTERVAL] [-b] [-h]"
        echo "Options:"
        echo "  -i INTERVAL, --interval INTERVAL  Set the interval at which the script checks for changes to the user configuration, in seconds. The default is 60 seconds."
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
        echo "" | tee -a alert.log
        echo "" | tee -a alert.log
        echo -e "[$alert_time] ALERT: There have been changes to the user configuration on the system!" | tee -a alert.log
        echo -e "Added users:" | tee -a alert.log
        awk 'FNR==NR{a[$0];next}!($0 in a)' <(echo "$initial_snapshot") <(echo "$current_users") | grep -v "^#" | tee -a alert.log
        echo -e "Deleted users:" | tee -a alert.log
        awk 'FNR==NR{a[$0];next}!($0 in a)' <(echo "$current_users") <(echo "$initial_snapshot") | grep -v "^#" | tee -a alert.log
        echo -e "Press Enter to acknowledge and continue" | tee -a alert.log

        # Play beep sound if enabled
        if [ $beep -eq 1 ]; then
            beep
        fi

        # Enter an infinite loop waiting for user input
        while :; do
            # Wait for user to press a key
            read -n 1 -s

            # Break out of loop if the "Enter" key is pressed
            if [[ $REPLY =~ ^$ ]]; then
                break
            fi

            # Print warning message every 5 seconds
            echo -e "${red}ALERT: There have been changes to the user configuration on the system!${reset}"
            cat alert.log
            echo -e "${yellow}Press Enter to acknowledge and continue${reset}"
            sleep 5
        done

        # Reset initial snapshot
        initial_snapshot=$current_users
    fi

    # Sleep for specified interval before checking again
    sleep $alert_interval
done
