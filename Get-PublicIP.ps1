function Get-PublicIP {
#.SYNOPSIS
# Returns the host's public IP address.
# ARBITRARY VERSION NUMBER:  1.1.1
# AUTHOR:  Tyler McCann (@tyler.rar)
#
#.DESCRIPTION
# Super simple script that reaches out to "http://ifconfig.me/ip" and returns the system's public IP address.
#
# Recommendations:
# -- Use 'TinyTools.psm1' (and included instructions) from the repo to load this script from your $PROFILE.
#
# Parameters:
#    -Help          -->    (Optional) Return Get-Help information
#
# Example Usage:
#    []  PS C:\Users\Bobby> Get-PublicIP
#        Host Public IP:  185.26.131.17
#
#    []  PS C:\Users\Bobby>
#
#.LINK
# https://github.com/tylerdotrar/Tiny-Tools

    Param ( [switch]$Help )

    # Return help information
    if ($Help) { return Get-Help Get-PublicIP }


    $PubIP = (Invoke-WebRequest "http://ifconfig.me/ip").content
    Write-Host "Host Public IP:  " -ForegroundColor Yellow -NoNewline
    
    return $PubIP
}