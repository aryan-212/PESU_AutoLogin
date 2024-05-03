
$username=""#Enter your prn/srn"
$pes_password=""#Enter your password






# Function to get the strongest Wi-Fi network from a given list of network SSIDs
function Get-StrongestWiFi {
    param (
        [Parameter(Mandatory)]
        [string[]] $PreferredSSIDs  # List of preferred Wi-Fi SSIDs
    )

    # Get all available Wi-Fi networks
    $availableNetworks = netsh wlan show networks mode=bssid

    # Parse the networks into a more structured form
    $networks = $availableNetworks -match 'SSID \d+ : ' | ForEach-Object {
        $ssid = $_ -replace 'SSID \d+ : ', ''
        $signalLine = $availableNetworks -match "SSID \d+ : $ssid" -replace '\s+', ''
        $signalStrength = ($signalLine -split ':')[1] -as [int]

        [PSCustomObject]@{
            SSID = $ssid
            Signal = $signalStrength
        }
    }

    # Filter the networks by the preferred SSIDs and sort by signal strength (descending)
    $strongestNetwork = $networks | Where-Object { $PreferredSSIDs -contains $_.SSID } | Sort-Object Signal -Descending | Select-Object -First 1

    return $strongestNetwork
}

# List of preferred SSIDs to check
$preferredNetworks = @("GJBC_Library", "GJBC", "PESU-Element Block","PESU-BH")

# Get the strongest Wi-Fi network from the preferred list
$strongestWiFi = Get-StrongestWiFi -PreferredSSIDs $preferredNetworks

# Connect to the strongest Wi-Fi network
if ($strongestWiFi) {
    $networkName = $strongestWiFi.SSID
    Write-Host "Connecting to the strongest Wi-Fi network: $networkName"

    # Connect to the network (assuming the profile already exists)
    netsh wlan connect name="$networkName"
} else {
    Write-Host "No preferred networks found in the available Wi-Fi networks."
    return
}
# Function to perform Warp disconnect
function warp_disconnect {
    Write-Host "Disconnecting from Warp..." 
    warp-cli disconnect > $null
    Write-Host "Warp is Disconnected" 
}

# Function to perform Warp connect
function warp_connect {
    Write-Host "Connecting to Warp..." 
    warp-cli connect > $null
    Write-Host "Warp is Connected" 
}

warp_disconnect > $null
Set-NetAdapterAdvancedProperty -Name "Wi-Fi" -AllProperties -RegistryKeyword "SoftwareRadioOff" -RegistryValue "0"

Start-Sleep -Seconds 1
Netsh wlan connect ssid="$networkName" name="$networkName" 
Start-Sleep -Seconds 1
# Get the current hour
$current_hour = (Get-Date).Hour
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

# Set the URL and password for CIE login
$cie_login_url = "https://192.168.254.1:8090/login.xml"
$cie_password = "pesu@2020"

# Set the URL and password for PES1UG19CS login
$pes_login_url = "https://192.168.254.1:8090"

# Define ANSI color codes
$green = [char]27 + "[0;32m"
$yellow = [char]27 + "[0;33m"
$red = [char]27 + "[0;31m"
$cyan = [char]27 + "[0;36m"
$reset = [char]27 + "[0m" # Reset color


function pes_login {
    
    # $response = Invoke-WebRequest -Uri $pes_login_url -Method POST -Body "mode=191&username=$username&password=$pes_password&a=1713188925839&producttype=0" -ContentType "application/x-www-form-urlencoded" -UseBasicParsing -SkipCertificateCheck
    # $message = [regex]::Match($response.Content, '(?<=<message>).*?(?=</message>)').Value
    #
    # if ($message -eq "<![CDATA[You are signed in as {username}]]>") {
    #     Write-Host "Successfully connected to PES1UG19CS ID: $username" 
    #     warp_connect
    #     exit 0
    # } else {
    #     Write-Host "$message"
    #     Write-Host "Login unsuccessful for username $username"
    # }
    Start-Sleep -Seconds 5

    $login_url = "https://192.168.254.1:8090/login.xml"
    Write-Host "Trying username $username" 
    $payload = "mode=191&username=$username&password=$pes_password&a=1713188925839&producttype=0"
    Start-Sleep -Seconds 1
    $response = Invoke-WebRequest -Uri $login_url -Method POST -Body $payload -ContentType "application/x-www-form-urlencoded" -UseBasicParsing -SkipCertificateCheck
    Start-Sleep -Seconds 1
    $message = [regex]::Match($response.Content, '(?<=<message>).*?(?=</message>)').Value

    if ($message -eq "<![CDATA[You are signed in as {username}]]>") {
        Write-Host "Successfully connected to PES1UG19CS ID: $username" 
        warp_connect
        exit 0
    } else {
        Write-Host "hello $message"
    }
}

function cie_login {
    param(
        [string]$username
    )

    $response = Invoke-WebRequest -Uri $cie_login_url -Method POST -Body "mode=191&username=$username&password=$cie_password&a=1713188925839&producttype=0" -ContentType "application/x-www-form-urlencoded" -UseBasicParsing -SkipCertificateCheck
    $message = [regex]::Match($response.Content, '(?<=<message>).*?(?=</message>)').Value

    if ($message -eq "<![CDATA[You are signed in as {username}]]>") {
        Write-Host "Successfully connected to CIE ID: $username" 
        warp_connect
        exit 0
    } else {
        Write-Host "Trying username $username" 
    }
}




#
# Check if the current hour is between 8:00 A.M. and 8:00 P.M.
if ($current_hour -ge 8 -and $current_hour -lt 20) {
    Start-Sleep -Seconds 5
    for ($username = 7; $username -le 60; $username++) {
        cie_login "CIE$(("{0:D2}" -f $username))"
    }
} else {
    # Perform PES1UG19CS login
    pes_login  
}
