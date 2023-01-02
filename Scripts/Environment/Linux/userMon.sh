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
        echo -e "${red}[$alert_time] ALERT: There have been changes to the user configuration on the system!${reset}" | tee -a alert.log
        echo -e "${yellow}Added users:${reset}" | tee -a alert.log
        awk 'FNR==NR{a[$0];next}!($0 in a)' <(echo "$initial_snapshot") <(echo "$current_users") | grep -v "^#" | tee -a alert.log
        echo -e "${yellow}Deleted users:${reset}" | tee -a alert.log
        awk 'FNR==NR{a[$0];next}!($0 in a)' <(echo "$current_users") <(echo "$initial_snapshot") | grep -v "^#" | tee -a alert.log
        echo "" | tee -a alert.log

        # Play beep sound if enabled
        if [ $beep -eq 1 ]; then
            beep
        fi

        # Print alert message and wait for user to press "Enter" key
        while :; do
            echo -e "${yellow}Press ${reset}${red}Enter${reset}${yellow} to acknowledge and continue${reset}"
            read -r -s -n1 key
            if [ "$key" = $'\0' ]; then
                break
            fi
            echo -e "${red}[$alert_time] ALERT: There have been changes to the user configuration on the system!${reset}"
        done

        # Reset initial snapshot
        initial_snapshot=$current_users
    fi

    # Sleep for specified interval before checking again
    sleep $alert_interval
done
