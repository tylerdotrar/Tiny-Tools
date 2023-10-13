function Invoke-IntranetZone {
#.SYNOPSIS
# Manage hosts in the Local Intranet Zone via CLI
# ARBITRARY VERSION NUMBER:  1.0.0
# AUTHOR:  Tyler McCann (@tylerdotrar)
#
#.DESCRIPTION
# List, add, and remove hosts to and from your system's Local intranet zone.  This
# allows for seemless communication and trust with these hosts -- useful for SMB
# shares (type: file), web downloads (type: http/https), etc.  This was initially
# created because navigating to "Internet Properties" in the Control Panel felt
# incredibly unintuitive and sloppy.
#
# Parameters:
#   -Hostname  -->  Specified hostname or IP address
#   -Type      -->  Specified host type (e.g., file, ftp, http, https, ldap)
#   -Add       -->  Add specified host and type to the local intranet zone
#   -Remove    -->  Remove specified host from the local intranet zone (all types)
#   -List      -->  Return a list of the current hosts added to the intranet zone
#   -Help      -->  Return Get-Help information
#
#.LINK
# https://github.com/tylerdotrar/Tiny-Tools


    Param (
        [string]$Hostname,
        [string]$Type,
        [switch]$Add,
        [switch]$Remove,
        [switch]$List,
        [switch]$Help
    )


    # Return Get-Help Information
    if ($Help) { return (Get-Help Invoke-IntranetZone) }


    # General Error Correction
    $AllowedTypes = @('file','ftp','http','https','ldap')
    if ($Type -and ($AllowedTypes -notcontains $Type)) { return (Write-Host '[-] Specified type is invalid; must be either file, ftp, http, https, or ldap.' -ForegroundColor Yellow) }
    elseif (!$Type -and $Add)                          { return (Write-Host '[-] Must specify host type. (e.g., file, ftp, http, https, ldap)' -ForegroundColor Yellow) }
    elseif (!$Add -and !$Remove -and !$List)           { return (Write-Host '[-] Failed to specify desired action. (e.g., add, remove, list)' -ForegroundColor Yellow) }


    # Establish Registry Keys
    $DomainZoneMap = 'Registry::HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains'
    $TargetRegKey  = "$DomainZoneMap\$Hostname"


    # List Current Hosts added to Intranet Zone
    if ($List) {
        
        $CurrentHosts = Get-ChildItem $DomainZoneMap | ? { $_.Property }

        Write-Host "[+] HKCU Local Intranet Zone Entries:" -ForegroundColor Yellow
        foreach ($SMBHost in $CurrentHosts) {
            
            $Hostname = ($SMBHost.Name).Split('\')[-1]
            foreach ($Property in $SMBHost.Property) {
                Write-Host " o  " -NoNewline -ForegroundColor Yellow
                Write-Host "${Property}://*${Hostname}"
            }
        }
        return
    }


    # Add Specified Host to Intranet Zone (requires $Type)
    if ($Add) {

        Write-Host '[+] Adding to HKCU Local Intranet Zone:' -ForegroundColor Yellow
        $Ltype = $Type.ToLower()
        Write-Host " o  Host: " -NoNewline -ForegroundColor Yellow
        Write-Host "${Ltype}://*${Hostname}"
       
        if (!(Test-Path $TargetRegKey)) { New-Item $TargetRegKey | Out-Null }
        Set-ItemProperty -Path $TargetRegKey -Name $Ltype -Value 1
        return
    }


    # Remove Specified Host from Intranet Zone
    if ($Remove) {
        
        if (!(Test-Path $TargetRegKey)) { return (Write-Host '[-] Target host does not exist.' -ForegroundColor Yellow) }

        Write-Host '[+] Removing from HKCU Local Intranet Zone:' -ForegroundColor Yellow
        Remove-Item -Path $TargetRegKey -Force | Out-Null
        
        Write-Host " o  Host: " -NoNewline -ForegroundColor Yellow
        Write-Host "*://*${Hostname}"
        return
    }
}