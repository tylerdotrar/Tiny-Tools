function VPN-Tunnel  {
#.SYNOPSIS
# Easily toggle WireGuard VPN tunnels.
# ARBITRARY VERSION NUMBER:  1.1.5
# AUTHOR:  Tyler McCann (@tylerdotrar)
#
#.DESCRIPTION
# Quickly and easily toggle WireGuard VPN tunnels via configuration file names. This
# script will append the '.conf.dpapi' file extension to the tunnel configuration
# specified with the '-Tunnel' parameter.
#
# (e.g., "-Tunnel 'RemoteHome'" correlates to "RemoteHome.conf.dpapi")
#
# Parameters:
#    -Enable        -->    Activate WireGuard interface
#    -Disable       -->    Deactivate WireGuard interface
#    -Restart       -->    Refresh Wireguard interface
#    -Tunnel        -->    Specify tunnel to use ('.conf.dpapi')
#    -Status        -->    Check current status of tunnel
#    -Help          -->    Return Get-Help Information
#
#.LINK
# https://github.com/tylerdotrar/Tiny-Tools

    Param(
        [string]$Tunnel = '<tunnel_name_here>',
        [switch]$Enable,
        [switch]$Disable,
		[switch]$Restart,
        [switch]$Status,
		[switch]$Help
    )
	
	
	# Return Get-Help Information
	if ($Help) { return Get-Help VPN-Tunnel }
	
    
    # Error Correction
    if ($Tunnel -eq '<tunnel_name_here>') { return (Write-Host '[-] No tunnel configuration specified.' -ForegroundColor Yellow) }
    if (!$Enable -and !$Disable -and !$Restart -and !$Status) { return (Write-Host '[-] No parameter specified.' -ForegroundColor Yellow) }

    # Get tunnel config path & determine if a tunnel aready exists
	$TunnelConf = "$env:ProgramFiles\Wireguard\Data\Configurations\$Tunnel" + ".conf.dpapi"
    if (Get-Service -Name "WireGuard*$Tunnel*") { $TunnelStatus = $TRUE }
    else { $TunnelStatus = $FALSE }


    # Enable VPN tunnel if it does not already exist
	if ($Enable) {
        
        Write-Host '[+] Enabling VPN tunnel...' -ForegroundColor Yellow

        if ($TunnelStatus) {
            Write-Host ' -  ' -NoNewline -ForegroundColor Red
            return (Write-Host 'Tunnel already established.')
        }

        wireguard /installtunnelservice $TunnelConf
        Write-Host ' o  ' -NoNewline -ForegroundColor Yellow
		return (Write-Host 'Tunnel established.')
	}
    

    # Disable VPN tunnel if it exists
	elseif ($Disable) {
        
        Write-Host '[+] Disabling VPN tunnel...' -ForegroundColor Yellow

        if ($TunnelStatus) {
            wireguard /uninstalltunnelservice $Tunnel
            Write-Host ' o  ' -NoNewline -ForegroundColor Yellow
		    return (Write-Host 'Tunnel deactivated.')
        }
        Write-Host ' -  ' -NoNewline -ForegroundColor Red
        return (Write-Host 'No tunnel established.')
	}
    
	
	# Refresh VPN tunnel.
	elseif ($Restart) {
        
        Write-Host '[+] Restarting VPN tunnel...' -ForegroundColor Yellow
        Write-Host ' o  ' -NoNewline -ForegroundColor Yellow

		wireguard /uninstalltunnelservice $Tunnel 2>$NULL
        Start-Sleep -Seconds 3
		wireguard /installtunnelservice $TunnelConf 2>$NULL
		
		return (Write-Host 'Tunnel reset.')
	}


    # Return current VPN status
    elseif ($Status) {
	    Write-Host '[+] VPN Status: ' -ForegroundColor Yellow
	    if ($TunnelStatus) { Write-Host ' o  ' -NoNewline -ForegroundColor Yellow; Write-Host 'Enabled' }
	    else               { Write-Host ' -  ' -NoNewline -ForegroundColor Red; Write-Host 'Disabled'   }
	    return
    }
}