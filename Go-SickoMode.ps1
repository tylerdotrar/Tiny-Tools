function Go-SickoMode {
#.SYNOPSIS
# Remote into workstations utilizing NoMachine or RDP.
# ARBITRARY VERSION NUMBER:  2.0.0
# AUTHOR:  Tyler McCann (@tylerdotrar)
#
#.DESCRIPTION
# Quickly and easily remote into configured workstations using either a NoMachine
# connection file (.nxs) or via RDP.  This script is written with the assumption 
# that '.nxs' files will be named using the target's hostname or IP address
# (e.g., "workstation22.nxs", "kali.coolguys.org.nxs", "10.10.10.69.nxs").
#
# Notes:
# [+] Modify the $Primary and $Secondary variables to desired default workstations.
# [+] This script will use NoMachine by default unless the '-RDP' switch is used.
# [+] Default NoMachine connection file directory: $env:USERPROFILE\Documents\NoMachine
#
# Parameters:
#    -Alternate    -->    Remote into the secondary remote system (default: false)
#    -Target       -->    Specified hostname/IP address (or '.nxs' file) to connect to.
#    -RDP          -->    Use RDP instead of NoMachine (default: false)
#    -Port         -->    RDP port being used (default: 3389)
#    -NxsFolder    -->    NoMachine connection file directory (default: Documents/NoMachine)
#    -Help         -->    Return Get-Help Information.
#
#.LINK
# https://github.com/tylerdotrar/Tiny-Tools


    Param(
        [switch]$Alternate,
        [string]$Target,
        [switch]$RDP,
        [int]   $Port      = 3389,
        [string]$NxsFolder = "$env:USERPROFILE/Documents/NoMachine",
        [switch]$Help
    )


    # Default and Alternate Remote Workstations
    $Primary   = '<hostname_or_ip>'
    $Secondary = '<hostname_or_ip>'
	
	
	# Return Get-Help Information
	if ($Help) { return Get-Help Go-SickoMode }    
    
    
    # Allow for two hardcoded targets for defaults if a target is not specified
    if (!$Target) {
        
        # Error Correction
        if (($Primary -eq '<hostname_or_ip>') -and ($Secondary -eq '<hostname_or_ip>')) {
            return (Write-Host '[-] Error. Default workstation(s) not configured.' -ForegroundColor Yellow)
        }

        # Set target to primary or secondary workstation
        if (!$Alternate) { $Target = $Primary   }
        else             { $Target = $Secondary }
    }


    # Attempt hostname / DNS resolution
    $IP = (Resolve-DnsName -Name $Target 2>$NULL).IPAddress
    if ($IP -ne $NULL) { $IpAddr = " ($IP)" }


    # Remote via RDP
    if ($RDP) {
        
        <#
        ENABLE RDP ON LINUX:
          sudo apt install xrdp -y
          sudo systemctl enable xrdp --now
        #>

        Write-Host '[+] Remoting method: ' -NoNewline -ForegroundColor Yellow
        Write-Host 'RDP'


        # Validate Connectivity
        $TestConnection = (Test-NetConnection -ComputerName $Target -Port $Port 2>$NULL 3>$NULL).TcpTestSucceeded
        if (!($TestConnection -eq $TRUE)) {
            Write-Host '[-] Unable to reach target: ' -NoNewline -ForegroundColor Yellow
            Write-Host "'${Target}:$Port'"
            return
        }

        # Connect via RDP
        Write-Host '[+] Connecting to: ' -NoNewline -ForegroundColor Yellow
        Write-Host "'$Target'$IpAddr"

        mstsc /v:${Target}:$Port
    }


    # Remote via NoMachine
    else {
        
        Write-Host '[+] Remoting method: ' -NoNewline -ForegroundColor Yellow
        Write-Host 'NoMachine'

        $NoMachinePlayer = "$env:ProgramFiles/NoMachine/bin/nxplayer.exe"
        $ConnectionPath  = "$NxsFolder/${Target}.nxs"
        $ConnectionFile  = $ConnectionPath.Replace('\','/')


        # Error Correction
        if (!(Test-Path -LiteralPath $ConnectionFile)) {
            Write-Host '[-] Unable to reach find: ' -NoNewline -ForegroundColor Yellow
            Write-Host "'$ConnectionFile'"
            return
        }
        if (!(Test-Path -LiteralPath $NoMachinePlayer)) {
            Write-Host '[-] Unable to reach find: ' -NoNewline -ForegroundColor Yellow
            Write-Host "'$NoMachinePlayer'"
            return
        }


        # Execute NoMachine Player
        Write-Host '[+] Connecting to: ' -NoNewline -ForegroundColor Yellow
        Write-Host "'$Target'$IpAddr"

        . $NoMachinePlayer $ConnectionFile
    }
}