#!/bin/bash

# Get the current hour
current_hour=$(date +%H)
current_hour=${current_hour#0}

# Set the URL and password for CIE login
cie_login_url="https://192.168.254.1:8090/login.xml"
cie_password="pesu@2020"

# Set the URL and password for PES1UG19CS login
pes_login_url="https://192.168.254.1:8090/login.xml"
pes_password="aryan@012"

# Define ANSI color codes
green='\033[0;32m'
yellow='\033[0;33m'
red='\033[0;31m'
cyan='\033[0;36m'
reset='\033[0m' # Reset color

# Function to perform Warp disconnect
warp_disconnect() {
    echo -e "${cyan}Disconnecting from Warp...${reset}"
    warp-cli disconnect >/dev/null
    echo -e "${cyan}Warp is ${red}Disconnected${reset}"
}

# Function to perform Warp connect
warp_connect() {
    echo -e "${cyan}Connecting to Warp...${reset}"
    warp-cli connect >/dev/null
    echo -e "${cyan}Warp is ${green}Connected${reset}"
}

# Function to perform CIE login
cie_login() {
    local username="$1"
    local response=$(curl -k -s -X POST -d "mode=191&username=$username&password=$cie_password&a=1713188925839&producttype=0" -H "Content-Type: application/x-www-form-urlencoded" "$cie_login_url")
    local message=$(echo "$response" | grep -oP '(?<=<message>).*?(?=</message>)')

    if [[ "$message" == "<![CDATA[You are signed in as {username}]]>" ]]; then
        echo -e "${green}Successfully connected to CIE ID: $username${reset}"  # Print the username
        warp_connect
        exit 0
    else
        echo -e "${yellow}Trying username $username${reset}"
    fi
}

# Function to perform PES1UG19CS login
pes_login() {
    local password="$1"

    # Set the URL of the login page
    login_url="https://192.168.254.1:8090/login.xml"

    # Loop through the provided usernames
    for username in "PES1UG19CS037" "PES1UG19CS107" "PES1UG19CS109"; do
        echo -e "${yellow}Trying username $username${reset}"  # Echo "Trying username"
        # Construct the payload
        payload="mode=191&username=$username&password=$password&a=1713188925839&producttype=0"

        # Send the POST request
        response=$(curl -k -s -X POST -d "$payload" -H "Content-Type: application/x-www-form-urlencoded" "$login_url")

        # Extract the relevant information from the response
        message=$(echo "$response" | grep -oP '(?<=<message>).*?(?=</message>)')

        # Check if the message indicates successful login
        if [[ "$message" == "<![CDATA[You are signed in as {username}]]>" ]]; then
            echo -e "${green}Successfully connected to PES1UG19CS ID: $username${reset}"
            warp_connect
            exit 0  # Exit the script
        else
            echo "" 
        fi
    done

    echo -e "${red}Login unsuccessful for all usernames${reset}"
}

# Check if the current hour is between 8:00 A.M. and 8:00 P.M.
if (( current_hour >= 8 && current_hour < 20 )); then
    for username in {7..60}; do
        cie_login "CIE$(printf "%02d" $username)"
    done
else
    # Perform PES1UG19CS login
    pes_login "$pes_password"
fi
