function Find-File {
#.SYNOPSIS
# Recursively parse for and through files.
# ARBITRARY VERSION NUMBER:  1.1.1
# AUTHOR:  Tyler McCann (@tylerdotrar)
#
#.DESCRIPTION
# Simple tool to recursively search for files (including hidden files) -- either via a
# string within the full file path or with a file extension.
#
# On top of searching for files, you can search through files looking for matches on a
# specified string -- the output will display the file, matched line, and line number.
#
# If a directory isn't specified, the tool will default to the current directory.
#
# Parameters:
#    -Pattern       -->   Base pattern to search for.
#    -Directory     -->   (Default: PWD) Directory to recursively search through.
#    -Extension     -->   (Optional) File extension to search for.
#    -Containing    -->   (Optional) File contents to search for.
#    -Help          -->   Return Get-Help information.
#
#.LINK
# https://github.com/tylerdotrar/Tiny-Tools
    

    Param(
        [string]$Pattern,
        [string]$Directory,
        [string]$Extension,
        [string]$Containing,
        [switch]$Help
    )
    

    # Return Help Information
    if ($Help) { return (Get-Help Find-File) }


    # Error correction
    if (!$Pattern) {
        if (!$Extension) { return (Write-Host 'Search pattern or extension not specified' -ForegroundColor Red) }
        else { $Pattern = $Extension }
    }


    # Set Directory is not Specified
	if (!$Directory) { $Directory = $PWD }
    

    # Grab all files (including hidden files) and sort
    $Everything = (Get-ChildItem -Path $Directory -Recurse).FullName 2>$NULL
    $Everything += (Get-ChildItem -Path $Directory -Recurse -Hidden).FullName 2>$NULL
	$Everything = $Everything | Sort-Object -Descending
    

    # Return matches on file contents
    if ($Containing) { return ($Everything | Select-String -SimpleMatch $Pattern | % { Get-ChildItem $_ -Include "*$Extension" | Select-String -Pattern $Containing -List | Select-Object LineNumber,Line,Path | Format-List }) }
    
    # Return matches on file names
    else { return ($Everything | Select-String -SimpleMatch $Pattern | % { (Get-ChildItem $_ -Include "*$Extension").FullName } | Select-String -SimpleMatch $Pattern) }
}