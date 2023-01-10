#!/bin/bash
# Script to monitor for user changes and provide logging and alerts
function banner {
    echo -e "${red}  @@@@@@@  @@@@@@   @@@@@@   @@@@@@ @@@@@@@ @@@      @@@ @@@  @@@ @@@@@@@@      @@@@@@@  @@@@@@@ @@@@@@@   @@@@@@@
 !@@      @@!  @@@ @@!  @@@ !@@       @@!   @@!      @@! @@!@!@@@ @@!          !@@      !@@      @@!  @@@ !@@     
 !@!      @!@  !@! @!@!@!@!  !@@!!    @!!   @!!      !!@ @!@@!!@! @!!!:!       !@!      !@!      @!@  !@! !@!     
 :!!      !!:  !!! !!:  !!!     !:!   !!:   !!:      !!: !!:  !!! !!:          :!!      :!!      !!:  !!! :!!     
  :: :: :  : :. :   :   : : ::.: :     :    : ::.: : :   ::    :  : :: :::      :: :: :  :: :: : :: :  :   :: :: :
                                                                                                                  
 @@@  @@@  @@@@@@ @@@@@@@@ @@@@@@@      @@@@@@@@@@   @@@@@@  @@@  @@@                                             
 @@!  @@@ !@@     @@!      @@!  @@@     @@! @@! @@! @@!  @@@ @@!@!@@@                                             
 @!@  !@!  !@@!!  @!!!:!   @!@!!@!      @!! !!@ @!@ @!@  !@! @!@@!!@!                                             
 !!:  !!!     !:! !!:      !!: :!!      !!:     !!: !!:  !!! !!:  !!!                                             
  :.:: :  ::.: :  : :: :::  :   : :      :      :    : :. :  ::    :                                              
                                                                                                                  ${reset}"
}

function monNotifier {
    echo ""
    echo ""
    echo -e "${yellow}Monitoring...${reset}"
    echo ""
    echo ""
}

function beepTune {
    beep -l 350 -f 392 -D 100 -n -l 350 -f 392 -D 100 -n -l 350 -f 392 -D 100 -n -l 250 -f 311.1 -D 100 -n -l 25 -f 466.2 -D 100 -n -l 350 -f 392 -D 100 -n -l 250 -f 311.1 -D 100 -n -l 25 -f 466.2 -D 100 -n -l 700 -f 392 -D 100 -n -l 350 -f 587.32 -D 100 -n -l 350 -f 587.32 -D 100 -n -l 350 -f 587.32 -D 100 -n -l 250 -f 622.26 -D 100 -n -l 25 -f 466.2 -D 100 -n -l 350 -f 369.99 -D 100 -n -l 250 -f 311.1 -D 100 -n -l 25 -f 466.2 -D 100 -n -l 700 -f 392 -D 100 -n -l 350 -f 784 -D 100 -n -l 250 -f 392 -D 100 -n -l 25 -f 392 -D 100 -n -l 350 -f 784 -D 100 -n -l 250 -f 739.98 -D 100 -n -l 25 -f 698.46 -D 100 -n -l 25 -f 659.26 -D 100 -n -l 25 -f 622.26 -D 100 -n -l 50 -f 659.26 -D 400 -n -l 25 -f 415.3 -D 200 -n -l 350 -f 554.36 -D 100 -n -l 250 -f 523.25 -D 100 -n -l 25 -f 493.88 -D 100 -n -l 25 -f 466.16 -D 100 -n -l 25 -f 440 -D 100 -n -l 50 -f 466.16 -D 400 -n -l 25 -f 311.13 -D 200 -n -l 350 -f 369.99 -D 100 -n -l 250 -f 311.13 -D 100 -n -l 25 -f 392 -D 100 -n -l 350 -f 466.16 -D 100 -n -l 250 -f 392 -D 100 -n -l 25 -f 466.16 -D 100 -n -l 700 -f 587.32 -D 100 -n -l 350 -f 784 -D 100 -n -l 250 -f 392 -D 100 -n -l 25 -f 392 -D 100 -n -l 350 -f 784 -D 100 -n -l 250 -f 739.98 -D 100 -n -l 25 -f 698.46 -D 100 -n -l 25 -f 659.26 -D 100 -n -l 25 -f 622.26 -D 100 -n -l 50 -f 659.26 -D 400 -n -l 25 -f 415.3 -D 200 -n -l 350 -f 554.36 -D 100 -n -l 250 -f 523.25 -D 100 -n -l 25 -f 493.88 -D 100 -n -l 25 -f 466.16 -D 100 -n -l 25 -f 440 -D 100 -n -l 50 -f 466.16 -D 400 -n -l 25 -f 311.13 -D 200 -n -l 350 -f 392 -D 100 -n -l 250 -f 311.13 -D 100 -n -l 25 -f 466.16 -D 100 -n -l 300 -f 392.00 -D 150 -n -l 250 -f 311.13 -D 100 -n -l 25 -f 466.16 -D 100 -n -l 700 -f 392
}
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
        banner
        echo -e "Usage: ${yellow}./userMon.sh${reset} [${red}-i${reset} INTERVAL] [${red}-b${reset}] [${red}-h${reset}]"
        echo "Options:"
        echo -e "  ${yellow}-i INTERVAL, --interval INTERVAL${reset}  Set the interval at which the script checks for changes to the user configuration, in seconds. The default is 60 seconds."
        echo -e "${yellow}  -b, --nobeep${reset}                      Disable the beep sound when an alert is triggered."
        echo -e "${yellow}  -h, --help${reset}                        Show this help message and exit."
        exit
        ;;
    *)
        shift
        ;;
    esac
done

# Start main loop
echo -e "${yellow}Starting User Monitoring...${reset}"
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

        # Play beep sound if enabled
        if [ $beep -eq 1 ]; then
            beepTune
        fi

        # Enter an infinite loop waiting for user input
        while :; do
            # Print warning message every 5 seconds
            echo -e "${red}ALERT: There have been changes to the user configuration on the system!${reset}"
            echo -e "${yellow}Press ENTER to acknowledge and continue monitoring${reset}"
            sleep .1

            # Wait for user to press a key
            read -n 1 -s

            # Break out of loop if the "Enter" key is pressed
            if [[ $REPLY =~ ^$ ]]; then
                break
            fi
        done

        # Reset initial snapshot
        initial_snapshot=$current_users
    fi

    # Sleep for specified interval before checking again
    monNotifier
    sleep $alert_interval
done
