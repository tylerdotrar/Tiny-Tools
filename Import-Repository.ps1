function Import-Repository {
#.SYNOPSIS
# List and load available PowerShell-based repositories into the current session.
# ARBITRARY VERSION NUMBER:  1.0.0
# AUTHOR:  Tyler McCann (@tylerdotrar)
#
#.DESCRIPTION
# A very hacky script made to automate the process of listing and importing scripts
# into the current session from repositories located in a specified parent directory.
# Only PowerShell scripts that contain 'function' in the first line are imported.
#
# How it works:
#   1. User inputs desired repository to import.
#   2. Script finds matching repository name in the parent repository/directory.
#   3. Script searches repository recursively for any '.ps1' files.
#   4. Script attempts to load each script into the global scope.
#     a. Check if the script's first line contains 'function'
#     b. Make function name global.
#     c. Create a temporary modified script in the $Temp directory.
#     d. Load modified global script into session.
#     e. Remove modified script.
# 
# Parameters:
#   -Repository  -->  Target repository to load into session
#   -List        -->  Return list of available repositories
#   -Silent      -->  Do not return text output
#   -ParentRepo  -->  Directory containing available repositories
#   -Help        -->  Return Get-Help information
#
#.LINK
# https://github.com/tylerdotrar/Tiny-Tools

    [Alias('import')]

    Param (
        [string]$Repo,
        [switch]$List,
        [switch]$Silent,
        [string]$ParentRepo = "V:/Code/Repos",
        [switch]$Help
    )


    # Return Get-Help Information
    if ($Help) { return (Get-Help Import-Repo) }


    # Error Correction
    if (!$List -and !$Repo) { return (Write-Host 'No parameter specified.' -ForegroundColor Red) }
    if (!(Test-Path -LiteralPath $ParentRepo)) { return (Write-Host 'Parent directory does not exit.' -ForegroundColor Red) }


    # Create List of Repositories in Parent Directory
    $RepoList = (Get-ChildItem $ParentRepo).FullName
    $AvailableRepos = @()

    foreach ($Suspect in $RepoList) {
        
        # Skip directories starting with '.'
        if ($Suspect.Split('\')[-1] -like ".*") { continue }

        # Determine if Repo Contains PowerShell Scripts
        $PSscripts = (Get-ChildItem $Suspect -Recurse -Filter "*.ps1").FullName

        if ($PSscripts) {
            $RepoName = (Get-Item $Suspect).Name
            $RepoDetails = [pscustomobject]@{ Repository = "$RepoName"; Path = "$Suspect"}
            $AvailableRepos += $RepoDetails
        }
    }


    # List Available Repositories
    if ($List) { return $AvailableRepos }


    # Import Repository into the Session
    if ($Repo) {
        
        # Valid Repository
        if ($AvailableRepos.Repository -contains $Repo) {
            
            # Load Every .ps1 into Session
            $ImportedList = @()
            $SkippedList  = @()
            $TargetPath = ($AvailableRepos | ? { $_.Repository -contains $Repo }).Path
            foreach ($PSscript in (Get-ChildItem $TargetPath -Recurse -Filter "*.ps1").fullname) {
                
                # Super Fucky Scope Bypass lol
                $Basename       = (Get-Item $PSscript).Name
                $TempPath       = "$env:TEMP/$BaseName"
                $ScriptContents = Get-Content $PSscript

                # Skip because script does not start with a function
                if ($ScriptContents[0] -notlike 'function*') {
                    $SkippedList += $Basename
                    continue
                }

                $FirstLine      = $ScriptContents[0]
                $GlobalLine     = ($FirstLine).Replace('function ','function GLOBAL:')

                # Load Modified Contents into Session and Cleanup (IEX is very inconsistent with complex scripts)
                $ScriptContents.Replace($FirstLine,$GlobalLine) > $TempPath
                . $TempPath
                Remove-Item $TempPath -Force

                # Added for output verbosity
                $ImportedList += $Basename
            }

            if (!$Silent) {
	    	    Write-Host '[+] Successfully Imported: ' -NoNewLine -ForegroundColor Yellow
	    	    Write-Host "'$($Repo.ToUpper())'"
                $ImportedList | % { Write-Host " o  " -NoNewline -ForegroundColor Yellow; $_ }
                $SkippedList | % { Write-Host " -  " -NoNewline -ForegroundColor Red; $_ }
            }
        }


        # Invalid Repository
		else {
            if (!$Silent) {
	            Write-Host '[-] Unsuccessfully Imported: ' -NoNewLine -ForegroundColor Yellow
	            Write-Host "'$($Repo.ToUpper())'"
            }
		}
    }
}