function Get-PublicIP {
#.SYNOPSIS
# Returns the host's public IP address.
# ARBITRARY VERSION NUMBER:  1.2.5
# AUTHOR:  Tyler McCann (@tylerdotrar)
#
#.DESCRIPTION
# Super simple script that reaches out to "http://ifconfig.me/ip" and returns the
# system's public IP address.
#
# Parameters:
#   -Raw     -->   Return only the IP address.
#   -Help    -->   Return Get-Help information.
#
#.LINK
# https://github.com/tylerdotrar/Tiny-Tools

    Param (
        [switch]$Raw,
        [switch]$Help
    )

    # Return help information
    if ($Help) { return Get-Help Get-PublicIP }

    # Main
    $PublicIP = (New-Object System.Net.WebClient).DownloadString("http://ifconfig.me/ip")

    if (!$Raw) {
        Write-Host "[+] Public IP Address:`n o  " -NoNewline -ForegroundColor Yellow
    }
    
    return $PublicIP
}