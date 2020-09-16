function Get-WhoIs {
#.SYNOPSIS
# Rudimentary WhoIs script.
# ARBITRARY VERSION NUMBER:  1.1.1
# AUTHOR:  Tyler McCann (@tyler.rar)
#
#.DESCRIPTION
# Script that reaches out to "http://whois.arin.net/rest/ip/..." and returns WhoIs
# infomration on input IP addresses.
#
# Recommendations:
# -- Use 'TinyTools.psm1' (and included instructions) from the repo to load this script from your $PROFILE.
#
# Parameters:
#    -IPAddress     -->    IP address to lookup
#    -Help          -->    (Optional) Return Get-Help information
#
# Example Usage:
#    []  PS C:\Users\Bobby> Get-WhoIs 8.8.8.8
#    
#        IP                     : 8.8.8.8
#        Name                   : LVLT-GOGL-8-8-8
#        RegisteredOrganization : Google LLC
#        City                   : Mountain View
#        StartAddress           : 8.8.8.0
#        EndAddress             : 8.8.8.255
#        NetBlocks              : 8.8.8.0/24
#        Updated                : 3/14/2014 4:52:05 PM
#
#    [] PS C:\Users\Bobby>
#
#.LINK
# https://github.com/tylerdotrar/Tiny-Tools

    Param (
        [IPAddress] $IPAddress,
        [switch]    $Help
    )

    # Return help information
    if ($Help) { return Get-Help Get-WhoIs }


    Try {
        $Header = @{"Accept" = "application/xml"}
        $URL = "http://whois.arin.net/rest/ip/$IPAddress"

        $Response = Invoke-Restmethod $URL -Headers $Header -ErrorAction Stop
    }

    Catch {
        $ErrorMsg = "An error occurred when retrieving WhoIs information for $IPAddress."
        Write-Host $ErrorMsg -ForegroundColor Red
    }


    if ($Response.net) {
        [pscustomobject]@{
            IP                      = $IPAddress
            Name                    = $Response.net.Name
            RegisteredOrganization  = $Response.net.orgRef.Name
            City                    = if ($Response.Net.OrgRef) { (Invoke-RestMethod $Response.net.orgRef.'#text').org.city } else { $NULL }
            StartAddress            = $Response.net.StartAddress
            EndAddress              = $Response.net.EndAddress
            NetBlocks               = $Response.net.NetBlocks.NetBlock | % {"$($_.startaddress)/$($_.cidrLength)"}
            Updated                 = $Response.net.UpdateDate -as [datetime]
        }
    }
}