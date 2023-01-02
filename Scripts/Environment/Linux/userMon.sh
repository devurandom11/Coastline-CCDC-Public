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
