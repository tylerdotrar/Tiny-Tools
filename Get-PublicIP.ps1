function Get-PublicIP {
#.SYNOPSIS
# Returns the host's public IP address.
# ARBITRARY VERSION NUMBER:  1.2.0
# AUTHOR:  Tyler McCann (@tylerdotrar)
#
#.DESCRIPTION
# Super simple script that reaches out to "http://ifconfig.me/ip" and returns the
# system's public IP address.
#
#.LINK
# https://github.com/tylerdotrar/Tiny-Tools

    Param ( [switch]$Help )

    # Return help information
    if ($Help) { return Get-Help Get-PublicIP }

    Write-Host "Public IP Address:" -ForegroundColor Yellow
    $PublicIP = (New-Object System.Net.WebClient).DownloadString("http://ifconfig.me/ip")
    
    return $PublicIP
}