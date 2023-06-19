function Bypass-ExecPolicy {
#.SYNOPSIS
# Educational file displaying how to simply bypass execution policies.
# ARBITRARY VERSION NUMBER:  1.1.1
# AUTHOR:  Tyler McCann (@tylerdotrar)
#
#.DESCRIPTION
# Super simple script that is more educational than useful.  It simply shows
# how easy it is to bypass execution policies in PowerShell (e.g., Restricted).
#
# Technically this script won't execute with a Restricted Execution Policy,
# however the one liner syntax will.
#
# Usage:
# [+] Pipe this function into 'iex':  Bypass-ExecPolicy My-Script.ps1 | iex
# [+] Or use the one-liner:  iex ([string](Get-Content My-Script.ps1 | % { "$_`n" }))
#
# Parameters:
#    -File        -->    Target file to execute.
#    -Help        -->    Return Get-Help information.
#
#.LINK
# https://github.com/tylerdotrar/Tiny-Tools


    Param (
        [string] $File,
        [switch] $Help
    )


    # Return Get-Help Information
    if ($Help) { return (Get-Help Bypass-ExecPolicy) }


    # Error Correction
    if (!$File) { return (Write-Host 'Input target file.' -ForegroundColor Red) }


    # One-Liner Syntax: 
    # REPLACE 'return' WITH 'iex'

    return ([string](Get-Content $File | % { "$_`n" }))
}