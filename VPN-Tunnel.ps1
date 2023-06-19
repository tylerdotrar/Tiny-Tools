function VPN-Tunnel  {
#.SYNOPSIS
# Easily toggle WireGuard VPN tunnels.
# ARBITRARY VERSION NUMBER:  1.1.1
# AUTHOR:  Tyler McCann (@tylerdotrar)
#
#.DESCRIPTION
# Quickly and easily toggle WireGuard VPN tunnels via configuration file names.
#
# Parameters:
#    -Enable        -->    Activate WireGuard interface
#    -Disable       -->    Deactivate WireGuard interface
#    -Restart       -->    Refresh Wireguard interface
#    -Tunnel        -->    Specify tunnel (.conf.dpapi)
#    -Status        -->    Check current status of tunnel
#    -Help          -->    Return Get-Help Information
#
#.LINK
# https://github.com/tylerdotrar/Tiny-Tools

    Param(
		[string]$Tunnel = 'PEN15_VPN',
        [switch]$Enable,
        [switch]$Disable,
		[switch]$Restart,
        [switch]$Status,
		[switch]$Help
    )
	
	
	# Return Get-Help Information
	if ($Help) { return Get-Help VPN-Tunnel }
	

    # Get tunnel config path & determine if a tunnel aready exists
	$TunnelConf = "$env:ProgramFiles\Wireguard\Data\Configurations\$Tunnel" + ".conf.dpapi"
    if (Get-Service -Name "WireGuard*$Tunnel*") { $TunnelStatus = $TRUE }
    else { $TunnelStatus = $FALSE }


    # Enable VPN tunnel if it does not already exist
	if ($Enable) {
        if ($TunnelStatus) { return (Write-Host 'VPN tunnel already established.' -ForegroundColor Red) }

        wireguard /installtunnelservice $TunnelConf
		return (Write-Host 'VPN tunnel established.' -ForegroundColor Green)
	}
    

    # Disable VPN tunnel if it exists
	elseif ($Disable) {
        if ($TunnelStatus) {
            wireguard /uninstalltunnelservice $Tunnel
		    return (Write-Host 'VPN tunnel deactivated.' -ForegroundColor Green)
        }

        return (Write-Host 'No VPN tunnel established.' -ForegroundColor Red)
	}
    
	
	# Refresh VPN tunnel.
	elseif ($Restart) {
		wireguard /uninstalltunnelservice $Tunnel 2>$NULL
        Start-Sleep -Seconds 3
		wireguard /installtunnelservice $TunnelConf 2>$NULL
		
		return (Write-Host 'VPN tunnel restarted.' -ForegroundColor Green)
	}

    # Return current VPN status
	Write-Host 'STATUS: ' -ForegroundColor Yellow -NoNewline
	if ($TunnelStatus) { Write-Host 'Enabled' -ForegroundColor Green }
	else               { Write-Host 'Disabled' -ForegroundColor Red  }
	return
}