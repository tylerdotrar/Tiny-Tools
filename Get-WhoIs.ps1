function Get-WhoIs {
#.SYNOPSIS
# Rudimentary WhoIs script.
# ARBITRARY VERSION NUMBER:  1.2.5
# AUTHOR:  Tyler McCann (@tylerdotrar)
#
#.DESCRIPTION
# Script that reaches out to "http://whois.arin.net/rest/ip/..." and 
# returns WhoIs information on input IP addresses.
#
# Parameters:
#    -IPAddress   -->    IP address to lookup
#    -Help        -->    Return Get-Help information
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
#
#.LINK
# https://github.com/tylerdotrar/Tiny-Tools

    Param (
        [IPAddress] $IPAddress,
        [switch]    $Help
    )


    # Return Get-Help Information
    if ($Help) { return Get-Help Get-WhoIs }


    # Error Correction
    if (!$IPAddress) { return (Write-Host 'Input IP address.' -ForegroundColor Red) }


    # Whois Lookup
    Try {
        $Header = @{"Accept" = "application/xml"}
        $URL = "http://whois.arin.net/rest/ip/$IPAddress"

        $Response = Invoke-Restmethod $URL -Headers $Header -ErrorAction Stop
    }


    # Error Catching
    Catch {
        $ErrorMsg = "An error occurred when retrieving WhoIs information for $IPAddress."
        return (Write-Host $ErrorMsg -ForegroundColor Red)
    }


    # Format Output
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