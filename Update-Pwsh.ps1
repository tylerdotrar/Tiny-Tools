function Update-Pwsh {
#.SYNOPSIS
# Automatically update PowerShell Core to the latest version on Windows.
# ARBITRARY VERSION NUMBER:  1.1.1
# AUTHOR:  Tyler McCann (@tylerdotrar)
#
#.DESCRIPTION
# Dynamically determine the latest release of PowerShell Core, compare it
# to the current version, and prompt user to automatically download & 
# install said release.
#
#.LINK
# https://github.com/tylerdotrar/Tiny-Tools


    # Determine most recent Windows x64 version of PowerShell
    $Github  = "https://github.com/PowerShell/PowerShell/releases"
    $Pwsh    = Invoke-WebRequest -Method GET -Uri $Github/latest -UseBasicParsing
    $Links   = ($Pwsh.links | ? { $_ -like "*download*" }).href | ? { $_ -like "*/tree/v*" }
    $Version = ($Links[0]).Split('/v')[-1]


    # Check current Pwsh version.
    $CurrentVersion = $PSVersionTable.PSVersion.ToString()
    if (($PSEdition -eq 'Core') -and ($CurrentVersion -eq $Version)) {
        Write-Host "Current PowerShell Core version (" -NoNewline
        Write-Host "v$Version" -NoNewline -ForegroundColor Green
        Write-Host ") is up-to-date." -NoNewline
        return
    }


    # Prompt before continuing
    Write-Host "This function will kill all PowerShell Core windows and install the latest version (" -NoNewline
    Write-Host "v$Version" -NoNewline -ForegroundColor Green ; Write-Host ")."
    Write-Host "Continue? [yes/no]: " -ForegroundColor Yellow -NoNewline
    $Reply = Read-Host

    $Continue = @('yes','y','si')
    if ($Continue -notcontains $Reply ) { return }


    # Download most recent version
    $Download = "$Github/download/v$Version/PowerShell-$Version-win-x64.msi"
    $OutFile  = "$env:TEMP\PowerShell-$Version-win-x64.msi"
    Invoke-WebRequest -Method GET -Uri $Download -OutFile $OutFile -UseBasicParsing


    # Launch classic PowerShell to install and cleanup.
    Start-Process -FilePath powershell -ArgumentList "-NoProfile -Command &{msiexec.exe /i '$OutFile' /passive}"


    # Kill running Pwsh instances for installation to succeed.
    Start-Sleep -Seconds 3
    Get-Process -Name pwsh 2>$NULL | % { $_ | Stop-Process }
}